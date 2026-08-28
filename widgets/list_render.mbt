///|
/// 列表组件（上游 `widgets::List`）：可选中、可高亮、支持正反方向
/// 与滚动边距的条目列表喵。
///
/// 渲染分层：列表样式铺满区域 → Block → 条目区。选中项叠加
/// `highlight_style`，高亮符号列按 `HighlightSpacing` 预留。
/// 状态语义对位上游：渲染会把选中项收敛进可视窗口并回写 `offset`，
/// 条目为空时取消选中喵。
pub(all) struct List {
  block : Block?
  items : Array[ListItem]
  style : @core.Style
  direction : ListDirection
  highlight_style : @core.Style
  highlight_symbol : @core.Line?
  repeat_highlight_symbol : Bool
  highlight_spacing : HighlightSpacing
  scroll_padding : Int
} derive(Eq, Debug)

///|
/// 从条目序列构造列表（上游 `List::new`）喵。
pub fn List::new(items : Array[ListItem]) -> List {
  {
    block: None,
    items,
    style: @core.Style::new(),
    direction: TopToBottom,
    highlight_style: @core.Style::new(),
    highlight_symbol: None,
    repeat_highlight_symbol: false,
    highlight_spacing: WhenSelected,
    scroll_padding: 0,
  }
}

///|
/// 替换条目序列（上游 `List::items`）喵。
pub fn List::items(self : List, items : Array[ListItem]) -> List {
  { ..self, items, }
}

///|
/// 包边框块（上游 `List::block`）喵。
pub fn List::block(self : List, block : Block) -> List {
  { ..self, block: Some(block) }
}

///|
/// 设列表样式（上游 `List::style`）喵。
pub fn List::style(self : List, style : @core.Style) -> List {
  { ..self, style, }
}

///|
/// 设高亮符号（上游 `List::highlight_symbol`）喵。
pub fn List::highlight_symbol(self : List, symbol : @core.Line) -> List {
  { ..self, highlight_symbol: Some(symbol) }
}

///|
/// 设高亮符号字符串（上游 `highlight_symbol` 的 `Into<Line>` 形态）喵。
pub fn List::highlight_symbol_str(self : List, symbol : String) -> List {
  self.highlight_symbol(@core.Line::raw(symbol))
}

///|
/// 设选中项高亮样式（上游 `List::highlight_style`）喵。
pub fn List::highlight_style(self : List, style : @core.Style) -> List {
  { ..self, highlight_style: style }
}

///|
/// 设是否每个条目行都重复高亮符号（上游 `List::repeat_highlight_symbol`）喵。
pub fn List::repeat_highlight_symbol(self : List, repeat : Bool) -> List {
  { ..self, repeat_highlight_symbol: repeat }
}

///|
/// 设高亮符号间距策略（上游 `List::highlight_spacing`）喵。
pub fn List::highlight_spacing(self : List, value : HighlightSpacing) -> List {
  { ..self, highlight_spacing: value }
}

///|
/// 设方向（上游 `List::direction`）喵。
pub fn List::direction(self : List, direction : ListDirection) -> List {
  { ..self, direction, }
}

///|
/// 设滚动边距（选中项周围需可见的行数，上游 `List::scroll_padding`）喵。
pub fn List::scroll_padding(self : List, padding : Int) -> List {
  { ..self, scroll_padding: padding }
}

///|
/// 条目数（上游 `List::len`）喵。
pub fn List::len(self : List) -> Int {
  self.items.length()
}

///|
/// 是否为空（上游 `List::is_empty`）喵。
pub fn List::is_empty(self : List) -> Bool {
  self.items.is_empty()
}

///|
/// 渲染列表（无状态形态：以默认状态驱动，上游 `Widget for &List`）喵。
impl @core.Widget for List with fn render(
  self : List,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let state = ListState::new()
  ignore(self.render_stateful(area, buf, state))
}

