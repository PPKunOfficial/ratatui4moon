///|
/// Position 单元测试：复刻 ratatui-v0.30.2 `layout/position.rs` 测试清单喵。

///|
/// 上游 new：字段原样落位喵。
test "Position::new 构造" {
  @debug.assert_eq(Position::new(1, 2), { x: 1, y: 2 })
}

///|
/// 上游 from_tuple：元组构造喵。
test "Position::of_tuple" {
  @debug.assert_eq(Position::of_tuple((1, 2)), Position::new(1, 2))
}

///|
/// 上游 into_tuple：拆回元组喵。
test "Position::to_tuple" {
  let (x, y) = Position::new(1, 2).to_tuple()
  inspect(x, content="1")
  inspect(y, content="2")
}

///|
/// 上游 from_rect：取矩形左上角喵。
test "Position::of_rect" {
  @debug.assert_eq(
    Position::of_rect(Rect::new(1, 2, 3, 4)),
    Position::new(1, 2),
  )
}

///|
/// 上游 to_string：Display 格式 `(x, y)` 喵。
test "Position::to_display" {
  inspect(Position::new(1, 2).to_display(), content="(1, 2)")
}

///|
/// 上游 offset_moves_position：平移坐标点喵。
test "Position::offset 平移" {
  @debug.assert_eq(
    Position::new(2, 3).offset(Offset::new(5, 7)),
    Position::new(7, 10),
  )
}

///|
/// 上游 offset_clamps_to_bounds：越界钳回 u16 域上限喵。
test "Position::offset 越界钳制" {
  @debug.assert_eq(
    Position::new(1, 1).offset(Offset::max()),
    Position::new(MAX_COORD, MAX_COORD),
  )
}

///|
/// 上游 add_and_subtract_offset：`+`/`-` 运算符喵。
test "Position 加减 Offset" {
  let position = Position::new(10, 10)
    .op_add(Offset::new(-3, 4))
    .op_sub(Offset::new(5, 20))
  @debug.assert_eq(position, Position::new(2, 0))
}

///|
/// 上游 add_assign_and_sub_assign_offset：以顺序平移等价复刻喵。
test "Position 顺序加减 Offset" {
  let mut position = Position::new(5, 5)
  position = position.op_add(Offset::new(2, 3))
  position = position.op_sub(Offset::new(10, 1))
  @debug.assert_eq(position, Position::new(0, 7))
}
