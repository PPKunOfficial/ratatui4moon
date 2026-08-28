///|
/// ANSI 引擎单元测试：锁定 SGR 增量协议与帧协议喵。
///
/// sgr 协议参照上游 crossterm 后端行为：修饰位在前、颜色在后；
/// 基线（Reset/Reset/无修饰）零噪音；颜色 SGR 参数映射对位
/// ratatui 的 crossterm `SetColors`/`SetAttributes` 语义喵。

///|
test "frame_to_ansi 连续单元格只挪行不重复定位" {
  let buf = @core.Buffer::new(@core.Rect::new(0, 0, 3, 2))
  buf.set_string(0, 0, "abc", @core.Style::default())
  buf.set_string(0, 1, "def", @core.Style::default())
  let changes = @core.Buffer::new(@core.Rect::new(0, 0, 3, 2)).diff(buf)
  inspect(frame_to_ansi(changes), content="\u{1b}[1;1Habc\u{1b}[2;1Hdef")
}

///|
test "frame_to_ansi 锁定 SGR 增量协议" {
  let buf = @core.Buffer::new(@core.Rect::new(0, 0, 2, 1))
  buf.set_string(
    0,
    0,
    "ab",
    @core.Style::new().fg(@core.Color::Red).add_modifier(@core.Modifier::bold()),
  )
  let changes = @core.Buffer::new(@core.Rect::new(0, 0, 2, 1)).diff(buf)
  // 帧首定位 + RESET + 加粗 + 红前景（背景未变不发射）+ 字符 + 帧末收束
  inspect(
    frame_to_ansi(changes),
    content="\u{1b}[1;1H\u{1b}[0m\u{1b}[1m\u{1b}[31mab\u{1b}[0m",
  )
}

///|
test "sgr_transition 增量协议" {
  // 帧首默认样式：零噪音
  inspect(sgr_transition(@core.Style::default(), None), content="")
  // 帧首进入非基线：RESET 打底 + 逐项设置
  inspect(
    sgr_transition(
      @core.Style::new().add_modifier(@core.Modifier::bold()),
      None,
    ),
    content="\u{1b}[0m\u{1b}[1m",
  )
  // 样式未变化：空串
  let bold = @core.Style::new().add_modifier(@core.Modifier::bold())
  inspect(sgr_transition(bold, Some(bold)), content="")
  // 非基线回到基线：只 RESET
  inspect(
    sgr_transition(@core.Style::default(), Some(bold)),
    content="\u{1b}[0m",
  )
  // 非基线之间切换：RESET 打底 + 新参数
  inspect(
    sgr_transition(@core.Style::new().fg(@core.Color::Green), Some(bold)),
    content="\u{1b}[0m\u{1b}[32m",
  )
}

///|
test "sgr_transition 背景与组合发射" {
  // 背景色走 40 段
  inspect(
    sgr_transition(@core.Style::new().bg(@core.Color::Blue), None),
    content="\u{1b}[0m\u{1b}[44m",
  )
  // 修饰位在前、颜色在后，多修饰位升序连接
  inspect(
    sgr_transition(
      @core.Style::new()
      .fg(@core.Color::Red)
      .bg(@core.Color::Blue)
      .add_modifier(@core.Modifier::italic().insert(@core.Modifier::bold())),
      None,
    ),
    content="\u{1b}[0m\u{1b}[1;3m\u{1b}[31m\u{1b}[44m",
  )
}

///|
test "sgr_transition 亮色与真彩色映射" {
  // 亮色走 90 段 / 100 段
  inspect(
    sgr_transition(@core.Style::new().fg(@core.Color::DarkGray), None),
    content="\u{1b}[0m\u{1b}[90m",
  )
  inspect(
    sgr_transition(@core.Style::new().bg(@core.Color::White), None),
    content="\u{1b}[0m\u{1b}[107m",
  )
  // 真彩色 38;2 / 48;2
  inspect(
    sgr_transition(@core.Style::new().fg(@core.Color::Rgb(255, 128, 0)), None),
    content="\u{1b}[0m\u{1b}[38;2;255;128;0m",
  )
  inspect(
    sgr_transition(@core.Style::new().bg(@core.Color::Rgb(0, 0, 0)), None),
    content="\u{1b}[0m\u{1b}[48;2;0;0;0m",
  )
  // 索引色 38;5 / 48;5
  inspect(
    sgr_transition(@core.Style::new().fg(@core.Color::Indexed(10)), None),
    content="\u{1b}[0m\u{1b}[38;5;10m",
  )
  // 显式 Reset 与基线同态：零噪音
  inspect(
    sgr_transition(
      @core.Style::new().fg(@core.Color::Reset).bg(@core.Color::Reset),
      None,
    ),
    content="",
  )
}