///|
/// 渲染列表（带状态：选中收敛、偏移回写，上游
/// `StatefulWidget for &List`）喵。
///
/// `state` 为引用语义结构体：渲染中修改的 `offset`/`selected`
/// 对调用方立即可见（对位上游 `&mut ListState`）喵。
pub fn List::render_stateful(
  self : List,
  area : @core.Rect,
  buf : @core.Buffer,
  state : ListState,
) -> Unit {
  buf.set_style(area, self.style)
  let list_area = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  if list_area.is_empty() {
    return
  }
  if self.items.is_empty() {
    state.select(None)
    return
  }
  // 选中项越界时收敛到最后一项
  let out_of_bounds = match state.selected {
    Some(s) => s >= self.items.length()
    None => false
  }
  if out_of_bounds {
    state.select(Some(self.items.length() - 1))
  }
  let list_height = list_area.height
  let (first_visible_index, last_visible_index) = self.get_items_bounds(
    state.selected,
    state.offset,
    list_height,
  )
  state.offset = first_visible_index
  let highlight_symbol = match self.highlight_symbol {
    Some(line) => line
    None => @core.Line::empty()
  }
  let highlight_symbol_width = highlight_symbol.width()
  let empty_symbol = String::make(highlight_symbol_width, ' ')
  let empty_symbol_line = @core.Line::raw(empty_symbol)
  let mut current_height = 0
  let selection_spacing = self.highlight_spacing.should_add(
    state.selected is Some(_),
  )
  for index in state.offset..<last_visible_index {
    let item = self.items[index]
    let (x, y) = match self.direction {
      BottomToTop => {
        current_height += item.height()
        (list_area.left(), list_area.bottom() - current_height)
      }
      TopToBottom => {
        let pos = (list_area.left(), list_area.top() + current_height)
        current_height += item.height()
        pos
      }
    }
    let row_area = @core.Rect::new(x, y, list_area.width, item.height())
    let item_style = self.style.patch(item.style)
    buf.set_style(row_area, item_style)
    let is_selected = match state.selected {
      Some(s) => s == index
      None => false
    }
    let item_area = if selection_spacing {
      @core.Rect::new(
        row_area.x + highlight_symbol_width,
        row_area.y,
        (row_area.width - highlight_symbol_width).clamp(
          min=0,
          max=row_area.width,
        ),
        row_area.height,
      )
    } else {
      row_area
    }
    item.content.render(item_area, buf)
    if is_selected {
      buf.set_style(row_area, self.highlight_style)
    }
    if selection_spacing {
      for j in 0..<item.content.height() {
        // 选中项首行（或按配置的每一行）显示高亮符号，其余行以空白占位喵
        let line = if is_selected && (j == 0 || self.repeat_highlight_symbol) {
          highlight_symbol
        } else {
          empty_symbol_line
        }
        let highlight_area = @core.Rect::new(
          x,
          y + j,
          highlight_symbol_width,
          1,
        )
        line.render(highlight_area, buf)
      }
    }
  }
  ignore(first_visible_index)
}

///|
/// 计算可视窗口的首/末条目索引：选中项与偏移收敛进可视区
/// （包私有，上游 `get_items_bounds`）喵。
fn List::get_items_bounds(
  self : List,
  selected : Int?,
  offset : Int,
  max_height : Int,
) -> (Int, Int) {
  let offset = if offset < self.items.length() - 1 {
    offset
  } else if self.items.length() > 0 {
    self.items.length() - 1
  } else {
    0
  }
  let mut first_visible_index = offset
  let mut last_visible_index = offset
  let mut height_from_offset = 0
  for index in offset..<self.items.length() {
    if height_from_offset + self.items[index].height() > max_height {
      break
    }
    height_from_offset += self.items[index].height()
    last_visible_index += 1
  }
  let index_to_display = self.apply_scroll_padding_to_selected_index(
    selected, max_height, first_visible_index, last_visible_index,
  )
  let index_to_display = match index_to_display {
    Some(i) => i
    None => offset
  }
  // 选中项在可视区之后：向后扩展窗口，前面放不下的条目移出喵
  while index_to_display >= last_visible_index {
    height_from_offset = (height_from_offset +
    self.items[last_visible_index].height()).clamp(
      min=0,
      max=height_from_offset + self.items[last_visible_index].height(),
    )
    last_visible_index += 1
    while height_from_offset > max_height {
      height_from_offset -= self.items[first_visible_index].height()
      if height_from_offset < 0 {
        height_from_offset = 0
      }
      first_visible_index += 1
    }
  }
  // 选中项在可视区之前：向前扩展窗口，尾部放不下的条目移出喵
  while index_to_display < first_visible_index {
    first_visible_index -= 1
    height_from_offset += self.items[first_visible_index].height()
    while height_from_offset > max_height {
      last_visible_index -= 1
      height_from_offset -= self.items[last_visible_index].height()
      if height_from_offset < 0 {
        height_from_offset = 0
      }
    }
  }
  (first_visible_index, last_visible_index)
}

///|
/// 按滚动边距收敛选中项索引（包私有，上游
/// `apply_scroll_padding_to_selected_index`）喵。
fn List::apply_scroll_padding_to_selected_index(
  self : List,
  selected : Int?,
  max_height : Int,
  first_visible_index : Int,
  last_visible_index : Int,
) -> Int? {
  let selected = match selected {
    Some(s) => {
      let last_valid_index = self.items.length() - 1
      if s < last_valid_index {
        s
      } else {
        last_valid_index
      }
    }
    None => return None
  }
  let last_valid_index = self.items.length() - 1
  // 条目高度不一致时逐步收缩边距，保证偏移稳定喵
  let mut scroll_padding = self.scroll_padding
  while scroll_padding > 0 {
    let mut height_around_selected = 0
    let lo = if selected - scroll_padding > 0 {
      selected - scroll_padding
    } else {
      0
    }
    let hi = if selected + scroll_padding < last_valid_index {
      selected + scroll_padding
    } else {
      last_valid_index
    }
    for index in lo..<=hi {
      height_around_selected += self.items[index].height()
    }
    if height_around_selected <= max_height {
      break
    }
    scroll_padding -= 1
  }
  let upper = if selected + scroll_padding < last_valid_index {
    selected + scroll_padding
  } else {
    last_valid_index
  }
  let lower = if selected - scroll_padding > 0 {
    selected - scroll_padding
  } else {
    0
  }
  let chosen = if upper >= last_visible_index {
    upper
  } else if lower < first_visible_index {
    lower
  } else {
    selected
  }
  Some(chosen.clamp(min=0, max=last_valid_index))
}

///|
/// 点调用提升声明（MoonBit extend 惯用法）喵。
pub extend List with @core.Widget::{render}
