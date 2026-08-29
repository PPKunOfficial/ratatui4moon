/// Cassowary 一次性求解子集（上游 crate `cassowary`/kasuari 的
/// `solver_impl.rs` 移植，ADR-1/ADR-3）喵。
///
/// 仅保留布局所需切面：`Solver::new()` → `add_constraint` × N →
/// `fetch_changes()` 一次；剔除 edit variable、suggest、增量删除与
/// dual optimize 机械。决定点（entering/leaving/subject）一律按
/// 符号 id 升序遍历，行为确定可复现（上游 HashMap 序不确定，但
/// 布局系统最优解唯一，输出一致）喵。

///|
/// 求解变量（上游 `Variable`）：全局递增 id 标识喵。
pub(all) struct Variable {
  id : Int
} derive(Eq, Hash, Debug)

///|
let variable_id_counter : Ref[Int] = { val: 0 }

///|
/// 产出新变量（上游 `Variable::new`）喵。
pub fn Variable::fresh() -> Variable {
  let v : Variable = { id: variable_id_counter.val }
  variable_id_counter.val += 1
  v
}

///|
/// 项：变量 × 系数（上游 `Term`）喵。
pub(all) struct Term {
  variable : Variable
  coefficient : Float
} derive(Eq, Debug)

///|
/// 线性表达式：Σ 系数×变量 + 常数（上游 `Expression`）喵。
pub(all) struct Expression {
  terms : Array[Term]
  constant : Float
} derive(Eq, Debug)

///|
/// 常数表达式（上游 `Expression::from_constant`）喵。
pub fn Expression::of_constant(v : Float) -> Expression {
  { terms: [], constant: v }
}

///|
/// 单项表达式（上游 `Expression::from_term`）喵。
pub fn Expression::of_term(term : Term) -> Expression {
  { terms: [term], constant: 0.0 }
}

///|
/// 单变量表达式 x（上游 `From<Variable>`）喵。
pub fn Expression::of_variable(v : Variable) -> Expression {
  Expression::of_term({ variable: v, coefficient: 1.0 })
}

///|
/// 表达式加法：a + b 喵。
pub fn expr_add(a : Expression, b : Expression) -> Expression {
  let terms : Array[Term] = []
  for t in a.terms {
    terms.push(t)
  }
  for t in b.terms {
    terms.push(t)
  }
  { terms, constant: a.constant + b.constant }
}

///|
/// 表达式减法：a − b 喵。
pub fn expr_sub(a : Expression, b : Expression) -> Expression {
  let terms : Array[Term] = []
  for t in a.terms {
    terms.push(t)
  }
  for t in b.terms {
    terms.push({ ..t, coefficient: -t.coefficient })
  }
  { terms, constant: a.constant - b.constant }
}

///|
/// 表达式与常数求和：a + c 喵。
pub fn expr_add_const(a : Expression, c : Float) -> Expression {
  { ..a, constant: a.constant + c }
}

///|
/// 表达式数乘：a × k 喵。
pub fn expr_scale(a : Expression, k : Float) -> Expression {
  {
    terms: a.terms.map(fn(t) { { ..t, coefficient: t.coefficient * k } }),
    constant: a.constant * k,
  }
}

///|
/// 整体取负（上游 `Expression::negate`）喵。
pub fn Expression::negate(self : Expression) -> Expression {
  {
    terms: self.terms.map(fn(t) { { ..t, coefficient: -t.coefficient } }),
    constant: -self.constant,
  }
}

///|
/// 关系算子（上游 `RelationalOperator`）喵。
pub(all) enum RelOp {
  LessOrEqual
  Equal
  GreaterOrEqual
} derive(Eq, Debug)

///|
/// 约束：`表达式 op 0` + 强度（上游 `Constraint`）喵。
pub(all) struct Constraint {
  expression : Expression
  strength : Float
  op : RelOp
} derive(Eq, Debug)

