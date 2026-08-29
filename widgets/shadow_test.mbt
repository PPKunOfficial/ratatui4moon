// 上游 `block/shadow.rs` 内联测试逐条复刻喵。

///|
/// 渲染辅助：4x4 缓冲内以 2x2 基区渲染阴影喵。
fn render_shadow(shadow : Shadow) -> @core.Buffer {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 4, 4))
  shadow.render(@core.Rect::new(0, 0, 2, 2), buffer)
  buffer
}

///|
/// 上游 `overlay_renders_style_without_changing_symbols`：overlay 只
/// 染样式不动符号，与基区重叠格跳过喵。
test "Shadow overlay 只染样式" {
  let buffer = @core.Buffer::with_lines(["abcd", "efgh", "ijkl", "mnop"])
  let shadow = Shadow::overlay().style(
    @core.Style::new().fg(@core.Red).bg(@core.Blue),
  )
  shadow.render(@core.Rect::new(0, 0, 2, 2), buffer)
  inspect(buffer.get(2, 1).symbol(), content="g")
  inspect(buffer.get(1, 2).symbol(), content="j")
  inspect(buffer.get(2, 2).symbol(), content="k")
  inspect(buffer.get(2, 1).fg.to_display(), content="Red")
  inspect(buffer.get(2, 1).bg.to_display(), content="Blue")
  // 基区内格子不受波及喵。
  inspect(buffer.get(1, 1).fg.to_display(), content="Reset")
  inspect(buffer.get(1, 1).bg.to_display(), content="Reset")
}

///|
/// 上游 `symbol_filters_fill_only_visible_shadow_cells`：符号填充只
/// 落在可见阴影格（rstest 两组：$ 与全块）喵。
test "Shadow 符号填充可见格" {
  let cases : Array[(Shadow, String)] = [
    (Shadow::symbol("$"), "$"),
    (Shadow::block(), "█"),
  ]
  for case in cases {
    let (shadow, symbol) = case
    let buffer = render_shadow(shadow)
    inspect(buffer.get(2, 1).symbol(), content=symbol)
    inspect(buffer.get(1, 2).symbol(), content=symbol)
    inspect(buffer.get(2, 2).symbol(), content=symbol)
    inspect(buffer.get(1, 1).symbol(), content=" ")
  }
}

///|
/// 上游 `render_is_clipped_to_buffer`：阴影区越界部分裁剪到缓冲喵。
test "Shadow 越界裁剪" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 3, 2))
  let shadow = Shadow::symbol("#")
  shadow.render(@core.Rect::new(0, 0, 2, 1), buffer)
  inspect(buffer.get(2, 1).symbol(), content="#")
}

///|
/// PlusFilter：把所有阴影格写成 +（上游测试内嵌效果）喵。
struct PlusFilter {
  _unit : Unit
} derive(Eq, Debug)

///|
/// 构造器：priv 字段让包外无合成构造器，测试文件内自备喵。
fn plus_filter() -> PlusFilter {
  { _unit: () }
}

///|
pub impl CellEffect for PlusFilter with fn apply(
  _self : PlusFilter,
  shadow_area : @core.Rect,
  base_area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  for y in shadow_area.top()..<shadow_area.bottom() {
    for x in shadow_area.left()..<shadow_area.right() {
      if base_area.contains(@core.Position::new(x, y)) {
        continue
      }
      match buf.mut_cell(x, y) {
        Some(cell) => cell.set_symbol("+")
        None => ()
      }
    }
  }
}

///|
/// 上游 `custom_filter_is_applied`：自定义 CellEffect 生效喵。
test "Shadow 自定义效果生效" {
  let shadow = Shadow::new(plus_filter())
  let buffer = render_shadow(shadow)
  inspect(buffer.get(2, 1).symbol(), content="+")
  inspect(buffer.get(1, 2).symbol(), content="+")
  inspect(buffer.get(2, 2).symbol(), content="+")
}

///|
/// 上游 `dimmed_filter_dims_background`：DIM 修饰位 + RGB 背景减半，
/// 基区格不受波及喵。
test "Shadow Dimmed 变暗效果" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 4, 4))
  buffer.set_style(buffer.area, @core.Style::new().bg(@core.Rgb(100, 120, 140)))
  let shadow = Shadow::new(dimmed())
  shadow.render(@core.Rect::new(0, 0, 2, 2), buffer)
  let dimmed_cell = buffer.get(2, 1)
  inspect(dimmed_cell.modifier.contains(@core.Modifier::dim()), content="true")
  inspect(dimmed_cell.bg.to_display(), content="#323C46")
  let untouched = buffer.get(1, 1)
  inspect(untouched.modifier.contains(@core.Modifier::dim()), content="false")
  inspect(untouched.bg.to_display(), content="#64788C")
}
