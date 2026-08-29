///|
/// 即时模式 widget 集喵。
///
/// widget 全部无状态：`render(area, buf)` 把自己画进缓冲即结束，
/// 无 retained 树、无响应式订阅——这正是与 vDOM 路线的分野喵。

///|
/// 标题位置（上游 `widgets::TitlePosition`）喵。
pub(all) enum TitlePosition {
  Top
  Bottom
} derive(Eq, Debug)

///|
/// 边框 + 标题 + 内边距的容器块（上游 `widgets::Block`）喵。
///
/// 渲染分层：基样式铺满区域 → 边框（边线先、四角后）→ 标题
/// （标题写在已染色的边框格上，样式按 patch 语义叠加）。
/// `inner` 计算 border/标题/padding 扣除后的内容区，供嵌套
/// widget 使用喵。
///
/// 渲染末段还叠加可选 `shadow` 阴影层（上游 `Block::shadow`）喵。
pub(all) struct Block {
  titles : Array[(TitlePosition?, @core.Line)]
  titles_style : @core.Style
  titles_alignment : @core.Alignment
  titles_position : TitlePosition
  borders : Borders
  border_style : @core.Style
  border_set : @core.BorderSet
  style : @core.Style
  padding : Padding
  merge_borders : @core.MergeStrategy
  shadow : Shadow?
} derive(Eq, Debug)

///|
/// 无边框无标题的块（上游 `Block::new`）喵。
pub fn Block::new() -> Block {
  {
    titles: [],
    titles_style: @core.Style::new(),
    titles_alignment: @core.Alignment::Left,
    titles_position: Top,
    borders: Borders::empty(),
    border_style: @core.Style::new(),
    border_set: BorderType::Plain.to_border_set(),
    style: @core.Style::new(),
    padding: Padding::zero(),
    merge_borders: Replace,
    shadow: None,
  }
}

///|
/// 四边全边框的块（上游 `Block::bordered`）喵。
pub fn Block::bordered() -> Block {
  Block::new().borders(Borders::all())
}

///|
/// 追加标题，位置承 `titles_position`（上游 `Block::title`）喵。
pub fn Block::title(self : Block, line : @core.Line) -> Block {
  let titles = self.titles.iter().collect()
  titles.push((None, line))
  { ..self, titles, }
}

///|
/// 追加字符串标题（上游 `title` 的 `Into<Line>` 形态）喵。
pub fn Block::title_str(self : Block, content : String) -> Block {
  self.title(@core.Line::raw(content))
}

///|
/// 追加顶部标题（上游 `Block::title_top`）喵。
pub fn Block::title_top(self : Block, line : @core.Line) -> Block {
  let titles = self.titles.iter().collect()
  titles.push((Some(Top), line))
  { ..self, titles, }
}

///|
/// 追加顶部字符串标题喵。
pub fn Block::title_top_str(self : Block, content : String) -> Block {
  self.title_top(@core.Line::raw(content))
}

///|
/// 追加底部标题（上游 `Block::title_bottom`）喵。
pub fn Block::title_bottom(self : Block, line : @core.Line) -> Block {
  let titles = self.titles.iter().collect()
  titles.push((Some(Bottom), line))
  { ..self, titles, }
}

///|
/// 追加底部字符串标题喵。
pub fn Block::title_bottom_str(self : Block, content : String) -> Block {
  self.title_bottom(@core.Line::raw(content))
}

///|
/// 设未显式指定位置标题的缺省位置（上游 `Block::title_position`）喵。
pub fn Block::title_position(self : Block, position : TitlePosition) -> Block {
  { ..self, titles_position: position }
}

///|
/// 设未显式指定对齐标题的缺省对齐（上游 `Block::title_alignment`）喵。
pub fn Block::title_alignment(
  self : Block,
  alignment : @core.Alignment,
) -> Block {
  { ..self, titles_alignment: alignment }
}

///|
/// 设块后阴影（上游 `Block::shadow`）：渲染于块区域加阴影偏移
/// 的区域喵。
pub fn Block::shadow(self : Block, shadow : Shadow) -> Block {
  { ..self, shadow: Some(shadow) }
}

///|
/// 设全部标题统一叠加的样式（上游 `Block::title_style`）喵。
pub fn Block::title_style(self : Block, style : @core.Style) -> Block {
  { ..self, titles_style: style }
}

///|
/// 设可见边框（上游 `Block::borders`）喵。
pub fn Block::borders(self : Block, borders : Borders) -> Block {
  { ..self, borders, }
}

///|
/// 设边框样式（上游 `Block::border_style`）喵。
pub fn Block::border_style(self : Block, style : @core.Style) -> Block {
  { ..self, border_style: style }
}

