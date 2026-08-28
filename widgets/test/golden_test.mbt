///|
/// 黄金 ANSI 快照：ratatui4moon 的验收形式喵。
///
/// 全链路：widget 渲染 → Buffer 差分 → TestBackend 录帧 → 精确 ANSI
/// 字符串断言。零真实终端、零 I/O、完全确定性；快照更新只走
/// `moon test --update`，禁止手改 content 字符串喵。
/// 注：ESC 以 `\u{1b}` 转义书写，保证源码可读、diff 可见；差分跳过
/// 未变化单元格，故快照中可见光标跳跃（如 `[2;9H`），属预期行为喵。

///|
/// v0.1 首个黄金快照：带边框的 hello 框（纯 ASCII，宽度表接入前先立管线）喵。
test "带边框 hello 的 ANSI 黄金快照" {
  let area = @core.Rect::new(0, 0, 16, 3)
  let buf = @core.Buffer::new(area)
  @widgets.Block::new().render(area, buf)
  buf.set_string(1, 1, "hello, ratatui", @core.Style::default())
  let t = @backend.TestBackend::new()
  t.draw(buf.diff(@core.Buffer::new(area)))
  inspect(
    t.last_ansi(),
    content="\u{1b}[1;1H┌──────────────┐\u{1b}[2;1H│hello,\u{1b}[2;9Hratatui│\u{1b}[3;1H└──────────────┘",
  )
}

///|
/// 带样式的黄金快照：锁定"光标定位 + SGR 增量"联合协议喵。
test "带加粗红字内容的黄金快照" {
  let area = @core.Rect::new(0, 0, 10, 3)
  let buf = @core.Buffer::new(area)
  @widgets.Block::new().render(area, buf)
  buf.set_string(1, 1, "hi", @core.Style::of(true, Some(@core.Color::Red)))
  let t = @backend.TestBackend::new()
  t.draw(buf.diff(@core.Buffer::new(area)))
  inspect(
    t.last_ansi(),
    content="\u{1b}[1;1H┌────────┐\u{1b}[2;1H│\u{1b}[0m\u{1b}[1m\u{1b}[31mhi\u{1b}[2;10H\u{1b}[0m│\u{1b}[3;1H└────────┘",
  )
}

///|
/// 多帧录帧：只有最近一帧参与 `last_ansi`，帧数可断言喵。
test "多帧录制与取帧" {
  let area = @core.Rect::new(0, 0, 4, 1)
  let t = @backend.TestBackend::new()
  let first = @core.Buffer::new(area)
  first.set_string(0, 0, "ab", @core.Style::default())
  t.draw(first.diff(@core.Buffer::new(area)))
  let second = @core.Buffer::new(area)
  second.set_string(0, 0, "cd", @core.Style::default())
  t.draw(second.diff(first))
  inspect(t.frame_count(), content="2")
  // 第二帧只含两个变化单元格
  inspect(t.last_ansi(), content="\u{1b}[1;1Hcd")
}
