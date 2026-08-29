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

///|
/// 是否为空白字形（上游 `StyledGrapheme::is_whitespace`）：零宽空格
/// 特判为空白；NBSP 虽属 Unicode 空白但被显式排除（作为普通字符
/// 参与断词）喵。
pub fn StyledGrapheme::is_whitespace(self : StyledGrapheme) -> Bool {
  self.symbol == "\u{200B}" ||
  (all_chars_whitespace(self.symbol) && self.symbol != "\u{00A0}")
}

///|
/// 全部码点均为 Unicode 空白（包私有，对位 Rust `char::is_whitespace`）喵。
fn all_chars_whitespace(symbol : String) -> Bool {
  if symbol == "" {
    return false
  }
  for ch in symbol {
    if !char_is_whitespace(ch.to_int()) {
      return false
    }
  }
  true
}

///|
/// Unicode White_Space 全量区间（包私有，对位 `char::is_whitespace`，
/// `00A0` 亦属空白但由外层 `is_whitespace` 单独排除 NBSP 单字符）喵。
fn char_is_whitespace(cp : Int) -> Bool {
  (cp >= 0x09 && cp <= 0x0D) ||
  cp == 0x20 ||
  cp == 0x00A0 ||
  cp == 0x85 ||
  cp == 0x1680 ||
  (cp >= 0x2000 && cp <= 0x200A) ||
  cp == 0x2028 ||
  cp == 0x2029 ||
  cp == 0x202F ||
  cp == 0x205F ||
  cp == 0x3000
}