///|
/// 按线型设边框符号（上游 `Block::border_type`）喵。
pub fn Block::border_type(self : Block, border_type : BorderType) -> Block {
  { ..self, border_set: border_type.to_border_set() }
}

///|
/// 直接设边框符号集（上游 `Block::border_set`）喵。
pub fn Block::border_set(self : Block, set : @core.BorderSet) -> Block {
  { ..self, border_set: set }
}

///|
/// 设边框合并策略，供相邻块边框折叠（上游 `Block::merge_borders`）喵。
pub fn Block::merge_borders(
  self : Block,
  strategy : @core.MergeStrategy,
) -> Block {
  { ..self, merge_borders: strategy }
}

///|
/// 设基样式（渲染时铺满整个区域，上游 `Block::style`）喵。
pub fn Block::style(self : Block, style : @core.Style) -> Block {
  { ..self, style, }
}

///|
/// 设内边距（上游 `Block::padding`）喵。
pub fn Block::padding(self : Block, padding : Padding) -> Block {
  { ..self, padding, }
}

///|
/// 指定位置是否有标题（含承 `titles_position` 的缺省，包私有）喵。
fn Block::has_title_at_position(self : Block, position : TitlePosition) -> Bool {
  for entry in self.titles {
    let (pos, _) = entry
    let effective = match pos {
      Some(p) => p
      None => self.titles_position
    }
    if effective == position {
      return true
    }
  }
  false
}

///|
/// 计算 border/标题/padding 扣除后的内容区（上游 `Block::inner`），
/// 退化时优雅收敛为空区域喵。
pub fn Block::inner(self : Block, area : @core.Rect) -> @core.Rect {
  let mut inner_x = area.x
  let mut inner_y = area.y
  let mut inner_width = area.width
  let mut inner_height = area.height
  if self.borders.intersects(Borders::left()) {
    inner_x = (inner_x + 1).clamp(min=0, max=area.right())
    inner_width = (inner_width - 1).clamp(min=0, max=inner_width)
  }
  if self.borders.intersects(Borders::top()) || self.has_title_at_position(Top) {
    inner_y = (inner_y + 1).clamp(min=0, max=area.bottom())
    inner_height = (inner_height - 1).clamp(min=0, max=inner_height)
  }
  if self.borders.intersects(Borders::right()) {
    inner_width = (inner_width - 1).clamp(min=0, max=inner_width)
  }
  if self.borders.intersects(Borders::bottom()) ||
    self.has_title_at_position(Bottom) {
    inner_height = (inner_height - 1).clamp(min=0, max=inner_height)
  }
  let horizontal_padding = self.padding.left + self.padding.right
  let vertical_padding = self.padding.top + self.padding.bottom
  inner_x += self.padding.left
  inner_y += self.padding.top
  inner_width = (inner_width - horizontal_padding).clamp(min=0, max=inner_width)
  inner_height = (inner_height - vertical_padding).clamp(
    min=0,
    max=inner_height,
  )
  @core.Rect::new(inner_x, inner_y, inner_width, inner_height)
}

///|
/// 渲染块（上游 `Widget for &Block`）喵。
impl @core.Widget for Block with fn render(
  self : Block,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let area = buf.area.intersection(area)
  if area.is_empty() {
    return
  }
  buf.set_style(area, self.style)
  self.render_borders(area, buf)
  self.render_titles(area, buf)
  match self.shadow {
    Some(shadow) => shadow.render(area, buf)
    None => ()
  }
}

///|
/// 渲染边框：边线先、四角后（角压线，包私有）喵。
fn Block::render_borders(
  self : Block,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  self.render_sides(area, buf)
  self.render_corners(area, buf)
}

///|
/// 渲染四条边线；同格冲突时按 左→上→右→下 的顺序覆写（包私有）喵。
fn Block::render_sides(
  self : Block,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let left = area.left()
  let top = area.top()
  let right = area.right() - 1
  let bottom = area.bottom() - 1
  fn put(x : Int, y : Int, symbol : String) -> Unit {
    match buf.mut_cell(x, y) {
      Some(cell) => {
        cell.merge_symbol(symbol, self.merge_borders)
        cell.set_style(self.border_style)
      }
      None => ()
    }
  }
  // 非 Replace 策略时边线端点不画：边线与角符号的某些合并组合
  // 不产生正确字符，端点交由角符号直接落格（上游 inset 语义）喵
  let non_replace = !(self.merge_borders is Replace)
  let left_inset_amount = if non_replace &&
    self.borders.contains(Borders::left()) {
    1
  } else {
    0
  }
  let top_inset_amount = if non_replace && self.borders.contains(Borders::top()) {
    1
  } else {
    0
  }
  let right_inset_amount = if non_replace &&
    self.borders.contains(Borders::right()) {
    1
  } else {
    0
  }
  let bottom_inset_amount = if non_replace &&
    self.borders.contains(Borders::bottom()) {
    1
  } else {
    0
  }
  let left_inset = left + left_inset_amount
  let top_inset = top + top_inset_amount
  let right_inset = right - right_inset_amount
  let bottom_inset = bottom - bottom_inset_amount
  if self.borders.contains(Borders::left()) {
    for y in top_inset..<=bottom_inset {
      put(left, y, self.border_set.vertical_left)
    }
  }
  if self.borders.contains(Borders::top()) {
    for x in left_inset..<=right_inset {
      put(x, top, self.border_set.horizontal_top)
    }
  }
  if self.borders.contains(Borders::right()) {
    for y in top_inset..<=bottom_inset {
      put(right, y, self.border_set.vertical_right)
    }
  }
  if self.borders.contains(Borders::bottom()) {
    for x in left_inset..<=right_inset {
      put(x, bottom, self.border_set.horizontal_bottom)
    }
  }
}

