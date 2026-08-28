///|
/// 多行文本容器（上游 `text::Text`）：行序列 + 文本级样式 + 文本级对齐喵。
///
/// 渲染时把文本级对齐作为父级缺省对齐下发给各行（行自带对齐优先），
/// 文本级样式经 `set_style` 铺满区域后由行/ span 样式逐层叠加喵。

///|
/// 多行文本（上游 `text::Text`）喵。
pub(all) struct Text {
  mut alignment : Alignment?
  mut style : Style
  mut lines : Array[Line]
} derive(Eq, Debug)

///|
/// 空文本（上游 `Text::default`：无行、无样式、无对齐）喵。
pub fn Text::empty() -> Text {
  { alignment: None, style: Style::new(), lines: [] }
}

///|
/// 从多行字符串建文本：按换行拆行（上游 `Text::raw`）喵。
///
/// 空串得到单个空行（上游语义：`""` → `[""]` 一行）；
/// 尾随换行不产生空尾行（对位 Rust `str::lines`）喵。
pub fn Text::raw(content : String) -> Text {
  let lines : Array[Line] = []
  if content == "" {
    lines.push(Line::raw(""))
  } else {
    let mut current = StringBuilder()
    for ch in content {
      if ch.to_int() == 0x0A {
        lines.push(Line::raw(current.to_string()))
        current = StringBuilder()
      } else {
        current.write_char(ch)
      }
    }
    let last = current.to_string()
    if last != "" {
      lines.push(Line::raw(last))
    }
  }
  Text::of_lines(lines)
}

///|
/// 带样式建文本（上游 `Text::styled`）喵。
pub fn Text::styled(content : String, style : Style) -> Text {
  Text::raw(content).patch_style(style)
}

///|
/// 以行序列建文本（上游 `From<Vec<Line>>`）喵。
pub fn Text::of_lines(lines : Array[Line]) -> Text {
  { alignment: None, style: Style::new(), lines }
}

///|
/// 以单行建文本（上游 `From<Line>`）喵。
pub fn Text::of_line(line : Line) -> Text {
  Text::of_lines([line])
}

///|
/// 以单 span 建文本（上游 `From<Span>`：不按换行拆分，原样成一行）喵。
pub fn Text::of_span(span : Span) -> Text {
  Text::of_line(Line::of_span(span))
}

///|
/// 换文本级样式（上游 `Text::style` builder）喵。
pub fn Text::with_style(self : Text, style : Style) -> Text {
  { ..self, style, }
}

///|
/// 叠加文本级样式（上游 `Text::patch_style`）喵。
pub fn Text::patch_style(self : Text, style : Style) -> Text {
  { ..self, style: self.style.patch(style) }
}

///|
/// 文本级样式复位（上游 `Text::reset_style`）喵。
pub fn Text::reset_style(self : Text) -> Text {
  { ..self, style: Style::reset() }
}

///|
/// 设文本级对齐（上游 `Text::alignment` builder）喵。
pub fn Text::with_alignment(self : Text, alignment : Alignment) -> Text {
  { ..self, alignment: Some(alignment) }
}

///|
/// 左对齐（上游 `Text::left_aligned`）喵。
pub fn Text::left_aligned(self : Text) -> Text {
  self.with_alignment(Left)
}

///|
/// 居中（上游 `Text::centered`）喵。
pub fn Text::centered(self : Text) -> Text {
  self.with_alignment(Center)
}

///|
/// 右对齐（上游 `Text::right_aligned`）喵。
pub fn Text::right_aligned(self : Text) -> Text {
  self.with_alignment(Right)
}

///|
/// 全部行的最大宽度（上游 `Text::width`）喵。
pub fn Text::width(self : Text) -> Int {
  let mut width = 0
  for line in self.lines {
    let w = line.width()
    if w > width {
      width = w
    }
  }
  width
}

///|
/// 行数（上游 `Text::height`）喵。
pub fn Text::height(self : Text) -> Int {
  self.lines.length()
}

///|
/// 追加一行（上游 `Text::push_line`）喵。
pub fn Text::push_line(self : Text, line : Line) -> Unit {
  self.lines.push(line)
}

///|
/// 把 span 追加进最后一行；空文本先建行（上游 `Text::push_span`）喵。
pub fn Text::push_span(self : Text, span : Span) -> Unit {
  match self.lines.last() {
    Some(line) => line.push_span(span)
    None => self.lines.push(Line::of_span(span))
  }
}

///|
/// 追加多行（上游 `Extend<Line>`）喵。
pub fn Text::push_lines(self : Text, lines : Array[Line]) -> Unit {
  for line in lines {
    self.lines.push(line)
  }
}

///|
/// `text + line`：文本级样式承自左值（上游 `Add<Line> for Text`）喵。
pub fn Text::add_line(self : Text, line : Line) -> Text {
  let lines = self.lines.iter().collect()
  lines.push(line)
  { alignment: self.alignment, style: self.style, lines }
}

///|
/// `text + text`：行拼接，样式承自左值（上游 `Add for Text`）喵。
pub fn Text::op_add(self : Text, other : Text) -> Text {
  let lines = self.lines.iter().collect()
  for line in other.lines {
    lines.push(line)
  }
  { alignment: self.alignment, style: self.style, lines }
}

///|
/// 拆出带样式的字形序列：`base_style` 先 patch 文本样式再逐行下发
/// （上游 `Text::styled_graphemes`）喵。
pub fn Text::styled_graphemes(
  self : Text,
  base_style : Style,
) -> Array[StyledGrapheme] {
  let style = base_style.patch(self.style)
  let out : Array[StyledGrapheme] = []
  for line in self.lines {
    for grapheme in line.styled_graphemes(style) {
      out.push(grapheme)
    }
  }
  out
}

///|
/// Display 语义（上游 `impl Display for Text`：行以换行连接）喵。
pub fn Text::to_display(self : Text) -> String {
  let out = StringBuilder()
  for i, line in self.lines {
    if i > 0 {
      out.write_char('\n')
    }
    out.write_string(line.to_display())
  }
  out.to_string()
}

///|
/// 渲染文本：文本级样式铺满区域，逐行渲染并把文本级对齐作为
/// 父级缺省对齐（上游 `WidgetRef for Text`）喵。
pub fn Text::render(self : Text, area : Rect, buf : Buffer) -> Unit {
  let area = buf.area.intersection(area)
  buf.set_style(area, self.style)
  for y, line in self.lines {
    if y >= area.height {
      break
    }
    let line_area = Rect::new(area.x, area.y + y, area.width, 1)
    line.render_with_alignment(line_area, buf, self.alignment)
  }
}
