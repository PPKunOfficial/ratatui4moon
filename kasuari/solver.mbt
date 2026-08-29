///|
/// Cassowary 完整求解器（上游 `solver.rs` 825 行完整移植）喵。
///
/// 保留增量编辑、约束增删、dual simplex 等全部特性；决定点（entering/leaving）
/// 一律按符号 id 升序遍历，行为确定可复现（上游 HashMap 序不确定，
/// 但布局最优解唯一，输出一致）喵。

///|
/// 内部求解器错误（上游 `InternalSolverError`）喵。
pub(all) suberror InternalSolverError {
  ObjectiveUnbounded
  DualOptimizeFailed
  FailedToFindLeavingRow
  EditConstraintNotInSystem
} derive(Eq, Debug)

///|
/// 加约束错误（上游 `AddConstraintError`）喵。
pub(all) suberror AddConstraintError {
  DuplicateConstraint
  UnsatisfiableConstraint
  InternalSolverError(String)
} derive(Eq, Debug)

///|
/// 删约束错误（上游 `RemoveConstraintError`）喵。
pub(all) suberror RemoveConstraintError {
  UnknownConstraint
  InternalSolverError(String)
} derive(Eq, Debug)

///|
/// 增 edit 变量错误（上游 `AddEditVariableError`）喵。
pub(all) suberror AddEditVariableError {
  DuplicateEditVariable
  BadRequiredStrength
} derive(Eq, Debug)

///|
/// 删 edit 变量错误（上游 `RemoveEditVariableError`）喵。
pub(all) suberror RemoveEditVariableError {
  UnknownEditVariable
  InternalSolverError(String)
} derive(Eq, Debug)

///|
/// 建议值错误（上游 `SuggestValueError`）喵。
pub(all) suberror SuggestValueError {
  UnknownEditVariable
  InternalSolverError(String)
} derive(Eq, Debug)

///|
/// 主元标记（上游 `Tag`）喵。
pub(all) struct Tag {
  marker : Symbol
  other : Symbol
} derive(Eq, Debug)

///|
priv enum OptimizeTarget {
  Objective
  Artificial
} derive(Eq, Debug)

///|
pub(all) struct EditInfo {
  tag : Tag
  constraint : Constraint
  mut constant : Double
}

///|
/// Cassowary 求解器（上游 `Solver`，完整版）喵。
pub struct Solver {
  constraints : Map[Int, Tag]
  constraint_store : Map[Int, Constraint]
  var_data : Map[Variable, (Double, Symbol, Int)]
  var_for_symbol : Map[Symbol, Variable]
  changed : Map[Variable, Bool]
  mut should_clear_changes : Bool
  rows : Map[Symbol, Row]
  edits : Map[Variable, EditInfo]
  infeasible_rows : Array[Symbol]
  mut objective : Row
  mut artificial : Row?
  mut id_tick : Int
}

///|
/// 新建求解器（上游 `Solver::new`）喵。
pub fn Solver::new() -> Solver {
  {
    constraints: Map([]),
    constraint_store: Map([]),
    var_data: Map([]),
    var_for_symbol: Map([]),
    changed: Map([]),
    should_clear_changes: false,
    rows: Map([]),
    edits: Map([]),
    infeasible_rows: [],
    objective: Row::make(0.0),
    artificial: None,
    id_tick: 1,
  }
}

///|
/// 别名：`make` 同 `new`，兼容旧布局求解器调用喵。
pub fn Solver::make() -> Solver {
  Solver::new()
}

///|
/// 批量加约束（上游 `add_constraints`）喵。
pub fn Solver::add_constraints(
  self : Solver,
  constraints : Array[Constraint],
) -> Unit raise AddConstraintError {
  for constraint in constraints {
    self.add_constraint(constraint)
  }
}

