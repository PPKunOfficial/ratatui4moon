///|
/// 文本基元（上游 `text::Span`/`text::Line`）喵。
///
/// Span 是带样式的连续文本；Line 聚合 span 序列并带行级样式与
/// 水平对齐，且自身即可渲染（对位上游 `Widget for Line`，含
/// 居中/右对齐与多宽字符截断语义）。Grapheme 簇细分与
/// `Text`（多行容器）随 `unicode/` 层落位喵。

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
/// 空片段（上游 `Span::default`）喵。
pub fn Span::empty() -> Span {
  { content: "", style: Style::new() }
}

///|
/// 换内容（上游 `Span::content` builder）喵。
pub fn Span::with_content(self : Span, content : String) -> Span {
  { ..self, content, }
}

///|
/// 换样式（上游 `Span::style` builder）喵。
pub fn Span::with_style(self : Span, style : Style) -> Span {
  { ..self, style, }
}

///|
/// 样式整体复位（上游 `Span::reset_style`）喵。
pub fn Span::reset_style(self : Span) -> Span {
  { ..self, style: Style::reset() }
}

///|
/// 叠加样式（上游 `Span::patch_style`）喵。
pub fn Span::patch_style(self : Span, style : Style) -> Span {
  { ..self, style: self.style.patch(style) }
}

///|
/// 显示宽度（上游 `Span::width`）喵。
pub fn Span::width(self : Span) -> Int {
  symbol_width(self.content)
}

///|
/// Display 语义（上游 `impl Display for Span`）：换行符不参与呈现，
/// 可选按码点数截断（对位 `{span:.4}` 精度）喵。
pub fn Span::to_display(self : Span, limit? : Int) -> String {
  let out = StringBuilder()
  let mut count = 0
  for ch in self.content {
    let cp = ch.to_int()
    if cp == 0x0A || cp == 0x0D {
      continue
    }
    match limit {
      Some(max) => if count >= max { break }
      None => ()
    }
    out.write_char(ch)
    count += 1
  }
  out.to_string()
}

///|
/// 拆出带样式的字形序列：`base_style` 先 patch 自身样式再逐字形下发；
/// 控制字符被过滤（上游 `Span::styled_graphemes`）喵。
pub fn Span::styled_graphemes(
  self : Span,
  base_style : Style,
) -> Array[StyledGrapheme] {
  let style = base_style.patch(self.style)
  let out : Array[StyledGrapheme] = []
  for ch in self.content {
    let cp = ch.to_int()
    if cp < 0x20 || (cp >= 0x7F && cp < 0xA0) {
      continue
    }
    out.push(StyledGrapheme::of(ch.to_string(), style))
  }
  out
}

///|
/// 渲染进缓冲：首字形必落格、零宽字形并入邻格、多宽字形隐藏
/// 尾列复位、越界截断（上游 `Widget for &Span`）喵。
impl Widget for Span with fn render(self : Span, area : Rect, buf : Buffer) -> Unit {
  let area = buf.area.intersection(area)
  if area.is_empty() {
    return
  }
  let mut x = area.x
  let y = area.y
  let mut i = 0
  for grapheme in self.styled_graphemes(Style::default()) {
    let symbol_width = symbol_width(grapheme.symbol)
    let next_x = x + symbol_width
    if next_x > area.right() {
      break
    }
    if i == 0 {
      // 首字形必落格（含零宽）
      match buf.mut_cell(x, y) {
        Some(cell) => {
          cell.set_symbol(grapheme.symbol)
          cell.set_style(grapheme.style)
        }
        None => ()
      }
    } else if x == area.x {
      // 仍在首格：零宽字形并入
      match buf.mut_cell(x, y) {
        Some(cell) => {
          cell.append_symbol(grapheme.symbol)
          cell.set_style(grapheme.style)
        }
        None => ()
      }
    } else if symbol_width == 0 {
      // 零宽字形并入前一格
      match buf.mut_cell(x - 1, y) {
        Some(cell) => {
          cell.append_symbol(grapheme.symbol)
          cell.set_style(grapheme.style)
        }
        None => ()
      }
    } else {
      // 普通字形
      match buf.mut_cell(x, y) {
        Some(cell) => {
          cell.set_symbol(grapheme.symbol)
          cell.set_style(grapheme.style)
        }
        None => ()
      }
    }
    // 多宽字形隐藏的尾列复位，防止被遮字符透出
    for hidden in (x + 1)..<next_x {
      match buf.mut_cell(hidden, y) {
        Some(cell) => cell.reset()
        None => ()
      }
    }
    x = next_x
    i += 1
  }
}

