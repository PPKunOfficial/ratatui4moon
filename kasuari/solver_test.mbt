///|
/// solver_test.mbt：上游 kasuari 单测复刻与行为对齐喵。
/// 覆盖：简单等式、强度排名、不可满足、重复约束、删约束、edit 变量、
/// suggest_value、quadrilateral 全量。

///|
test "Solver 简单等式 REQUIRED" {
  let solver = Solver::new()
  let x = Variable::new()
  solver.add_constraint(
    Constraint::new(
      expr_sub(Expression::of_variable(x), Expression::of_constant(5.0)),
      Equal,
      Strength::required(),
    ),
  )
  let _ = solver.fetch_changes()
  let v = solver.get_value(x)
  // 需精确 5.0 喵
  if !(v == 5.0) {
    @debug.assert_eq(v, 5.0)
  }
}

///|
test "Solver 不可满足检测" {
  let solver = Solver::new()
  let x = Variable::new()
  let r1 = Constraint::new(
    expr_sub(Expression::of_variable(x), Expression::of_constant(0.0)),
    LessOrEqual,
    Strength::required(),
  )
  let r2 = Constraint::new(
    expr_sub(Expression::of_variable(x), Expression::of_constant(10.0)),
    GreaterOrEqual,
    Strength::required(),
  )
  let r = try {
    solver.add_constraint(r1)
    solver.add_constraint(r2)
    "solved"
  } catch {
    UnsatisfiableConstraint => "unsatisfiable"
    DuplicateConstraint => "duplicate"
    InternalSolverError(_) => "internal"
  }
  inspect(r, content="unsatisfiable")
}

///|
test "Solver 强度排名 REQUIRED 覆盖 WEAK" {
  let solver = Solver::new()
  let x = Variable::new()
  solver.add_constraint(
    Constraint::new(
      expr_sub(Expression::of_variable(x), Expression::of_constant(100.0)),
      GreaterOrEqual,
      Strength::required(),
    ),
  )
  solver.add_constraint(
    Constraint::new(
      expr_sub(Expression::of_variable(x), Expression::of_constant(10.0)),
      Equal,
      Strength::weak(),
    ),
  )
  let _ = solver.fetch_changes()
  inspect(solver.get_value(x), content="100")
}

///|
test "Solver 重复约束检测" {
  let solver = Solver::new()
  let x = Variable::new()
  let c = Constraint::new(
    expr_sub(Expression::of_variable(x), Expression::of_constant(1.0)),
    Equal,
    Strength::required(),
  )
  solver.add_constraint(c)
  let dup = try {
    solver.add_constraint(c)
    "ok"
  } catch {
    DuplicateConstraint => "duplicate"
    _ => "other"
  }
  inspect(dup, content="duplicate")
}

///|
test "Solver 删约束后可加新约束" {
  let solver = Solver::new()
  let v = Variable::new()
  let c = Constraint::new(
    expr_sub(Expression::of_variable(v), Expression::of_constant(100.0)),
    Equal,
    Strength::required(),
  )
  solver.add_constraint(c)
  let _ = solver.fetch_changes()
  inspect(solver.get_value(v), content="100")
  solver.remove_constraint(c)
  let c2 = Constraint::new(
    expr_sub(Expression::of_variable(v), Expression::of_constant(0.0)),
    Equal,
    Strength::required(),
  )
  solver.add_constraint(c2)
  let _ = solver.fetch_changes()
  inspect(solver.get_value(v), content="0")
}

///|
test "Solver edit variable suggest" {
  let solver = Solver::new()
  let x = Variable::new()
  // 初始无约束，x 默认 0
  solver.add_edit_variable(x, Strength::strong())
  solver.suggest_value(x, 42.0)
  let _ = solver.fetch_changes()
  inspect(solver.get_value(x), content="42")
  // 再次 suggest
  solver.suggest_value(x, 100.0)
  let _ = solver.fetch_changes()
  inspect(solver.get_value(x), content="100")
}

///|
test "Solver edit variable 需先添加" {
  let solver = Solver::new()
  let x = Variable::new()
  let r = try {
    solver.suggest_value(x, 1.0)
    "ok"
  } catch {
    UnknownEditVariable => "unknown"
    _ => "other"
  }
  inspect(r, content="unknown")
}