///|
/// 加单条约束（上游 `add_constraint`：判重 → 建行 → 选 subject → 人工变量回退 → optimize）喵。
pub fn Solver::add_constraint(
  self : Solver,
  constraint : Constraint,
) -> Unit raise AddConstraintError {
  if self.constraints.get(constraint.id) is Some(_) {
    raise DuplicateConstraint
  }
  let (row, tag) = self.create_row(constraint)
  let mut subject = choose_subject(row, tag)
  // 全 dummy 行：常数为零即冗余约束（dummy marker 入基），非零即不可满足喵。
  if subject.typ is Invalid && row_all_dummies(row) {
    if !near_zero(row.constant) {
      raise UnsatisfiableConstraint
    } else {
      subject = tag.marker
    }
  }
  if subject.typ is Invalid {
    let sat = self.add_with_artificial_variable(row) catch {
      _ => raise InternalSolverError("internal")
    }
    if !sat {
      raise UnsatisfiableConstraint
    }
  } else {
    row.solve_for_symbol(subject)
    self.substitute(subject, row)
    if subject.typ is External && row.constant != 0.0 {
      match self.var_for_symbol.get(subject) {
        Some(v) => self.mark_changed(v)
        None => ()
      }
    }
    self.rows.set(subject, row)
  }
  self.constraints.set(constraint.id, tag)
  self.constraint_store.set(constraint.id, constraint)
  // 逐条 optimize：系统更小、状态一致（上游一致）喵。
  self.optimise(OptimizeTarget::Objective) catch {
    _ => raise InternalSolverError("internal")
  }
}

///|
/// 删约束（上游 `remove_constraint`）喵。
pub fn Solver::remove_constraint(
  self : Solver,
  constraint : Constraint,
) -> Unit raise RemoveConstraintError {
  let tag = match self.constraints.get(constraint.id) {
    Some(t) => t
    None => raise UnknownConstraint
  }
  self.constraints.remove(constraint.id)
  self.constraint_store.remove(constraint.id)
  // 先从目标函数移除 error 影响，再转轴喵。
  self.remove_constraint_effects(constraint, tag)
  // 若 marker 在基中直接丢行；否则转轴后再丢喵。
  if self.rows.get(tag.marker) is None {
    let found = self.get_marker_leaving_row(tag.marker)
    match found {
      Some(pair) => {
        let (leaving, row) = pair
        row.solve_for_symbols(leaving, tag.marker)
        self.substitute(tag.marker, row)
      }
      None => raise InternalSolverError("FailedToFindLeavingRow")
    }
  } else {
    self.rows.remove(tag.marker)
  }
  self.optimise(OptimizeTarget::Objective) catch {
    _ => raise InternalSolverError("internal")
  }
  // 引用计数递减，归零即删变量映射喵。
  for term in constraint.expression.terms {
    if !near_zero(term.coefficient) {
      let mut should_remove = false
      match self.var_data.get(term.variable) {
        Some(data) => {
          let new_count = data.2 - 1
          if new_count == 0 {
            should_remove = true
          } else {
            self.var_data.set(term.variable, (data.0, data.1, new_count))
          }
        }
        None => ()
      }
      if should_remove {
        match self.var_data.get(term.variable) {
          Some(data) => {
            self.var_for_symbol.remove(data.1)
            self.var_data.remove(term.variable)
          }
          None => ()
        }
      }
    }
  }
}

///|
/// 约束是否已在求解器中（上游 `has_constraint`）喵。
pub fn Solver::has_constraint(self : Solver, constraint : Constraint) -> Bool {
  self.constraints.get(constraint.id) is Some(_)
}

///|
/// 增 edit 变量（上游 `add_edit_variable`）喵。
pub fn Solver::add_edit_variable(
  self : Solver,
  v : Variable,
  strength : Strength,
) -> Unit raise AddEditVariableError {
  if self.edits.get(v) is Some(_) {
    raise DuplicateEditVariable
  }
  if strength == Strength::required() {
    raise BadRequiredStrength
  }
  let cn = Constraint::new(
    Expression::of_term(Term::new(v, 1.0)),
    Equal,
    strength,
  )
  // 上游 unwrap：约束必可加（强度非 REQUIRED，恒可满足）喵。
  self.add_constraint(cn) catch {
    _ => ()
  }
  let tag = match self.constraints.get(cn.id) {
    Some(t) => t
    None => { marker: symbol_invalid, other: symbol_invalid }
  }
  self.edits.set(v, { tag, constraint: cn, constant: 0.0 })
}

///|
/// 删 edit 变量（上游 `remove_edit_variable`）喵。
pub fn Solver::remove_edit_variable(
  self : Solver,
  v : Variable,
) -> Unit raise RemoveEditVariableError {
  match self.edits.get(v) {
    None => raise UnknownEditVariable
    Some(info) => {
      let cn = info.constraint
      self.edits.remove(v)
      self.remove_constraint(cn) catch {
        _ => raise InternalSolverError("EditConstraintNotInSystem")
      }
    }
  }
}

