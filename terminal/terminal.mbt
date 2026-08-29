// 终端会话层（上游 `ratatui-core/src/terminal.rs` + terminal/{frame,
// buffers,backend,viewport,cursor,render,resize,init}.rs）：双缓冲
// Terminal + Frame 即时渲染管线喵。
//
// 载体折算登记：
// - 上游 `Terminal<B>` 泛型以 `&Backend` trait 对象承载；
// - 上游 `Backend::Result<T, B::Error>` 以 `raise Error`（Failure）
//   承载；
// - 上游 `Drop for Terminal`（恢复光标可见性）无 MoonBit 对应物，
//   登记缓议；
// - `insert_before` 等行内视口管理 API 随 inline.rs 后续批次落地。

///|
/// 终端绘制区域模式（上游 `terminal::Viewport`）喵。
pub(all) enum Viewport {
  /// 占满整个终端（`Terminal::new` 缺省，原点恒为 (0,0)，随终端
  /// 尺寸自动重排）喵。
  Fullscreen
  /// 行内视口：横跨终端全宽，锚定创建时光标行（`Inline(height)`，
  /// 高度钳制到终端高度）喵。
  Inline(Int)
  /// 固定区域：以终端坐标给定的矩形，不自动重排喵。
  Fixed(@core.Rect)
} derive(Eq, Debug)

///|
/// 缺省视口（上游 `Viewport::default` = `Fullscreen`）喵。
pub fn Viewport::default() -> Viewport {
  Fullscreen
}

///|
/// Display 语义（上游 `Display for Viewport`）喵。
pub fn Viewport::to_display(self : Viewport) -> String {
  match self {
    Fullscreen => "Fullscreen"
    Inline(height) => "Inline(\{height})"
    Fixed(area) => "Fixed(\{area.to_display()})"
  }
}

///|
/// `Terminal::with_options` 的选项（上游 `TerminalOptions`）喵。
pub(all) struct TerminalOptions {
  viewport : Viewport
} derive(Eq, Debug)

///|
/// 缺省选项（上游 `TerminalOptions::default`）喵。
pub fn TerminalOptions::default() -> TerminalOptions {
  { viewport: Fullscreen }
}

///|
/// 一帧渲染完成后的快照（上游 `CompletedFrame`）：缓冲 + 渲染区域
/// + 帧序号喵。
pub struct CompletedFrame {
  buffer : @core.Buffer
  area : @core.Rect
  count : Int
} derive(Debug)

///|
/// 帧序号（上游 `CompletedFrame::count`）喵。
pub fn CompletedFrame::count(self : CompletedFrame) -> Int {
  self.count
}

///|
/// 渲染区域（上游 `CompletedFrame::area`）喵。
pub fn CompletedFrame::area(self : CompletedFrame) -> @core.Rect {
  self.area
}

///|
/// 渲染缓冲（上游 `CompletedFrame::buffer`）喵。
pub fn CompletedFrame::buffer(self : CompletedFrame) -> @core.Buffer {
  self.buffer
}

///|
/// 单帧渲染上下文（上游 `terminal::Frame`）：当前缓冲 + 视口区域
/// + 可选光标位置 + 帧序号喵。
pub struct Frame {
  /// 本帧渲染期间由 `set_cursor_position` 设置的光标位置喵。
  mut cursor_position : @core.Position?
  viewport_area : @core.Rect
  buffer : @core.Buffer
  count : Int
} derive(Debug)

///|
/// 帧区域（上游 `Frame::area`）：渲染期间恒定喵。
pub fn Frame::area(self : Frame) -> @core.Rect {
  self.viewport_area
}

///|
/// 渲染一个 Widget（上游 `Frame::render_widget`）喵。
pub fn Frame::render_widget(
  self : Frame,
  widget : &@core.Widget,
  area : @core.Rect,
) -> Unit {
  widget.render(area, self.buffer)
}

///|
/// 渲染一个 StatefulWidget（上游 `Frame::render_stateful_widget` 的
/// 等价形态：状态打包进 `Stateful` 组件值，本 trait 无关联类型）喵。
pub fn Frame::render_stateful_widget(
  self : Frame,
  widget : &@core.StatefulWidget,
  area : @core.Rect,
) -> Unit {
  widget.render(area, self.buffer)
}

///|
/// 直读本帧缓冲（上游 `Frame::buffer_mut`）喵。
pub fn Frame::buffer_mut(self : Frame) -> @core.Buffer {
  self.buffer
}

///|
/// 设置帧光标位置（上游 `Frame::set_cursor_position`）喵。
pub fn Frame::set_cursor_position(
  self : Frame,
  position : @core.Position,
) -> Unit {
  self.cursor_position = Some(position)
}

