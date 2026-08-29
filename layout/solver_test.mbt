///|
/// 求解器单元测试：复刻 cassowary 上游行为规格（含 tests/quadrilateral.rs
/// 前半段——一次性子集不含 edit variable，后半段登记不适用）喵。

///|
/// 简单等式约束收敛喵。
test "Solver 简单等式" {
  let solver = Solver::make()
  let x = Variable::fresh()
  solver.add_constraint(
    Constraint::new(
      expr_sub(Expression::of_variable(x), Expression::of_constant(5.0)),
      Equal,
      strength_required(),
    ),
  )
  ignore(solver.fetch_changes())
  assert_eq(solver.get_value(x), 5.0)
}

///|
/// REQUIRED 约束冲突判定为不可满足喵。
test "Solver 不可满足检测" {
  let solver = Solver::make()
  let x = Variable::fresh()
  let expr = Expression::of_variable(x)
  let r1 = Constraint::new(
    expr_sub(expr, Expression::of_constant(0.0)),
    LessOrEqual,
    strength_required(),
  )
  let r2 = Constraint::new(
    expr_sub(expr, Expression::of_constant(10.0)),
    GreaterOrEqual,
    strength_required(),
  )
  let r = try {
    solver.add_constraint(r1)
    solver.add_constraint(r2)
    "solved"
  } catch {
    UnsatisfiableConstraint => "unsatisfiable"
    InternalSolverError(_) => "internal"
  }
  inspect(r, content="unsatisfiable")
}

///|
/// 弱等式可被强约束覆盖，强度排名决定违让喵。
test "Solver 强度排名" {
  let solver = Solver::make()
  let x = Variable::fresh()
  // x >= 100（REQUIRED）
  solver.add_constraint(
    Constraint::new(
      expr_sub(Expression::of_variable(x), Expression::of_constant(100.0)),
      GreaterOrEqual,
      strength_required(),
    ),
  )
  // x == 10（WEAK）
  solver.add_constraint(
    Constraint::new(
      expr_sub(Expression::of_variable(x), Expression::of_constant(10.0)),
      Equal,
      strength_weak(),
    ),
  )
  ignore(solver.fetch_changes())
  assert_eq(solver.get_value(x), 100.0)
}

///|
/// 上游 tests/quadrilateral.rs（前半段）喵。
test "Solver 四边形中点" {
  let point_starts : Array[(Float, Float)] = [
    (10.0, 10.0),
    (10.0, 200.0),
    (200.0, 200.0),
    (200.0, 10.0),
  ]
  let points : Array[(Variable, Variable)] = []
  for _ in 0..<4 {
    points.push((Variable::fresh(), Variable::fresh()))
  }
  let midpoints : Array[(Variable, Variable)] = []
  for _ in 0..<4 {
    midpoints.push((Variable::fresh(), Variable::fresh()))
  }
  let solver = Solver::make()
  let mut weight : Float = 1.0
  for i in 0..<4 {
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(points[i].0),
          Expression::of_constant(point_starts[i].0),
        ),
        Equal,
        strength_weak() * weight,
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(points[i].1),
          Expression::of_constant(point_starts[i].1),
        ),
        Equal,
        strength_weak() * weight,
      ),
    )
    weight = weight * 2.0
  }
  for pair in [(0, 1), (1, 2), (2, 3), (3, 0)] {
    let start = pair.0
    let end = pair.1
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(midpoints[start].0),
          expr_scale(
            expr_add(
              Expression::of_variable(points[start].0),
              Expression::of_variable(points[end].0),
            ),
            0.5,
          ),
        ),
        Equal,
        strength_required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(midpoints[start].1),
          expr_scale(
            expr_add(
              Expression::of_variable(points[start].1),
              Expression::of_variable(points[end].1),
            ),
            0.5,
          ),
        ),
        Equal,
        strength_required(),
      ),
    )
  }
  // 间距下界：p0.x + 20 <= p2.x 等（STRONG）喵。
  for pair in [(0, 2), (0, 3), (1, 2), (1, 3)] {
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          expr_add_const(Expression::of_variable(points[pair.0].0), 20.0),
          Expression::of_variable(points[pair.1].0),
        ),
        LessOrEqual,
        strength_strong(),
      ),
    )
  }
  for pair in [(0, 1), (0, 2)] {
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          expr_add_const(Expression::of_variable(points[pair.0].1), 20.0),
          Expression::of_variable(points[pair.1].1),
        ),
        LessOrEqual,
        strength_strong(),
      ),
    )
  }
  for pair in [(3, 1), (3, 2)] {
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          expr_add_const(Expression::of_variable(points[pair.0].1), 20.0),
          Expression::of_variable(points[pair.1].1),
        ),
        LessOrEqual,
        strength_strong(),
      ),
    )
  }
  for point in points {
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(point.0), Expression::of_constant(0.0)),
        GreaterOrEqual,
        strength_required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(Expression::of_variable(point.1), Expression::of_constant(0.0)),
        GreaterOrEqual,
        strength_required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(point.0),
          Expression::of_constant(500.0),
        ),
        LessOrEqual,
        strength_required(),
      ),
    )
    solver.add_constraint(
      Constraint::new(
        expr_sub(
          Expression::of_variable(point.1),
          Expression::of_constant(500.0),
        ),
        LessOrEqual,
        strength_required(),
      ),
    )
  }
  ignore(solver.fetch_changes())
  let expected : Array[(Float, Float)] = [
    (10.0, 105.0),
    (105.0, 200.0),
    (200.0, 105.0),
    (105.0, 10.0),
  ]
  for i in 0..<4 {
    assert_eq(solver.get_value(midpoints[i].0), expected[i].0)
    assert_eq(solver.get_value(midpoints[i].1), expected[i].1)
  }
}
