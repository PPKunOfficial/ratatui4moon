/// Clear（上游 `widgets/clear.rs`）：清空区域以支持弹窗等覆盖绘制喵。

///|
/// 区域清空组件（上游 `widgets::Clear` 单元结构体）：把区域内所有
/// 单元格复位为空白，供后续 widget 覆盖绘制（弹窗位）喵。
pub(all) struct Clear {}

///|
/// 构造清空组件（上游 `Clear` 值位）喵。
pub fn Clear::new() -> Clear {
  Clear::{  }
}

///|
/// 渲染清空（上游 `Widget for &Clear`：区域与缓冲求交后逐格复位，
/// 交叉为空即整体跳过）喵。
pub impl @core.Widget for Clear with fn render(
  self : Clear,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  ignore(self)
  let area = area.intersection(buf.area)
  if area.is_empty() {
    return
  }
  for x in area.left()..<area.right() {
    for y in area.top()..<area.bottom() {
      match buf.mut_cell(x, y) {
        Some(cell) => cell.reset()
        None => ()
      }
    }
  }
}
