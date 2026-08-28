///|
/// 列表方向（上游 `list::ListDirection`）喵。
pub(all) enum ListDirection {
  TopToBottom
  BottomToTop
} derive(Eq, Debug)

///|
/// Display 语义（上游 strum Display：变体名）喵。
pub fn ListDirection::to_display(self : ListDirection) -> String {
  match self {
    TopToBottom => "TopToBottom"
    BottomToTop => "BottomToTop"
  }
}

///|
/// 高亮符号与单元格间距策略（上游 `table::HighlightSpacing`，
/// List 与 Table 共用；随 Table 复刻迁至共享位置）喵。
pub(all) enum HighlightSpacing {
  Always
  WhenSelected
  Never
} derive(Eq, Debug)

///|
/// 是否为本次渲染预留高亮符号列（上游 `HighlightSpacing::should_add`）喵。
pub fn HighlightSpacing::should_add(
  self : HighlightSpacing,
  has_selection : Bool,
) -> Bool {
  match self {
    Always => true
    WhenSelected => has_selection
    Never => false
  }
}

///|
/// 列表项（上游 `list::ListItem`）：多行文本 + 项级样式喵。
pub(all) struct ListItem {
  content : @core.Text
  style : @core.Style
} derive(Eq, Debug)

///|
/// 从文本构造列表项（上游 `ListItem::new`）喵。
pub fn ListItem::of(content : @core.Text) -> ListItem {
  { content, style: @core.Style::new() }
}

///|
/// 从单行字符串构造列表项喵。
pub fn ListItem::of_str(content : String) -> ListItem {
  ListItem::of(@core.Text::raw(content))
}

///|
/// 从单 span 构造列表项喵。
pub fn ListItem::of_span(span : @core.Span) -> ListItem {
  ListItem::of(@core.Text::of_span(span))
}

///|
/// 设项级样式（上游 `ListItem::style`）喵。
pub fn ListItem::style(self : ListItem, style : @core.Style) -> ListItem {
  { ..self, style, }
}

///|
/// 项高度 = 文本行数（上游 `ListItem::height`）喵。
pub fn ListItem::height(self : ListItem) -> Int {
  self.content.height()
}

///|
/// 项宽度 = 文本最大行宽（上游 `ListItem::width`）喵。
pub fn ListItem::width(self : ListItem) -> Int {
  self.content.width()
}

///|
/// 列表状态（上游 `list::ListState`）：滚动偏移 + 选中项喵。
///
/// `select(None)` 会同时把偏移归零；`select_next/previous` 从未选中
/// 状态出发分别落到 0 / 最大索引喵。
pub(all) struct ListState {
  mut offset : Int
  mut selected : Int?
} derive(Eq, Debug)

///|
/// 构造状态（上游 `ListState::default`）喵。
pub fn ListState::new() -> ListState {
  { offset: 0, selected: None }
}

///|
/// 设偏移（上游 `ListState::with_offset`）喵。
pub fn ListState::with_offset(self : ListState, offset : Int) -> ListState {
  { ..self, offset, }
}

///|
/// 设选中项（上游 `ListState::with_selected`）喵。
pub fn ListState::with_selected(self : ListState, selected : Int?) -> ListState {
  { ..self, selected, }
}

///|
/// 读选中项（上游 `ListState::selected`）喵。
pub fn ListState::selected(self : ListState) -> Int? {
  self.selected
}

///|
/// 选中/取消选中；取消时偏移归零（上游 `ListState::select`）喵。
pub fn ListState::select(self : ListState, index : Int?) -> Unit {
  self.selected = index
  if index is None {
    self.offset = 0
  }
}

///|
/// 选中下一项；未选中时落到 0（上游 `ListState::select_next`）喵。
pub fn ListState::select_next(self : ListState) -> Unit {
  let next = match self.selected {
    Some(i) => if i < MAX_LIST_INDEX { i + 1 } else { MAX_LIST_INDEX }
    None => 0
  }
  self.select(Some(next))
}

///|
/// 选中上一项；未选中时落到最大索引（上游 `ListState::select_previous`）喵。
pub fn ListState::select_previous(self : ListState) -> Unit {
  let previous = match self.selected {
    Some(i) => if i > 0 { i - 1 } else { 0 }
    None => MAX_LIST_INDEX
  }
  self.select(Some(previous))
}

///|
/// 选中首项（上游 `ListState::select_first`）喵。
pub fn ListState::select_first(self : ListState) -> Unit {
  self.select(Some(0))
}

///|
/// 选中末项（上游 `ListState::select_last`）喵。
pub fn ListState::select_last(self : ListState) -> Unit {
  self.select(Some(MAX_LIST_INDEX))
}

///|
/// 向下滚动 N 项（未选中视为 0，上游 `ListState::scroll_down_by`）喵。
pub fn ListState::scroll_down_by(self : ListState, amount : Int) -> Unit {
  let selected = match self.selected {
    Some(i) => i
    None => 0
  }
  self.select(
    Some(
      if selected + amount < MAX_LIST_INDEX {
        selected + amount
      } else {
        MAX_LIST_INDEX
      },
    ),
  )
}

///|
/// 向上滚动 N 项（未选中视为 0，饱和不出界，上游
/// `ListState::scroll_up_by`）喵。
pub fn ListState::scroll_up_by(self : ListState, amount : Int) -> Unit {
  let selected = match self.selected {
    Some(i) => i
    None => 0
  }
  self.select(Some(if selected - amount > 0 { selected - amount } else { 0 }))
}

///|
/// 状态索引域上限（对位上游 usize::MAX 语义；本库坐标为 Int 域，
/// 取 i32 域最大值喵）。
const MAX_LIST_INDEX : Int = 2147483647
