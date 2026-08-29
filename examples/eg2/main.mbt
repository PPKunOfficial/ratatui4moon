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

///|
fn run_tty() -> Unit {
  let backend = @backend.TtyBackend::new() catch {
    e => {
      println("TtyBackend::new failed: \{e}")
      run_test_backend()
      return
    }
  }
  let terminal = @terminal.Terminal::new(backend) catch {
    e => {
      println("Terminal::new failed: \{e}")
      backend.close()
      return
    }
  }
  try {
    let _ = terminal.draw(fn(frame) { render(frame) })
  } catch {
    e => println("draw failed: \{e}")
  }
  let _ = sleep_secs(2)
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

///|
fn run_test_backend() -> Unit {
  let backend = @backend.TestBackend::new_with_size(80, 24)
  let terminal = @terminal.Terminal::new(backend) catch { _ => return }
  try {
    let _ = terminal.draw(fn(frame) { render(frame) })
  } catch {
    _ => ()
  }
  println("=== TestBackend 80x24 buffer_view ===")
  println(backend.to_display())
  println("=== last_ansi len=\{backend.last_ansi().length()} ===")
  let ansi = backend.last_ansi()
  let preview = if ansi.length() > 300 { ansi[0:300].to_string() } else { ansi }
  println(preview.replace_all(old="\u{1b}", new="\\x1b"))
}

///|
fn render(frame : @terminal.Frame) -> Unit {
  let area = frame.area()
  let v_chunks = @layout.Layout::vertical([
    @core.Length(3),
    @core.Fill(1),
    @core.Length(3),
  ]).split(area)
  let header_block = @widgets.Block::new()
    .title_str(" ratatui4moon eg2 ")
    .borders(@widgets.Borders::all())
  let header_para = @widgets.Paragraph::of_str(
      " Pure MoonBit  Zero FFI  Double/f64  770 tests ",
    )
    .alignment(@core.Alignment::Center)
    .block(header_block)
  header_para.render(v_chunks[0], frame.buffer_mut())

  let body = @layout.Layout::horizontal([
    @core.Percentage(30),
    @core.Percentage(70),
  ]).split(v_chunks[1])
  let left_block = @widgets.Block::new()
    .title_str(" Nav ")
    .borders(@widgets.Borders::all())
  left_block.render(body[0], frame.buffer_mut())
  let inner = body[0].inner(@core.Margin::new(1, 1))
  @widgets.Paragraph::of_str(
    "  Block\n  Paragraph\n  List/Tabs\n  Gauge\n  Sparkline\n  Canvas/Chart",
  ).render(inner, frame.buffer_mut())

  let right = @layout.Layout::vertical([
    @core.Length(3),
    @core.Length(7),
    @core.Fill(1),
  ]).split(body[1])
  @widgets.Gauge::default()
  .block(
    @widgets.Block::new().title_str(" Gauge ").borders(@widgets.Borders::all()),
  )
  .gauge_style(@core.Style::new().fg(@core.Color::Green))
  .percent(64)
  .render(right[0], frame.buffer_mut())
  @widgets.Sparkline::default()
  .block(
    @widgets.Block::new()
    .title_str(" Sparkline ")
    .borders(@widgets.Borders::all()),
  )
  .data([0, 2, 4, 6, 8, 7, 5, 3, 1, 3, 5, 7, 9, 8, 6, 4, 2, 4, 6, 8, 9, 7, 5, 3])
  .style(@core.Style::new().fg(@core.Color::Cyan))
  .render(right[1], frame.buffer_mut())
  @widgets.Paragraph::of_str(
    " Table: ratatui 0.30.2 OK\n kasuari 0.4.12 OK\n unicode 0.2.2 OK",
  )
  .block(
    @widgets.Block::new().title_str(" Table ").borders(@widgets.Borders::all()),
  )
  .render(right[2], frame.buffer_mut())

  let footer_block = @widgets.Block::new()
    .title_str(" Footer ")
    .borders(@widgets.Borders::all())
  @widgets.Paragraph::of_str(" size=\{area.width}x\{area.height}  sync fd1 ")
  .alignment(@core.Alignment::Center)
  .block(footer_block)
  .render(v_chunks[2], frame.buffer_mut())
}

///|
extern "C" fn sleep_secs(secs : Int) -> Int = "sleep"