///|
/// 以表达式、算子与强度构造约束（上游 `Constraint::new`）喵。
pub fn Constraint::new(
  expression : Expression,
  op : RelOp,
  strength : Float,
) -> Constraint {
  { expression, op, strength }
}

///|
/// 强度常量与工具（上游 `strength` 模块）喵。
pub fn strength_required() -> Float {
  1001001000.0
}

///|
pub fn strength_strong() -> Float {
  1000000.0
}

///|
pub fn strength_medium() -> Float {
  1000.0
}

///|
pub fn strength_weak() -> Float {
  1.0
}

///|
/// 以 STRONG/MEDIUM/WEAK 三层组合构造强度（上游 `strength::create`）喵。
pub fn strength_create(a : Float, b : Float, c : Float, w : Float) -> Float {
  let strong_part = (a * w).max(0.0).min(1000.0) * 1000000.0
  let medium_part = (b * w).max(0.0).min(1000.0) * 1000.0
  let weak_part = (c * w).max(0.0).min(1000.0)
  strong_part + medium_part + weak_part
}

///|
/// 强度夹取到合法区间（上游 `strength::clip`）喵。
pub fn strength_clip(s : Float) -> Float {
  let hi = s.min(strength_required())
  if hi < 0.0 {
    0.0
  } else {
    hi
  }
}

///|
/// 符号类别（上游 `SymbolType`）喵。
pub(all) enum SymbolType {
  Invalid
  External
  Slack
  Error
  Dummy
} derive(Eq, Hash)

///|
/// 单纯形符号（上游 `Symbol`）：id 单调递增喵。
pub struct Symbol {
  id : Int
  typ : SymbolType
} derive(Eq, Hash)

///|
pub let symbol_invalid : Symbol = { id: 0, typ: Invalid }

///|
/// 近零判定（上游 `near_zero`，ε = 1e-8）喵。
let near_zero_eps : Float = 0.00000001

///|
fn near_zero(value : Float) -> Bool {
  if value < 0.0 {
    -value < near_zero_eps
  } else {
    value < near_zero_eps
  }
}

///|
/// 单纯形表行：Σ 系数×符号 + 常数（上游 `Row`）喵。
pub struct Row {
  cells : Map[Symbol, Float]
  mut constant : Float
}

///|
fn Row::make(constant : Float) -> Row {
  { cells: Map([]), constant }
}

///|
/// 按 id 升序的单元格快照（决定性遍历基）喵。
fn Row::sorted_cells(self : Row) -> Array[(Symbol, Float)] {
  let out : Array[(Symbol, Float)] = []
  for k, v in self.cells {
    out.push((k, v))
  }
  out.sort_by(fn(a, b) { a.0.id - b.0.id })
  out
}

///|
/// 写入符号系数：合并同类项，归零即删（上游 `insert_symbol`）喵。
fn Row::insert_symbol(self : Row, s : Symbol, coefficient : Float) -> Unit {
  match self.cells.get(s) {
    Some(existing) => {
      let merged = existing + coefficient
      if near_zero(merged) {
        self.cells.remove(s)
      } else {
        self.cells.set(s, merged)
      }
    }
    None => if !near_zero(coefficient) { self.cells.set(s, coefficient) }
  }
}

///|
/// 以系数并入另一行（上游 `insert_row`）；返回常数是否变化喵。
fn Row::insert_row(self : Row, other : Row, coefficient : Float) -> Bool {
  let constant_diff = other.constant * coefficient
  self.constant += constant_diff
  for pair in other.sorted_cells() {
    self.insert_symbol(pair.0, pair.1 * coefficient)
  }
  constant_diff != 0.0
}

///|
/// 移除符号（上游 `Row::remove`）喵。
fn Row::drop_symbol(self : Row, s : Symbol) -> Unit {
  self.cells.remove(s)
}

