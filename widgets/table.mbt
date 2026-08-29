/// Table 数据类型（上游 `table/cell.rs` + `table/row.rs`）喵。
///
/// 上游 `table::Cell`/`table::Row` 在 MoonBit 无嵌套命名空间，且
/// `Cell` 与 core 缓冲单元格撞名，故定名 `TableCell`/`TableRow` 喵。

///|
/// 表格单元格（上游 `table::Cell`）：承载 `Text` 内容与整体样式，
/// `column_span` 允许横跨多列喵。
pub(all) struct TableCell {
  content : @core.Text
  style : @core.Style
  column_span : Int
} derive(Eq, Debug)

///|
/// 以文本构造（上游 `Cell::new`，column_span 缺省 1）喵。
pub fn TableCell::new(content : @core.Text) -> TableCell {
  { content, style: @core.Style::new(), column_span: 1 }
}

///|
/// 以字符串构造（上游 `Cell::new` 的 `Into<Text>` 形态）喵。
pub fn TableCell::of_str(content : String) -> TableCell {
  TableCell::new(@core.Text::raw(content))
}

///|
/// 缺省构造（上游 `Cell::default`：空内容）喵。
pub fn TableCell::default() -> TableCell {
  TableCell::new(@core.Text::empty())
}

///|
/// 设内容（上游 `Cell::content`）喵。
pub fn TableCell::content(self : TableCell, content : @core.Text) -> TableCell {
  { ..self, content, }
}

///|
/// 设字符串内容（上游 `content` 的 `Into<Text>` 形态）喵。
pub fn TableCell::content_str(self : TableCell, content : String) -> TableCell {
  self.content(@core.Text::raw(content))
}

///|
/// 设列跨度（上游 `Cell::column_span`）喵。
pub fn TableCell::column_span(self : TableCell, column_span : Int) -> TableCell {
  { ..self, column_span, }
}

///|
/// 设单元格样式（上游 `Cell::style`：覆盖行样式、被内容样式覆盖）喵。
pub fn TableCell::style(self : TableCell, style : @core.Style) -> TableCell {
  { ..self, style, }
}

///|
/// 渲染单元格（包私有，上游 `Cell::render`：先染整体样式再渲染内容）喵。
fn TableCell::render(
  self : TableCell,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  buf.set_style(area, self.style)
  self.content.render(area, buf)
}

///|
/// 表格行（上游 `table::Row`）：单元格集合 + 固定高度 + 上下外边距
/// + 整行样式喵。
pub(all) struct TableRow {
  cells : Array[TableCell]
  height : Int
  top_margin : Int
  bottom_margin : Int
  style : @core.Style
} derive(Eq, Debug)

///|
/// 以单元格序列构造（上游 `Row::new`：高度缺省 1）喵。
pub fn TableRow::new(cells : Array[TableCell]) -> TableRow {
  {
    cells,
    height: 1,
    top_margin: 0,
    bottom_margin: 0,
    style: @core.Style::new(),
  }
}

///|
/// 以字符串序列构造（上游 `Row::new` 的 `Into<Cell>` 形态）喵。
pub fn TableRow::of_strs(cells : Array[String]) -> TableRow {
  let out : Array[TableCell] = []
  for cell in cells {
    out.push(TableCell::of_str(cell))
  }
  TableRow::new(out)
}

///|
/// 缺省构造（上游 `Row::default`）喵。
pub fn TableRow::default() -> TableRow {
  TableRow::new([])
}

///|
/// 设单元格序列（上游 `Row::cells`）喵。
pub fn TableRow::cells(self : TableRow, cells : Array[TableCell]) -> TableRow {
  { ..self, cells, }
}

///|
/// 设固定高度（上游 `Row::height`：超出部分的内容被截断）喵。
pub fn TableRow::height(self : TableRow, height : Int) -> TableRow {
  { ..self, height, }
}

///|
/// 设上外边距（上游 `Row::top_margin`：行前空行数）喵。
pub fn TableRow::top_margin(self : TableRow, margin : Int) -> TableRow {
  { ..self, top_margin: margin }
}

