///|
/// ratatui4moon 终端实战示例：`TtyBackend` 直驱真机喵。
///
/// 布局：纵向 Header(3) + Body(Fill) + Footer(3)
/// Body 横向：左侧 Paragraph(30%) + 右侧纵向 Gauge/Sparkline/Paragraph
/// 操作：任意键退出；非 TTY 自动回退 TestBackend 打印 ANSI 长度喵。
async fn main {
  let tty = @tty.Tty::stdio() catch {
    _ => {
      run_with_test_backend()
      return
    }
  }
  let is_tty = try {
    let _ = tty.window_size()
    true
  } catch {
    _ => false
  }
  if !is_tty {
    run_with_test_backend()
    return
  }
  let backend = @backend.TtyBackend::from_tty(tty)
  let terminal = @terminal.Terminal::new(backend) catch {
    e => {
      println("Terminal::new 失败: \{e}")
      backend.close()
      return
    }
  }
  try {
    let _ = terminal.draw(fn(frame) { render_dashboard(frame) })
  } catch {
    e => println("draw 失败: \{e}")
  }
  println("\n[ eg ] 按任意键退出…")
  let _ = tty.read_event()
  backend.close()
  println("Bye~ 喵")
}

///|
fn run_with_test_backend() -> Unit {
  let backend = @backend.TestBackend::new_with_size(80, 24)
  let terminal = @terminal.Terminal::new(backend) catch { _ => return }
  try {
    let _ = terminal.draw(fn(frame) { render_dashboard(frame) })
  } catch {
    _ => ()
  }
  let ansi = backend.last_ansi()
  println("[非 TTY 回退] TestBackend 80x24，ANSI 长度=\{ansi.length()}")
  let preview = if ansi.length() > 120 { ansi[0:120].to_owned() } else { ansi }
  let visible = preview.replace_all(old="\u{1b}", new="\\x1b")
  println(visible)
}

///|
fn render_dashboard(frame : @terminal.Frame) -> Unit {
  let area = frame.area()
  let v_chunks = @layout.Layout::vertical([
    @core.Length(3),
    @core.Fill(1),
    @core.Length(3),
  ]).split(area)
  let header_area = v_chunks[0]
  let body_area = v_chunks[1]
  let footer_area = v_chunks[2]

  let header_block = @widgets.Block::new()
    .title_str(" ratatui4moon eg — TtyBackend 仪表盘 ")
    .borders(@widgets.Borders::all())
    .border_type(@widgets.BorderType::Double)
  let header_para = @widgets.Paragraph::of_str(
      "  纯 MoonBit · 零 FFI · Double/f64 精度 · 770 测全绿  ",
    )
    .alignment(@core.Alignment::Center)
    .block(header_block)
  header_para.render(header_area, frame.buffer_mut())

  let h_chunks = @layout.Layout::horizontal([
    @core.Percentage(30),
    @core.Percentage(70),
  ]).split(body_area)
  let left_area = h_chunks[0]
  let right_area = h_chunks[1]

  let left_block = @widgets.Block::new()
    .title_str(" 导航 ")
    .borders(@widgets.Borders::all())
  left_block.render(left_area, frame.buffer_mut())
  let inner_left = left_area.inner(@core.Margin::new(1, 1))
  let left_para = @widgets.Paragraph::of_str(
    "● Block / Paragraph\n● List / Tabs\n● Gauge / Sparkline\n● BarChart / Table\n● Canvas / Chart\n● TtyBackend 同步桥",
  )
  left_para.render(inner_left, frame.buffer_mut())

  let r_chunks = @layout.Layout::vertical([
    @core.Length(3),
    @core.Length(5),
    @core.Fill(1),
  ]).split(right_area)

  let gauge = @widgets.Gauge::default()
    .block(
      @widgets.Block::new()
      .title_str(" Gauge 64% ")
      .borders(@widgets.Borders::all()),
    )
    .gauge_style(@core.Style::new().fg(@core.Color::Green))
    .percent(64)
  gauge.render(r_chunks[0], frame.buffer_mut())

  let spark = @widgets.Sparkline::default()
    .block(
      @widgets.Block::new()
      .title_str(" Sparkline ")
      .borders(@widgets.Borders::all()),
    )
    .data([1, 5, 2, 8, 3, 9, 4, 7, 6, 5, 8, 2])
    .style(@core.Style::new().fg(@core.Color::Cyan))
  spark.render(r_chunks[1], frame.buffer_mut())

  let right_para = @widgets.Paragraph::of_str(
    " Table 区域（Layout 驱动列宽）：\n ratatui 0.30.2  ✅\n kasuari 0.4.12  ✅\n unicode-width 0.2.2 ✅",
  ).block(
    @widgets.Block::new().title_str(" Table ").borders(@widgets.Borders::all()),
  )
  right_para.render(r_chunks[2], frame.buffer_mut())

  let footer_block = @widgets.Block::new()
    .title_str(" Footer ")
    .borders(@widgets.Borders::all())
  let footer_text = "  按任意键退出  ·  TtyBackend 同步直写 fd 1 / GetStdHandle  ·  size=\{area.width}x\{area.height}  "
  let footer_para = @widgets.Paragraph::of_str(footer_text)
    .alignment(@core.Alignment::Center)
    .block(footer_block)
  footer_para.render(footer_area, frame.buffer_mut())
}
