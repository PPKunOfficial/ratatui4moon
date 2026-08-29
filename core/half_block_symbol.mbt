/// 半块符号（上游 `symbols/half_block.rs`）：上半块 `▀` / 下半块
/// `▄` / 全块 `█`，HalfBlock 标记借前后景双色把单格拆成 1x2 伪像素喵。
///
/// 上游以 `char` 承载，Canvas 直接逐字符写入 Cell，故本处同型喵。

///|
/// 上半块（上游 `symbols::half_block::UPPER`）喵。
pub const HALF_BLOCK_UPPER : Char = '▀'

///|
/// 下半块（上游 `symbols::half_block::LOWER`）喵。
pub const HALF_BLOCK_LOWER : Char = '▄'

///|
/// 全块（上游 `symbols::half_block::FULL`）喵。
pub const HALF_BLOCK_FULL : Char = '█'
