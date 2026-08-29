///|
/// 极简实战示例：无中文、无 raw mode、无输入阻塞，纯 ASCII 渲染
/// 兼容 TTY 与非 TTY（CI）喵。

fn main {
  let use_tty = try {
    let tty = @tty.Tty::stdio()
    let _ = tty.window_size()
    true
  } catch {
    _ => false
  }
  if use_tty {
    run_tty()
  } else {
    run_test_backend()
  }
}

fn run_tty() -> Unit {
  let backend = try {
    @backend.TtyBackend::new()
  } catch {
    e => {
      println("TtyBackend::new failed: \{e}")
      run_test_backend()
      return
    }
  }
  let terminal = try {
    @terminal.Terminal::new(backend)
  } catch {
    e => {
      println("Terminal::new failed: \{e}")
      backend.close()
      return
    }
  }
  // 直接渲染一帧，不进入 alt screen，不读输入，2 秒后自动清屏退出，避免 raw mode 残留喵。
  try {
    let _ = terminal.draw(fn(frame) { render(frame) })
  } catch {
    e => println("draw failed: \{e}")
  }
  let _ = sleep_secs(2)
  // 清屏并恢复光标，避免残留喵。
  try {
    backend.clear()
    backend.show_cursor()
    backend.flush()
  } catch {
    _ => ()
  }
  backend.close()
  println("done (tty) 喵")
}

fn run_test_backend() -> Unit {
  let backend = @backend.TestBackend::new_with_size(80, 24)
  let terminal = @terminal.Terminal::new(backend) catch {
    _ => return
  }
  try {
    let _ = terminal.draw(fn(frame) { render(frame) })
  } catch {
    _ => ()
  }
  // 非 TTY 环境直接打印 ANSI 预览（`\\x1b` 可视化），便于 CI 查看喵。
  let ansi = backend.last_ansi()
  println("TestBackend 80x24 ANSI len=\{ansi.length()}")
  let preview = if ansi.length() > 200 { ansi[0:200].to_string() } else { ansi }
  println(preview.replace_all(old="\u{1b}", new="\\x1b"))
}

fn render(frame : @terminal.Frame) -> Unit {
  let area = frame.area()
  let chunks = @layout.Layout::vertical([
    @core.Length(3),
    @core.Fill(1),
    @core.Length(3),
  ]).split(area)
  let header = @widgets.Block::new()
    .title_str(" ratatui4moon eg2 - ASCII only ")
    .borders(@widgets.Borders::all())
  let header_para = @widgets.Paragraph::of_str(" Pure MoonBit / Zero FFI / Double/f64 / 770 tests ")
    .alignment(@core.Alignment::Center)
    .block(header)
  header_para.render(chunks[0], frame.buffer_mut())

  let body = @layout.Layout::horizontal([
    @core.Percentage(30),
    @core.Percentage(70),
  ]).split(chunks[1])
  let left = @widgets.Block::new().title_str(" Nav ").borders(@widgets.Borders::all())
  left.render(body[0], frame.buffer_mut())
  let inner = body[0].inner(@core.Margin::new(1, 1))
  @widgets.Paragraph::of_str(" * Block\n * Paragraph\n * List/Tabs\n * Gauge\n * Sparkline\n * Table/Canvas").render(inner, frame.buffer_mut())

  let right = @layout.Layout::vertical([
    @core.Length(3),
    @core.Length(5),
    @core.Fill(1),
  ]).split(body[1])
  @widgets.Gauge::default()
    .block(@widgets.Block::new().title_str(" Gauge 64% ").borders(@widgets.Borders::all()))
    .gauge_style(@core.Style::new().fg(@core.Color::Green))
    .percent(64)
    .render(right[0], frame.buffer_mut())
  @widgets.Sparkline::default()
    .block(@widgets.Block::new().title_str(" Sparkline ").borders(@widgets.Borders::all()))
    .data([1, 5, 2, 8, 3, 9, 4, 7, 6, 5, 8, 2])
    .style(@core.Style::new().fg(@core.Color::Cyan))
    .render(right[1], frame.buffer_mut())
  @widgets.Paragraph::of_str(" Table: ratatui 0.30.2 OK / kasuari 0.4.12 OK")
    .block(@widgets.Block::new().title_str(" Table ").borders(@widgets.Borders::all()))
    .render(right[2], frame.buffer_mut())

  let footer = @widgets.Block::new().title_str(" Footer ").borders(@widgets.Borders::all())
  @widgets.Paragraph::of_str(" size=\{area.width}x\{area.height}  |  sync ANSI fd1  |  no raw input ")
    .alignment(@core.Alignment::Center)
    .block(footer)
    .render(chunks[2], frame.buffer_mut())
}

extern "C" fn sleep_secs(secs : Int) -> Int = "sleep"
