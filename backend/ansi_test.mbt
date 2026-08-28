///|
test "frame_to_ansi 连续单元格只挪行不重复定位" {
  let buf = @core.Buffer::new(@core.Rect::new(0, 0, 3, 2))
  buf.set_string(0, 0, "abc", @core.Style::default())
  buf.set_string(0, 1, "def", @core.Style::default())
  let changes = buf.diff(@core.Buffer::new(@core.Rect::new(0, 0, 3, 2)))
  inspect(frame_to_ansi(changes), content="\u{1b}[1;1Habc\u{1b}[2;1Hdef")
}

///|
test "frame_to_ansi 锁定 SGR 增量协议" {
  let buf = @core.Buffer::new(@core.Rect::new(0, 0, 2, 1))
  buf.set_string(0, 0, "ab", @core.Style::of(true, Some(@core.Color::Red)))
  let changes = buf.diff(@core.Buffer::new(@core.Rect::new(0, 0, 2, 1)))
  // 帧首定位 + RESET + 加粗 + 红前景 + 字符 + 帧末收束
  inspect(
    frame_to_ansi(changes),
    content="\u{1b}[1;1H\u{1b}[0m\u{1b}[1m\u{1b}[31mab\u{1b}[0m",
  )
}

///|
test "sgr_transition 增量协议" {
  // 帧首默认样式：零噪音
  inspect(sgr_transition(@core.Style::default(), None), content="")
  // 帧首进入非默认：RESET 打底 + 逐项设置
  inspect(
    sgr_transition(@core.Style::of(true, None), None),
    content="\u{1b}[0m\u{1b}[1m",
  )
  // 样式未变化：空串
  inspect(
    sgr_transition(
      @core.Style::of(true, None),
      Some(@core.Style::of(true, None)),
    ),
    content="",
  )
  // 非默认回到默认：只 RESET
  inspect(
    sgr_transition(@core.Style::default(), Some(@core.Style::of(true, None))),
    content="\u{1b}[0m",
  )
  // 非默认之间切换：RESET 打底 + 新参数
  inspect(
    sgr_transition(
      @core.Style::of(false, Some(@core.Color::Green)),
      Some(@core.Style::of(true, None)),
    ),
    content="\u{1b}[0m\u{1b}[32m",
  )
}
