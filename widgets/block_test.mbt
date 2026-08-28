///|
test "Block 绘制四角与边线" {
  let buf = @core.Buffer::new(@core.Rect::new(0, 0, 4, 3))
  Block::new().render(@core.Rect::new(0, 0, 4, 3), buf)
  inspect(
    buf.get(0, 0).symbol(),
    content=(
      #|┌
    ),
  )
  inspect(
    buf.get(3, 0).symbol(),
    content=(
      #|┐
    ),
  )
  inspect(
    buf.get(0, 2).symbol(),
    content=(
      #|└
    ),
  )
  inspect(
    buf.get(3, 2).symbol(),
    content=(
      #|┘
    ),
  )
  inspect(
    buf.get(1, 0).symbol(),
    content=(
      #|─
    ),
  )
  inspect(
    buf.get(2, 0).symbol(),
    content=(
      #|─
    ),
  )
  inspect(
    buf.get(0, 1).symbol(),
    content=(
      #|│
    ),
  )
  inspect(
    buf.get(3, 1).symbol(),
    content=(
      #|│
    ),
  )
  // 内部不被 Block 碰
  inspect(
    buf.get(1, 1).symbol(),
    content=(
      #| 
    ),
  )
  inspect(
    buf.get(2, 1).symbol(),
    content=(
      #| 
    ),
  )
}

///|
test "Block 不足 2x2 优雅退化" {
  let buf = @core.Buffer::new(@core.Rect::new(0, 0, 3, 2))
  Block::new().render(@core.Rect::new(0, 0, 3, 1), buf)
  Block::new().render(@core.Rect::new(0, 0, 1, 2), buf)
  Block::new().render(@core.Rect::new(0, 0, 1, 1), buf)
  inspect(
    @core.Buffer::new(@core.Rect::new(0, 0, 3, 2)).diff(buf).length(),
    content="0",
  )
}

///|
test "Block 在非原点区域与偏移坐标对齐" {
  let area = @core.Rect::new(10, 5, 5, 3)
  let buf = @core.Buffer::new(area)
  Block::new().render(area, buf)
  inspect(
    buf.get(10, 5).symbol(),
    content=(
      #|┌
    ),
  )
  inspect(
    buf.get(14, 7).symbol(),
    content=(
      #|┘
    ),
  )
  inspect(
    buf.get(12, 5).symbol(),
    content=(
      #|─
    ),
  )
  inspect(
    buf.get(14, 6).symbol(),
    content=(
      #|│
    ),
  )
}

///|
test "Block 样式作用于边框" {
  let buf = @core.Buffer::new(@core.Rect::new(0, 0, 3, 2))
  let block = Block::styled(
    @core.Style::new().fg(@core.Color::Red).add_modifier(@core.Modifier::bold()),
  )
  block.render(@core.Rect::new(0, 0, 3, 2), buf)
  inspect(
    buf.get(0, 0).style().has_modifier(@core.Modifier::bold()),
    content="true",
  )
  @debug.assert_eq(buf.get(0, 0).style().fg, Some(@core.Color::Red))
  @debug.assert_eq(buf.get(2, 1).style().fg, Some(@core.Color::Red))
}
