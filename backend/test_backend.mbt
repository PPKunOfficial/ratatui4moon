// 测试后端（上游 `backend/test.rs`）：内存缓冲渲染的 Backend 实现，
// 集成测试与黄金快照的确定性支点，零真实终端、零 I/O 喵。
//
// 本库扩展：`frames` 录帧字段承载既有黄金 ANSI 快照管线
// （`last_ansi`），上游无对应字段喵。

///|
/// 测试后端（上游 `TestBackend`）：主缓冲 + 回滚缓冲 + 光标状态 +
/// 录帧序列喵。
pub(all) struct TestBackend {
  buffer : @core.Buffer
  scrollback : @core.Buffer
  /// 光标是否可见（上游 `cursor`）喵。
  mut cursor : Bool
  /// 光标位置（上游 `pos`）喵。
  mut pos : (Int, Int)
  frames : Array[Array[(Int, Int, @core.Cell)]]
}

///|
/// 以行列尺寸创建测试后端（上游 `TestBackend::new`）喵。
pub fn TestBackend::new_with_size(width : Int, height : Int) -> TestBackend {
  {
    buffer: @core.Buffer::empty(@core.Rect::new(0, 0, width, height)),
    scrollback: @core.Buffer::empty(@core.Rect::new(0, 0, width, 0)),
    cursor: false,
    pos: (0, 0),
    frames: [],
  }
}

///|
/// 以初始行集创建测试后端，尺寸取自行数与行宽（上游
/// `TestBackend::with_lines`）喵。
pub fn TestBackend::new_with_lines(lines : Array[String]) -> TestBackend {
  let buffer = @core.Buffer::with_lines(lines)
  let scrollback = @core.Buffer::empty(
    @core.Rect::new(0, 0, buffer.area.width, 0),
  )
  { buffer, scrollback, cursor: false, pos: (0, 0), frames: [] }
}

///|
/// 兼容入口：无尺寸创建（本库黄金快照管线的历史 API）喵。
pub fn TestBackend::new() -> TestBackend {
  TestBackend::new_with_size(0, 0)
}

///|
/// 内部缓冲引用（上游 `TestBackend::buffer`）喵。
pub fn TestBackend::buffer(self : TestBackend) -> @core.Buffer {
  self.buffer
}

///|
/// 光标是否可见（上游 `TestBackend::cursor_visible`）喵。
pub fn TestBackend::cursor_visible(self : TestBackend) -> Bool {
  self.cursor
}

///|
/// 当前光标位置（上游 `TestBackend::cursor_position`）喵。
pub fn TestBackend::cursor_position(self : TestBackend) -> @core.Position {
  @core.Position::new(self.pos.0, self.pos.1)
}

///|
/// 回滚缓冲（上游 `TestBackend::scrollback`）：行滚出屏顶后追加于
/// 此，高度上限 65535 行喵。
pub fn TestBackend::scrollback(self : TestBackend) -> @core.Buffer {
  self.scrollback
}

///|
/// 调整后端尺寸（上游 `TestBackend::resize`）：回滚缓冲保高缩宽喵。
pub fn TestBackend::resize(
  self : TestBackend,
  width : Int,
  height : Int,
) -> Unit {
  self.buffer.resize(@core.Rect::new(0, 0, width, height))
  let scrollback_height = self.scrollback.area.height
  self.scrollback.resize(@core.Rect::new(0, 0, width, scrollback_height))
}

///|
/// 断言主缓冲与期望相等（上游 `TestBackend::assert_buffer`）喵。
pub fn TestBackend::assert_buffer(
  self : TestBackend,
  expected : @core.Buffer,
) -> Unit raise {
  @core.Buffer::assert_buffer_eq(self.buffer, expected)
}

///|
/// 断言回滚缓冲与期望相等（上游 `assert_scrollback`）喵。
pub fn TestBackend::assert_scrollback(
  self : TestBackend,
  expected : @core.Buffer,
) -> Unit raise {
  @debug.assert_eq(self.scrollback, expected)
}

///|
/// 断言回滚缓冲为空（上游 `assert_scrollback_empty`）喵。
pub fn TestBackend::assert_scrollback_empty(self : TestBackend) -> Unit raise {
  let expected = {
    ..@core.Buffer::empty(@core.Rect::new(0, 0, self.scrollback.area.width, 0)),
    cells: [],
  }
  self.assert_scrollback(expected)
}

///|
/// 断言主缓冲等于期望行集（上游 `assert_buffer_lines`）喵。
pub fn TestBackend::assert_buffer_lines(
  self : TestBackend,
  expected : Array[String],
) -> Unit raise {
  self.assert_buffer(@core.Buffer::with_lines(expected))
}

