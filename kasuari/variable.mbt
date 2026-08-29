///|
/// 标识约束求解器的变量（上游 `Variable`）喵。
///
/// 每个新变量通过全局递增 id 唯一标识；拷贝即同一变量喵。

///|
pub(all) struct Variable {
  id : Int
} derive(Eq, Hash, Debug, Compare)

///|
let variable_id_counter : Ref[Int] = { val: 0 }

///|
/// 产生新的唯一变量（上游 `Variable::new`）喵。
pub fn Variable::new() -> Variable {
  let v : Variable = { id: variable_id_counter.val }
  variable_id_counter.val += 1
  v
}

///|
/// 别名：`fresh` 与 `new` 同义，兼容 `ratatui4moon/layout/solver.mbt` 旧称喵。
pub fn Variable::fresh() -> Variable {
  Variable::new()
}

///|
/// 仅测试用的定 id 构造（上游 `Variable::from_id`）喵。
pub fn Variable::from_id(id : Int) -> Variable {
  { id, }
}