///|
/// 是否已是 edit 变量（上游 `has_edit_variable`）喵。
pub fn Solver::has_edit_variable(self : Solver, v : Variable) -> Bool {
  self.edits.get(v) is Some(_)
}

///|
/// 为 edit 变量建议值（上游 `suggest_value`，含 dual_optimize）喵。
pub fn Solver::suggest_value(
  self : Solver,
  variable : Variable,
  value : Double,
) -> Unit raise SuggestValueError {
  let info = match self.edits.get(variable) {
    None => raise UnknownEditVariable
    Some(i) => i
  }
  let delta = value - info.constant
  info.constant = value
  self.edits.set(variable, info)
  let marker = info.tag.marker
  let other = info.tag.other
  // 标记与其它符号皆非 External喵。
  let mut handled = false
  match self.rows.get(marker) {
    Some(row) => {
      let new_c = row.add(-delta)
      if new_c < 0.0 {
        self.infeasible_rows.push(marker)
      }
      handled = true
    }
    None => ()
  }
  if !handled {
    match self.rows.get(other) {
      Some(row) => {
        let new_c = row.add(delta)
        if new_c < 0.0 {
          self.infeasible_rows.push(other)
        }
        handled = true
      }
      None => ()
    }
  }
  if !handled {
    let keys : Array[Symbol] = []
    for k, _v in self.rows {
      keys.push(k)
    }
    for sym in keys {
      match self.rows.get(sym) {
        Some(row) => {
          let coeff = row.coefficient_for(marker)
          let diff = delta * coeff
          if diff != 0.0 && sym.typ is External {
            match self.var_for_symbol.get(sym) {
              Some(v) => self.mark_changed(v)
              None => ()
            }
          }
          if coeff != 0.0 {
            let new_c = row.add(diff)
            if new_c < 0.0 && !(sym.typ is External) {
              self.infeasible_rows.push(sym)
            }
          }
        }
        None => ()
      }
    }
  }
  self.dual_optimize() catch {
    _ => raise InternalSolverError("internal")
  }
}

///|
/// 标记变量值已变化（上游 `var_changed`）喵。
fn Solver::mark_changed(self : Solver, v : Variable) -> Unit {
  if self.should_clear_changes {
    self.changed.clear()
    self.should_clear_changes = false
  }
  self.changed.set(v, true)
}

///|
/// 拉取自上次调用以来的全部变量值变化（上游 `fetch_changes`）喵。
pub fn Solver::fetch_changes(self : Solver) -> Array[(Variable, Double)] {
  if self.should_clear_changes {
    self.changed.clear()
    self.should_clear_changes = false
  } else {
    self.should_clear_changes = true
  }
  let out : Array[(Variable, Double)] = []
  let changed_ids : Array[Variable] = []
  for k, _v in self.changed {
    changed_ids.push(k)
  }
  changed_ids.sort_by(fn(a, b) { a.id - b.id })
  for v in changed_ids {
    match self.var_data.get(v) {
      Some(data) => {
        let new_value = match self.rows.get(data.1) {
          Some(r) => r.constant
          None => 0.0
        }
        let old_value = data.0
        if old_value != new_value {
          out.push((v, new_value))
          self.var_data.set(v, (new_value, data.1, data.2))
        }
      }
      None => ()
    }
  }
  out
}

///|
/// 重置求解器到空初始态（上游 `reset`）喵。
pub fn Solver::reset(self : Solver) -> Unit {
  self.rows.clear()
  self.constraints.clear()
  self.constraint_store.clear()
  self.var_data.clear()
  self.var_for_symbol.clear()
  self.changed.clear()
  self.should_clear_changes = false
  self.edits.clear()
  self.infeasible_rows.clear()
  self.objective = Row::make(0.0)
  self.artificial = None
  self.id_tick = 1
}

///|
/// 直读变量当前值（上游 `get_value`，测试/调试用）喵。
pub fn Solver::get_value(self : Solver, v : Variable) -> Double {
  match self.var_data.get(v) {
    Some(data) =>
      match self.rows.get(data.1) {
        Some(r) => r.constant
        None => 0.0
      }
    None => 0.0
  }
}

