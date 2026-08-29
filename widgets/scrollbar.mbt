/// Scrollbar（上游 `widgets/scrollbar.rs`）：环绕区域边缘的滚动条，
/// 含方向/位置状态机与"轨道起段 + 滑块 + 轨道末段"三段长度分配喵。

///|
/// 滚动条环绕方位（上游 `ScrollbarOrientation`）喵。
pub(all) enum ScrollbarOrientation {
  VerticalRight
  VerticalLeft
  HorizontalBottom
  HorizontalTop
} derive(Eq, Debug)

///|
/// 是否纵向（上游 `ScrollbarOrientation::is_vertical`）喵。
pub fn ScrollbarOrientation::is_vertical(self : ScrollbarOrientation) -> Bool {
  match self {
    VerticalRight | VerticalLeft => true
    HorizontalBottom | HorizontalTop => false
  }
}

///|
/// 是否横向（上游 `ScrollbarOrientation::is_horizontal`）喵。
pub fn ScrollbarOrientation::is_horizontal(self : ScrollbarOrientation) -> Bool {
  match self {
    HorizontalBottom | HorizontalTop => true
    VerticalRight | VerticalLeft => false
  }
}

///|
/// 转显示名（上游 `Display`）喵。
pub fn ScrollbarOrientation::to_display(self : ScrollbarOrientation) -> String {
  match self {
    VerticalRight => "VerticalRight"
    VerticalLeft => "VerticalLeft"
    HorizontalBottom => "HorizontalBottom"
    HorizontalTop => "HorizontalTop"
  }
}

///|
/// 从变体名解析（上游 `FromStr`，大小写敏感）喵。
pub fn ScrollbarOrientation::from_str(s : String) -> ScrollbarOrientation? {
  match s {
    "VerticalRight" => Some(VerticalRight)
    "VerticalLeft" => Some(VerticalLeft)
    "HorizontalBottom" => Some(HorizontalBottom)
    "HorizontalTop" => Some(HorizontalTop)
    _ => None
  }
}

///|
/// 滚动方向（上游 `ScrollDirection`，供 `ScrollbarState::scroll`）喵。
pub(all) enum ScrollDirection {
  Forward
  Backward
} derive(Eq, Debug)

///|
/// 转显示名（上游 `Display`）喵。
pub fn ScrollDirection::to_display(self : ScrollDirection) -> String {
  match self {
    Forward => "Forward"
    Backward => "Backward"
  }
}

///|
/// 从变体名解析（上游 `FromStr`，大小写敏感）喵。
pub fn ScrollDirection::from_str(s : String) -> ScrollDirection? {
  match s {
    "Forward" => Some(Forward)
    "Backward" => Some(Backward)
    _ => None
  }
}

///|
/// 滚动条状态（上游 `ScrollbarState`）：内容总长、当前位置与视口
/// 内容长度。`content_length` 为 0 时整条不渲染喵。
pub(all) struct ScrollbarState {
  mut content_length : Int
  mut position : Int
  mut viewport_content_length : Int
} derive(Eq, Debug)

///|
/// 以内容总长构造（上游 `ScrollbarState::new`，位置与视口长度为 0）喵。
pub fn ScrollbarState::new(content_length : Int) -> ScrollbarState {
  { content_length, position: 0, viewport_content_length: 0 }
}

///|
/// 设滚动位置（上游 `ScrollbarState::position` 的 builder 形态）喵。
pub fn ScrollbarState::with_position(
  self : ScrollbarState,
  position : Int,
) -> ScrollbarState {
  { ..self, position, }
}

///|
/// 设内容总长（上游 `ScrollbarState::content_length` 的 builder 形态）喵。
pub fn ScrollbarState::with_content_length(
  self : ScrollbarState,
  content_length : Int,
) -> ScrollbarState {
  { ..self, content_length, }
}

///|
/// 设视口内容长度（上游 `viewport_content_length` 的 builder 形态；
/// 0 表示回退用轨道长度充当视口长度）喵。
pub fn ScrollbarState::with_viewport_content_length(
  self : ScrollbarState,
  viewport_content_length : Int,
) -> ScrollbarState {
  { ..self, viewport_content_length, }
}

///|
/// 位置回退一格，不低于 0（上游 `prev`）喵。
pub fn ScrollbarState::prev(self : ScrollbarState) -> Unit {
  if self.position > 0 {
    self.position = self.position - 1
  }
}

