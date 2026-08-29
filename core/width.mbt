///|
/// 符号显示宽度（v0.2：委托 `unicode/` 包的 unicode-width 0.2.2
/// 全量表状态机，替换 v0.1 近似区间法）喵。
///
/// 语义对位上游 `unicode-width` 0.2 的 `str::width`：控制字符与
/// 零宽符号宽 0、CJK/全角宽 2、VS16/ZWJ emoji 序列整体宽 2；
/// **换行符特判宽 1**（状态机 LINE_FEED 分支，`Span::width` 语义
/// 由此而来，上游测试标注"待重新审视" #1271）喵。
pub fn symbol_width(symbol : String) -> Int {
  @unicode.str_width(symbol)
}

///|
/// 从头部按显示宽度截断，保留尾部（上游 `unicode-truncate` crate 的
/// `unicode_truncate_start`）喵。
///
/// 返回 (保留文本, 实际显示宽度)：整码点裁剪，零宽码点不占列；
/// 越过截断点之前的零宽码点随头部一起丢弃喵。
pub fn truncate_start(text : String, max_width : Int) -> (String, Int) {
  let chars : Array[Char] = []
  for ch in text {
    chars.push(ch)
  }
  let kept : Array[Char] = []
  let mut total = 0
  for i2 in 0..<chars.length() {
    let ch = chars[chars.length() - 1 - i2]
    let width = char_display_width(ch)
    if total + width > max_width {
      break
    }
    total += width
    kept.push(ch)
  }
  let content = StringBuilder()
  for i2 in 0..<kept.length() {
    content.write_char(kept[kept.length() - 1 - i2])
  }
  (content.to_string(), total)
}

///|
/// 单码点显示宽度：控制字符 0，其余查全量表（上游
/// `UnicodeWidthChar::width` 的 `unwrap_or(0)` 承载）喵。
pub fn char_display_width(ch : Char) -> Int {
  @unicode.single_char_width(ch.to_int()).unwrap_or(0)
}