///|
/// 取变量符号（无则建，引用计数 +1；上游 `get_var_symbol`）喵。
fn Solver::get_var_symbol(self : Solver, v : Variable) -> Symbol {
  match self.var_data.get(v) {
    Some(data) => {
      self.var_data.set(v, (data.0, data.1, data.2 + 1))
      data.1
    }
    None => {
      let s : Symbol = { id: self.id_tick, typ: External }
      self.id_tick += 1
      self.var_for_symbol.set(s, v)
      self.var_data.set(v, (@double.not_a_number, s, 1))
      s
    }
  }
}

///|
/// 为约束建行：变量符号 + slack/error/dummy（上游 `create_row`）喵。
fn Solver::create_row(self : Solver, constraint : Constraint) -> (Row, Tag) {
  let expr = constraint.expression
  let row = Row::make(expr.constant)
  for term in expr.terms {
    if !near_zero(term.coefficient) {
      let symbol = self.get_var_symbol(term.variable)
      match self.rows.get(symbol) {
        Some(other_row) => ignore(row.insert_row(other_row, term.coefficient))
        None => row.insert_symbol(symbol, term.coefficient)
      }
    }
  }
  let tag : Tag = match constraint.op {
    GreaterOrEqual | LessOrEqual => {
      let coeff : Double = if constraint.op is LessOrEqual { 1.0 } else { -1.0 }
      let slack : Symbol = { id: self.id_tick, typ: Slack }
      self.id_tick += 1
      row.insert_symbol(slack, coeff)
      if constraint.strength.val < Strength::required().val {
        let error : Symbol = { id: self.id_tick, typ: Error }
        self.id_tick += 1
        row.insert_symbol(error, -coeff)
        self.objective.insert_symbol(error, constraint.strength.val)
        { marker: slack, other: error }
      } else {
        { marker: slack, other: symbol_invalid }
      }
    }
    Equal =>
      if constraint.strength.val < Strength::required().val {
        let errplus : Symbol = { id: self.id_tick, typ: Error }
        self.id_tick += 1
        let errminus : Symbol = { id: self.id_tick, typ: Error }
        self.id_tick += 1
        row.insert_symbol(errplus, -1.0)
        row.insert_symbol(errminus, 1.0)
        self.objective.insert_symbol(errplus, constraint.strength.val)
        self.objective.insert_symbol(errminus, constraint.strength.val)
        { marker: errplus, other: errminus }
      } else {
        let dummy : Symbol = { id: self.id_tick, typ: Dummy }
        self.id_tick += 1
        row.insert_symbol(dummy, 1.0)
        { marker: dummy, other: symbol_invalid }
      }
  }
  if row.constant < 0.0 {
    row.reverse_sign()
  }
  (row, tag)
}

///|
/// 选主元目标（上游 `choose_subject`：首个 external，其次负系数 slack/error 标记）喵。
fn choose_subject(row : Row, tag : Tag) -> Symbol {
  for pair in row.sorted_cells() {
    if pair.0.typ is External {
      return pair.0
    }
  }
  if tag.marker.typ is Slack || tag.marker.typ is Error {
    if row.coefficient_for(tag.marker) < 0.0 {
      return tag.marker
    }
  }
  if tag.other.typ is Slack || tag.other.typ is Error {
    if row.coefficient_for(tag.other) < 0.0 {
      return tag.other
    }
  }
  symbol_invalid
}

///|
/// 以人工变量入表（上游 `add_with_artificial_variable`）；返回约束是否可满足喵。
fn Solver::add_with_artificial_variable(
  self : Solver,
  row : Row,
) -> Bool raise InternalSolverError {
  let art : Symbol = { id: self.id_tick, typ: Slack }
  self.id_tick += 1
  self.rows.set(art, row.clone_row())
  let artificial_row = row.clone_row()
  self.artificial = Some(artificial_row)
  self.optimise(Artificial)
  let success = near_zero(artificial_row.constant)
  self.artificial = None
  match self.rows.get(art) {
    Some(art_row) => {
      if art_row.cells.is_empty() {
        self.rows.remove(art)
        return success
      }
      let entering = any_pivotable_symbol(art_row)
      if entering.typ is Invalid {
        self.rows.remove(art)
        return false
      }
      art_row.solve_for_symbols(art, entering)
      self.substitute(entering, art_row)
      self.rows.remove(art)
      self.rows.set(entering, art_row)
    }
    None => ()
  }
  // 从所有行与目标中移除人工符号喵。
  let row_keys : Array[Symbol] = []
  for k, _v in self.rows {
    row_keys.push(k)
  }
  for k in row_keys {
    match self.rows.get(k) {
      Some(r) => r.drop_symbol(art)
      None => ()
    }
  }
  self.objective.drop_symbol(art)
  success
}

