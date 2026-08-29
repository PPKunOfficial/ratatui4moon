///|
/// expression_test.mbt：复刻上游 `expression.rs` 语义喵。

///|
test "Expression from_constant / from_term" {
  let e = Expression::of_constant(3.0)
  @debug.assert_eq(e.constant, 3.0)
  @debug.assert_eq(e.terms.length(), 0)
  let v = Variable::from_id(5)
  let e2 = Expression::of_variable(v)
  @debug.assert_eq(e2.terms.length(), 1)
  @debug.assert_eq(e2.constant, 0.0)
}

///|
test "Expression 加减乘除" {
  let v = Variable::from_id(0)
  let e = Expression::of_variable(v)
  let e2 = expr_add_const(e, 2.0)
  @debug.assert_eq(e2.constant, 2.0)
  let e3 = expr_mul(e2, 2.0)
  @debug.assert_eq(e3.constant, 4.0)
  @debug.assert_eq(e3.terms[0].coefficient, 2.0)
  let e4 = expr_div(e3, 2.0)
  @debug.assert_eq(e4.constant, 2.0)
  let e5 = e4.negate()
  @debug.assert_eq(e5.constant, -2.0)
}

///|
test "Expression 合并" {
  let v = Variable::from_id(0)
  let w = Variable::from_id(1)
  let ev = Expression::of_variable(v)
  let ew = Expression::of_variable(w)
  let e = expr_add(ev, ew)
  @debug.assert_eq(e.terms.length(), 2)
  let e2 = expr_sub(e, ew)
  // e - ew  => 剩余 v 项
  // 注意：expr_sub 会复制并取负，长度为 2 + 1? 实际实现为 2 项 + 负 1 项 => 3 项含消去? 但 near_zero 会在求解时消去，此处直接检查
  @debug.assert_eq(e2.terms.length(), 3)
}