///|
/// 单片段转行（上游 `From<Span> for Line`）喵。
pub fn Span::to_line(self : Span) -> Line {
  Line::of_span(self)
}

///|
/// 一行文本：span 序列 + 行级样式 + 水平对齐（上游 `text::Line`）喵。
///
/// 渲染时行级样式经 `set_style` 铺满行区域，span 样式逐字形叠加；
/// 对齐缺省承左，块标题等父级可经 `render_with_alignment` 注入
/// 默认对齐喵。
pub(all) struct Line {
  mut spans : Array[Span]
  mut style : Style
  mut alignment : Alignment?
} derive(Eq, Debug)

///|
/// 无样式单行（上游 `Line::raw`）喵。
pub fn Line::raw(content : String) -> Line {
  { spans: [Span::raw(content)], style: Style::new(), alignment: None }
}

///|
/// 行级样式单行（上游 `Line::styled`：样式落在 `Line::style`，
/// 写入时铺满行区域）喵。
pub fn Line::styled(content : String, style : Style) -> Line {
  { spans: [Span::raw(content)], style, alignment: None }
}

///|
/// 空行（上游 `Line::default`）喵。
pub fn Line::empty() -> Line {
  { spans: [], style: Style::new(), alignment: None }
}

///|
/// 以 span 序列建行（上游 `From<Vec<Span>>`）喵。
pub fn Line::of_spans(spans : Array[Span]) -> Line {
  { spans, style: Style::new(), alignment: None }
}

///|
/// 以单 span 建行（上游 `From<Span>`）喵。
pub fn Line::of_span(span : Span) -> Line {
  Line::of_spans([span])
}

///|
/// 换行级样式（上游 `Line::style` builder）喵。
pub fn Line::with_style(self : Line, style : Style) -> Line {
  { ..self, style, }
}

///|
/// 设对齐（上游 `Line::alignment` builder）喵。
pub fn Line::with_alignment(self : Line, alignment : Alignment) -> Line {
  { ..self, alignment: Some(alignment) }
}

///|
/// 左对齐（上游 `Line::left_aligned`）喵。
pub fn Line::left_aligned(self : Line) -> Line {
  self.with_alignment(Left)
}

///|
/// 居中（上游 `Line::centered`）喵。
pub fn Line::centered(self : Line) -> Line {
  self.with_alignment(Center)
}

///|
/// 右对齐（上游 `Line::right_aligned`）喵。
pub fn Line::right_aligned(self : Line) -> Line {
  self.with_alignment(Right)
}

///|
/// 叠加行级样式（上游 `Line::patch_style`）喵。
pub fn Line::patch_style(self : Line, style : Style) -> Line {
  { ..self, style: self.style.patch(style) }
}

///|
/// 行级样式复位（上游 `Line::reset_style`）喵。
pub fn Line::reset_style(self : Line) -> Line {
  { ..self, style: Style::reset() }
}

///|
/// 追加 span（上游 `Line::push_span`）喵。
pub fn Line::push_span(self : Line, span : Span) -> Unit {
  self.spans.push(span)
}

///|
/// 追加多个 span（上游 `Line::extend`）喵。
pub fn Line::push_spans(self : Line, spans : Array[Span]) -> Unit {
  for span in spans {
    self.spans.push(span)
  }
}