///|
/// 以给定行替换全表符号（上游 `substitute`）喵。
fn Solver::substitute(self : Solver, symbol : Symbol, row : Row) -> Unit {
  let keys : Array[Symbol] = []
  for k, _v in self.rows {
    keys.push(k)
  }
  for other_symbol in keys {
    match self.rows.get(other_symbol) {
      Some(other_row) => {
        let constant_changed = other_row.substitute(symbol, row)
        if other_symbol.typ is External && constant_changed {
          match self.var_for_symbol.get(other_symbol) {
            Some(v) => self.mark_changed(v)
            None => ()
          }
        }
        if !(other_symbol.typ is External) && other_row.constant < 0.0 {
          self.infeasible_rows.push(other_symbol)
        }
      }
      None => ()
    }
  }
  ignore(self.objective.substitute(symbol, row))
  match self.artificial {
    Some(artificial_row) => ignore(artificial_row.substitute(symbol, row))
    None => ()
  }
}

///|
/// 相位二单纯形迭代至目标最小（上游 `optimise`）喵。
fn Solver::optimise(
  self : Solver,
  target : OptimizeTarget,
) -> Unit raise InternalSolverError {
  while true {
    let entering = match target {
      Objective => get_entering_symbol(self.objective)
      Artificial =>
        match self.artificial {
          Some(r) => get_entering_symbol(r)
          None => symbol_invalid
        }
    }
    if entering.typ is Invalid {
      return
    }
    let found = self.get_leaving_row(entering)
    let (leaving, row) = match found {
      Some(pair) => pair
      None => raise ObjectiveUnbounded
    }
    row.solve_for_symbols(leaving, entering)
    self.substitute(entering, row)
    if entering.typ is External && row.constant != 0.0 {
      match self.var_for_symbol.get(entering) {
        Some(v) => self.mark_changed(v)
        None => ()
      }
    }
    self.rows.set(entering, row)
  }
}

///|
/// dual simplex：修复 infeasible 行（上游 `dual_optimize`）喵。
fn Solver::dual_optimize(self : Solver) -> Unit raise InternalSolverError {
  while true {
    let leaving = match self.infeasible_rows.pop() {
      Some(s) => s
      None => return
    }
    let maybe_row = self.rows.get(leaving)
    match maybe_row {
      None => continue
      Some(row) => {
        if row.constant >= 0.0 {
          continue
        }
        // 需移出 map 再处理，避免借用冲突喵。
        self.rows.remove(leaving)
        let entering = self.get_dual_entering_symbol(row)
        if entering.typ is Invalid {
          raise DualOptimizeFailed
        }
        row.solve_for_symbols(leaving, entering)
        self.substitute(entering, row)
        if entering.typ is External && row.constant != 0.0 {
          match self.var_for_symbol.get(entering) {
            Some(v) => self.mark_changed(v)
            None => ()
          }
        }
        self.rows.set(entering, row)
      }
    }
  }
}

///|
/// 目标行中首个非 dummy 且系数为负的符号（上游 `get_entering_symbol`）喵。
fn get_entering_symbol(objective : Row) -> Symbol {
  for pair in objective.sorted_cells() {
    if !(pair.0.typ is Dummy) && pair.1 < 0.0 {
      return pair.0
    }
  }
  symbol_invalid
}

///|
/// dual 进入符号：行中系数 >0 且 objective/系数 比值最小者（上游 `get_dual_entering_symbol`）喵。
fn Solver::get_dual_entering_symbol(self : Solver, row : Row) -> Symbol {
  let mut entering = symbol_invalid
  let mut ratio : Double = @double.infinity
  for pair in row.sorted_cells() {
    if pair.1 > 0.0 && !(pair.0.typ is Dummy) {
      let coeff = self.objective.coefficient_for(pair.0)
      let r = coeff / pair.1
      if r < ratio {
        ratio = r
        entering = pair.0
      }
    }
  }
  entering
}

