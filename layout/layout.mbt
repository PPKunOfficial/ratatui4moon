/// Layout（上游 `ratatui-core/src/layout/layout.rs`）：弹性分区与
/// spacer 段求解喵。
///
/// 求解走 cassowary 一次性子集（本包 solver.mbt）；约束体系、强度
/// 排名、Flex/Spacing 语义与 100 倍浮点精度放大均一比一复刻上游喵。

///|
/// 间距（上游 `layout::Spacing`）：正值为撑开、负值（Overlap）为压紧喵。
pub(all) enum Spacing {
  Space(Int)
  Overlap(Int)
} derive(Eq, Debug)

///|
/// 求解出的分段/间隔段（上游 `Element`）：一对起止变量喵。
priv struct Element {
  start : Variable
  end : Variable
}

///|
fn Element::make(start : Variable, end : Variable) -> Element {
  { start, end }
}

///|
/// 段尺寸表达式 `end - start`（上游 `Element::size`）喵。
fn Element::size_expr(self : Element) -> Expression {
  expr_sub(
    Expression::of_variable(self.end),
    Expression::of_variable(self.start),
  )
}

///|
/// `size <= n`（上游 `has_max_size`）喵。
fn Element::has_max_size(
  self : Element,
  size : Int,
  strength : Double,
) -> Constraint {
  Constraint::new(
    expr_sub(
      self.size_expr(),
      Expression::of_constant(float_of_int_scaled(size)),
    ),
    LessOrEqual,
    strength,
  )
}

///|
/// `size >= n`（上游 `has_min_size`）喵。
fn Element::has_min_size(
  self : Element,
  size : Int,
  strength : Double,
) -> Constraint {
  Constraint::new(
    expr_sub(
      self.size_expr(),
      Expression::of_constant(float_of_int_scaled(size)),
    ),
    GreaterOrEqual,
    strength,
  )
}

///|
/// `size == n`（上游 `has_int_size`）喵。
fn Element::has_int_size(
  self : Element,
  size : Int,
  strength : Double,
) -> Constraint {
  Constraint::new(
    expr_sub(
      self.size_expr(),
      Expression::of_constant(float_of_int_scaled(size)),
    ),
    Equal,
    strength,
  )
}

///|
/// `size == 浮点常数`（上游 `has_size(spacing_f64, …)` 的标量形态）喵。
fn Element::has_size_const(
  self : Element,
  size : Double,
  strength : Double,
) -> Constraint {
  Constraint::new(
    expr_sub(self.size_expr(), Expression::of_constant(size)),
    Equal,
    strength,
  )
}

///|
/// `size == 表达式`（上游 `has_size`）喵。
fn Element::has_size(
  self : Element,
  size : Expression,
  strength : Double,
) -> Constraint {
  Constraint::new(expr_sub(self.size_expr(), size), Equal, strength)
}

///|
/// `size == 2 × 表达式`（上游 `has_double_size`）喵。
fn Element::has_double_size(
  self : Element,
  size : Expression,
  strength : Double,
) -> Constraint {
  Constraint::new(
    expr_sub(self.size_expr(), expr_scale(size, 2.0)),
    Equal,
    strength,
  )
}

///|
/// `size == 0`（上游 `is_empty`：REQUIRED − WEAK 强度）喵。
fn Element::is_empty(self : Element) -> Constraint {
  Constraint::new(
    expr_sub(self.size_expr(), Expression::of_constant(0.0)),
    Equal,
    strength_required() - strength_weak(),
  )
}

///|
/// 布局坐标的 100 倍精度放大（上游 `FLOAT_PRECISION_MULTIPLIER`）喵。
let float_precision_multiplier : Double = 100.0

///|
fn float_of_int_scaled(n : Int) -> Double {
  Double::from_int(n) * float_precision_multiplier
}

///|
/// 上游 `strengths` 模块：Spacer 等尺寸（REQUIRED/10）喵。
fn spacer_size_eq() -> Double {
  strength_required() / 10.0
}

///|
/// Min 下界强度（STRONG×100）喵。
fn min_size_ge() -> Double {
  strength_strong() * 100.0
}

///|
/// Max 上界强度（STRONG×100）喵。
fn max_size_le() -> Double {
  strength_strong() * 100.0
}

///|
/// Length 等值强度（STRONG×10）喵。
fn length_size_eq() -> Double {
  strength_strong() * 10.0
}

///|
/// Percentage 等值强度（STRONG）喵。
fn percentage_size_eq() -> Double {
  strength_strong()
}

///|
/// Ratio 等值强度（STRONG/10）喵。
fn ratio_size_eq() -> Double {
  strength_strong() / 10.0
}

