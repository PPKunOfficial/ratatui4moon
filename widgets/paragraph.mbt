///|
/// 折行配置（上游 `widgets::Wrap`）：`trim` 决定折行时是否裁剪
/// 行首/换行处空白喵。
pub(all) struct Wrap {
  trim : Bool
} derive(Eq, Debug)

///|
/// 构造折行配置喵。
pub fn Wrap::of(trim : Bool) -> Wrap {
  { trim, }
}

///|
/// 段落组件（上游 `widgets::Paragraph`）：多行文本 + 可选边框块 +
/// 可选折行 + 滚动偏移 + 对齐喵。
///
/// 渲染分层：段落样式铺满区域 → Block（边框/标题）→ 文本区按
/// 截断（LineTruncator）或折行（WordWrapper）产出字形行，
/// 按 `scroll` 偏移后写入缓冲喵。
pub(all) struct Paragraph {
  block : Block?
  style : @core.Style
  wrap : Wrap?
  text : @core.Text
  scroll : @core.Position
  alignment : @core.Alignment
} derive(Eq, Debug)

///|
/// 从文本构造段落；文本级对齐承为段落缺省对齐（上游 `Paragraph::new`）喵。
pub fn Paragraph::new(text : @core.Text) -> Paragraph {
  let alignment = match text.alignment {
    Some(a) => a
    None => @core.Alignment::Left
  }
  {
    block: None,
    style: @core.Style::new(),
    wrap: None,
    text,
    scroll: @core.Position::new(0, 0),
    alignment,
  }
}

///|
/// 从字符串构造段落喵。
pub fn Paragraph::of_str(content : String) -> Paragraph {
  Paragraph::new(@core.Text::raw(content))
}

///|
/// 包边框块（上游 `Paragraph::block`）喵。
pub fn Paragraph::block(self : Paragraph, block : Block) -> Paragraph {
  { ..self, block: Some(block) }
}

///|
/// 设段落样式（上游 `Paragraph::style`）喵。
pub fn Paragraph::style(self : Paragraph, style : @core.Style) -> Paragraph {
  { ..self, style, }
}

///|
/// 开启折行（上游 `Paragraph::wrap`）喵。
pub fn Paragraph::wrap(self : Paragraph, wrap : Wrap) -> Paragraph {
  { ..self, wrap: Some(wrap) }
}

///|
/// 设滚动偏移 (垂直, 水平)（上游 `Paragraph::scroll`）喵。
pub fn Paragraph::scroll(self : Paragraph, offset : (Int, Int)) -> Paragraph {
  { ..self, scroll: @core.Position::new(offset.1, offset.0) }
}

///|
/// 设对齐（上游 `Paragraph::alignment`）喵。
pub fn Paragraph::alignment(
  self : Paragraph,
  alignment : @core.Alignment,
) -> Paragraph {
  { ..self, alignment, }
}

///|
/// 左对齐（上游 `Paragraph::left_aligned`）喵。
pub fn Paragraph::left_aligned(self : Paragraph) -> Paragraph {
  self.alignment(@core.Alignment::Left)
}

///|
/// 居中（上游 `Paragraph::centered`）喵。
pub fn Paragraph::centered(self : Paragraph) -> Paragraph {
  self.alignment(@core.Alignment::Center)
}

///|
/// 右对齐（上游 `Paragraph::right_aligned`）喵。
pub fn Paragraph::right_aligned(self : Paragraph) -> Paragraph {
  self.alignment(@core.Alignment::Right)
}

///|
/// 在给定宽度下的渲染行数（含边框占行，上游 `Paragraph::line_count`，
/// 上游标注 unstable）喵。
pub fn Paragraph::line_count(self : Paragraph, width : Int) -> Int {
  if width < 1 {
    return 0
  }
  let (top, bottom) = match self.block {
    Some(b) => b.vertical_space()
    None => (0, 0)
  }
  let count = match self.wrap {
    Some(wrap) => {
      let styled : Array[(Array[@core.StyledGrapheme], @core.Alignment)] = []
      for line in self.text.lines {
        let alignment = match line.alignment {
          Some(a) => a
          None => self.alignment
        }
        styled.push((line.styled_graphemes(self.style), alignment))
      }
      let composer = WordWrapper::new(styled, width, wrap.trim)
      let mut count = 0
      while true {
        match composer.next_line() {
          Some(_) => count += 1
          None => break
        }
      }
      count
    }
    None => self.text.height()
  }
  count + top + bottom
}