///|
/// 位置前进一格，钳制到 `content_length - 1`（上游 `next`）喵。
pub fn ScrollbarState::next(self : ScrollbarState) -> Unit {
  let max_position = if self.content_length > 0 {
    self.content_length - 1
  } else {
    0
  }
  self.position = if self.position + 1 < max_position {
    self.position + 1
  } else {
    max_position
  }
}

///|
/// 位置归零（上游 `first`）喵。
pub fn ScrollbarState::first(self : ScrollbarState) -> Unit {
  self.position = 0
}

///|
/// 位置到末尾 `content_length - 1`（上游 `last`）喵。
pub fn ScrollbarState::last(self : ScrollbarState) -> Unit {
  self.position = if self.content_length > 0 {
    self.content_length - 1
  } else {
    0
  }
}

///|
/// 按方向滚动一格（上游 `scroll`）喵。
pub fn ScrollbarState::scroll(
  self : ScrollbarState,
  direction : ScrollDirection,
) -> Unit {
  match direction {
    Forward => self.next()
    Backward => self.prev()
  }
}

///|
/// 读当前位置（上游 `get_position`）喵。
pub fn ScrollbarState::get_position(self : ScrollbarState) -> Int {
  self.position
}

///|
/// 滚动条（上游 `widgets::Scrollbar`）：thumb/track/begin/end 的符号
/// 与样式独立可配；track/begin/end 可显式置 `None` 关闭喵。
pub(all) struct Scrollbar {
  orientation : ScrollbarOrientation
  thumb_style : @core.Style
  thumb_symbol : String
  track_style : @core.Style
  track_symbol : String?
  begin_style : @core.Style
  begin_symbol : String?
  end_style : @core.Style
  end_symbol : String?
} derive(Eq, Debug)

///|
/// 以方位构造（上游 `Scrollbar::new`：纵向配双竖集合、横向配双横
/// 集合）喵。
pub fn Scrollbar::new(orientation : ScrollbarOrientation) -> Scrollbar {
  let symbols = if orientation.is_vertical() {
    @core.ScrollbarSet::double_vertical()
  } else {
    @core.ScrollbarSet::double_horizontal()
  }
  Scrollbar::new_with_symbols(orientation, symbols)
}

///|
/// 以方位与符号集合构造（包私有，上游 `new_with_symbols`）喵。
fn Scrollbar::new_with_symbols(
  orientation : ScrollbarOrientation,
  symbols : @core.ScrollbarSet,
) -> Scrollbar {
  {
    orientation,
    thumb_symbol: symbols.thumb,
    thumb_style: @core.Style::new(),
    track_symbol: Some(symbols.track),
    track_style: @core.Style::new(),
    begin_symbol: Some(symbols.begin),
    begin_style: @core.Style::new(),
    end_symbol: Some(symbols.end),
    end_style: @core.Style::new(),
  }
}

///|
/// 换方位并按纵向/横向重置缺省符号（上游 `Scrollbar::orientation`；
/// 已显式置 `None` 的 track/begin/end 保持关闭）喵。
pub fn Scrollbar::orientation(
  self : Scrollbar,
  orientation : ScrollbarOrientation,
) -> Scrollbar {
  let symbols = if orientation.is_vertical() {
    @core.ScrollbarSet::double_vertical()
  } else {
    @core.ScrollbarSet::double_horizontal()
  }
  let scrollbar = { ..self, orientation, }
  scrollbar.symbols(symbols)
}

///|
/// 换方位并整组换符号（上游 `Scrollbar::orientation_and_symbol`）喵。
pub fn Scrollbar::orientation_and_symbol(
  self : Scrollbar,
  orientation : ScrollbarOrientation,
  symbols : @core.ScrollbarSet,
) -> Scrollbar {
  let scrollbar = { ..self, orientation, }
  scrollbar.symbols(symbols)
}

///|
/// 设滑块符号（上游 `Scrollbar::thumb_symbol`）喵。
pub fn Scrollbar::thumb_symbol(self : Scrollbar, symbol : String) -> Scrollbar {
  { ..self, thumb_symbol: symbol }
}

///|
/// 设滑块样式（上游 `Scrollbar::thumb_style`）喵。
pub fn Scrollbar::thumb_style(
  self : Scrollbar,
  style : @core.Style,
) -> Scrollbar {
  { ..self, thumb_style: style }
}

