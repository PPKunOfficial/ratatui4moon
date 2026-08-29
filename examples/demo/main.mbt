///|
fn main {
  // Demo: TtyBackend with Terminal
  let backend = @backend.TtyBackend::new() catch {
    e => {
      run_fallback(e.to_string())
      return
    }
  }
  let terminal = @terminal.Terminal::new(backend) catch {
    e => {
      backend.close()
      run_fallback(e.to_string())
      return
    }
  }
  let size = backend.size() catch { _ => @core.Size::new(80, 24) }
  println("TtyBackend created, size=\{size.width}x\{size.height}")
  try {
    let _ = terminal.draw(fn(frame) {
      let area = frame.area()
      let para = @widgets.Paragraph::of_str("Hello TtyBackend!")
      para.render(area, frame.buffer_mut())
    })
  } catch {
    _ => ()
  }
  println("Draw succeeded")
  backend.close()
}

///|
fn run_fallback(reason : String) -> Unit {
  println("TtyBackend unavailable (\{reason}), using TestBackend fallback")
  let tb = @backend.TestBackend::new_with_size(80, 24)
  let terminal = @terminal.Terminal::new(tb) catch {
    err => {
      println("Terminal::new failed: \{err}")
      return
    }
  }
  try {
    let _ = terminal.draw(fn(frame) {
      let area = frame.area()
      let para = @widgets.Paragraph::of_str("Hello ratatui4moon (TestBackend)!")
      para.render(area, frame.buffer_mut())
    })
  } catch {
    _ => ()
  }
  println("Fallback draw succeeded, last_ansi_len=\{tb.last_ansi().length()}")
}