///|
/// 整行取负（上游 `reverse_sign`）喵。
fn Row::reverse_sign(self : Row) -> Unit {
  self.constant = -self.constant
  let keys : Array[Symbol] = []
  for k, _ in self.cells {
    keys.push(k)
  }
  for k in keys {
    match self.cells.get(k) {
      Some(v) => self.cells.set(k, -v)
      None => ()
    }
  }
}

///|
/// 解出符号并主元化（上游 `solve_for_symbol`；符号不在行内属
/// 程序员错误，`guard!` 断言）喵。
fn Row::solve_for_symbol(self : Row, s : Symbol) -> Unit {
  let coeff = match self.cells.get(s) {
    Some(c) => {
      self.cells.remove(s)
      (-1.0 : Float) / c
    }
    None => 0.0
  }
  guard! coeff != 0.0
  self.constant *= coeff
  let keys : Array[Symbol] = []
  for k, _ in self.cells {
    keys.push(k)
  }
  for k in keys {
    match self.cells.get(k) {
      Some(v) => self.cells.set(k, v * coeff)
      None => ()
    }
  }
}

///|
/// 双符号主元化（上游 `solve_for_symbols`）喵。
fn Row::solve_for_symbols(self : Row, lhs : Symbol, rhs : Symbol) -> Unit {
  self.insert_symbol(lhs, -1.0)
  self.solve_for_symbol(rhs)
}

///|
/// 读符号系数（上游 `coefficient_for`）喵。
fn Row::coefficient_for(self : Row, s : Symbol) -> Float {
  match self.cells.get(s) {
    Some(v) => v
    None => 0.0
  }
}

///|
/// 以给定行替换符号（上游 `substitute`）；返回常数是否变化喵。
fn Row::substitute(self : Row, s : Symbol, row : Row) -> Bool {
  match self.cells.get(s) {
    Some(coeff) => {
      self.cells.remove(s)
      self.insert_row(row, coeff)
    }
    None => false
  }
}

///|
/// 克隆行（上游 `row.clone()`）喵。
fn Row::clone_row(self : Row) -> Row {
  let copy = Row::make(self.constant)
  for k, v in self.cells {
    copy.cells.set(k, v)
  }
  copy
}

///|
/// 加约束错误（上游 `AddConstraintError`）喵。
pub(all) suberror AddConstraintError {
  UnsatisfiableConstraint
  InternalSolverError(String)
} derive(Eq, Debug)

///|
/// 行是否全由 dummy 符号构成（上游 `all_dummies`）喵。
fn all_dummies(row : Row) -> Bool {
  for pair in row.sorted_cells() {
    if !(pair.0.typ is Dummy) {
      return false
    }
  }
  true
}

///|
/// 主元标记（上游 `Tag`）喵。
pub struct Tag {
  marker : Symbol
  other : Symbol
}

///|
/// Cassowary 求解器（一次性子集，上游 `Solver`）喵。
pub struct Solver {
  var_data : Map[Variable, (Float, Symbol, Int)]
  var_for_symbol : Map[Symbol, Variable]
  changed : Map[Variable, Bool]
  mut should_clear_changes : Bool
  rows : Map[Symbol, Row]
  infeasible_rows : Array[Symbol]
  objective : Row
  mut artificial : Row?
  mut id_tick : Int
}