///|
/// `line + span`：样式与对齐承自左行（上游 `Add<Span> for Line`）喵。
pub fn Line::op_add(self : Line, span : Span) -> Line {
  let spans = self.spans.iter().collect()
  spans.push(span)
  { spans, style: self.style, alignment: self.alignment }
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

///|
/// Display 语义（上游 `impl Display for Line`）：各 span 内容拼接，
/// 换行不参与呈现喵。
pub fn Line::to_display(self : Line) -> String {
  let out = StringBuilder()
  for span in self.spans {
    out.write_string(span.to_display())
  }
  out.to_string()
}

///|
/// 拆出带样式的字形序列：`base_style` 先 patch 行样式，span 再叠加
/// （上游 `Line::styled_graphemes`）喵。
pub fn Line::styled_graphemes(
  self : Line,
  base_style : Style,
) -> Array[StyledGrapheme] {
  let style = base_style.patch(self.style)
  let out : Array[StyledGrapheme] = []
  for span in self.spans {
    for grapheme in span.styled_graphemes(style) {
      out.push(grapheme)
    }
  }
  out
}

///|
/// 渲染进缓冲（上游 `Widget for Line`，缺省承左对齐）喵。
impl Widget for Line with fn render(self : Line, area : Rect, buf : Buffer) -> Unit {
  self.render_with_alignment(area, buf, None)
}

///|
/// 带父级缺省对齐的渲染（上游 `render_with_alignment`，原为
/// pub(crate)，块标题跨包注入对齐所需）喵。
///
/// 只渲染区域首行；行宽放得下时按对齐缩进，放不下时按对齐从
/// 左侧裁剪（右对齐裁左、居中各半），多宽字符按整字形取舍喵。
pub fn Line::render_with_alignment(
  self : Line,
  area : Rect,
  buf : Buffer,
  parent_alignment : Alignment?,
) -> Unit {
  let area = buf.area.intersection(area)
  if area.is_empty() {
    return
  }
  let area = Rect::new(area.x, area.y, area.width, 1)
  let line_width = self.width()
  if line_width == 0 {
    return
  }
  buf.set_style(area, self.style)
  let alignment : Alignment? = match self.alignment {
    Some(a) => Some(a)
    None => parent_alignment
  }
  let area_width = area.width
  if line_width <= area_width {
    let indent = match alignment {
      Some(Center) => (area_width - line_width) / 2
      Some(Right) => area_width - line_width
      _ => 0
    }
    let indented = Rect::new(
      area.x + indent,
      area.y,
      (area.width - indent).clamp(min=0, max=area.width),
      area.height,
    )
    render_spans(self.spans, indented, buf, 0)
  } else {
    // 区域放不下整行：右侧由区域宽度自然截断，只需按对齐裁左
    let skip = match alignment {
      Some(Center) => (line_width - area_width) / 2
      Some(Right) => line_width - area_width
      _ => 0
    }
    render_spans(self.spans, area, buf, skip)
  }
}

///|
/// 依次渲染可见 span（包私有，上游 `render_spans`）喵。
fn render_spans(
  spans : Array[Span],
  area : Rect,
  buf : Buffer,
  skip_width : Int,
) -> Unit {
  let mut area = area
  for item in spans_after_width(spans, skip_width) {
    let (span, span_width, offset) = item
    area = Rect::new(
      area.x + offset,
      area.y,
      (area.width - offset).clamp(min=0, max=area.width),
      area.height,
    )
    if area.is_empty() {
      break
    }
    span.render(area, buf)
    area = Rect::new(
      area.x + span_width,
      area.y,
      (area.width - span_width).clamp(min=0, max=area.width),
      area.height,
    )
  }
}

///|
/// 计算 `skip_width` 之后的可见 span 序列：被整段跳过的丢弃，
/// 被部分跳过的从头部按整字形裁剪，并以偏移补偿首字形的宽度差
/// （包私有，上游 `spans_after_width`）喵。
fn spans_after_width(
  spans : Array[Span],
  skip_width : Int,
) -> Array[(Span, Int, Int)] {
  let mut skip = skip_width
  let out : Array[(Span, Int, Int)] = []
  for span in spans {
    let span_width = span.width()
    if skip >= span_width {
      skip -= span_width
      continue
    }
    // 裁剪作用于 span 头部（尾部由区域宽度自然截断）
    let available = span_width - skip
    skip = 0
    if span_width <= available {
      out.push((span, span_width, 0))
    } else {
      let (content, actual_width) = truncate_start(span.content, available)
      // 首字形被整只裁掉时，剩余宽度差以缩进补偿（如螃蟹 emoji 的左半）
      let offset = available - actual_width
      out.push((Span::styled(content, span.style), actual_width, offset))
    }
  }
  out
}

///|
/// 点调用提升声明（MoonBit extend 惯用法）喵。
pub extend Span with Widget::{render}

///|
/// 点调用提升声明（MoonBit extend 惯用法）喵。
pub extend Line with Widget::{render}
