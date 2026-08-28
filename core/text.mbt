///|
/// 文本基元（上游 `text::Span`/`text::Line` 的最小面）喵。
///
/// v0.1 只覆盖 Buffer 写入路径所需：单 Span 构造、宽度计算与
/// `Line` 的 span 聚合；对齐/折行/Grapheme 细分随 `unicode/` 层落位喵。

///|
/// 带样式的连续文本片段（上游 `text::Span`）喵。
pub(all) struct Span {
  content : String
  style : Style
} derive(Eq, Debug)

///|
/// 无样式片段（上游 `Span::raw`）喵。
pub fn Span::raw(content : String) -> Span {
  { content, style: Style::new() }
}

///|
/// 带样式片段（上游 `Span::styled`）喵。
pub fn Span::styled(content : String, style : Style) -> Span {
  { content, style }
}

///|
/// 显示宽度（上游 `Span::width`）喵。
pub fn Span::width(self : Span) -> Int {
  symbol_width(self.content)
}

///|
/// 一行文本：span 序列 + 行级样式（上游 `text::Line`）喵。
///
/// 写入时行级样式 patch 到 span 样式（`Buffer::set_line`）喵。
pub(all) struct Line {
  spans : Array[Span]
  style : Style
} derive(Eq, Debug)

///|
/// 无样式单行（上游 `Line::raw`）喵。
pub fn Line::raw(content : String) -> Line {
  { spans: [Span::raw(content)], style: Style::new() }
}

///|
/// 行级样式单行（上游 `Line::styled`：样式落在 `Line::style`，
/// 写入时经 `line.style.patch(span.style)` 作用于文本）喵。
pub fn Line::styled(content : String, style : Style) -> Line {
  { spans: [Span::raw(content)], style }
}

///|
/// 行显示宽度 = 各 span 宽度之和（上游 `Line::width`）喵。
pub fn Line::width(self : Line) -> Int {
  let mut total = 0
  for span in self.spans {
    total += span.width()
  }
  total
}
