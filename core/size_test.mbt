///|
/// Size 单元测试：复刻 ratatui-v0.30.2 `layout/size.rs` 测试清单喵。

///|
/// 上游 new：字段原样落位喵。
test "Size::new 构造" {
  let size = Size::new(10, 20)
  inspect(size.width, content="10")
  inspect(size.height, content="20")
}

///|
/// 上游 from_tuple：元组构造喵。
test "Size::of_tuple" {
  @debug.assert_eq(Size::of_tuple((10, 20)), Size::new(10, 20))
}

///|
/// 上游 to_tuple：拆回元组喵。
test "Size::to_tuple" {
  let (width, height) = Size::new(10, 20).to_tuple()
  inspect(width, content="10")
  inspect(height, content="20")
}

///|
/// 上游 from_rect：从矩形提取喵。
test "Size::of_rect" {
  @debug.assert_eq(Size::of_rect(Rect::new(0, 0, 10, 20)), Size::new(10, 20))
}

///|
/// 上游 display：Display 格式 `宽x高` 喵。
test "Size::to_display" {
  inspect(Size::new(10, 20).to_display(), content="10x20")
}

///|
/// 上游 area：面积（含 u16 上限平方，Int64 承装）喵。
test "Size::area" {
  @debug.assert_eq(Size::new(10, 20).area(), 200L)
  @debug.assert_eq(Size::new(0, 0).area(), 0L)
  @debug.assert_eq(Size::new(MAX_COORD, MAX_COORD).area(), 4294836225L)
}
