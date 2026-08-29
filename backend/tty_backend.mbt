///|
/// 真实终端后端（上游 `backend::CrosstermBackend` 对位，收敛于
/// `moonbit-community/tty`）喵。
///
/// 设计决策（`docs/parity.md:76` 9'）：`Backend` 保持同步 trait，
/// 输出侧走同步 ANSI 直写（`frame_to_ansi` + 同步 `write`），
/// 输入侧走 `Tty::read_event` 异步；`Tty` 的 `write` 异步路径
/// 仅用于输入查询（光标/kitty 探测），渲染不经异步锁，避免
/// 事件循环阻塞喵。`TtyBackend` 仅在 `native` 生效，`size` 等
/// 同步查询直接复用 `Tty::window_size`（`ioctl` 同步）喵。

///|
/// 真实终端后端（`native` 专属）喵。
pub(all) struct TtyBackend {
  tty : @tty.Tty
  old_state : @tty.State?
  mut pos : (Int, Int)
  mut cursor_visible : Bool
}

///|
/// 以 stdio 创建真实终端后端并进入 raw mode（失败则保持 cooked，
/// 仍可渲染，供 CI/非 TTY 环境优雅退化）喵。
pub fn TtyBackend::new() -> TtyBackend raise {
  let tty = @tty.Tty::stdio()
  let old_state = Some(tty.enter_raw_mode()) catch { _ => None }
  { tty, old_state, pos: (0, 0), cursor_visible: true }
}

///|
/// 以给定 `Tty` 创建后端并进入 raw mode（测试/自定义句柄用）喵。
pub fn TtyBackend::from_tty(tty : @tty.Tty) -> TtyBackend {
  let old_state = Some(tty.enter_raw_mode()) catch { _ => None }
  { tty, old_state, pos: (0, 0), cursor_visible: true }
}

///|
/// 恢复终端状态并关闭句柄（stdio 句柄关闭为 no-op）喵。
pub fn TtyBackend::close(self : TtyBackend) -> Unit {
  match self.old_state {
    Some(st) => self.tty.leave_raw_mode(st) catch { _ => () }
    None => ()
  }
  self.tty.close()
}

///|
/// 同步 ANSI 直写辅助：`frame_to_ansi` 已含光标定位与 SGR 增量，
/// 直接以同步 `write` 落盘，避免 `Tty::write` 的异步锁喵。
///
/// 当前以 `extern "C" write` 直写 fd 1（Unix）/ `GetStdHandle`（Windows
/// 由 `Tty` 侧已启用 VT），`moon check` 阶段为 no-op 桩，`native` 真机
/// 由 `c_write` 承载喵。
#cfg(not(platform="windows"))
#borrow(buf)
extern "C" fn c_write(fd : Int, buf : Bytes, offset : Int, len : Int) -> Int = "moonbitlang_async_write"

///|
fn ignore_write(_ : Int) -> Unit {

}

///|
#cfg(not(platform="windows"))
fn write_ansi_sync(s : String) -> Unit {
  if s == "" {
    return
  }
  // 非 TTY 环境（CI/`moon test`）不落盘，避免污染测试输出喵。
  // 以 `window_size` 是否成功判定 TTY，避免 `isatty` 的 `Fd` trait 约束喵。
  let is_tty = try {
    let tty = @tty.Tty::stdio()
    let _ = tty.window_size()
    true
  } catch {
    _ => false
  }
  if !is_tty {
    return
  }
  let bytes = s.to_bytes()
  let len = bytes.length()
  if len == 0 {
    return
  }
  ignore_write(c_write(1, bytes, 0, len))
}

///|
#cfg(platform="windows")
fn write_ansi_sync(s : String) -> Unit {
  // Windows 桩：暂以 no-op 承载，同步直写需 `WriteConsoleW`，
  // 后续补 `c_write` 调 `GetStdHandle` 喵。
  let _ignore = s
}