///|
/// 设下外边距（上游 `Row::bottom_margin`：行后空行数）喵。
pub fn TableRow::bottom_margin(self : TableRow, margin : Int) -> TableRow {
  { ..self, bottom_margin: margin }
}

///|
/// 设整行样式（上游 `Row::style`）喵。
pub fn TableRow::style(self : TableRow, style : @core.Style) -> TableRow {
  { ..self, style, }
}

///|
/// 含外边距的总行高（包私有，上游 `height_with_margin`）喵。
fn TableRow::height_with_margin(self : TableRow) -> Int {
  self.height + self.top_margin + self.bottom_margin
}

///|
/// 状态索引域上限（对位上游 usize::MAX 哨兵语义；本库坐标为 Int 域，
/// 取 i32 域最大值）。
const MAX_TABLE_INDEX : Int = 2147483647

///|
/// 表格状态（上游 `table::TableState`）：首显示行偏移、选中行与
/// 选中列喵。
pub(all) struct TableState {
  mut offset : Int
  mut selected : Int?
  mut selected_column : Int?
} derive(Eq, Debug)

///|
/// 新建状态（上游 `TableState::new`）喵。
pub fn TableState::new() -> TableState {
  { offset: 0, selected: None, selected_column: None }
}

///|
/// 设首显示行（上游 `with_offset`）喵。
pub fn TableState::with_offset(self : TableState, offset : Int) -> TableState {
  { ..self, offset, }
}

///|
/// 设选中行（上游 `with_selected`）喵。
pub fn TableState::with_selected(
  self : TableState,
  selected : Int?,
) -> TableState {
  { ..self, selected, }
}

///|
/// 设选中列（上游 `with_selected_column`）喵。
pub fn TableState::with_selected_column(
  self : TableState,
  selected_column : Int?,
) -> TableState {
  { ..self, selected_column, }
}

///|
/// 设选中单元格（上游 `with_selected_cell`）喵。
pub fn TableState::with_selected_cell(
  self : TableState,
  selected : (Int, Int)?,
) -> TableState {
  match selected {
    Some((r, c)) => { ..self, selected: Some(r), selected_column: Some(c) }
    None => { ..self, selected: None, selected_column: None }
  }
}

///|
/// 读首显示行（上游 `offset`）喵。
pub fn TableState::offset(self : TableState) -> Int {
  self.offset
}

///|
/// 读选中行（上游 `selected`）喵。
pub fn TableState::selected(self : TableState) -> Int? {
  self.selected
}

///|
/// 读选中列（上游 `selected_column`）喵。
pub fn TableState::selected_column(self : TableState) -> Int? {
  self.selected_column
}

///|
/// 读选中单元格（上游 `selected_cell`：行列都有才算）喵。
pub fn TableState::selected_cell(self : TableState) -> (Int, Int)? {
  match (self.selected, self.selected_column) {
    (Some(r), Some(c)) => Some((r, c))
    _ => None
  }
}

///|
/// 设选中行（上游 `select`：置 None 时偏移归零）喵。
pub fn TableState::select(self : TableState, index : Int?) -> Unit {
  self.selected = index
  if index is None {
    self.offset = 0
  }
}

///|
/// 设选中列（上游 `select_column`）喵。
pub fn TableState::select_column(self : TableState, index : Int?) -> Unit {
  self.selected_column = index
}

///|
/// 设选中单元格（上游 `select_cell`：置 None 时偏移归零）喵。
pub fn TableState::select_cell(
  self : TableState,
  indexes : (Int, Int)?,
) -> Unit {
  match indexes {
    Some((r, c)) => {
      self.selected = Some(r)
      self.selected_column = Some(c)
    }
    None => {
      self.offset = 0
      self.selected = None
      self.selected_column = None
    }
  }
}

///|
/// 选中下一行；未选中时落到第 0 行（上游 `select_next`）喵。
pub fn TableState::select_next(self : TableState) -> Unit {
  let next = match self.selected {
    Some(i) => if i < MAX_TABLE_INDEX { i + 1 } else { MAX_TABLE_INDEX }
    None => 0
  }
  self.select(Some(next))
}