///|
/// Min/Max 等值强度（MEDIUM×10）喵。
fn min_max_size_eq() -> Double {
  strength_medium() * 10.0
}

///|
/// Fill 生长强度（MEDIUM）喵。
fn fill_grow() -> Double {
  strength_medium()
}

///|
/// Min 非遗留生长强度（MEDIUM/10）喵。
fn grow() -> Double {
  strength_medium() / 10.0
}

///|
/// Spacer 生长强度（WEAK×10）喵。
fn space_grow() -> Double {
  strength_weak() * 10.0
}

///|
/// 全段等尺寸强度（WEAK）喵。
fn all_segment_grow() -> Double {
  strength_weak()
}

///|
/// 分区配置（上游 `layout::Layout`）喵。
pub(all) struct Layout {
  direction : @core.Direction
  margin : @core.Margin
  constraints : Array[@core.Constraint]
  flex : @core.Flex
  spacing : Spacing
} derive(Eq, Debug)

///|
/// 缺省构造（上游 `Layout::default`：纵向、零边距、Legacy、零间距）喵。
pub fn Layout::default() -> Layout {
  {
    direction: @core.Vertical,
    margin: @core.Margin::new(0, 0),
    constraints: [],
    flex: @core.Flex::default(),
    spacing: Space(0),
  }
}

///|
/// 以方向与约束构造（上游 `Layout::new`）喵。
pub fn Layout::make(
  direction : @core.Direction,
  constraints : Array[@core.Constraint],
) -> Layout {
  { ..Layout::default(), direction, constraints }
}

///|
/// 纵向切分布局（上游 `Layout::vertical`）喵。
pub fn Layout::vertical(constraints : Array[@core.Constraint]) -> Layout {
  Layout::make(@core.Vertical, constraints)
}

///|
/// 横向切分布局（上游 `Layout::horizontal`）喵。
pub fn Layout::horizontal(constraints : Array[@core.Constraint]) -> Layout {
  Layout::make(@core.Horizontal, constraints)
}

///|
/// 设方向（上游 `Layout::direction`）喵。
pub fn Layout::direction(self : Layout, direction : @core.Direction) -> Layout {
  { ..self, direction, }
}

///|
/// 设边距（上游 `Layout::margin`）喵。
pub fn Layout::margin(self : Layout, margin : @core.Margin) -> Layout {
  { ..self, margin, }
}

///|
/// 设水平边距（上游 `Layout::horizontal_margin`）喵。
pub fn Layout::horizontal_margin(self : Layout, horizontal : Int) -> Layout {
  { ..self, margin: @core.Margin::new(horizontal, self.margin.vertical) }
}

///|
/// 设垂直边距（上游 `Layout::vertical_margin`）喵。
pub fn Layout::vertical_margin(self : Layout, vertical : Int) -> Layout {
  { ..self, margin: @core.Margin::new(self.margin.horizontal, vertical) }
}

///|
/// 设约束序列（上游 `Layout::constraints`）喵。
pub fn Layout::constraints(
  self : Layout,
  constraints : Array[@core.Constraint],
) -> Layout {
  { ..self, constraints, }
}

///|
/// 设 flex 对齐策略（上游 `Layout::flex`）喵。
pub fn Layout::flex(self : Layout, flex : @core.Flex) -> Layout {
  { ..self, flex, }
}

///|
/// 设间距（上游 `Layout::spacing`：负值转 Overlap）喵。
pub fn Layout::spacing(self : Layout, spacing : Int) -> Layout {
  {
    ..self,
    spacing: if spacing < 0 {
      Overlap(-spacing)
    } else {
      Space(spacing)
    },
  }
}

///|
/// 切分区域（上游 `Layout::split`）喵。
///
/// 约束体系构造上恒可满足；求解器内部错误按铁律 3 优雅退化：
/// 返回以内区起点为锚的全零尺寸段，不 panic 喵。
pub fn Layout::split(self : Layout, area : @core.Rect) -> Array[@core.Rect] {
  try {
    let (segments, _spacers) = self.split_with_spacers(area)
    segments
  } catch {
    UnsatisfiableConstraint => self.degenerate_segments(area)
    InternalSolverError(_) => self.degenerate_segments(area)
  }
}

///|
/// 切分区域并返回段与 spacer（上游 `Layout::split_with_spacers`）喵。
pub fn Layout::split_with_spacers(
  self : Layout,
  area : @core.Rect,
) -> (Array[@core.Rect], Array[@core.Rect]) raise AddConstraintError {
  let (segments, spacers, _solver) = self.try_split(area)
  (segments, spacers)
}