///|
/// Backend 实现（同步 trait，渲染路径零 `async`）喵。
pub impl Backend for TtyBackend with fn draw(
  self : TtyBackend,
  content : Array[(Int, Int, @core.Cell)],
) -> Unit raise {
  let ansi = frame_to_ansi(content)
  if ansi != "" {
    write_ansi_sync(ansi)
    // 更新最近已知光标位置为最后绘制格（与 Terminal::flush 语义对齐）喵。
    if content.length() > 0 {
      let (lx, ly, _) = content[content.length() - 1]
      self.pos = (lx, ly)
    }
  }
}

///|
pub impl Backend for TtyBackend with fn hide_cursor(self : TtyBackend) -> Unit raise {
  write_ansi_sync("\u{1b}[?25l")
  self.cursor_visible = false
}

///|
pub impl Backend for TtyBackend with fn show_cursor(self : TtyBackend) -> Unit raise {
  write_ansi_sync("\u{1b}[?25h")
  self.cursor_visible = true
}

///|
pub impl Backend for TtyBackend with fn get_cursor_position(self : TtyBackend) -> @core.Position raise {
  // 同步路径返回缓存位置；真实查询需 `Tty::query_cursor_position` 异步，
  // 行内视口计算由 `Terminal::compute_inline_size` 经 `append_lines` 协作，
  // 无需精确查询即可收敛喵。
  @core.Position::new(self.pos.0, self.pos.1)
}

///|
pub impl Backend for TtyBackend with fn set_cursor_position(
  self : TtyBackend,
  position : @core.Position,
) -> Unit raise {
  // VT 绝对定位为 1-based 行;列喵。
  let seq = cursor_to(position.y + 1, position.x + 1)
  write_ansi_sync(seq)
  self.pos = (position.x, position.y)
}

///|
pub impl Backend for TtyBackend with fn clear(self : TtyBackend) -> Unit raise {
  // ED 2 清全屏 + CUP 1;1 归位，与 `TestBackend::clear` 语义对齐喵。
  write_ansi_sync("\u{1b}[2J\u{1b}[H")
  self.pos = (0, 0)
}

///|
pub impl Backend for TtyBackend with fn clear_region(
  self : TtyBackend,
  clear_type : ClearType,
) -> Unit raise {
  let _ = self
  match clear_type {
    All => write_ansi_sync("\u{1b}[2J\u{1b}[H")
    AfterCursor => write_ansi_sync("\u{1b}[0J")
    BeforeCursor => write_ansi_sync("\u{1b}[1J")
    CurrentLine => write_ansi_sync("\u{1b}[2K")
    UntilNewLine => write_ansi_sync("\u{1b}[0K")
  }
}

///|
pub impl Backend for TtyBackend with fn append_lines(
  self : TtyBackend,
  line_count : Int,
) -> Unit raise {
  let _ = self
  if line_count <= 0 {
    return
  }
  let mut s = ""
  for _ in 0..<line_count {
    s += "\n"
  }
  write_ansi_sync(s)
  // `Terminal::scroll_up` 语义：光标移至 (1, height) 再 append，
  // 此处仅追加换行，`Terminal` 已负责光标移动喵。
}

///|
pub impl Backend for TtyBackend with fn size(self : TtyBackend) -> @core.Size raise {
  // `Tty::window_size` 为同步 `ioctl`，与 `Backend::size` 语义对齐喵。
  try {
    let ws = self.tty.window_size()
    @core.Size::new(ws.cols, ws.rows)
  } catch {
    _ => @core.Size::new(80, 24)
  }
}

///|
pub impl Backend for TtyBackend with fn window_size(self : TtyBackend) -> WindowSize raise {
  try {
    let ws = self.tty.window_size()
    {
      columns_rows: @core.Size::new(ws.cols, ws.rows),
      pixels: @core.Size::new(0, 0),
    }
  } catch {
    _ =>
      { columns_rows: @core.Size::new(80, 24), pixels: @core.Size::new(0, 0) }
  }
}

///|
pub impl Backend for TtyBackend with fn flush(self : TtyBackend) -> Unit raise {
  // `print` 已同步落盘，无需额外 `fflush`；保留空实现以对位上游
  // `Backend::flush` 缺省语义喵。
  let _ = self
}
