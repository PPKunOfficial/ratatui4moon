///|
/// MergeStrategy 单元测试：复刻 ratatui-v0.30.2 `symbols/merge.rs`
/// 测试清单喵。

///|
/// 全部上游符号表（含非边框符号）喵。
fn all_symbols() -> Array[String] {
  [
    "─", "━", "│", "┃", "┄", "┅", "┆", "┇", "┈", "┉", "┊",
    "┋", "┌", "┍", "┎", "┏", "┐", "┑", "┒", "┓", "└", "┕",
    "┖", "┗", "┘", "┙", "┚", "┛", "├", "┝", "┞", "┟", "┠",
    "┡", "┢", "┣", "┤", "┥", "┦", "┧", "┨", "┩", "┪", "┫",
    "┬", "┭", "┮", "┯", "┰", "┱", "┲", "┳", "┴", "┵", "┶",
    "┷", "┸", "┹", "┺", "┻", "┼", "┽", "┾", "┿", "╀", "╁",
    "╂", "╃", "╄", "╅", "╆", "╇", "╈", "╉", "╊", "╋", "╌",
    "╍", "╎", "╏", "═", "║", "╒", "╓", "╔", "╕", "╖", "╗",
    "╘", "╙", "╚", "╛", "╜", "╝", "╞", "╟", "╠", "╡", "╢",
    "╣", "╤", "╥", "╦", "╧", "╨", "╩", "╪", "╫", "╬", "╭",
    "╮", "╯", "╰", "╴", "╵", "╶", "╷", "╸", "╹", "╺", "╻",
    "╼", "╽", "╾", "╿", " ", "a", "b",
  ]
}

///|
/// 上游 replace_merge_strategy：Replace 全组合返回后符号喵。
test "Replace 策略全组合" {
  let strategy = MergeStrategy::Replace
  for a in all_symbols() {
    for b in all_symbols() {
      @debug.assert_eq(strategy.merge(a, b), b)
    }
  }
}

///|
/// 上游 exact_merge_strategy：存在精确合成字符才合并喵。
test "Exact 策略" {
  let strategy = MergeStrategy::Exact
  inspect(strategy.merge("┆", "─"), content="─")
  inspect(strategy.merge("┏", "┆"), content="┆")
  inspect(strategy.merge("╎", "┉"), content="┉")
  inspect(strategy.merge("┋", "┋"), content="┋")
  inspect(strategy.merge("╷", "╶"), content="┌")
  inspect(strategy.merge("╭", "┌"), content="┌")
  inspect(strategy.merge("│", "┕"), content="┝")
  inspect(strategy.merge("┏", "│"), content="┝")
  inspect(strategy.merge("│", "┏"), content="┢")
  inspect(strategy.merge("╽", "┕"), content="┢")
  inspect(strategy.merge("│", "─"), content="┼")
  inspect(strategy.merge("┘", "┌"), content="┼")
  inspect(strategy.merge("┵", "┝"), content="┿")
  inspect(strategy.merge("│", "━"), content="┿")
  inspect(strategy.merge("┵", "╞"), content="╞")
  inspect(strategy.merge(" ", "╠"), content=" ")
  inspect(strategy.merge("╠", " "), content=" ")
  inspect(strategy.merge("╎", "╧"), content="╧")
  inspect(strategy.merge("╛", "╒"), content="╪")
  inspect(strategy.merge("│", "═"), content="╪")
  inspect(strategy.merge("╤", "╧"), content="╪")
  inspect(strategy.merge("╡", "╞"), content="╪")
  inspect(strategy.merge("┌", "╭"), content="╭")
  inspect(strategy.merge("┘", "╭"), content="╭")
  inspect(strategy.merge("┌", "a"), content="a")
  inspect(strategy.merge("a", "╭"), content="a")
  inspect(strategy.merge("a", "b"), content="b")
}

///|
/// 上游 fuzzy_merge_strategy：不可表示组合按末次并入符号降级喵。
test "Fuzzy 策略" {
  let strategy = MergeStrategy::Fuzzy
  inspect(strategy.merge("┆", "─"), content="┼")
  inspect(strategy.merge("┏", "┆"), content="┝")
  inspect(strategy.merge("╎", "┉"), content="┿")
  inspect(strategy.merge("╷", "╶"), content="┌")
  inspect(strategy.merge("╭", "┌"), content="┌")
  inspect(strategy.merge("│", "┏"), content="┢")
  inspect(strategy.merge("╽", "┕"), content="┢")
  inspect(strategy.merge("│", "─"), content="┼")
  inspect(strategy.merge("┆", "─"), content="┼")
  inspect(strategy.merge("┘", "┌"), content="┼")
  inspect(strategy.merge("┘", "╭"), content="┼")
  inspect(strategy.merge("╎", "┉"), content="┿")
  inspect(strategy.merge(" ", "╠"), content=" ")
  inspect(strategy.merge("╠", " "), content=" ")
  inspect(strategy.merge("┵", "╞"), content="╪")
  inspect(strategy.merge("╛", "╒"), content="╪")
  inspect(strategy.merge("│", "═"), content="╪")
  inspect(strategy.merge("╤", "╧"), content="╪")
  inspect(strategy.merge("╡", "╞"), content="╪")
  inspect(strategy.merge("╎", "╧"), content="╪")
  inspect(strategy.merge("┌", "╭"), content="╭")
  inspect(strategy.merge("┌", "a"), content="a")
  inspect(strategy.merge("a", "╭"), content="a")
  inspect(strategy.merge("a", "b"), content="b")
}

///|
/// 上游模块文档示例：三种策略的代表行为喵。
test "MergeStrategy 文档示例" {
  inspect(MergeStrategy::Replace.merge("│", "━"), content="━")
  inspect(MergeStrategy::Exact.merge("│", "─"), content="┼")
  inspect(MergeStrategy::Fuzzy.merge("┘", "╔"), content="╬")
  inspect(MergeStrategy::Fuzzy.merge("┌", "┐"), content="┬")
  // 虚线段并入实线段（Fuzzy 降级）喵
  inspect(MergeStrategy::Fuzzy.merge("╎", "╍"), content="┿")
  // 圆角段并入直角段（Fuzzy 降级）喵
  inspect(MergeStrategy::Fuzzy.merge("┘", "╭"), content="┼")
  // 双线与粗线按末次并入符号二选一喵
  inspect(MergeStrategy::Fuzzy.merge("┃", "═"), content="╬")
  inspect(MergeStrategy::Fuzzy.merge("═", "┃"), content="╋")
  // 不可表示的 双线+实线 组合按末次并入符号二选一喵
  inspect(MergeStrategy::Fuzzy.merge("┐", "╔"), content="╦")
  inspect(MergeStrategy::Fuzzy.merge("╔", "┐"), content="┬")
}
