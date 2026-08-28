///|
/// Padding 单元测试：复刻 ratatui-v0.30.2 `block/padding.rs`
/// 测试清单喵（`From<u16>` 转换糖与 const 语境不复刻）喵。

///|
/// 上游 new：逐边构造喵。
test "Padding::new 构造" {
  @debug.assert_eq(Padding::new(1, 2, 3, 4), {
    left: 1,
    right: 2,
    top: 3,
    bottom: 4,
  })
  inspect(Padding::zero().left, content="0")
}

///|
/// 上游 constructors：全部便捷构造喵。
test "Padding 构造器" {
  @debug.assert_eq(Padding::horizontal(1), Padding::new(1, 1, 0, 0))
  @debug.assert_eq(Padding::vertical(1), Padding::new(0, 0, 1, 1))
  @debug.assert_eq(Padding::uniform(1), Padding::new(1, 1, 1, 1))
  @debug.assert_eq(Padding::proportional(1), Padding::new(2, 2, 1, 1))
  @debug.assert_eq(Padding::symmetric(1, 2), Padding::new(1, 1, 2, 2))
  @debug.assert_eq(Padding::left(1), Padding::new(1, 0, 0, 0))
  @debug.assert_eq(Padding::right(1), Padding::new(0, 1, 0, 0))
  @debug.assert_eq(Padding::top(1), Padding::new(0, 0, 1, 0))
  @debug.assert_eq(Padding::bottom(1), Padding::new(0, 0, 0, 1))
}