///|
/// 切分并返回求解器（调试/断言用）喵。
fn Layout::try_split(
  self : Layout,
  area : @core.Rect,
) -> (Array[@core.Rect], Array[@core.Rect], Solver) raise AddConstraintError {
  let solver = Solver::make()
  let inner_area = area.inner(self.margin)
  let (area_start, area_end) = match self.direction {
    @core.Horizontal =>
      (
        Double::from_int(inner_area.x) * float_precision_multiplier,
        Double::from_int(inner_area.right()) * float_precision_multiplier,
      )
    @core.Vertical =>
      (
        Double::from_int(inner_area.y) * float_precision_multiplier,
        Double::from_int(inner_area.bottom()) * float_precision_multiplier,
      )
  }
  // 变量带：n 段 → n+1 条边界；spacers 取相邻偶对、segments 取错位偶对喵。
  let variable_count = self.constraints.length() * 2 + 2
  let variables : Array[Variable] = []
  for _ in 0..<variable_count {
    variables.push(Variable::fresh())
  }
  let spacers : Array[Element] = []
  let segments : Array[Element] = []
  let spacer_count = self.constraints.length() + 1
  for i in 0..<spacer_count {
    spacers.push(Element::make(variables[i * 2], variables[i * 2 + 1]))
    if i < self.constraints.length() {
      segments.push(Element::make(variables[i * 2 + 1], variables[i * 2 + 2]))
    }
  }
  let area_size = Element::make(variables[0], variables[variable_count - 1])
  configure_area(solver, area_size, area_start, area_end)
  configure_variable_in_area_constraints(solver, variables, area_size)
  configure_variable_constraints(solver, variables)
  configure_flex_constraints(
    solver,
    area_size,
    spacers,
    self.flex,
    self.spacing,
  )
  configure_constraints(
    solver,
    area_size,
    segments,
    self.constraints,
    self.flex,
  )
  configure_fill_constraints(solver, segments, self.constraints, self.flex)
  if !(self.flex is Legacy) {
    for i in 1..<segments.length() {
      solver.add_constraint(
        segments[i - 1].has_size(segments[i].size_expr(), all_segment_grow()),
      )
    }
  }
  let changes : Map[Variable, Double] = Map([])
  for pair in solver.fetch_changes() {
    changes.set(pair.0, pair.1)
  }
  let segment_rects = changes_to_rects(
    changes,
    segments,
    inner_area,
    self.direction,
  )
  let spacer_rects = changes_to_rects(
    changes,
    spacers,
    inner_area,
    self.direction,
  )
  (segment_rects, spacer_rects, solver)
}

///|
/// 退化输出：以内区起点为锚的全零尺寸段（铁律 3 优雅退化）喵。
fn Layout::degenerate_segments(
  self : Layout,
  area : @core.Rect,
) -> Array[@core.Rect] {
  let inner_area = area.inner(self.margin)
  let count = self.constraints.length()
  let out : Array[@core.Rect] = []
  for _ in 0..<count {
    out.push(@core.Rect::new(inner_area.x, inner_area.y, 0, 0))
  }
  out
}

///|
/// 区域锚定：start/end 锚定到内区两端（上游 `configure_area`）喵。
fn configure_area(
  solver : Solver,
  area : Element,
  area_start : Double,
  area_end : Double,
) -> Unit raise AddConstraintError {
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        Expression::of_variable(area.start),
        Expression::of_constant(area_start),
      ),
      Equal,
      strength_required(),
    ),
  )
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        Expression::of_variable(area.end),
        Expression::of_constant(area_end),
      ),
      Equal,
      strength_required(),
    ),
  )
}

///|
/// 全部变量收敛在内区（上游 `configure_variable_in_area_constraints`）喵。
fn configure_variable_in_area_constraints(
  solver : Solver,
  variables : Array[Variable],
  area : Element,
) -> Unit raise AddConstraintError {
  for variable in variables {
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(variable),
          Expression::of_variable(area.start),
        ),
        GreaterOrEqual,
        strength_required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(variable),
          Expression::of_variable(area.end),
        ),
        LessOrEqual,
        strength_required(),
      ),
    )
  }
}

///|
/// 段边界单调（上游 `configure_variable_constraints`：
/// `skip(1).tuples()` 非重叠偶对 v1≤v2、v3≤v4……spacer 两端不设
/// 单调约束，为负间距 overlap 留通道）喵。
fn configure_variable_constraints(
  solver : Solver,
  variables : Array[Variable],
) -> Unit raise AddConstraintError {
  let mut i = 1
  while i + 1 < variables.length() {
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(variables[i]),
          Expression::of_variable(variables[i + 1]),
        ),
        LessOrEqual,
        strength_required(),
      ),
    )
    i += 2
  }
}