///|
test "Solver edit variable 不能 REQUIRED" {
  let solver = Solver::new()
  let x = Variable::new()
  let r = try {
    solver.add_edit_variable(x, Strength::required())
    "ok"
  } catch {
    BadRequiredStrength => "bad"
    _ => "other"
  }
  inspect(r, content="bad")
}

///|
test "Solver quadrilateral 前半段：中点约束" {
  // 复刻上游 quadrilateral.rs 前半段（无 edit）喵
  let point_starts : Array[(Double, Double)] = [
    (10.0, 10.0),
    (10.0, 200.0),
    (200.0, 200.0),
    (200.0, 10.0),
  ]
  let points : Array[(Variable, Variable)] = []
  for _ in 0..<4 {
    points.push((Variable::new(), Variable::new()))
  }
  let midpoints : Array[(Variable, Variable)] = []
  for _ in 0..<4 {
    midpoints.push((Variable::new(), Variable::new()))
  }
  let solver = Solver::new()
  let mut weight : Double = 1.0
  for i in 0..<4 {
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(points[i].0),
          Expression::of_constant(point_starts[i].0),
        ),
        Equal,
        Strength::weak().mul_float(weight),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(points[i].1),
          Expression::of_constant(point_starts[i].1),
        ),
        Equal,
        Strength::weak().mul_float(weight),
      ),
    )
    weight *= 2.0
  }
  for i in 0..<4 {
    let start = i
    let end = (i + 1) % 4
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(midpoints[start].0),
          expr_mul(
            expr_add(
              Expression::of_variable(points[start].0),
              Expression::of_variable(points[end].0),
            ),
            0.5,
          ),
        ),
        Equal,
        Strength::required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(midpoints[start].1),
          expr_mul(
            expr_add(
              Expression::of_variable(points[start].1),
              Expression::of_variable(points[end].1),
            ),
            0.5,
          ),
        ),
        Equal,
        Strength::required(),
      ),
    )
  }
  // 间距约束：每点间 ≥20
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        expr_add(
          Expression::of_variable(points[0].0),
          Expression::of_constant(20.0),
        ),
        Expression::of_variable(points[2].0),
      ),
      LessOrEqual,
      Strength::strong(),
    ),
  )
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        expr_add(
          Expression::of_variable(points[0].0),
          Expression::of_constant(20.0),
        ),
        Expression::of_variable(points[3].0),
      ),
      LessOrEqual,
      Strength::strong(),
    ),
  )
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        expr_add(
          Expression::of_variable(points[1].0),
          Expression::of_constant(20.0),
        ),
        Expression::of_variable(points[2].0),
      ),
      LessOrEqual,
      Strength::strong(),
    ),
  )
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        expr_add(
          Expression::of_variable(points[1].0),
          Expression::of_constant(20.0),
        ),
        Expression::of_variable(points[3].0),
      ),
      LessOrEqual,
      Strength::strong(),
    ),
  )
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        expr_add(
          Expression::of_variable(points[0].1),
          Expression::of_constant(20.0),
        ),
        Expression::of_variable(points[1].1),
      ),
      LessOrEqual,
      Strength::strong(),
    ),
  )
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        expr_add(
          Expression::of_variable(points[0].1),
          Expression::of_constant(20.0),
        ),
        Expression::of_variable(points[2].1),
      ),
      LessOrEqual,
      Strength::strong(),
    ),
  )
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        expr_add(
          Expression::of_variable(points[3].1),
          Expression::of_constant(20.0),
        ),
        Expression::of_variable(points[1].1),
      ),
      LessOrEqual,
      Strength::strong(),
    ),
  )
  solver.add_constraint(
    Constraint::new(
      expr_sub(
        expr_add(
          Expression::of_variable(points[3].1),
          Expression::of_constant(20.0),
        ),
        Expression::of_variable(points[2].1),
      ),
      LessOrEqual,
      Strength::strong(),
    ),
  )
  for p in points {
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(p.0), Expression::of_constant(0.0)),
        GreaterOrEqual,
        Strength::required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(p.1), Expression::of_constant(0.0)),
        GreaterOrEqual,
        Strength::required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(p.0), Expression::of_constant(500.0)),
        LessOrEqual,
        Strength::required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(p.1), Expression::of_constant(500.0)),
        LessOrEqual,
        Strength::required(),
      ),
    )
  }
  let _ = solver.fetch_changes()
  // 中点应为 (10,105) (105,200) (200,105) (105,10)
  inspect(solver.get_value(midpoints[0].0), content="10")
  inspect(solver.get_value(midpoints[0].1), content="105")
  inspect(solver.get_value(midpoints[1].0), content="105")
  inspect(solver.get_value(midpoints[1].1), content="200")
  inspect(solver.get_value(midpoints[2].0), content="200")
  inspect(solver.get_value(midpoints[2].1), content="105")
  inspect(solver.get_value(midpoints[3].0), content="105")
  inspect(solver.get_value(midpoints[3].1), content="10")
}