///|
/// 选中下一列（上游 `select_next_column`）喵。
pub fn TableState::select_next_column(self : TableState) -> Unit {
  let next = match self.selected_column {
    Some(i) => if i < MAX_TABLE_INDEX { i + 1 } else { MAX_TABLE_INDEX }
    None => 0
  }
  self.select_column(Some(next))
}

///|
/// 选中上一行；未选中时落到最大索引哨兵（渲染时收敛，上游
/// `select_previous`）喵。
pub fn TableState::select_previous(self : TableState) -> Unit {
  let previous = match self.selected {
    Some(i) => if i > 0 { i - 1 } else { 0 }
    None => MAX_TABLE_INDEX
  }
  self.select(Some(previous))
}

///|
/// 选中上一列（上游 `select_previous_column`）喵。
pub fn TableState::select_previous_column(self : TableState) -> Unit {
  let previous = match self.selected_column {
    Some(i) => if i > 0 { i - 1 } else { 0 }
    None => MAX_TABLE_INDEX
  }
  self.select_column(Some(previous))
}

///|
/// 选中首行（上游 `select_first`）喵。
pub fn TableState::select_first(self : TableState) -> Unit {
  self.select(Some(0))
}

///|
/// 选中首列（上游 `select_first_column`）喵。
pub fn TableState::select_first_column(self : TableState) -> Unit {
  self.select_column(Some(0))
}

///|
/// 选中末行（哨兵语义，上游 `select_last`）喵。
pub fn TableState::select_last(self : TableState) -> Unit {
  self.select(Some(MAX_TABLE_INDEX))
}

///|
/// 选中末列（哨兵语义，上游 `select_last_column`）喵。
pub fn TableState::select_last_column(self : TableState) -> Unit {
  self.select_column(Some(MAX_TABLE_INDEX))
}

///|
/// 向下滚动 N 行（上游 `scroll_down_by`）喵。
pub fn TableState::scroll_down_by(self : TableState, amount : Int) -> Unit {
  let selected = match self.selected {
    Some(i) => i
    None => 0
  }
  self.select(
    Some(
      if selected + amount < MAX_TABLE_INDEX {
        selected + amount
      } else {
        MAX_TABLE_INDEX
      },
    ),
  )
}

///|
/// 向上滚动 N 行（上游 `scroll_up_by`）喵。
pub fn TableState::scroll_up_by(self : TableState, amount : Int) -> Unit {
  let selected = match self.selected {
    Some(i) => i
    None => 0
  }
  self.select(Some(if selected - amount > 0 { selected - amount } else { 0 }))
}

///|
/// 向右滚动 N 列（上游 `scroll_right_by`）喵。
pub fn TableState::scroll_right_by(self : TableState, amount : Int) -> Unit {
  let selected = match self.selected_column {
    Some(i) => i
    None => 0
  }
  self.select_column(
    Some(
      if selected + amount < MAX_TABLE_INDEX {
        selected + amount
      } else {
        MAX_TABLE_INDEX
      },
    ),
  )
}

///|
/// 向左滚动 N 列（上游 `scroll_left_by`）喵。
pub fn TableState::scroll_left_by(self : TableState, amount : Int) -> Unit {
  let selected = match self.selected_column {
    Some(i) => i
    None => 0
  }
  self.select_column(
    Some(if selected - amount > 0 { selected - amount } else { 0 }),
  )
}

///|
/// 表格组件（上游 `table::Table`）喵。
pub(all) struct Table {
  block : Block?
  style : @core.Style
  header : TableRow?
  footer : TableRow?
  rows : Array[TableRow]
  widths : Array[@core.Constraint]
  column_spacing : Int
  row_highlight_style : @core.Style
  column_highlight_style : @core.Style
  cell_highlight_style : @core.Style
  highlight_symbol : @core.Text
  highlight_spacing : HighlightSpacing
  flex : @core.Flex
} derive(Eq, Debug)

///|
/// 缺省构造（上游 `Table::default`：列距 1、WhenSelected、Flex::Start）喵。
pub fn Table::default() -> Table {
  {
    block: None,
    style: @core.Style::new(),
    header: None,
    footer: None,
    rows: [],
    widths: [],
    column_spacing: 1,
    row_highlight_style: @core.Style::new(),
    column_highlight_style: @core.Style::new(),
    cell_highlight_style: @core.Style::new(),
    highlight_symbol: @core.Text::empty(),
    highlight_spacing: WhenSelected,
    flex: @core.Start,
  }
}