///|
/// 渲染四角：右下→右上→左下→左上（包私有）喵。
fn Block::render_corners(
  self : Block,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let left = area.left()
  let top = area.top()
  let right = area.right() - 1
  let bottom = area.bottom() - 1
  fn put(x : Int, y : Int, symbol : String) -> Unit {
    match buf.mut_cell(x, y) {
      Some(cell) => {
        cell.merge_symbol(symbol, self.merge_borders)
        cell.set_style(self.border_style)
      }
      None => ()
    }
  }
  if self.borders.contains(Borders::right().union(Borders::bottom())) {
    put(right, bottom, self.border_set.bottom_right)
  }
  if self.borders.contains(Borders::right().union(Borders::top())) {
    put(right, top, self.border_set.top_right)
  }
  if self.borders.contains(Borders::left().union(Borders::bottom())) {
    put(left, bottom, self.border_set.bottom_left)
  }
  if self.borders.contains(Borders::left().union(Borders::top())) {
    put(left, top, self.border_set.top_left)
  }
}

///|
/// 渲染标题：先上后下（包私有）喵。
fn Block::render_titles(
  self : Block,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  self.render_title_position(Top, area, buf)
  self.render_title_position(Bottom, area, buf)
}

///|
/// 渲染指定位置的标题；调用顺序决定覆盖行为：左→中→右
/// （包私有，上游 `render_title_position`）喵。
fn Block::render_title_position(
  self : Block,
  position : TitlePosition,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  self.render_left_titles(position, area, buf)
  self.render_center_titles(position, area, buf)
  self.render_right_titles(position, area, buf)
}

///|
/// 筛选指定位置与对齐的标题（包私有，上游 `filtered_titles`）喵。
fn Block::filtered_titles(
  self : Block,
  position : TitlePosition,
  alignment : @core.Alignment,
) -> Array[@core.Line] {
  let out : Array[@core.Line] = []
  for entry in self.titles {
    let (pos, line) = entry
    let effective_position = match pos {
      Some(p) => p
      None => self.titles_position
    }
    let effective_alignment = match line.alignment {
      Some(a) => a
      None => self.titles_alignment
    }
    if effective_position == position && effective_alignment == alignment {
      out.push(line)
    }
  }
  out
}

///|
/// 标题行区域：单行高、宽度扣除左右边框（包私有）喵。
fn Block::titles_area(
  self : Block,
  area : @core.Rect,
  position : TitlePosition,
) -> @core.Rect {
  let left_border = if self.borders.contains(Borders::left()) { 1 } else { 0 }
  let right_border = if self.borders.contains(Borders::right()) { 1 } else { 0 }
  let y = match position {
    Top => area.top()
    Bottom => area.bottom() - 1
  }
  @core.Rect::new(
    area.left() + left_border,
    y,
    (area.width - left_border - right_border).clamp(min=0, max=area.width),
    1,
  )
}

///|
/// 渲染左对齐标题：依次左排，标题间留 1 列空隙（包私有）喵。
fn Block::render_left_titles(
  self : Block,
  position : TitlePosition,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let titles = self.filtered_titles(position, @core.Alignment::Left)
  let mut titles_area = self.titles_area(area, position)
  for title in titles {
    if titles_area.is_empty() {
      break
    }
    let title_width = title.width()
    let title_area = @core.Rect::new(
      titles_area.x,
      titles_area.y,
      title_width.clamp(min=0, max=titles_area.width),
      titles_area.height,
    )
    buf.set_style(title_area, self.titles_style)
    title.render(title_area, buf)
    let advance = title_width + 1
    titles_area = @core.Rect::new(
      titles_area.x + advance,
      titles_area.y,
      (titles_area.width - advance).clamp(min=0, max=titles_area.width),
      titles_area.height,
    )
  }
}