///|
/// 设轨道符号（`None` 关闭轨道，上游 `Scrollbar::track_symbol`）喵。
pub fn Scrollbar::track_symbol(self : Scrollbar, symbol : String?) -> Scrollbar {
  { ..self, track_symbol: symbol }
}

///|
/// 设轨道样式（上游 `Scrollbar::track_style`）喵。
pub fn Scrollbar::track_style(
  self : Scrollbar,
  style : @core.Style,
) -> Scrollbar {
  { ..self, track_style: style }
}

///|
/// 设起点箭头符号（`None` 关闭，上游 `Scrollbar::begin_symbol`）喵。
pub fn Scrollbar::begin_symbol(self : Scrollbar, symbol : String?) -> Scrollbar {
  { ..self, begin_symbol: symbol }
}

///|
/// 设起点箭头样式（上游 `Scrollbar::begin_style`）喵。
pub fn Scrollbar::begin_style(
  self : Scrollbar,
  style : @core.Style,
) -> Scrollbar {
  { ..self, begin_style: style }
}

///|
/// 设终点箭头符号（`None` 关闭，上游 `Scrollbar::end_symbol`）喵。
pub fn Scrollbar::end_symbol(self : Scrollbar, symbol : String?) -> Scrollbar {
  { ..self, end_symbol: symbol }
}

///|
/// 设终点箭头样式（上游 `Scrollbar::end_style`）喵。
pub fn Scrollbar::end_style(self : Scrollbar, style : @core.Style) -> Scrollbar {
  { ..self, end_style: style }
}

///|
/// 整组换符号（上游 `Scrollbar::symbols`）：仅当 track/begin/end 当前
/// 有值才替换，显式关闭的不复活；thumb 无条件替换喵。
pub fn Scrollbar::symbols(
  self : Scrollbar,
  symbols : @core.ScrollbarSet,
) -> Scrollbar {
  {
    ..self,
    thumb_symbol: symbols.thumb,
    track_symbol: match self.track_symbol {
      Some(_) => Some(symbols.track)
      None => None
    },
    begin_symbol: match self.begin_symbol {
      Some(_) => Some(symbols.begin)
      None => None
    },
    end_symbol: match self.end_symbol {
      Some(_) => Some(symbols.end)
      None => None
    },
  }
}

///|
/// 整组设四段样式（上游 `Scrollbar::style`）喵。
pub fn Scrollbar::style(self : Scrollbar, style : @core.Style) -> Scrollbar {
  {
    ..self,
    track_style: style,
    thumb_style: style,
    begin_style: style,
    end_style: style,
  }
}

///|
/// 渲染滚动条（带状态，上游 `StatefulWidget for Scrollbar`）喵。
///
/// `state` 为引用语义结构体喵。内容总长为 0 或去掉箭头后的轨道
/// 长度为 0 时整条跳过。
pub fn Scrollbar::render_stateful(
  self : Scrollbar,
  area : @core.Rect,
  buf : @core.Buffer,
  state : ScrollbarState,
) -> Unit {
  if state.content_length == 0 ||
    self.track_length_excluding_arrow_heads(area) == 0 {
    return
  }
  let bar_area = self.scrollbar_area(area)
  let symbols = self.bar_symbols(bar_area, state)
  for i, cell in symbols {
    let (x, y) = if self.orientation.is_vertical() {
      (bar_area.left(), bar_area.top() + i)
    } else {
      (bar_area.left() + i, bar_area.top())
    }
    match cell {
      Some((symbol, style)) => ignore(buf.set_string(x, y, symbol, style))
      None => ()
    }
  }
}

///|
/// 滚动条占据的单行/单列子区域（包私有，上游 `scrollbar_area`）：
/// 纵向取首/末列，横向取首/末行喵。
fn Scrollbar::scrollbar_area(self : Scrollbar, area : @core.Rect) -> @core.Rect {
  match self.orientation {
    VerticalLeft => @core.Rect::new(area.left(), area.top(), 1, area.height)
    VerticalRight =>
      @core.Rect::new(area.right() - 1, area.top(), 1, area.height)
    HorizontalTop => @core.Rect::new(area.left(), area.top(), area.width, 1)
    HorizontalBottom =>
      @core.Rect::new(area.left(), area.bottom() - 1, area.width, 1)
  }
}