///|
/// 以行与列宽约束构造（上游 `Table::new`；百分比越界按无 panic
/// 铁律饱和到 100 喵）。
pub fn Table::make(
  rows : Array[TableRow],
  widths : Array[@core.Constraint],
) -> Table {
  { ..Table::default(), rows, widths: clamp_percentages(widths) }
}

///|
/// 百分比约束饱和到 100（上游 `ensure_percentages_less_than_100`
/// 断言的无 panic 等价）喵。
fn clamp_percentages(
  widths : Array[@core.Constraint],
) -> Array[@core.Constraint] {
  let out : Array[@core.Constraint] = []
  for w in widths {
    match w {
      @core.Percentage(p) =>
        out.push(@core.Percentage(if p > 100 { 100 } else { p }))
      other => out.push(other)
    }
  }
  out
}

///|
/// 设行序列（上游 `Table::rows`）喵。
pub fn Table::rows(self : Table, rows : Array[TableRow]) -> Table {
  { ..self, rows, }
}

///|
/// 设列宽约束（上游 `Table::widths`）喵。
pub fn Table::widths(self : Table, widths : Array[@core.Constraint]) -> Table {
  { ..self, widths: clamp_percentages(widths) }
}

///|
/// 设列间距（上游 `Table::column_spacing`）喵。
pub fn Table::column_spacing(self : Table, spacing : Int) -> Table {
  { ..self, column_spacing: spacing }
}

///|
/// 包边框块（上游 `Table::block`）喵。
pub fn Table::block(self : Table, block : Block) -> Table {
  { ..self, block: Some(block) }
}

///|
/// 设基础样式（上游 `Table::style`）喵。
pub fn Table::style(self : Table, style : @core.Style) -> Table {
  { ..self, style, }
}

///|
/// 设表头行（上游 `Table::header`）喵。
pub fn Table::header(self : Table, header : TableRow) -> Table {
  { ..self, header: Some(header) }
}

///|
/// 设表尾行（上游 `Table::footer`）喵。
pub fn Table::footer(self : Table, footer : TableRow) -> Table {
  { ..self, footer: Some(footer) }
}

///|
/// 设选中行样式（上游 `Table::row_highlight_style`）喵。
pub fn Table::row_highlight_style(self : Table, style : @core.Style) -> Table {
  { ..self, row_highlight_style: style }
}

///|
/// 设选中列样式（上游 `Table::column_highlight_style`）喵。
pub fn Table::column_highlight_style(
  self : Table,
  style : @core.Style,
) -> Table {
  { ..self, column_highlight_style: style }
}

///|
/// 设选中单元格样式（上游 `Table::cell_highlight_style`）喵。
pub fn Table::cell_highlight_style(self : Table, style : @core.Style) -> Table {
  { ..self, cell_highlight_style: style }
}

///|
/// 设高亮符号（上游 `Table::highlight_symbol`）喵。
pub fn Table::highlight_symbol(self : Table, symbol : @core.Text) -> Table {
  { ..self, highlight_symbol: symbol }
}

///|
/// 设高亮符号字符串（上游 `highlight_symbol` 的 `Into<Text>` 形态）喵。
pub fn Table::highlight_symbol_str(self : Table, symbol : String) -> Table {
  self.highlight_symbol(@core.Text::raw(symbol))
}

///|
/// 设高亮列占位策略（上游 `Table::highlight_spacing`）喵。
pub fn Table::highlight_spacing(
  self : Table,
  value : HighlightSpacing,
) -> Table {
  { ..self, highlight_spacing: value }
}

///|
/// 设列间剩余空间分配策略（上游 `Table::flex`）喵。
pub fn Table::flex(self : Table, flex : @core.Flex) -> Table {
  { ..self, flex, }
}

///|
/// 渲染表格（无状态形态：以默认状态驱动，上游 `Widget for &Table`）喵。
pub impl @core.Widget for Table with fn render(
  self : Table,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let state = TableState::new()
  self.render_stateful(area, buf, state)
}