///|
/// 双缓冲终端（上游 `Terminal<B>`）：经 Backend 把差分应用到真实
/// 终端面喵。
pub struct Terminal {
  backend : &@backend.Backend
  buffers : (@core.Buffer, @core.Buffer)
  /// 当前缓冲下标（0/1 交替）喵。
  mut current : Int
  /// Ratatui 认为光标已被隐藏（上游 `hidden_cursor`）喵。
  mut hidden_cursor : Bool
  viewport : Viewport
  /// 当前视口矩形（`Frame::area` 的来源）喵。
  mut viewport_area : @core.Rect
  /// 最近一次已知的可渲染区域（上游 `last_known_area`）喵。
  mut last_known_area : @core.Rect
  /// 最近已知光标位置（上游 `last_known_cursor_pos`）喵。
  mut last_known_cursor_pos : @core.Position
  /// 已渲染帧数（上游 `frame_count`）喵。
  mut frame_count : Int
}

///|
/// 以缺省全屏视口创建终端（上游 `Terminal::new`）喵。
pub fn Terminal::new(backend : &@backend.Backend) -> Terminal raise {
  Terminal::with_options(backend, { viewport: Fullscreen })
}

///|
/// 以视口选项创建终端（上游 `Terminal::with_options`）：行内视口
/// 锚定当前光标行并在近底时上移滚动喵。
pub fn Terminal::with_options(
  backend : &@backend.Backend,
  options : TerminalOptions,
) -> Terminal raise {
  let area : @core.Rect = match options.viewport {
    Fullscreen => @core.Rect::of_size(backend.size())
    Inline(_) => @core.Rect::of_size(backend.size())
    Fixed(area) => area
  }
  let (viewport_area, cursor_pos) : (@core.Rect, @core.Position) = match
    options.viewport {
    Fullscreen => (area, @core.Position::new(0, 0))
    Inline(height) => {
      let (rect, pos) = compute_inline_size(backend, height, area.as_size(), 0)
      (rect, pos)
    }
    Fixed(area) => (area, area.as_position())
  }
  {
    backend,
    buffers: (
      @core.Buffer::empty(viewport_area),
      @core.Buffer::empty(viewport_area),
    ),
    current: 0,
    hidden_cursor: false,
    viewport: options.viewport,
    viewport_area,
    last_known_area: area,
    last_known_cursor_pos: cursor_pos,
    frame_count: 0,
  }
}

///|
/// 共享后端引用（上游 `Terminal::backend`）：测试与专用集成用喵。
pub fn Terminal::backend(self : Terminal) -> &@backend.Backend {
  self.backend
}

///|
/// 查询后端真实尺寸（上游 `Terminal::size`）喵。
pub fn Terminal::size(self : Terminal) -> @core.Size raise {
  self.backend.size()
}

///|
/// 行内视口尺寸计算（上游 `inline::compute_inline_size`）：以当前
/// 光标行为锚，必要时追加空行使视口完整可见喵。
fn compute_inline_size(
  backend : &@backend.Backend,
  height : Int,
  size : @core.Size,
  offset_in_previous_viewport : Int,
) -> (@core.Rect, @core.Position) raise {
  let pos = backend.get_cursor_position()
  let mut row = pos.y
  let max_height = size.height.min(height)
  let lines_after_cursor = (height - offset_in_previous_viewport - 1).max(0)
  backend.append_lines(lines_after_cursor)
  let available_lines = (size.height - row - 1).max(0)
  let missing_lines = (lines_after_cursor - available_lines).max(0)
  if missing_lines > 0 {
    row = (row - missing_lines).max(0)
  }
  row = (row - offset_in_previous_viewport).max(0)
  (@core.Rect::new(0, row, size.width, max_height), pos)
}

///|
/// 返回当前帧（上游 `Terminal::get_frame`）：手工渲染的逃生门，
/// Frame 借持当前缓冲喵。
pub fn Terminal::get_frame(self : Terminal) -> Frame {
  {
    cursor_position: None,
    viewport_area: self.viewport_area,
    buffer: self.current_buffer_mut(),
    count: self.frame_count,
  }
}

///|
/// 当前缓冲可变引用（上游 `Terminal::current_buffer_mut`）喵。
pub fn Terminal::current_buffer_mut(self : Terminal) -> @core.Buffer {
  match self.current {
    0 => self.buffers.0
    _ => self.buffers.1
  }
}

///|
/// 非当前缓冲（内部）喵。
fn Terminal::previous_buffer(self : Terminal) -> @core.Buffer {
  match self.current {
    0 => self.buffers.1
    _ => self.buffers.0
  }
}