///|
/// 段约束按强度排名落位（上游 `configure_constraints`）喵。
fn configure_constraints(
  solver : Solver,
  area : Element,
  segments : Array[Element],
  constraints : Array[@core.Constraint],
  flex : @core.Flex,
) -> Unit raise AddConstraintError {
  for i, constraint in constraints {
    if i >= segments.length() {
      break
    }
    let segment = segments[i]
    match constraint {
      @core.Max(max) => {
        solver.add_constraint(segment.has_max_size(max, max_size_le()))
        solver.add_constraint(segment.has_int_size(max, min_max_size_eq()))
      }
      @core.Min(min) => {
        solver.add_constraint(segment.has_min_size(min, min_size_ge()))
        if flex is Legacy {
          solver.add_constraint(segment.has_int_size(min, min_max_size_eq()))
        } else {
          solver.add_constraint(segment.has_size(area.size_expr(), fill_grow()))
        }
      }
      @core.Length(length) =>
        solver.add_constraint(segment.has_int_size(length, length_size_eq()))
      @core.Percentage(p) =>
        solver.add_constraint(
          segment.has_size(
            expr_scale(area.size_expr(), Double::from_int(p) / 100.0),
            percentage_size_eq(),
          ),
        )
      @core.Ratio(num, den) => {
        // 分母取 max(1) 规避除零（上游一致）喵。
        let denominator = if den > 1 { den } else { 1 }
        solver.add_constraint(
          segment.has_size(
            expr_scale(
              expr_scale(area.size_expr(), Double::from_int(num)),
              1.0 / Double::from_int(denominator),
            ),
            ratio_size_eq(),
          ),
        )
      }
      @core.Fill(_) =>
        solver.add_constraint(segment.has_size(area.size_expr(), fill_grow()))
    }
  }
}

///|
/// Flex 策略约束（上游 `configure_flex_constraints`）喵。
fn configure_flex_constraints(
  solver : Solver,
  area : Element,
  spacers : Array[Element],
  flex : @core.Flex,
  spacing : Spacing,
) -> Unit raise AddConstraintError {
  let spacing_value = match spacing {
    Space(x) => x
    Overlap(x) => -x
  }
  let spacing_f64 = Double::from_int(spacing_value) * float_precision_multiplier
  let middle_start = 1
  let middle_end = spacers.length() - 1
  match flex {
    Legacy => {
      for i in middle_start..<middle_end {
        solver.add_constraint(
          spacers[i].has_size_const(spacing_f64, spacer_size_eq()),
        )
      }
      if spacers.length() >= 2 {
        solver.add_constraint(spacers[0].is_empty())
        solver.add_constraint(spacers[spacers.length() - 1].is_empty())
      }
    }
    SpaceAround =>
      if spacers.length() <= 2 {
        for i in 0..<spacers.length() {
          for j in (i + 1)..<spacers.length() {
            solver.add_constraint(
              spacers[i].has_size(spacers[j].size_expr(), spacer_size_eq()),
            )
          }
        }
        for spacer in spacers {
          solver.add_constraint(
            spacer.has_min_size(spacing_value, spacer_size_eq()),
          )
          solver.add_constraint(spacer.has_size(area.size_expr(), space_grow()))
        }
      } else {
        let last_index = spacers.length() - 1
        for i in 1..<last_index {
          for j in (i + 1)..<last_index {
            solver.add_constraint(
              spacers[i].has_size(spacers[j].size_expr(), spacer_size_eq()),
            )
          }
        }
        if 1 < last_index {
          solver.add_constraint(
            spacers[1].has_double_size(spacers[0].size_expr(), spacer_size_eq()),
          )
          solver.add_constraint(
            spacers[1].has_double_size(
              spacers[last_index].size_expr(),
              spacer_size_eq(),
            ),
          )
        }
        for spacer in spacers {
          solver.add_constraint(
            spacer.has_min_size(spacing_value, spacer_size_eq()),
          )
          solver.add_constraint(spacer.has_size(area.size_expr(), space_grow()))
        }
      }
    SpaceEvenly => {
      for i in 0..<spacers.length() {
        for j in (i + 1)..<spacers.length() {
          solver.add_constraint(
            spacers[i].has_size(spacers[j].size_expr(), spacer_size_eq()),
          )
        }
      }
      for spacer in spacers {
        solver.add_constraint(
          spacer.has_min_size(spacing_value, spacer_size_eq()),
        )
        solver.add_constraint(spacer.has_size(area.size_expr(), space_grow()))
      }
    }
    SpaceBetween => {
      for i in middle_start..<middle_end {
        for j in (i + 1)..<middle_end {
          solver.add_constraint(
            spacers[i].has_size(spacers[j].size_expr(), spacer_size_eq()),
          )
        }
      }
      for i in middle_start..<middle_end {
        solver.add_constraint(
          spacers[i].has_min_size(spacing_value, spacer_size_eq()),
        )
        solver.add_constraint(
          spacers[i].has_size(area.size_expr(), space_grow()),
        )
      }
      if spacers.length() >= 2 {
        solver.add_constraint(spacers[0].is_empty())
        solver.add_constraint(spacers[spacers.length() - 1].is_empty())
      }
    }
    Start => {
      for i in middle_start..<middle_end {
        solver.add_constraint(
          spacers[i].has_size_const(spacing_f64, spacer_size_eq()),
        )
      }
      if spacers.length() >= 2 {
        solver.add_constraint(spacers[0].is_empty())
        solver.add_constraint(
          spacers[spacers.length() - 1].has_size(area.size_expr(), grow()),
        )
      }
    }
    Center => {
      for i in middle_start..<middle_end {
        solver.add_constraint(
          spacers[i].has_size_const(spacing_f64, spacer_size_eq()),
        )
      }
      if spacers.length() >= 2 {
        let first = spacers[0]
        let last = spacers[spacers.length() - 1]
        solver.add_constraint(first.has_size(area.size_expr(), grow()))
        solver.add_constraint(last.has_size(area.size_expr(), grow()))
        solver.add_constraint(
          first.has_size(last.size_expr(), spacer_size_eq()),
        )
      }
    }
    End => {
      for i in middle_start..<middle_end {
        solver.add_constraint(
          spacers[i].has_size_const(spacing_f64, spacer_size_eq()),
        )
      }
      if spacers.length() >= 2 {
        solver.add_constraint(spacers[spacers.length() - 1].is_empty())
        solver.add_constraint(spacers[0].has_size(area.size_expr(), grow()))
      }
    }
  }
}

