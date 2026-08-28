///|
/// 带样式的单个字形（上游 `text::StyledGrapheme`）喵。
///
/// v0.1 以单码点为字形近似（见 `width.mbt`），ZWJ 图形簇随
/// `unicode/` 全量表升级喵。
pub(all) struct StyledGrapheme {
  symbol : String
  style : Style
} derive(Eq, Debug)

///|
/// 构造字形（上游 `StyledGrapheme::new`）喵。
pub fn StyledGrapheme::of(symbol : String, style : Style) -> StyledGrapheme {
  { symbol, style }
}