///|
/// 渲染表格（带状态：选中收敛、偏移回写，上游
/// `StatefulWidget for &Table`）喵。
pub fn Table::render_stateful(
  self : Table,
  area : @core.Rect,
  buf : @core.Buffer,
  state : TableState,
) -> Unit {
  buf.set_style(area, self.style)
  let table_area = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  if table_area.is_empty() {
    return
  }
  // 选中行越界收敛到最后一行；空表取消选中喵。
  let out_of_bounds = match state.selected {
    Some(s) => s >= self.rows.length()
    None => false
  }
  if out_of_bounds {
    state.select(
      Some(if self.rows.length() > 0 { self.rows.length() - 1 } else { 0 }),
    )
  }
  if self.rows.is_empty() {
    state.select(None)
  }
  let column_count = self.column_count()
  let selected_column_out_of_bounds = match state.selected_column {
    Some(s) => s >= column_count
    None => false
  }
  if selected_column_out_of_bounds {
    state.select_column(
      Some(if column_count > 0 { column_count - 1 } else { 0 }),
    )
  }
  if column_count == 0 {
    state.select_column(None)
  }
  let selection_width = self.selection_width(state)
  let column_widths = self.get_column_widths(
    table_area.width,
    selection_width,
    column_count,
  )
  let (header_area, rows_area, footer_area) = self.layout(table_area)
  self.render_header(header_area, buf, column_widths)
  self.render_rows(rows_area, buf, selection_width, state, column_widths)
  self.render_footer(footer_area, buf, column_widths)
}

///|
/// 切分表区为表头/行区/表尾（包私有，上游 `Table::layout`：七段
/// 纵向约束承载头尾外边距）喵。
fn Table::layout(
  self : Table,
  area : @core.Rect,
) -> (@core.Rect, @core.Rect, @core.Rect) {
  let header_top = match self.header {
    Some(h) => h.top_margin
    None => 0
  }
  let header_height = match self.header {
    Some(h) => h.height
    None => 0
  }
  let header_bottom = match self.header {
    Some(h) => h.bottom_margin
    None => 0
  }
  let footer_top = match self.footer {
    Some(f) => f.top_margin
    None => 0
  }
  let footer_height = match self.footer {
    Some(f) => f.height
    None => 0
  }
  let footer_bottom = match self.footer {
    Some(f) => f.bottom_margin
    None => 0
  }
  let segments = @layout.Layout::vertical([
    @core.Length(header_top),
    @core.Length(header_height),
    @core.Length(header_bottom),
    @core.Min(0),
    @core.Length(footer_top),
    @core.Length(footer_height),
    @core.Length(footer_bottom),
  ]).split(area)
  (segments[1], segments[3], segments[5])
}

///|
/// 渲染表头单元格（包私有，上游 `render_header`）喵。
fn Table::render_header(
  self : Table,
  area : @core.Rect,
  buf : @core.Buffer,
  column_widths : Array[@core.Rect],
) -> Unit {
  match self.header {
    Some(header) => {
      buf.set_style(area, header.style)
      let count = if column_widths.length() < header.cells.length() {
        column_widths.length()
      } else {
        header.cells.length()
      }
      for i in 0..<count {
        let cell_area = column_widths[i]
        let area_to_render = @core.Rect::new(
          area.x + cell_area.x,
          area.y,
          cell_area.width,
          area.height,
        )
        header.cells[i].render(area_to_render, buf)
      }
    }
    None => ()
  }
}

///|
/// 渲染表尾单元格（包私有，上游 `render_footer`）喵。
fn Table::render_footer(
  self : Table,
  area : @core.Rect,
  buf : @core.Buffer,
  column_widths : Array[@core.Rect],
) -> Unit {
  match self.footer {
    Some(footer) => {
      buf.set_style(area, footer.style)
      let count = if column_widths.length() < footer.cells.length() {
        column_widths.length()
      } else {
        footer.cells.length()
      }
      for i in 0..<count {
        let cell_area = column_widths[i]
        let area_to_render = @core.Rect::new(
          area.x + cell_area.x,
          area.y,
          cell_area.width,
          area.height,
        )
        footer.cells[i].render(area_to_render, buf)
      }
    }
    None => ()
  }
}