///|
/// 逐格符号序列：begin + 轨道(前段) + thumb + 轨道(后段) + end，
/// 已关闭的分量为 `None` 占位跳写（包私有，上游 `bar_symbols`）喵。
fn Scrollbar::bar_symbols(
  self : Scrollbar,
  area : @core.Rect,
  state : ScrollbarState,
) -> Array[(String, @core.Style)?] {
  let (track_start_len, thumb_len, track_end_len) = self.part_lengths(
    area, state,
  )
  let track_cell : (String, @core.Style)? = match self.track_symbol {
    Some(s) => Some((s, self.track_style))
    None => None
  }
  let out : Array[(String, @core.Style)?] = []
  // 上游 flatten 语义：begin/end 关闭时不占序列槽位；track 关闭时
  // 仍占槽位（跳写）喵。
  match self.begin_symbol {
    Some(s) => out.push(Some((s, self.begin_style)))
    None => ()
  }
  for _ in 0..<track_start_len {
    out.push(track_cell)
  }
  for _ in 0..<thumb_len {
    out.push(Some((self.thumb_symbol, self.thumb_style)))
  }
  for _ in 0..<track_end_len {
    out.push(track_cell)
  }
  match self.end_symbol {
    Some(s) => out.push(Some((s, self.end_style)))
    None => ()
  }
  out
}

///|
/// 三段长度分配（包私有，上游 `part_lengths`）：返回
/// `(轨道前段, 滑块, 轨道后段)`，四舍五入整除（0.5 进位）喵。
///
/// 滑块钳制在轨道内（`thumb_start + thumb_length <= track_length`），
/// 对位上游 issue #2582 修复：大滑块贴底时不再挤出 end 箭头喵。
fn Scrollbar::part_lengths(
  self : Scrollbar,
  area : @core.Rect,
  state : ScrollbarState,
) -> (Int, Int, Int) {
  let track_length = self.track_length_excluding_arrow_heads(area)
  if track_length == 0 {
    return (0, 0, 0)
  }
  let viewport_length = self.viewport_length(state, area)
  let max_position = if state.content_length > 0 {
    state.content_length - 1
  } else {
    0
  }
  let start_position = if state.position < 0 {
    0
  } else if state.position > max_position {
    max_position
  } else {
    state.position
  }
  let max_viewport_position = max_position + viewport_length
  if max_viewport_position == 0 {
    // 防除零：整条当滑块喵。
    return (0, track_length, 0)
  }
  let thumb_length = rounding_divide(
    viewport_length * track_length,
    max_viewport_position,
  ).clamp(min=1, max=track_length)
  let thumb_start = rounding_divide(
    start_position * track_length,
    max_viewport_position,
  ).clamp(min=0, max=track_length - thumb_length)
  let track_end = track_length - (thumb_start + thumb_length)
  (thumb_start, thumb_length, track_end)
}

///|
/// 去掉两端箭头后的轨道长度（包私有，上游
/// `track_length_excluding_arrow_heads`）喵。
fn Scrollbar::track_length_excluding_arrow_heads(
  self : Scrollbar,
  area : @core.Rect,
) -> Int {
  let start_len = match self.begin_symbol {
    Some(s) => @core.symbol_width(s)
    None => 0
  }
  let end_len = match self.end_symbol {
    Some(s) => @core.symbol_width(s)
    None => 0
  }
  let arrows_len = start_len + end_len
  if self.orientation.is_vertical() {
    if area.height > arrows_len {
      area.height - arrows_len
    } else {
      0
    }
  } else if area.width > arrows_len {
    area.width - arrows_len
  } else {
    0
  }
}

///|
/// 视口长度（包私有，上游 `viewport_length`）：优先显式
/// `viewport_content_length`，否则纵向用区域高、横向用区域宽喵。
fn Scrollbar::viewport_length(
  self : Scrollbar,
  state : ScrollbarState,
  area : @core.Rect,
) -> Int {
  if state.viewport_content_length != 0 {
    state.viewport_content_length
  } else if self.orientation.is_vertical() {
    area.height
  } else {
    area.width
  }
}

///|
/// 四舍五入整除（包私有，上游 `rounding_divide`：`(n + d/2) / d`，
/// 0.5 向上进位；调用方保证 `d > 0`）喵。
fn rounding_divide(numerator : Int, denominator : Int) -> Int {
  (numerator + denominator / 2) / denominator
}
