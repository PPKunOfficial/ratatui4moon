///|
/// 关系算子（上游 `RelationalOperator`）喵。

///|
pub(all) enum RelOp {
  LessOrEqual
  Equal
  GreaterOrEqual
} derive(Eq, Debug)

///|
/// 别名：与 Rust `RelationalOperator` 命名对齐，便于对照喵。
pub type RelationalOperator = RelOp

///|
/// 加权关系：算子 + 强度（上游 `WeightedRelation`）喵。

///|
pub(all) enum WeightedRelation {
  EQ(Strength)
  LE(Strength)
  GE(Strength)
} derive(Eq, Debug)

///|
/// 把加权关系拆为 (算子, 强度) 喵。
pub fn weighted_relation_to_pair(wr : WeightedRelation) -> (RelOp, Strength) {
  match wr {
    EQ(s) => (Equal, s)
    LE(s) => (LessOrEqual, s)
    GE(s) => (GreaterOrEqual, s)
  }
}