///|
/// 断言回滚缓冲等于期望行集（上游 `assert_scrollback_lines`）喵。
pub fn TestBackend::assert_scrollback_lines(
  self : TestBackend,
  expected : Array[String],
) -> Unit raise {
  self.assert_scrollback(@core.Buffer::with_lines(expected))
}

///|
/// 断言光标位置（上游 `assert_cursor_position`）喵。
pub fn TestBackend::assert_cursor_position(
  self : TestBackend,
  position : @core.Position,
) -> Unit raise {
  @debug.assert_eq(self.get_cursor_position(), position)
}

///|
/// 缓冲的人类可读视图（上游 `Display for TestBackend` →
/// `buffer_view`）：逐行加引号，被宽符号遮蔽的格子行尾列出示意喵。
pub fn TestBackend::to_display(self : TestBackend) -> String {
  buffer_view(self.buffer)
}

///|
/// 缓冲视图渲染（上游 `buffer_view`）喵。
fn buffer_view(buffer : @core.Buffer) -> String {
  let view = StringBuilder()
  let width = if buffer.area.width == 0 { 1 } else { buffer.area.width }
  for y in 0..<buffer.area.height {
    let overwritten : Array[(Int, String)] = []
    let mut skip = 0
    view.write_string("\"")
    for x in 0..<width {
      let cell = buffer.get(x, y)
      let sym = cell.symbol()
      if skip == 0 {
        view.write_string(sym)
      } else {
        overwritten.push((x, sym))
      }
      let cw = cell.cell_width()
      skip = (if skip > cw { skip } else { cw }) - 1
      if skip < 0 {
        skip = 0
      }
    }
    view.write_string("\"")
    if overwritten.length() > 0 {
      let parts = overwritten.map(fn(entry) {
        let (x, sym) = entry
        "\{x}: \"\{sym}\""
      })
      view.write_string(" Hidden by multi-width symbols: [\{parts.join(", ")}]")
    }
    view.write_string("\n")
  }
  view.to_string()
}

///|
/// 把单元序列追加到回滚缓冲底部并裁剪到 65535 行（上游
/// `append_to_scrollback`）喵。
fn append_to_scrollback(
  scrollback : @core.Buffer,
  cells : Array[@core.Cell],
) -> Unit {
  for cell in cells {
    scrollback.cells.push(cell)
  }
  let width = if scrollback.area.width == 0 { 1 } else { scrollback.area.width }
  let new_height = (scrollback.cells.length() / width).min(65535)
  let keep_from = (scrollback.cells.length() - width * 65535).max(0)
  if keep_from > 0 {
    rotate_cells_left(scrollback.cells, keep_from)
    for _ in 0..<keep_from {
      let _ = scrollback.cells.pop()
    }
  }
  scrollback.area = @core.Rect::new(
    scrollback.area.x,
    scrollback.area.y,
    scrollback.area.width,
    new_height,
  )
}

///|
/// 就地左旋数组前缀（上游 `Vec::rotate_left`）喵。
fn rotate_cells_left(cells : Array[@core.Cell], by : Int) -> Unit {
  let n = cells.length()
  if n == 0 || by <= 0 || by >= n {
    if n > 0 && by > n {
      rotate_cells_left(cells, by % n)
    }
    return
  }
  let head : Array[@core.Cell] = []
  for i in 0..<by {
    head.push(cells[i])
  }
  for i in by..<n {
    cells[i - by] = cells[i]
  }
  for i, cell in head {
    cells[n - by + i] = cell
  }
}

///|
/// Backend 实现（上游 `impl Backend for TestBackend`，上游错误类型
/// Infallible 以不可失败 raise 对位）喵。
pub impl Backend for TestBackend with fn draw(
  self : TestBackend,
  content : Array[(Int, Int, @core.Cell)],
) -> Unit raise {
  let recorded : Array[(Int, Int, @core.Cell)] = []
  for entry in content {
    let (x, y, cell) = entry
    match self.buffer.mut_cell(x, y) {
      Some(target) => {
        target.set_symbol(cell.symbol())
        target.set_style(cell.style())
      }
      None => ()
    }
    recorded.push((x, y, @core.Cell::of_cell(cell)))
  }
  self.frames.push(recorded)
}

///|
/// 隐藏光标喵。
pub impl Backend for TestBackend with fn hide_cursor(self : TestBackend) -> Unit raise {
  self.cursor = false
}

///|
/// 显示光标喵。
pub impl Backend for TestBackend with fn show_cursor(self : TestBackend) -> Unit raise {
  self.cursor = true
}