///|
/// 把当前缓冲差分应用到后端（上游 `Terminal::flush`）：记录最后
/// 更新格作为最近已知光标位置喵。
pub fn Terminal::flush(self : Terminal) -> Unit raise {
  let previous_buffer = self.previous_buffer()
  let current_buffer = self.current_buffer_mut()
  let mut last_pos : @core.Position? = None
  let updates = previous_buffer.diff(current_buffer)
  if updates.length() > 0 {
    let (lx, ly, _) = updates[updates.length() - 1]
    last_pos = Some(@core.Position::new(lx, ly))
  }
  self.backend.draw(updates)
  match last_pos {
    Some(pos) => self.last_known_cursor_pos = pos
    None => ()
  }
}

///|
/// 复位非当前缓冲并交换（上游 `Terminal::swap_buffers`）喵。
pub fn Terminal::swap_buffers(self : Terminal) -> Unit {
  self.previous_buffer().reset()
  self.current = 1 - self.current
}

///|
/// 清屏并在下次 draw 全量重绘（上游 `Terminal::clear`）：保留后端
/// 光标位置喵。
pub fn Terminal::clear(self : Terminal) -> Unit raise {
  let original_cursor = self.backend.get_cursor_position()
  self.clear_viewport()
  self.backend.set_cursor_position(original_cursor)
}

///|
/// 按视口清除并复位背衬缓冲（上游 `clear_viewport`）：不保存/恢复
/// 光标喵。
fn Terminal::clear_viewport(self : Terminal) -> Unit raise {
  match self.viewport {
    Fullscreen => self.backend.clear_region(All)
    Inline(_) => {
      self.backend.set_cursor_position(self.viewport_area.as_position())
      self.backend.clear_region(AfterCursor)
    }
    Fixed(_) => self.clear_fixed_viewport(self.viewport_area)
  }
  self.previous_buffer().reset()
}

///|
/// 清除固定视口：优先使用终端清除命令（上游
/// `clear_fixed_viewport`）喵。
fn Terminal::clear_fixed_viewport(
  self : Terminal,
  area : @core.Rect,
) -> Unit raise {
  if area.is_empty() {
    return
  }
  let size = self.backend.size()
  let is_full_width = area.x == 0 && area.width == size.width
  let ends_at_bottom = area.bottom() == size.height
  if is_full_width && ends_at_bottom {
    self.backend.set_cursor_position(area.as_position())
    self.backend.clear_region(AfterCursor)
  } else if is_full_width {
    self.clear_full_width_rows(area)
  } else {
    self.clear_region_cells(area)
  }
}

///|
/// 整宽行清除（上游 `clear_full_width_rows`）喵。
fn Terminal::clear_full_width_rows(
  self : Terminal,
  area : @core.Rect,
) -> Unit raise {
  for y in area.top()..<area.bottom() {
    self.backend.set_cursor_position(@core.Position::new(0, y))
    self.backend.clear_region(CurrentLine)
  }
}

///|
/// 非整宽区域直接写空格（上游 `clear_region_cells`）喵。
fn Terminal::clear_region_cells(
  self : Terminal,
  area : @core.Rect,
) -> Unit raise {
  let clear_cell = @core.Cell::empty()
  let updates : Array[(Int, Int, @core.Cell)] = []
  for position in area.positions() {
    updates.push((position.x, position.y, clear_cell))
  }
  self.backend.draw(updates)
}

///|
/// 隐藏光标并登记状态（上游 `Terminal::hide_cursor`）喵。
pub fn Terminal::hide_cursor(self : Terminal) -> Unit raise {
  self.backend.hide_cursor()
  self.hidden_cursor = true
}

///|
/// 显示光标并登记状态（上游 `Terminal::show_cursor`）喵。
pub fn Terminal::show_cursor(self : Terminal) -> Unit raise {
  self.backend.show_cursor()
  self.hidden_cursor = false
}

///|
/// 查询光标位置（上游 `Terminal::get_cursor_position`）喵。
pub fn Terminal::get_cursor_position(self : Terminal) -> @core.Position raise {
  self.backend.get_cursor_position()
}

///|
/// 设置光标位置并更新内部追踪（上游 `Terminal::set_cursor_position`）喵。
pub fn Terminal::set_cursor_position(
  self : Terminal,
  position : @core.Position,
) -> Unit raise {
  self.backend.set_cursor_position(position)
  self.last_known_cursor_pos = position
}

///|
/// 调整视口与内部缓冲（上游 `Terminal::resize`）：行内视口保光标
/// 相对行；横向缩窄时清屏防折行错乱喵。
pub fn Terminal::resize(self : Terminal, area : @core.Rect) -> Unit raise {
  let (next_area, cursor_to_restore) : (@core.Rect, @core.Position?) = match
    self.viewport {
    Inline(height) => {
      let offset_in_previous_viewport = (self.last_known_cursor_pos.y -
      self.viewport_area.top()).max(0)
      let (rect, cursor_position) = compute_inline_size(
        self.backend,
        height,
        area.as_size(),
        offset_in_previous_viewport,
      )
      (rect, Some(cursor_position))
    }
    Fixed(_) | Fullscreen => (area, None)
  }
  let mut next_area = next_area
  if next_area.width < self.viewport_area.width {
    next_area = @core.Rect::new(
      next_area.x,
      0,
      next_area.width,
      next_area.height,
    )
    self.backend.clear_region(All)
  }
  self.set_viewport_area(next_area)
  self.clear_viewport()
  match cursor_to_restore {
    Some(cursor_position) => self.backend.set_cursor_position(cursor_position)
    None => ()
  }
  self.last_known_area = area
}

