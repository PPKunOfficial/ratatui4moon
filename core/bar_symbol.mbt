/// 柱状填充符号表（上游 `symbols/bar.rs`）：八级底对齐填充块 +
/// 三级/九级填充集合，Sparkline 波形与 BarChart 柱体的绘制基元喵。
///
/// 与 `symbols/block.rs` 的左对齐半块（▏▎▍…）不同，bar 系是底对齐
/// 横条块（▁▂▃…█）。常量统一加 `BAR_` 前缀对位上游 `symbols::bar::*` 喵。

///|
/// 全填充柱（上游 `symbols::bar::FULL`）喵。
pub const BAR_FULL : String = "█"

///|
/// 七八填充柱（上游 `SEVEN_EIGHTHS`）喵。
pub const BAR_SEVEN_EIGHTHS : String = "▇"

///|
/// 四分之三填充柱（上游 `THREE_QUARTERS`）喵。
pub const BAR_THREE_QUARTERS : String = "▆"

///|
/// 八分之五填充柱（上游 `FIVE_EIGHTHS`）喵。
pub const BAR_FIVE_EIGHTHS : String = "▅"

///|
/// 半填充柱（上游 `HALF`）喵。
pub const BAR_HALF : String = "▄"

///|
/// 八分之三填充柱（上游 `THREE_EIGHTHS`）喵。
pub const BAR_THREE_EIGHTHS : String = "▃"

///|
/// 四分之一填充柱（上游 `ONE_QUARTER`）喵。
pub const BAR_ONE_QUARTER : String = "▂"

///|
/// 八分之一填充柱（上游 `ONE_EIGHTH`）喵。
pub const BAR_ONE_EIGHTH : String = "▁"

///|
/// 填充级别集合（上游 `symbols::bar::Set`）：从满格到空格的
/// 九档底对齐填充符，Sparkline 以集合整体取用喵。
pub(all) struct BarSet {
  full : String
  seven_eighths : String
  three_quarters : String
  five_eighths : String
  half : String
  three_eighths : String
  one_quarter : String
  one_eighth : String
  empty : String
} derive(Eq, Debug)

///|
/// 三级填充集合（上游 `bar::THREE_LEVELS`：全/半/空三档）喵。
pub fn BarSet::three_levels() -> BarSet {
  {
    full: BAR_FULL,
    seven_eighths: BAR_FULL,
    three_quarters: BAR_HALF,
    five_eighths: BAR_HALF,
    half: BAR_HALF,
    three_eighths: BAR_HALF,
    one_quarter: BAR_HALF,
    one_eighth: " ",
    empty: " ",
  }
}

///|
/// 九级填充集合（上游 `bar::NINE_LEVELS`，也是缺省集合）喵。
pub fn BarSet::nine_levels() -> BarSet {
  {
    full: BAR_FULL,
    seven_eighths: BAR_SEVEN_EIGHTHS,
    three_quarters: BAR_THREE_QUARTERS,
    five_eighths: BAR_FIVE_EIGHTHS,
    half: BAR_HALF,
    three_eighths: BAR_THREE_EIGHTHS,
    one_quarter: BAR_ONE_QUARTER,
    one_eighth: BAR_ONE_EIGHTH,
    empty: " ",
  }
}

///|
/// 缺省集合（上游 `Set::default` = `NINE_LEVELS`）喵。
pub fn BarSet::default() -> BarSet {
  BarSet::nine_levels()
}