///|
/// 行内首个 slack/error 符号（上游 `any_pivotable_symbol`）喵。
fn any_pivotable_symbol(row : Row) -> Symbol {
  for pair in row.sorted_cells() {
    if pair.0.typ is Slack || pair.0.typ is Error {
      return pair.0
    }
  }
  symbol_invalid
}

///|
/// 最小比率出基行（上游 `get_leaving_row`）喵。
fn Solver::get_leaving_row(self : Solver, entering : Symbol) -> (Symbol, Row)? {
  let mut ratio : Double = @double.infinity
  let mut found : Symbol? = None
  let keys : Array[Symbol] = []
  for k, _v in self.rows {
    keys.push(k)
  }
  keys.sort_by(fn(a, b) { a.id - b.id })
  for symbol in keys {
    match self.rows.get(symbol) {
      Some(row) =>
        if !(symbol.typ is External) {
          let temp = row.coefficient_for(entering)
          if temp < 0.0 {
            let temp_ratio = -row.constant / temp
            if temp_ratio < ratio {
              ratio = temp_ratio
              found = Some(symbol)
            }
          }
        }
      None => ()
    }
  }
  match found {
    Some(s) =>
      match self.rows.get(s) {
        Some(row) => {
          self.rows.remove(s)
          Some((s, row))
        }
        None => None
      }
    None => None
  }
}

///|
/// 标记变量的离基行（上游 `get_marker_leaving_row`）喵。
fn Solver::get_marker_leaving_row(
  self : Solver,
  marker : Symbol,
) -> (Symbol, Row)? {
  let mut r1 : Double = @double.infinity
  let mut r2 : Double = @double.infinity
  let mut first : Symbol? = None
  let mut second : Symbol? = None
  let mut third : Symbol? = None
  let keys : Array[Symbol] = []
  for k, _v in self.rows {
    keys.push(k)
  }
  keys.sort_by(fn(a, b) { a.id - b.id })
  for symbol in keys {
    match self.rows.get(symbol) {
      Some(row) => {
        let c = row.coefficient_for(marker)
        if c == 0.0 {
          continue
        }
        if symbol.typ is External {
          third = Some(symbol)
        } else if c < 0.0 {
          let r = -row.constant / c
          if r < r1 {
            r1 = r
            first = Some(symbol)
          }
        } else {
          let r = row.constant / c
          if r < r2 {
            r2 = r
            second = Some(symbol)
          }
        }
      }
      None => ()
    }
  }
  let chosen = match first {
    Some(s) => Some(s)
    None =>
      match second {
        Some(s) => Some(s)
        None => third
      }
  }
  match chosen {
    Some(s) => {
      // external 行若常数非零需标记变化喵。
      if s.typ is External {
        match self.rows.get(s) {
          Some(r) =>
            if r.constant != 0.0 {
              match self.var_for_symbol.get(s) {
                Some(v) => self.mark_changed(v)
                None => ()
              }
            }
          None => ()
        }
      }
      match self.rows.get(s) {
        Some(row) => {
          self.rows.remove(s)
          Some((s, row))
        }
        None => None
      }
    }
    None => None
  }
}

///|
/// 移除约束对目标函数的 error 影响（上游 `remove_constraint_effects`）喵。
fn Solver::remove_constraint_effects(
  self : Solver,
  constraint : Constraint,
  tag : Tag,
) -> Unit {
  if tag.marker.typ is Error {
    self.remove_marker_effects(tag.marker, constraint.strength.val)
  }
  if tag.other.typ is Error {
    self.remove_marker_effects(tag.other, constraint.strength.val)
  }
}

///|
/// 移除单个 error 标记对目标函数的影响（上游 `remove_marker_effects`）喵。
fn Solver::remove_marker_effects(
  self : Solver,
  marker : Symbol,
  strength : Double,
) -> Unit {
  match self.rows.get(marker) {
    Some(row) => ignore(self.objective.insert_row(row, -strength))
    None => self.objective.insert_symbol(marker, -strength)
  }
}

///|
/// 忽略值辅助（MoonBit 无 `ignore` 内建时以 let _ 丢弃）喵。
fn[T] ignore(_ : T) -> Unit {

}