///|
/// 自动重排（上游 `Terminal::autoresize`）：全屏/行内视口在 draw
/// 前对齐后端尺寸；固定视口不重排喵。
pub fn Terminal::autoresize(self : Terminal) -> Unit raise {
  match self.viewport {
    Fullscreen | Inline(_) => {
      let area = @core.Rect::of_size(self.size())
      if area != self.last_known_area {
        self.resize(area)
      }
    }
    Fixed(_) => ()
  }
}

///|
/// 调整缓冲与视口区域（上游 `set_viewport_area`，内部）喵。
fn Terminal::set_viewport_area(self : Terminal, area : @core.Rect) -> Unit {
  self.current_buffer_mut().resize(area)
  self.previous_buffer().resize(area)
  self.viewport_area = area
}

///|
/// 渲染一帧（上游 `Terminal::draw`）：autoresize → 回调 → 冲刷 →
/// 光标 → 交换缓冲喵。
pub fn Terminal::draw(
  self : Terminal,
  render_callback : (Frame) -> Unit raise,
) -> CompletedFrame raise {
  self.try_draw(render_callback)
}

///|
/// 渲染一帧（可失败回调，上游 `Terminal::try_draw`）：回调报错时
/// 后端/缓冲/光标/帧计数保持不变喵。
pub fn Terminal::try_draw(
  self : Terminal,
  render_callback : (Frame) -> Unit raise,
) -> CompletedFrame raise {
  self.autoresize()
  let frame = self.get_frame()
  render_callback(frame)
  let cursor_position = frame.cursor_position
  self.apply_buffer_with_cursor(cursor_position)
}

///|
/// 应用当前缓冲并隐藏光标（上游 `Terminal::apply_buffer`）喵。
pub fn Terminal::apply_buffer(self : Terminal) -> CompletedFrame raise {
  self.apply_buffer_with_cursor(None)
}

///|
/// 应用当前缓冲并定位光标（上游 `Terminal::apply_buffer_with_cursor`）：
/// None 隐藏光标喵。
pub fn Terminal::apply_buffer_with_cursor(
  self : Terminal,
  cursor_position : @core.Position?,
) -> CompletedFrame raise {
  self.flush()
  match cursor_position {
    None => self.hide_cursor()
    Some(position) => {
      self.show_cursor()
      self.set_cursor_position(position)
    }
  }
  self.swap_buffers()
  self.backend.flush()
  let completed_frame : CompletedFrame = {
    buffer: self.previous_buffer(),
    area: self.last_known_area,
    count: self.frame_count,
  }
  self.frame_count = self.frame_count + 1
  completed_frame
}

///|
/// 视口区域观测（上游白盒字段访问的只读访问器承载）喵。
pub fn Terminal::viewport_area(self : Terminal) -> @core.Rect {
  self.viewport_area
}

///|
/// 最近已知区域观测（上游白盒字段访问的只读访问器承载）喵。
pub fn Terminal::last_known_area(self : Terminal) -> @core.Rect {
  self.last_known_area
}

///|
/// 最近已知光标位置观测（上游白盒字段访问的只读访问器承载）喵。
pub fn Terminal::last_known_cursor_pos(self : Terminal) -> @core.Position {
  self.last_known_cursor_pos
}

///|
/// 光标隐藏状态观测（上游白盒字段访问的只读访问器承载）喵。
pub fn Terminal::hidden_cursor(self : Terminal) -> Bool {
  self.hidden_cursor
}

///|
/// 帧计数观测（上游白盒字段访问的只读访问器承载）喵。
pub fn Terminal::frame_count(self : Terminal) -> Int {
  self.frame_count
}

///|
/// 当前缓冲下标观测（上游白盒字段访问的只读访问器承载）喵。
pub fn Terminal::current(self : Terminal) -> Int {
  self.current
}

///|
/// 按下标观测双缓冲（上游 `buffers[i]` 白盒访问的等价承载）喵。
pub fn Terminal::buffer_at(self : Terminal, index : Int) -> @core.Buffer {
  match index {
    0 => self.buffers.0
    _ => self.buffers.1
  }
}

///|
/// 视口模式观测（上游 `terminal.viewport` 白盒访问的等价承载）喵。
pub fn Terminal::viewport(self : Terminal) -> Viewport {
  self.viewport
}
