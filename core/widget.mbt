///|
/// 即时模式组件契约（上游 `widgets::Widget` trait）：把组件画进
/// 缓冲的给定区域喵。
///
/// Span/Line/Text 等类型的 `render` 均为本 trait 的实现；
/// `String` 亦实现（按区域宽度截断写入，样式为空）喵。
pub(open) trait Widget {
  fn render(Self, Rect, Buffer) -> Unit
}

///|
/// `String` 的 Widget 实现（上游 `impl Widget for String`）：
/// 从区域左上角写入，超出区域宽度截断。注意 MoonBit 禁止为外来
/// 类型定义方法（无 extend 提升），调用走 `Widget::render` 显式
/// 形式（上游为 `"str".render(area, buf)` 点调用）喵。
pub impl Widget for String with fn render(
  self : String,
  area : Rect,
  buf : Buffer,
) -> Unit {
  ignore(buf.set_stringn(area.x, area.y, self, area.width, Style::new()))
}
