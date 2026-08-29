// 上游 `layout/rect/iter.rs` 内联测试逐条复刻（12 条）喵。

///|
/// 上游 `rows` 喵。
test "Rows 正向迭代" {
  let rect = Rect::new(0, 0, 2, 3)
  let rows = Rows::new(rect)
  inspect(rows.size_hint().0, content="3")
  @debug.assert_eq(rows.next(), Some(Rect::new(0, 0, 2, 1)))
  inspect(rows.size_hint().0, content="2")
  @debug.assert_eq(rows.next(), Some(Rect::new(0, 1, 2, 1)))
  inspect(rows.size_hint().0, content="1")
  @debug.assert_eq(rows.next(), Some(Rect::new(0, 2, 2, 1)))
  inspect(rows.size_hint().0, content="0")
  @debug.assert_eq(rows.next(), None)
  inspect(rows.size_hint().0, content="0")
  @debug.assert_eq(rows.next_back(), None)
  inspect(rows.size_hint().0, content="0")
}

///|
/// 上游 `rows_back` 喵。
test "Rows 反向迭代" {
  let rect = Rect::new(0, 0, 2, 3)
  let rows = Rows::new(rect)
  @debug.assert_eq(rows.next_back(), Some(Rect::new(0, 2, 2, 1)))
  inspect(rows.size_hint().0, content="2")
  @debug.assert_eq(rows.next_back(), Some(Rect::new(0, 1, 2, 1)))
  inspect(rows.size_hint().0, content="1")
  @debug.assert_eq(rows.next_back(), Some(Rect::new(0, 0, 2, 1)))
  inspect(rows.size_hint().0, content="0")
  @debug.assert_eq(rows.next_back(), None)
  inspect(rows.size_hint().0, content="0")
  @debug.assert_eq(rows.next(), None)
  inspect(rows.size_hint().0, content="0")
}

///|
/// 上游 `rows_meet_in_the_middle` 喵。
test "Rows 双端相向迭代在中点相遇" {
  let rect = Rect::new(0, 0, 2, 4)
  let rows = Rows::new(rect)
  @debug.assert_eq(rows.next(), Some(Rect::new(0, 0, 2, 1)))
  @debug.assert_eq(rows.next_back(), Some(Rect::new(0, 3, 2, 1)))
  inspect(rows.size_hint().0, content="2")
  @debug.assert_eq(rows.next(), Some(Rect::new(0, 1, 2, 1)))
  @debug.assert_eq(rows.next_back(), Some(Rect::new(0, 2, 2, 1)))
  inspect(rows.size_hint().0, content="0")
  @debug.assert_eq(rows.next(), None)
  @debug.assert_eq(rows.next_back(), None)
  inspect(rows.size_hint().0, content="0")
}

///|
/// 上游 `columns` 喵。
test "Columns 正向迭代" {
  let rect = Rect::new(0, 0, 3, 2)
  let columns = Columns::new(rect)
  inspect(columns.size_hint().0, content="3")
  @debug.assert_eq(columns.next(), Some(Rect::new(0, 0, 1, 2)))
  @debug.assert_eq(columns.next(), Some(Rect::new(1, 0, 1, 2)))
  @debug.assert_eq(columns.next(), Some(Rect::new(2, 0, 1, 2)))
  @debug.assert_eq(columns.next(), None)
  @debug.assert_eq(columns.next_back(), None)
}

///|
/// 上游 `columns_back` 喵。
test "Columns 反向迭代" {
  let rect = Rect::new(0, 0, 3, 2)
  let columns = Columns::new(rect)
  @debug.assert_eq(columns.next_back(), Some(Rect::new(2, 0, 1, 2)))
  inspect(columns.size_hint().0, content="2")
  @debug.assert_eq(columns.next_back(), Some(Rect::new(1, 0, 1, 2)))
  @debug.assert_eq(columns.next_back(), Some(Rect::new(0, 0, 1, 2)))
  @debug.assert_eq(columns.next_back(), None)
  @debug.assert_eq(columns.next(), None)
}

///|
/// 上游 `columns_meet_in_the_middle` 喵。
test "Columns 双端相向迭代在中点相遇" {
  let rect = Rect::new(0, 0, 4, 2)
  let columns = Columns::new(rect)
  @debug.assert_eq(columns.next(), Some(Rect::new(0, 0, 1, 2)))
  @debug.assert_eq(columns.next_back(), Some(Rect::new(3, 0, 1, 2)))
  inspect(columns.size_hint().0, content="2")
  @debug.assert_eq(columns.next(), Some(Rect::new(1, 0, 1, 2)))
  @debug.assert_eq(columns.next_back(), Some(Rect::new(2, 0, 1, 2)))
  inspect(columns.size_hint().0, content="0")
  @debug.assert_eq(columns.next(), None)
  @debug.assert_eq(columns.next_back(), None)
}

///|
/// 上游 `columns_max`：正向跳过 65534 列后到达最后一列喵。
test "Columns 极大宽度正向" {
  let rect = Rect::new(0, 0, 65535, 1)
  let columns = Columns::new(rect).skip(65534)
  @debug.assert_eq(columns.next(), Some(Rect::new(65534, 0, 1, 1)))
  @debug.assert_eq(columns.next(), None)
}

///|
/// 上游 `columns_min`：反向跳过 65534 列后到达第一列喵。
test "Columns 极大宽度反向" {
  let rect = Rect::new(0, 0, 65535, 1)
  let columns = Columns::new(rect).rev().skip(65534)
  @debug.assert_eq(columns.next(), Some(Rect::new(0, 0, 1, 1)))
  @debug.assert_eq(columns.next(), None)
  @debug.assert_eq(columns.next(), None)
}

///|
/// 上游 `positions` 喵。
test "Positions 正向迭代" {
  let rect = Rect::new(0, 0, 2, 2)
  let positions = Positions::new(rect)
  inspect(positions.size_hint().0, content="4")
  @debug.assert_eq(positions.next(), Some(Position::new(0, 0)))
  @debug.assert_eq(positions.next(), Some(Position::new(1, 0)))
  @debug.assert_eq(positions.next(), Some(Position::new(0, 1)))
  @debug.assert_eq(positions.next(), Some(Position::new(1, 1)))
  @debug.assert_eq(positions.next(), None)
  inspect(positions.size_hint().0, content="0")
}

///|
/// 上游 `positions_zero_width` 喵。
test "Positions 零宽" {
  let rect = Rect::new(0, 0, 0, 1)
  let positions = Positions::new(rect)
  inspect(positions.size_hint().0, content="0")
  @debug.assert_eq(positions.next(), None)
}

///|
/// 上游 `positions_zero_height` 喵。
test "Positions 零高" {
  let rect = Rect::new(0, 0, 1, 0)
  let positions = Positions::new(rect)
  inspect(positions.size_hint().0, content="0")
  @debug.assert_eq(positions.next(), None)
}

///|
/// 上游 `positions_zero_by_zero` 喵。
test "Positions 零乘零" {
  let rect = Rect::new(0, 0, 0, 0)
  let positions = Positions::new(rect)
  inspect(positions.size_hint().0, content="0")
  @debug.assert_eq(positions.next(), None)
}
