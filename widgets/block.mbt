///|
/// 即时模式 widget 集喵。
///
/// widget 全部无状态：`render(area, buf)` 把自己画进缓冲即结束，
/// 无 retained 树、无响应式订阅——这正是与 vDOM 路线的分野喵。

///|
/// 单线边框块组件喵。
///
/// spike 阶段只有边框；标题、内边距、圆角边框等按消费方需求增量追加。
/// `style` 以 patch 语义作用于全部边框字符喵。
pub(all) struct Block {
  style : @core.Style
} derive(Eq, Debug)

///|
/// 默认样式边框块喵。
pub fn Block::new() -> Block {
  { style: @core.Style::default() }
}

///|
/// 指定边框样式喵。
pub fn Block::styled(style : @core.Style) -> Block {
  { style, }
}

///|
/// 把边框渲染进 `buf` 的 `area` 区域喵。
///
/// 区域不足 2×2 时整体跳过（优雅退化，不炸喵）；边框字符：
/// 四角 `┌ ┐ └ ┘`，横边 `─`，竖边 `│`。
pub fn Block::render(
  self : Block,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  if area.width < 2 || area.height < 2 {
    return
  }
  let right = area.right() - 1
  let bottom = area.bottom() - 1
  fn put(x : Int, y : Int, symbol : String) -> Unit {
    match buf.mut_cell(x, y) {
      Some(cell) => {
        cell.set_symbol(symbol)
        cell.set_style(self.style)
      }
      None => ()
    }
  }
  put(area.x, area.y, "┌")
  put(right, area.y, "┐")
  put(area.x, bottom, "└")
  put(right, bottom, "┘")
  for x in (area.x + 1)..<right {
    put(x, area.y, "─")
    put(x, bottom, "─")
  }
  for y in (area.y + 1)..<bottom {
    put(area.x, y, "│")
    put(right, y, "│")
  }
}