///|
/// 渲染可见行与选中样式（包私有，上游 `render_rows`：行样式 →
/// 选中符号 → 单元格 → 行/列/单元格高亮叠加）喵。
fn Table::render_rows(
  self : Table,
  area : @core.Rect,
  buf : @core.Buffer,
  selection_width : Int,
  state : TableState,
  column_widths : Array[@core.Rect],
) -> Unit {
  if self.rows.is_empty() {
    return
  }
  let (start_index, end_index) = self.visible_rows(state, area)
  state.offset = start_index
  let mut y_offset = 0
  let mut selected_row_area : @core.Rect? = None
  let last = if end_index < self.rows.length() {
    end_index
  } else {
    self.rows.length()
  }
  for i in start_index..<last {
    let row = self.rows[i]
    let y = area.y + y_offset + row.top_margin
    let raw_height = y + row.height
    let height = if raw_height < area.bottom() {
      raw_height - y
    } else {
      area.bottom() - y
    }
    let clamped = if height > 0 { height } else { 0 }
    let row_area = @core.Rect::new(area.x, y, area.width, clamped)
    buf.set_style(row_area, row.style)
    let is_selected = match state.selected {
      Some(index) => index == i
      None => false
    }
    if selection_width > 0 && is_selected {
      self.set_selection_style(buf, selection_width, row_area, row)
    }
    self.render_row_cells(buf, column_widths, row.cells, row_area)
    if is_selected {
      selected_row_area = Some(row_area)
    }
    y_offset += row.height_with_margin()
  }
  let selected_column_area : @core.Rect? = match state.selected_column {
    Some(s) =>
      if s < column_widths.length() {
        let cell_area = column_widths[s]
        Some(
          @core.Rect::new(
            cell_area.x + area.x,
            area.y,
            cell_area.width,
            area.height,
          ),
        )
      } else {
        None
      }
    None => None
  }
  match (selected_row_area, selected_column_area) {
    (Some(row_area), Some(col_area)) => {
      buf.set_style(row_area, self.row_highlight_style)
      buf.set_style(col_area, self.column_highlight_style)
      buf.set_style(row_area.intersection(col_area), self.cell_highlight_style)
    }
    (Some(row_area), None) => buf.set_style(row_area, self.row_highlight_style)
    (None, Some(col_area)) =>
      buf.set_style(col_area, self.column_highlight_style)
    (None, None) => ()
  }
}

///|
/// 把单元格铺进各列（包私有，上游 `render_row_cells`：按
/// column_span 跨列取宽，耗尽即止）喵。
fn Table::render_row_cells(
  self : Table,
  buf : @core.Buffer,
  column_widths : Array[@core.Rect],
  cells : Array[TableCell],
  row_area : @core.Rect,
) -> Unit {
  let mut cursor = 0
  for cell in cells {
    match
      get_cell_area(
        column_widths,
        cursor,
        cell.column_span,
        self.column_spacing,
      ) {
      Some(cell_area) => {
        cursor = cell_area.y
        let area_to_render = @core.Rect::new(
          row_area.x + cell_area.x,
          row_area.y,
          cell_area.width,
          row_area.height,
        )
        cell.render(area_to_render, buf)
      }
      None => ()
    }
  }
}

///|
/// 选中行样式与高亮符号（包私有，上游 `set_selection_style`）喵。
fn Table::set_selection_style(
  self : Table,
  buf : @core.Buffer,
  selection_width : Int,
  row_area : @core.Rect,
  row : TableRow,
) -> Unit {
  let selection_area = @core.Rect::new(
    row_area.x,
    row_area.y,
    selection_width,
    row_area.height,
  )
  buf.set_style(selection_area, row.style)
  self.highlight_symbol.render(selection_area, buf)
}