///|
/// 文本最大行宽（含边框占列，上游 `Paragraph::line_width`，
/// 上游标注 unstable）喵。
pub fn Paragraph::line_width(self : Paragraph) -> Int {
  let mut width = 0
  for line in self.text.lines {
    let w = line.width()
    if w > width {
      width = w
    }
  }
  let (left, right) = match self.block {
    Some(b) => b.horizontal_space()
    None => (0, 0)
  }
  width + left + right
}

///|
/// 渲染段落（上游 `Widget for &Paragraph`）喵。
impl @core.Widget for Paragraph with fn render(
  self : Paragraph,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let area = buf.area.intersection(area)
  buf.set_style(area, self.style)
  let text_area = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  self.render_paragraph(text_area, buf)
}

///|
/// 渲染文本区（包私有，上游 `render_paragraph`）喵。
fn Paragraph::render_paragraph(
  self : Paragraph,
  text_area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  if text_area.is_empty() {
    return
  }
  buf.set_style(text_area, self.style)
  let styled : Array[(Array[@core.StyledGrapheme], @core.Alignment)] = []
  for line in self.text.lines {
    let alignment = match line.alignment {
      Some(a) => a
      None => self.alignment
    }
    // 注意：字形基样式取文本级样式（对位上游 line.styled_graphemes(text.style)）喵
    styled.push((line.styled_graphemes(self.text.style), alignment))
  }
  match self.wrap {
    Some(wrap) => {
      let composer = WordWrapper::new(styled, text_area.width, wrap.trim)
      // 滚动：先消费掉 scroll.y 行
      for _ in 0..<self.scroll.y {
        if composer.next_line() is None {
          return
        }
      }
      render_lines(composer, text_area, buf)
    }
    None => {
      // 截断模式：直接跳过 scroll.y 行再合成
      let skipped : Array[(Array[@core.StyledGrapheme], @core.Alignment)] = []
      for i in self.scroll.y..<styled.length() {
        skipped.push(styled[i])
      }
      let composer = LineTruncator::new(skipped, text_area.width)
      composer.set_horizontal_offset(self.scroll.x)
      render_lines(composer, text_area, buf)
    }
  }
}

///|
/// 逐行渲染合成产出，区域高度耗尽即止（包私有，上游 `render_lines`）喵。
fn[C : LineComposer] render_lines(
  composer : C,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let mut y = 0
  while true {
    match composer.next_line() {
      Some(wrapped) => {
        render_line(wrapped, area, buf, y)
        y += 1
        if y >= area.height {
          break
        }
      }
      None => break
    }
  }
}

///|
/// 渲染单行：按对齐取横移，逐字形写入（零宽字形跳过）喵。
fn render_line(
  wrapped : WrappedLine,
  area : @core.Rect,
  buf : @core.Buffer,
  y : Int,
) -> Unit {
  let mut x = get_line_offset(wrapped.width, area.width, wrapped.alignment)
  for grapheme in wrapped.graphemes {
    let width = @core.symbol_width(grapheme.symbol)
    if width == 0 {
      continue
    }
    let symbol = if grapheme.symbol == "" { " " } else { grapheme.symbol }
    match buf.mut_cell(area.left() + x, area.top() + y) {
      Some(cell) => {
        cell.set_symbol(symbol)
        cell.set_style(grapheme.style)
      }
      None => ()
    }
    x += width
  }
}

///|
/// 按对齐计算行横移（包私有，上游 `get_line_offset`）喵。
fn get_line_offset(
  line_width : Int,
  text_area_width : Int,
  alignment : @core.Alignment,
) -> Int {
  match alignment {
    @core.Alignment::Center =>
      (text_area_width / 2 - line_width / 2).clamp(
        min=0,
        max=text_area_width / 2,
      )
    @core.Alignment::Right =>
      (text_area_width - line_width).clamp(min=0, max=text_area_width)
    @core.Alignment::Left => 0
  }
}

///|
/// 点调用提升声明（MoonBit extend 惯用法）喵。
pub extend Paragraph with @core.Widget::{render}