///|
/// 渲染居中标题（包私有）喵。
fn Block::render_center_titles(
  self : Block,
  position : TitlePosition,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let titles_area = self.titles_area(area, position)
  let titles = self.filtered_titles(position, @core.Alignment::Center)
  // 标题间 1 列空隙，末尾不计
  let mut total_width = 0
  for title in titles {
    total_width += title.width() + 1
  }
  if total_width > 0 {
    total_width -= 1
  }
  if total_width <= titles_area.width {
    self.render_centered_titles_without_truncation(
      titles, total_width, titles_area, buf,
    )
  } else {
    self.render_centered_titles_with_truncation(
      titles, total_width, titles_area, buf,
    )
  }
}

///|
/// 渲染放得下的居中标题组（包私有）喵。
fn Block::render_centered_titles_without_truncation(
  self : Block,
  titles : Array[@core.Line],
  total_width : Int,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let mut area = area
  let indent = (area.width - total_width) / 2
  area = @core.Rect::new(area.left() + indent, area.y, area.width, area.height)
  for title in titles {
    let width = title.width()
    let title_area = @core.Rect::new(
      area.x,
      area.y,
      width.clamp(min=0, max=area.width),
      area.height,
    )
    buf.set_style(title_area, self.titles_style)
    title.render(title_area, buf)
    let advance = width + 1
    area = @core.Rect::new(
      area.x + advance,
      area.y,
      (area.width - advance).clamp(min=0, max=area.width),
      area.height,
    )
  }
}

///|
/// 渲染放不下的居中标题组：左侧按整字形裁剪（包私有）喵。
fn Block::render_centered_titles_with_truncation(
  self : Block,
  titles : Array[@core.Line],
  total_width : Int,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let mut area = area
  let mut offset = ((total_width - area.width) / 2).clamp(
    min=0,
    max=total_width,
  )
  for title in titles {
    if area.is_empty() {
      break
    }
    let width = (area.width.clamp(min=0, max=title.width()) - offset).clamp(
      min=0,
      max=area.width,
    )
    let title_area = @core.Rect::new(area.x, area.y, width, area.height)
    buf.set_style(title_area, self.titles_style)
    if offset > 0 {
      // 标题左侧被裁，右对齐渲染使可见部分对齐
      title.right_aligned().render(title_area, buf)
      offset = (offset - width - 1).clamp(min=0, max=offset)
    } else {
      title.left_aligned().render(title_area, buf)
    }
    let advance = width + 1
    area = @core.Rect::new(
      area.x + advance,
      area.y,
      (area.width - advance).clamp(min=0, max=area.width),
      area.height,
    )
  }
}

///|
/// 渲染右对齐标题：逆序右排（包私有）喵。
fn Block::render_right_titles(
  self : Block,
  position : TitlePosition,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let titles = self.filtered_titles(position, @core.Alignment::Right)
  let mut titles_area = self.titles_area(area, position)
  let count = titles.length()
  for i2 in 0..<count {
    let title = titles[count - 1 - i2]
    if titles_area.is_empty() {
      break
    }
    let title_width = title.width()
    let x = (titles_area.right() - title_width).clamp(
      min=titles_area.left(),
      max=titles_area.right(),
    )
    let title_area = @core.Rect::new(
      x,
      titles_area.y,
      title_width.clamp(min=0, max=titles_area.width),
      titles_area.height,
    )
    buf.set_style(title_area, self.titles_style)
    title.render(title_area, buf)
    titles_area = @core.Rect::new(
      titles_area.x,
      titles_area.y,
      (titles_area.width - title_width - 1).clamp(min=0, max=titles_area.width),
      titles_area.height,
    )
  }
}

///|
/// 块占用的水平空间（左右边框 + 左右 padding，上游 `horizontal_space`）喵。
pub fn Block::horizontal_space(self : Block) -> (Int, Int) {
  let left_border = if self.borders.contains(Borders::left()) { 1 } else { 0 }
  let right_border = if self.borders.contains(Borders::right()) { 1 } else { 0 }
  (self.padding.left + left_border, self.padding.right + right_border)
}

///|
/// 块占用的垂直空间（上下边框/标题 + 上下 padding，上游 `vertical_space`）喵。
pub fn Block::vertical_space(self : Block) -> (Int, Int) {
  let has_top = self.borders.contains(Borders::top()) ||
    self.has_title_at_position(Top)
  let has_bottom = self.borders.contains(Borders::bottom()) ||
    self.has_title_at_position(Bottom)
  let top_border = if has_top { 1 } else { 0 }
  let bottom_border = if has_bottom { 1 } else { 0 }
  (self.padding.top + top_border, self.padding.bottom + bottom_border)
}

///|
/// 点调用提升声明（MoonBit extend 惯用法）喵。
pub extend Block with @core.Widget::{render}
