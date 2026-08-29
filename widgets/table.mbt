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