///|
/// Fill（与非遗留 Min）段按缩放因子成比例（上游
/// `configure_fill_constraints`）喵。
fn configure_fill_constraints(
  solver : Solver,
  segments : Array[Element],
  constraints : Array[@core.Constraint],
  flex : @core.Flex,
) -> Unit raise AddConstraintError {
  // 收集参与比例均衡的下标喵。
  let fills : Array[Int] = []
  for i, constraint in constraints {
    if i >= segments.length() {
      break
    }
    let participating = match constraint {
      @core.Fill(_) => true
      @core.Min(_) => !(flex is Legacy)
      _ => false
    }
    if participating {
      fills.push(i)
    }
  }
  for a in 0..<fills.length() {
    for b in (a + 1)..<fills.length() {
      let left = fills[a]
      let right = fills[b]
      let left_scaling_factor = match constraints[left] {
        @core.Fill(scale) => Double::from_int(scale).max(0.000001)
        @core.Min(_) => 1.0
        _ => 1.0
      }
      let right_scaling_factor = match constraints[right] {
        @core.Fill(scale) => Double::from_int(scale).max(0.000001)
        @core.Min(_) => 1.0
        _ => 1.0
      }
      solver.add_constraint(
        Constraint::new(
          expr_sub(
            expr_scale(segments[right].size_expr(), left_scaling_factor),
            expr_scale(segments[left].size_expr(), right_scaling_factor),
          ),
          Equal,
          grow(),
        ),
      )
    }
  }
}

///|
/// 变量值 → Rect（上游 `changes_to_rects`：双重取整后按方向铺放）喵。
fn changes_to_rects(
  changes : Map[Variable, Double],
  elements : Array[Element],
  area : @core.Rect,
  direction : @core.Direction,
) -> Array[@core.Rect] {
  let out : Array[@core.Rect] = []
  for element in elements {
    let start = match changes.get(element.start) {
      Some(v) => v
      None => 0.0
    }
    let end = match changes.get(element.end) {
      Some(v) => v
      None => 0.0
    }
    let start = (start.round() / float_precision_multiplier).round().to_int()
    let end = (end.round() / float_precision_multiplier).round().to_int()
    let size = if end > start { end - start } else { 0 }
    match direction {
      @core.Horizontal =>
        out.push(@core.Rect::new(start, area.y, size, area.height))
      @core.Vertical =>
        out.push(@core.Rect::new(area.x, start, area.width, size))
    }
  }
  out
}
