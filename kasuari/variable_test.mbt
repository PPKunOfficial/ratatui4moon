///|
/// variable_test.mbt：复刻上游 `variable.rs` 运算语义喵。

///|
test "Variable new 唯一" {
  let a = Variable::new()
  let b = Variable::new()
  @debug.assert_eq(a == b, false)
}

///|
test "Variable from_id 定值" {
  let v = Variable::from_id(42)
  @debug.assert_eq(v.id, 42)
}

///|
test "Variable 加减乘除与 Expression 互转" {
  let v = Variable::from_id(0)
  let w = Variable::from_id(1)
  // v + 5
  let e = expr_add_const(Expression::of_variable(v), 5.0)
  @debug.assert_eq(e.constant, 5.0)
  @debug.assert_eq(e.terms.length(), 1)
  // v + w
  let e2 = expr_add(Expression::of_variable(v), Expression::of_variable(w))
  @debug.assert_eq(e2.terms.length(), 2)
  @debug.assert_eq(e2.constant, 0.0)
  // v * 2
  let t = Term::of_variable(v)
  let t2 = term_mul(t, 2.0)
  @debug.assert_eq(t2.coefficient, 2.0)
  // v / 2
  let t3 = term_div(t, 2.0)
  @debug.assert_eq(t3.coefficient, 0.5)
  // -v
  let t4 = term_neg(t)
  @debug.assert_eq(t4.coefficient, -1.0)
}