///|
/// 新建求解器（上游 `Solver::new`）喵。
pub fn Solver::make() -> Solver {
  {
    var_data: Map([]),
    var_for_symbol: Map([]),
    changed: Map([]),
    should_clear_changes: false,
    rows: Map([]),
    infeasible_rows: [],
    objective: Row::make(0.0),
    artificial: None,
    id_tick: 1,
  }
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
/// 加单条约束（上游 `add_constraint` 主路径：choose subject →
/// artificial 回退 → optimize）喵。
pub fn Solver::add_constraint(
  self : Solver,
  constraint : Constraint,
) -> Unit raise AddConstraintError {
  let (row, tag) = self.create_row(constraint)
  let mut subject = choose_subject(row, tag)
  // 全 dummy 行：常数为零即冗余约束（dummy marker 入基），非零即不可满足喵。
  if subject.typ is Invalid && all_dummies(row) {
    if !near_zero(row.constant) {
      raise UnsatisfiableConstraint
    } else {
      subject = tag.marker
    }
  }
  if subject.typ is Invalid {
    if !self.add_with_artificial_variable(row) {
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
  // 逐条 optimize：系统更小、状态一致（上游一致）喵。
  self.optimise(self.objective)
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
      self.var_data.set(v, (@float.not_a_number, s, 1))
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
      let coeff : Float = if constraint.op is LessOrEqual { 1.0 } else { -1.0 }
      let slack : Symbol = { id: self.id_tick, typ: Slack }
      self.id_tick += 1
      row.insert_symbol(slack, coeff)
      if constraint.strength < strength_required() {
        let error : Symbol = { id: self.id_tick, typ: Error }
        self.id_tick += 1
        row.insert_symbol(error, -coeff)
        self.objective.insert_symbol(error, constraint.strength)
        { marker: slack, other: error }
      } else {
        { marker: slack, other: symbol_invalid }
      }
    }
    Equal =>
      if constraint.strength < strength_required() {
        let errplus : Symbol = { id: self.id_tick, typ: Error }
        self.id_tick += 1
        let errminus : Symbol = { id: self.id_tick, typ: Error }
        self.id_tick += 1
        row.insert_symbol(errplus, -1.0)
        row.insert_symbol(errminus, 1.0)
        self.objective.insert_symbol(errplus, constraint.strength)
        self.objective.insert_symbol(errminus, constraint.strength)
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
/// 选主元目标（上游 `choose_subject`：首个 external，其次负系数
/// slack/error 标记）喵。
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
/// 以人工变量入表（上游 `add_with_artificial_variable`）；返回约束
/// 是否可满足喵。
fn Solver::add_with_artificial_variable(
  self : Solver,
  row : Row,
) -> Bool raise AddConstraintError {
  let art : Symbol = { id: self.id_tick, typ: Slack }
  self.id_tick += 1
  self.rows.set(art, row.clone_row())
  let artificial_row = row.clone_row()
  self.artificial = Some(artificial_row)
  self.optimise(artificial_row)
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
  for k, _ in self.rows {
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
  for k, _ in self.rows {
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
  objective : Row,
) -> Unit raise AddConstraintError {
  while true {
    let entering = get_entering_symbol(objective)
    if entering.typ is Invalid {
      return
    }
    let found = self.get_leaving_row(entering)
    let (leaving, row) = match found {
      Some(pair) => pair
      None => raise InternalSolverError("The objective is unbounded")
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
/// 目标行中首个非 dummy 且系数为负的符号（上游
/// `get_entering_symbol`）喵。
fn get_entering_symbol(objective : Row) -> Symbol {
  for pair in objective.sorted_cells() {
    if !(pair.0.typ is Dummy) && pair.1 < 0.0 {
      return pair.0
    }
  }
  symbol_invalid
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
  let mut ratio : Float = @float.infinity
  let mut found : Symbol? = None
  let keys : Array[Symbol] = []
  for k, _ in self.rows {
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
pub fn Solver::fetch_changes(self : Solver) -> Array[(Variable, Float)] {
  if self.should_clear_changes {
    self.changed.clear()
    self.should_clear_changes = false
  } else {
    self.should_clear_changes = true
  }
  let out : Array[(Variable, Float)] = []
  let changed_ids : Array[Variable] = []
  for k, _ in self.changed {
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
/// 直读变量当前值（上游 `get_value`，测试/调试用）喵。
pub fn Solver::get_value(self : Solver, v : Variable) -> Float {
  match self.var_data.get(v) {
    Some(data) =>
      match self.rows.get(data.1) {
        Some(r) => r.constant
        None => 0.0
      }
    None => 0.0
  }
}
