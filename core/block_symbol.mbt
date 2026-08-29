/// 块填充符号表（上游 `symbols/block.rs`）：八级左对齐填充块 +
/// 三级/九级填充集合，Gauge 高精度进度与 Sparkline 波形的前置喵。
///
/// 常量统一加 `BLOCK_` 前缀对位上游 `symbols::block::*` 喵。

///|
/// 全填充块（上游 `symbols::block::FULL`）喵。
pub const BLOCK_FULL : String = "█"

///|
/// 七八填充块（上游 `SEVEN_EIGHTHS`）喵。
pub const BLOCK_SEVEN_EIGHTHS : String = "▉"

///|
/// 四分之三填充块（上游 `THREE_QUARTERS`）喵。
pub const BLOCK_THREE_QUARTERS : String = "▊"

///|
/// 八分之五填充块（上游 `FIVE_EIGHTHS`）喵。
pub const BLOCK_FIVE_EIGHTHS : String = "▋"

///|
/// 半填充块（上游 `HALF`）喵。
pub const BLOCK_HALF : String = "▌"

///|
/// 八分之三填充块（上游 `THREE_EIGHTHS`）喵。
pub const BLOCK_THREE_EIGHTHS : String = "▍"

///|
/// 四分之一填充块（上游 `ONE_QUARTER`）喵。
pub const BLOCK_ONE_QUARTER : String = "▎"

///|
/// 八分之一填充块（上游 `ONE_EIGHTH`）喵。
pub const BLOCK_ONE_EIGHTH : String = "▏"

///|
/// 填充级别集合（上游 `symbols::block::Set`）：从满格到空格的
/// 九档填充符，Sparkline 以集合整体取用喵。
pub(all) struct BlockSet {
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
/// 三级填充集合（上游 `block::THREE_LEVELS`：全/半/空三档）喵。
pub fn BlockSet::three_levels() -> BlockSet {
  {
    full: BLOCK_FULL,
    seven_eighths: BLOCK_FULL,
    three_quarters: BLOCK_HALF,
    five_eighths: BLOCK_HALF,
    half: BLOCK_HALF,
    three_eighths: BLOCK_HALF,
    one_quarter: BLOCK_HALF,
    one_eighth: " ",
    empty: " ",
  }
}

///|
/// 九级填充集合（上游 `block::NINE_LEVELS`，也是缺省集合）喵。
pub fn BlockSet::nine_levels() -> BlockSet {
  {
    full: BLOCK_FULL,
    seven_eighths: BLOCK_SEVEN_EIGHTHS,
    three_quarters: BLOCK_THREE_QUARTERS,
    five_eighths: BLOCK_FIVE_EIGHTHS,
    half: BLOCK_HALF,
    three_eighths: BLOCK_THREE_EIGHTHS,
    one_quarter: BLOCK_ONE_QUARTER,
    one_eighth: BLOCK_ONE_EIGHTH,
    empty: " ",
  }
}

///|
/// 缺省集合（上游 `Set::default` = `NINE_LEVELS`）喵。
pub fn BlockSet::default() -> BlockSet {
  BlockSet::nine_levels()
}
