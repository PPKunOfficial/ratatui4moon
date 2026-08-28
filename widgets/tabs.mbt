///|
/// 缺省高亮样式（上游 `DEFAULT_HIGHLIGHT_STYLE` 常量）：反显喵。
pub fn tabs_default_highlight_style() -> @core.Style {
  @core.Style::new().add_modifier(@core.Modifier::reversed())
}

///|
/// 横向标签栏组件（上游 `widgets::Tabs`）：一组标题 + 分隔符 +
/// 两侧内边距，选中标签叠加高亮样式喵。
///
/// 渲染自左向右推进：左内边距 → 标题（选中则叠 highlight_style）→
/// 右内边距 → 分隔符，超出区域宽度即止喵。
pub(all) struct Tabs {
  block : Block?
  titles : Array[@core.Line]
  selected : Int?
  style : @core.Style
  highlight_style : @core.Style
  divider : @core.Span
  padding_left : @core.Line
  padding_right : @core.Line
} derive(Eq, Debug)

///|
/// 从标题行序列构造（上游 `Tabs::new`：非空时缺省选中第 0 个，
/// 分隔符 `│`，两侧各 1 空格内边距）喵。
pub fn Tabs::new(titles : Array[@core.Line]) -> Tabs {
  let selected = if titles.is_empty() { None } else { Some(0) }
  {
    block: None,
    titles,
    selected,
    style: @core.Style::new(),
    highlight_style: tabs_default_highlight_style(),
    divider: @core.Span::raw("│"),
    padding_left: @core.Line::raw(" "),
    padding_right: @core.Line::raw(" "),
  }
}

///|
/// 从字符串序列构造（上游 `Tabs::new` 的 `Into<Line>` 形态）喵。
pub fn Tabs::of_strs(titles : Array[String]) -> Tabs {
  let lines : Array[@core.Line] = []
  for title in titles {
    lines.push(@core.Line::raw(title))
  }
  Tabs::new(lines)
}

///|
/// 替换标题并收敛选中索引（上游 `Tabs::titles`）喵。
pub fn Tabs::titles(self : Tabs, titles : Array[@core.Line]) -> Tabs {
  let selected = if titles.is_empty() {
    None
  } else {
    match self.selected {
      Some(s) =>
        Some(if s < titles.length() - 1 { s } else { titles.length() - 1 })
      None => Some(0)
    }
  }
  { ..self, titles, selected }
}

///|
/// 包边框块（上游 `Tabs::block`）喵。
pub fn Tabs::block(self : Tabs, block : Block) -> Tabs {
  { ..self, block: Some(block) }
}

///|
/// 设选中标签（越界视为无选中，上游 `Tabs::select`）喵。
pub fn Tabs::select(self : Tabs, selected : Int?) -> Tabs {
  { ..self, selected, }
}

///|
/// 设基础样式（上游 `Tabs::style`）喵。
pub fn Tabs::style(self : Tabs, style : @core.Style) -> Tabs {
  { ..self, style, }
}

///|
/// 设选中高亮样式（上游 `Tabs::highlight_style`）喵。
pub fn Tabs::highlight_style(self : Tabs, style : @core.Style) -> Tabs {
  { ..self, highlight_style: style }
}

///|
/// 设分隔符（上游 `Tabs::divider`）喵。
pub fn Tabs::divider(self : Tabs, divider : @core.Span) -> Tabs {
  { ..self, divider, }
}

///|
/// 设分隔符字符串（上游 `divider` 的 `Into<Span>` 形态）喵。
pub fn Tabs::divider_str(self : Tabs, divider : String) -> Tabs {
  self.divider(@core.Span::raw(divider))
}

///|
/// 设两侧内边距（上游 `Tabs::padding`）喵。
pub fn Tabs::padding(
  self : Tabs,
  left : @core.Line,
  right : @core.Line,
) -> Tabs {
  { ..self, padding_left: left, padding_right: right }
}

///|
/// 设两侧内边距字符串（上游 `padding` 的 `Into<Line>` 形态）喵。
pub fn Tabs::padding_str(self : Tabs, left : String, right : String) -> Tabs {
  self.padding(@core.Line::raw(left), @core.Line::raw(right))
}

///|
/// 设左内边距字符串（上游 `Tabs::padding_left`）喵。
pub fn Tabs::padding_left_str(self : Tabs, left : String) -> Tabs {
  { ..self, padding_left: @core.Line::raw(left) }
}

///|
/// 设右内边距字符串（上游 `Tabs::padding_right`）喵。
pub fn Tabs::padding_right_str(self : Tabs, right : String) -> Tabs {
  { ..self, padding_right: @core.Line::raw(right) }
}

///|
/// 渲染标签栏（上游 `Widget for &Tabs`）喵。
pub impl @core.Widget for Tabs with fn render(
  self : Tabs,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  buf.set_style(area, self.style)
  let tabs_area = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  self.render_tabs(tabs_area, buf)
}

///|
/// 逐段推进渲染：左内边距 → 标题（选中叠高亮）→ 右内边距 →
/// 分隔符，区域耗尽即止（包私有，上游 `render_tabs`）喵。
fn Tabs::render_tabs(
  self : Tabs,
  tabs_area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  if tabs_area.is_empty() {
    return
  }
  let mut x = tabs_area.left()
  let titles_length = self.titles.length()
  for i, title in self.titles {
    let last_title = titles_length - 1 == i
    let mut remaining_width = tabs_area.right() - x
    if remaining_width <= 0 {
      break
    }
    // 左内边距
    let pos = buf.set_line(
      x,
      tabs_area.top(),
      self.padding_left,
      remaining_width,
    )
    x = pos.0
    remaining_width = tabs_area.right() - x
    if remaining_width <= 0 {
      break
    }
    // 标题
    let pos = buf.set_line(x, tabs_area.top(), title, remaining_width)
    if self.selected == Some(i) {
      buf.set_style(
        @core.Rect::new(
          x,
          tabs_area.top(),
          (pos.0 - x).clamp(min=0, max=remaining_width),
          1,
        ),
        self.highlight_style,
      )
    }
    x = pos.0
    remaining_width = tabs_area.right() - x
    if remaining_width <= 0 {
      break
    }
    // 右内边距
    let pos = buf.set_line(
      x,
      tabs_area.top(),
      self.padding_right,
      remaining_width,
    )
    x = pos.0
    remaining_width = tabs_area.right() - x
    if remaining_width <= 0 || last_title {
      break
    }
    // 分隔符
    let pos = buf.set_span(x, tabs_area.top(), self.divider, remaining_width)
    x = pos.0
    ignore(remaining_width)
  }
}