///|
/// 单元格跨列取区（包私有，上游 `get_cell_area`：消耗 span 个列宽，
/// 宽度累加列距；游标经 `Rect.y` 回传）喵。
fn get_cell_area(
  column_widths : Array[@core.Rect],
  cursor : Int,
  cell_column_span : Int,
  column_spacing : Int,
) -> @core.Rect? {
  if cell_column_span == 0 {
    return None
  }
  if cursor >= column_widths.length() {
    return None
  }
  let first = column_widths[cursor]
  let mut n_columns_taken = 1
  let mut all_columns_width = first.width
  let mut j = cursor + 1
  while j < column_widths.length() && n_columns_taken < cell_column_span {
    all_columns_width += column_widths[j].width
    n_columns_taken += 1
    j += 1
  }
  let width = all_columns_width + (n_columns_taken - 1) * column_spacing
  // 以 y 字段回传新游标（上游 Iterator 形态的等价承载）喵。
  Some(@core.Rect::new(first.x, j, width, 1))
}

///|
/// 可见行索引区间（包私有，上游 `visible_rows`：偏移起算 + 选中
/// 行滚动收敛 + 部分行 inclusion）喵。
fn Table::visible_rows(
  self : Table,
  state : TableState,
  area : @core.Rect,
) -> (Int, Int) {
  let last_row = if self.rows.length() > 0 { self.rows.length() - 1 } else { 0 }
  let mut start = if state.offset < last_row { state.offset } else { last_row }
  match state.selected {
    Some(selected) => if selected < start { start = selected }
    None => ()
  }
  let mut end = start
  let mut height = 0
  for i in start..<self.rows.length() {
    let item = self.rows[i]
    if height + item.height > area.height {
      break
    }
    height += item.height_with_margin()
    end += 1
  }
  match state.selected {
    Some(selected) => {
      let selected = if selected < last_row { selected } else { last_row }
      // 滚动直到选中行可见喵。
      while selected >= end {
        height += self.rows[end].height_with_margin()
        end += 1
        while height > area.height {
          height -= self.rows[start].height_with_margin()
          start += 1
        }
      }
    }
    None => ()
  }
  // 剩余空间容纳部分行喵。
  if height < area.height && end < self.rows.length() {
    end += 1
  }
  (start, end)
}

///|
/// 各列 (x, width)（包私有，上游 `get_column_widths`：选择列占位 +
/// 列宽约束切分；widths 未设时等分）喵。
fn Table::get_column_widths(
  self : Table,
  max_width : Int,
  selection_width : Int,
  col_count : Int,
) -> Array[@core.Rect] {
  let widths : Array[@core.Constraint] = if self.widths.is_empty() {
    let equal = if col_count > 0 { max_width / col_count } else { max_width }
    let out : Array[@core.Constraint] = []
    for _ in 0..<col_count {
      out.push(@core.Length(equal))
    }
    out
  } else {
    self.widths
  }
  // 选择列占位 + 剩余列区（上游固定二段切分）喵。
  let areas = @layout.Layout::horizontal([
    @core.Length(selection_width),
    @core.Fill(0),
  ]).split(@core.Rect::new(0, 0, max_width, 1))
  let columns_area = areas[1]
  let rects = @layout.Layout::horizontal(widths)
    .flex(self.flex)
    .spacing(self.column_spacing)
    .split(columns_area)
  let out : Array[@core.Rect] = []
  for c in rects {
    out.push(@core.Rect::new(c.x, 0, c.width, 1))
  }
  out
}

///|
/// 列数 = 表头/表尾/各行单元格数的最大值（上游 `column_count` 为
/// 包私有；本库测试文件只见 pub API，故公开为查询方法）喵。
pub fn Table::column_count(self : Table) -> Int {
  let mut count = 0
  let sources : Array[Array[TableCell]] = []
  match self.header {
    Some(h) => sources.push(h.cells)
    None => ()
  }
  match self.footer {
    Some(f) => sources.push(f.cells)
    None => ()
  }
  for row in self.rows {
    sources.push(row.cells)
  }
  for cells in sources {
    if cells.length() > count {
      count = cells.length()
    }
  }
  count
}

///|
/// 选择列宽（包私有，上游 `selection_width`）喵。
fn Table::selection_width(self : Table, state : TableState) -> Int {
  let has_selection = state.selected is Some(_)
  if self.highlight_spacing.should_add(has_selection) {
    self.highlight_symbol.width()
  } else {
    0
  }
}
