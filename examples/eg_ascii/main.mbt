///|
/// ASCII 极简，无边框，无 UTF-8 箱线，确保任意终端不乱码喵。
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
    run_test()
  }
}

///|
fn run_tty() -> Unit {
  let backend = @backend.TtyBackend::new() catch {
    _ => {
      run_test()
      return
    }
  }
  let terminal = @terminal.Terminal::new(backend) catch {
    _ => {
      backend.close()
      return
    }
  }
  try {
    let _ = terminal.draw(fn(frame) { render(frame) })
  } catch {
    _ => ()
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
}

///|
fn run_test() -> Unit {
  let backend = @backend.TestBackend::new_with_size(80, 24)
  let terminal = @terminal.Terminal::new(backend) catch { _ => return }
  try {
    let _ = terminal.draw(fn(frame) { render(frame) })
  } catch {
    _ => ()
  }
  println(backend.to_display())
}

///|
fn render(frame : @terminal.Frame) -> Unit {
  let area = frame.area()
  let v = @layout.Layout::vertical([
    @core.Length(1),
    @core.Fill(1),
    @core.Length(1),
  ]).split(area)
  @widgets.Paragraph::of_str(" ratatui4moon  eg_ascii  770 tests  Double/f64 ")
  .alignment(@core.Alignment::Center)
  .render(v[0], frame.buffer_mut())
  let body = @layout.Layout::horizontal([
    @core.Percentage(30),
    @core.Percentage(70),
  ]).split(v[1])
  @widgets.Paragraph::of_str(
    " Nav:\n  Block\n  Paragraph\n  List\n  Gauge\n  Sparkline",
  ).render(body[0], frame.buffer_mut())
  let r = @layout.Layout::vertical([
    @core.Length(3),
    @core.Length(5),
    @core.Fill(1),
  ]).split(body[1])
  @widgets.Gauge::default().percent(64).render(r[0], frame.buffer_mut())
  @widgets.Sparkline::default()
  .data([0, 2, 4, 6, 8, 7, 5, 3, 1, 3, 5, 7, 9, 8, 6, 4, 2, 4, 6, 8])
  .render(r[1], frame.buffer_mut())
  @widgets.Paragraph::of_str(" Table: ratatui 0.30.2 OK | kasuari 0.4.12 OK").render(
    r[2],
    frame.buffer_mut(),
  )
  @widgets.Paragraph::of_str(" size=\{area.width}x\{area.height} ")
  .alignment(@core.Alignment::Center)
  .render(v[2], frame.buffer_mut())
}

///|
extern "C" fn sleep_secs(s : Int) -> Int = "sleep"
