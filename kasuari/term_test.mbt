///|
/// term_test.mbt：复刻上游 `term.rs` 运算喵。

///|
test "Term new / from_variable" {
  let v = Variable::from_id(0)
  let t = Term::new(v, 2.0)
  @debug.assert_eq(t.coefficient, 2.0)
  let t2 = Term::of_variable(v)
  @debug.assert_eq(t2.coefficient, 1.0)
}

///|
test "Term mul div" {
  let v = Variable::from_id(1)
  let t = Term::of_variable(v)
  @debug.assert_eq(term_mul(t, 2.0).coefficient, 2.0)
  @debug.assert_eq(term_div(t, 2.0).coefficient, 0.5)
}

///|
test "Term 加减 Expression" {
  let v = Variable::from_id(0)
  let w = Variable::from_id(1)
  let tv = Term::of_variable(v)
  let tw = Term::of_variable(w)
  // tv + 2.0
  let e = expr_add_const(Expression::of_term(tv), 2.0)
  @debug.assert_eq(e.constant, 2.0)
  // tv + tw
  let e2 = expr_add(Expression::of_term(tv), Expression::of_term(tw))
  @debug.assert_eq(e2.terms.length(), 2)
  // tv - tw
  let e3 = expr_sub(Expression::of_term(tv), Expression::of_term(tw))
  @debug.assert_eq(e3.terms.length(), 2)
  @debug.assert_eq(e3.terms[1].coefficient, -1.0)
}
