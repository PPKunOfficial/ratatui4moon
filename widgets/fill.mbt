/// Fill（上游 `widgets/fill.rs`）：以单一符号与样式铺满渲染区域喵。

///|
/// 区域填充组件（上游 `widgets::Fill`）：把 `symbol` 与 `style` 写进
/// 区域内每个单元格——背景、分隔带、滚动条轨道等实心块的基元喵。
pub(all) struct Fill {
  symbol : String
  style : @core.Style
} derive(Eq, Debug)

///|
/// 以符号构造（上游 `Fill::new`，样式缺省不改动）喵。
pub fn Fill::new(symbol : String) -> Fill {
  { symbol, style: @core.Style::new() }
}

///|
/// 设填充样式（上游 `Fill::style`）喵。
pub fn Fill::style(self : Fill, style : @core.Style) -> Fill {
  { ..self, style, }
}

///|
/// 替换填充符号（上游 `Fill::symbol`）喵。
pub fn Fill::symbol(self : Fill, symbol : String) -> Fill {
  { ..self, symbol, }
}

///|
/// 渲染填充（上游 `Widget for &Fill`：区域与缓冲求交后逐格写入，
/// 越界静默裁剪，交叉为空即整体跳过）喵。
pub impl @core.Widget for Fill with fn render(
  self : Fill,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let area = area.intersection(buf.area)
  if area.is_empty() {
    return
  }
  for position in area.positions() {
    match buf.mut_cell(position.x, position.y) {
      Some(cell) => {
        cell.set_symbol(self.symbol)
        cell.set_style(self.style)
      }
      None => ()
    }
  }
}
