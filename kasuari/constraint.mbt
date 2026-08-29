///|
/// 约束：`表达式 op 0` + 强度（上游 `Constraint`）喵。
///
/// Rust 侧以 Arc 指针身份判等；MoonBit 侧以单调 id 判等，保持
/// `DuplicateConstraint` 语义可复现喵。

///|
pub(all) struct Constraint {
  id : Int
  expression : Expression
  strength : Strength
  op : RelOp
} derive(Eq, Debug)

///|
let constraint_id_counter : Ref[Int] = { val: 1 }

///|
/// 以表达式、算子与强度构造约束（上游 `Constraint::new`）喵。
pub fn Constraint::new(
  expression : Expression,
  op : RelOp,
  strength : Strength,
) -> Constraint {
  let id = constraint_id_counter.val
  constraint_id_counter.val += 1
  { id, expression, strength, op }
}

///|
/// 便捷构造：表达式与加权关系直接合成约束喵。
pub fn Constraint::of_weighted(
  expression : Expression,
  relation : WeightedRelation,
) -> Constraint {
  let (op, strength) = weighted_relation_to_pair(relation)
  Constraint::new(expression, op, strength)
}

///|
/// 约束表达式访问器（上游 `expr`）喵。
pub fn Constraint::expr(self : Constraint) -> Expression {
  self.expression
}

///|
/// 约束算子访问器（上游 `op`）喵。
pub fn Constraint::relational_operator(self : Constraint) -> RelOp {
  self.op
}

///|
/// 约束强度访问器（上游 `strength`）喵。
pub fn Constraint::strength_value(self : Constraint) -> Strength {
  self.strength
}

///|
/// 中间类型：偏约束（上游 `PartialConstraint`）——表达式 + 加权关系，
/// 待与右侧表达式合成完整约束喵。

///|
pub(all) struct PartialConstraint {
  expression : Expression
  relation : WeightedRelation
} derive(Eq, Debug)

///|
pub fn PartialConstraint::new(
  expression : Expression,
  relation : WeightedRelation,
) -> PartialConstraint {
  { expression, relation }
}

///|
/// `PartialConstraint | b`：左侧表达式 − 右侧表达式 → 约束喵。
pub fn partial_constraint_to_constraint(
  pc : PartialConstraint,
  rhs : Expression,
) -> Constraint {
  let (op, strength) = weighted_relation_to_pair(pc.relation)
  Constraint::new(expr_sub(pc.expression, rhs), op, strength)
}

///|
/// 表达式与加权关系合成偏约束：`expr | EQ(s)` 喵。
pub fn expr_weighted(
  expr : Expression,
  relation : WeightedRelation,
) -> PartialConstraint {
  PartialConstraint::new(expr, relation)
}

///|
/// 变量与加权关系合成偏约束喵。
pub fn variable_weighted(
  v : Variable,
  relation : WeightedRelation,
) -> PartialConstraint {
  PartialConstraint::new(Expression::of_variable(v), relation)
}

///|
/// 项与加权关系合成偏约束喵。
pub fn term_weighted(
  t : Term,
  relation : WeightedRelation,
) -> PartialConstraint {
  PartialConstraint::new(Expression::of_term(t), relation)
}

///|
/// 常量与加权关系合成偏约束喵。
pub fn const_weighted(
  c : Double,
  relation : WeightedRelation,
) -> PartialConstraint {
  PartialConstraint::new(Expression::of_constant(c), relation)
}