///|
test "Solver quadrilateral 后半段：edit suggest" {
  // 复刻 quadrilateral.rs 后半段：edit 变量 suggest
  let points : Array[(Variable, Variable)] = []
  for _ in 0..<4 {
    points.push((Variable::new(), Variable::new()))
  }
  let midpoints : Array[(Variable, Variable)] = []
  for _ in 0..<4 {
    midpoints.push((Variable::new(), Variable::new()))
  }
  let solver = Solver::new()
  // 先与前半段相同建模
  let point_starts : Array[(Double, Double)] = [
    (10.0, 10.0),
    (10.0, 200.0),
    (200.0, 200.0),
    (200.0, 10.0),
  ]
  let mut w : Double = 1.0
  for i in 0..<4 {
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(points[i].0),
          Expression::of_constant(point_starts[i].0),
        ),
        Equal,
        Strength::weak().mul_float(w),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(points[i].1),
          Expression::of_constant(point_starts[i].1),
        ),
        Equal,
        Strength::weak().mul_float(w),
      ),
    )
    w *= 2.0
  }
  for i in 0..<4 {
    let s = i
    let e = (i + 1) % 4
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(midpoints[s].0),
          expr_mul(
            expr_add(
              Expression::of_variable(points[s].0),
              Expression::of_variable(points[e].0),
            ),
            0.5,
          ),
        ),
        Equal,
        Strength::required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(midpoints[s].1),
          expr_mul(
            expr_add(
              Expression::of_variable(points[s].1),
              Expression::of_variable(points[e].1),
            ),
            0.5,
          ),
        ),
        Equal,
        Strength::required(),
      ),
    )
  }
  for p in points {
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(p.0), Expression::of_constant(0.0)),
        GreaterOrEqual,
        Strength::required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(p.0), Expression::of_constant(500.0)),
        LessOrEqual,
        Strength::required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(p.1), Expression::of_constant(0.0)),
        GreaterOrEqual,
        Strength::required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(p.1), Expression::of_constant(500.0)),
        LessOrEqual,
        Strength::required(),
      ),
    )
  }
  let _ = solver.fetch_changes()
  // 加 edit
  solver.add_edit_variable(points[2].0, Strength::strong())
  solver.add_edit_variable(points[2].1, Strength::strong())
  solver.suggest_value(points[2].0, 300.0)
  solver.suggest_value(points[2].1, 400.0)
  let _ = solver.fetch_changes()
  inspect(solver.get_value(points[2].0), content="300")
  inspect(solver.get_value(points[2].1), content="400")
  // 中点受 edit 影响
  // 期望 (10,105) (155,300) (250,205) (105,10) —— 取自上游断言，允许浮点容差，故用 get_value 精确比较
  let mx0x = solver.get_value(midpoints[0].0)
  let mx0y = solver.get_value(midpoints[0].1)
  let mx1x = solver.get_value(midpoints[1].0)
  let mx1y = solver.get_value(midpoints[1].1)
  let mx2x = solver.get_value(midpoints[2].0)
  let mx2y = solver.get_value(midpoints[2].1)
  let mx3x = solver.get_value(midpoints[3].0)
  let mx3y = solver.get_value(midpoints[3].1)
  // 容差 1e-6
  let close = fn(a : Double, b : Double) -> Bool {
    let d = if a > b { a - b } else { b - a }
    d < 0.000001
  }
  @debug.assert_eq(close(mx0x, 10.0), true)
  @debug.assert_eq(close(mx0y, 105.0), true)
  @debug.assert_eq(close(mx1x, 155.0), true)
  @debug.assert_eq(close(mx1y, 300.0), true)
  @debug.assert_eq(close(mx2x, 250.0), true)
  @debug.assert_eq(close(mx2y, 205.0), true)
  @debug.assert_eq(close(mx3x, 105.0), true)
  @debug.assert_eq(close(mx3y, 10.0), true)
}
