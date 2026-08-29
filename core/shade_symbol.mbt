/// 明暗符号常量表（上游 `symbols/shade.rs`）：四级明暗度方块，
/// Sparkline 缺值符号与 Canvas 密度图的绘制基元喵。
///
/// 常量统一加 `SHADE_` 前缀对位上游 `symbols::shade::*` 喵。

///|
/// 空明暗（上游 `symbols::shade::EMPTY`，即空格）喵。
pub const SHADE_EMPTY : String = " "

///|
/// 微亮明暗（上游 `LIGHT`，八分之一样式 ░）喵。
pub const SHADE_LIGHT : String = "░"

///|
/// 半明暗（上游 `MEDIUM`，▒）喵。
pub const SHADE_MEDIUM : String = "▒"

///|
/// 深明暗（上游 `DARK`，▓）喵。
pub const SHADE_DARK : String = "▓"

///|
/// 全明暗（上游 `FULL`，█）喵。
pub const SHADE_FULL : String = "█"