///|
/// 查询光标位置喵。
pub impl Backend for TestBackend with fn get_cursor_position(self : TestBackend) -> @core.Position raise {
  self.cursor_position()
}

///|
/// 设置光标位置喵。
pub impl Backend for TestBackend with fn set_cursor_position(
  self : TestBackend,
  position : @core.Position,
) -> Unit raise {
  self.pos = (position.x, position.y)
}

///|
/// 清空主缓冲喵。
pub impl Backend for TestBackend with fn clear(self : TestBackend) -> Unit raise {
  self.buffer.reset()
}

///|
/// 按区域清除：以光标为参考点折算内容区间逐格复位（上游
/// `clear_region`）喵。
pub impl Backend for TestBackend with fn clear_region(
  self : TestBackend,
  clear_type : ClearType,
) -> Unit raise {
  let width = self.buffer.area.width
  let height = self.buffer.area.height
  let index_at = fn(x : Int, y : Int) -> Int { self.buffer.index_of(x, y) }
  match clear_type {
    All => self.buffer.reset()
    AfterCursor => {
      let index = index_at(self.pos.0, self.pos.1)
      for i in index..<self.buffer.cells.length() {
        self.buffer.cells[i].reset()
      }
    }
    BeforeCursor => {
      let index = index_at(self.pos.0, self.pos.1)
      for i in 0..<=index {
        if i < self.buffer.cells.length() {
          self.buffer.cells[i].reset()
        }
      }
    }
    CurrentLine =>
      if height > 0 {
        let line_start = index_at(0, self.pos.1)
        let line_end = index_at(width - 1, self.pos.1)
        for i in line_start..<=line_end {
          self.buffer.cells[i].reset()
        }
      }
    UntilNewLine =>
      if width > 0 {
        let index = index_at(self.pos.0, self.pos.1)
        let line_end = index_at(width - 1, self.pos.1)
        for i in index..<=line_end {
          self.buffer.cells[i].reset()
        }
      }
  }
}

///|
/// 在当前光标处追加 n 行：底部换行溢出行滚入回滚缓冲（上游
/// `append_lines`）喵。
pub impl Backend for TestBackend with fn append_lines(
  self : TestBackend,
  line_count : Int,
) -> Unit raise {
  let position = self.get_cursor_position()
  let cur_x = position.x
  let cur_y = position.y
  let width = self.buffer.area.width
  let height = self.buffer.area.height
  let new_cursor_x = (cur_x + 1).min((width - 1).max(0))
  let max_y = (height - 1).max(0)
  let lines_after_cursor = (max_y - cur_y).max(0)
  if line_count > lines_after_cursor {
    let scroll_by = line_count - lines_after_cursor
    let cells_to_scrollback = self.buffer.cells.length().min(width * scroll_by)
    // 顶部滚出内容进回滚缓冲，再旋转补位喵。
    let moving : Array[@core.Cell] = []
    for i in 0..<cells_to_scrollback {
      moving.push(self.buffer.cells[i])
    }
    append_to_scrollback(self.scrollback, moving)
    rotate_cells_left(self.buffer.cells, cells_to_scrollback)
    for _ in 0..<(width * scroll_by - cells_to_scrollback) {
      append_to_scrollback(self.scrollback, [@core.Cell::empty()])
    }
  }
  let new_cursor_y = (cur_y + line_count).min(max_y)
  self.set_cursor_position(@core.Position::new(new_cursor_x, new_cursor_y))
}

///|
/// 查询尺寸喵。
pub impl Backend for TestBackend with fn size(self : TestBackend) -> @core.Size raise {
  self.buffer.area.as_size()
}

///|
/// 查询窗口尺寸（像素取 640x480 占位，同上游）喵。
pub impl Backend for TestBackend with fn window_size(self : TestBackend) -> WindowSize raise {
  {
    columns_rows: self.buffer.area.as_size(),
    pixels: @core.Size::new(640, 480),
  }
}

///|
/// 冲刷（无操作，同上游）喵。
pub impl Backend for TestBackend with fn flush(_self : TestBackend) -> Unit raise {
  ()
}

///|
/// 已录帧数（本库黄金快照管线扩展）喵。
pub fn TestBackend::frame_count(self : TestBackend) -> Int {
  self.frames.length()
}

///|
/// 最近一帧的 ANSI 渲染；无帧返回空串（本库黄金快照管线扩展）喵。
pub fn TestBackend::last_ansi(self : TestBackend) -> String {
  match self.frames.last() {
    Some(frame) => frame_to_ansi(frame)
    None => ""
  }
}
