///|
test "set_string 越界裁剪" {
  let buf = Buffer::new(Rect::new(0, 0, 5, 2))
  buf.set_string(3, 0, "abcdef", Style::default())
  inspect(
    buf.get(3, 0).ch,
    content=(
      #|a
    ),
  )
  inspect(
    buf.get(4, 0).ch,
    content=(
      #|b
    ),
  )
  // 越界部分被裁剪，保持空白
  inspect(
    buf.get(5, 0).ch,
    content=(
      #| 
    ),
  )
}

///|
test "非原点坐标系按绝对坐标读写" {
  let buf = Buffer::new(Rect::new(10, 5, 4, 2))
  buf.set_string(10, 5, "abcd", Style::default())
  inspect(
    buf.get(10, 5).ch,
    content=(
      #|a
    ),
  )
  inspect(
    buf.get(13, 5).ch,
    content=(
      #|d
    ),
  )
  // 区域外写入被忽略
  buf.set_cell(9, 5, 'z', Style::default())
  inspect(
    buf.get(9, 5).ch,
    content=(
      #| 
    ),
  )
}

///|
test "diff 只报告变化单元格且坐标为绝对坐标" {
  let area = Rect::new(0, 0, 3, 2)
  let prev = Buffer::new(area)
  let next = Buffer::new(area)
  next.set_cell(1, 0, 'x', Style::default())
  next.set_cell(0, 1, 'y', Style::default())
  let changes = next.diff(prev)
  inspect(changes.length(), content="2")
  inspect(changes[0].0, content="1")
  inspect(changes[0].1, content="0")
  inspect(changes[1].0, content="0")
  inspect(changes[1].1, content="1")
}

///|
test "空区域优雅退化" {
  let area = Rect::new(0, 0, 0, 3)
  let buf = Buffer::new(area)
  buf.set_string(0, 0, "anything", Style::default())
  inspect(buf.diff(Buffer::new(area)).length(), content="0")
}
