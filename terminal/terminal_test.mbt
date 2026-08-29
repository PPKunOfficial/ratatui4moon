// 上游 `terminal/{buffers,backend,viewport,cursor,resize,init,render}.rs`
// 内联测试逐条复刻（terminal.rs 单文件承载，测试名保留上游对应关系）喵。
//
// 不可移植登记：
// - 上游白盒字段访问（`terminal.buffers[i]`/`last_known_cursor_pos`
//   等）以只读访问器承载（Terminal::buffer_at 等）；
// - `clear_viewport`（上游 pub(super)）不可从测试直测，`clear_
//   viewport_inline_leaves_cursor_at_viewport_origin` 以 `clear`
//   的光标保持语义等价承载；
// - `backend_mut` 的直改场景以"持有原后端引用"（MoonBit 对象引用
//   语义）承载。

///|
/// 上游 `get_frame_uses_current_viewport_and_frame_count` 喵。
test "get_frame 使用当前视口与帧计数" {
  let backend = @backend.TestBackend::new_with_size(5, 3)
  let terminal = @terminal.Terminal::new(backend)
  let frame = terminal.get_frame()
  inspect(frame.count, content="0")
  inspect(frame.area().width, content="5")
  inspect(frame.area().height, content="3")
  inspect(frame.buffer_mut().area == frame.area(), content="true")
}

///|
/// 上游 `flush_writes_updates_and_tracks_last_updated_cell` 喵。
test "flush 写入更新并追踪最后更新格" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  let frame = terminal.get_frame()
  match frame.buffer_mut().mut_cell(1, 0) {
    Some(cell) => cell.set_symbol("x")
    None => ()
  }
  terminal.flush()
  backend.assert_buffer_lines([" x ", "   "])
  @debug.assert_eq(terminal.last_known_cursor_pos(), @core.Position::new(1, 0))
}

///|
/// 上游 `flush_with_no_updates_does_not_change_last_known_cursor_pos` 喵。
test "flush 无更新不改光标追踪" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  terminal.set_cursor_position(@core.Position::new(2, 1))
  terminal.flush()
  @debug.assert_eq(terminal.last_known_cursor_pos(), @core.Position::new(2, 1))
}

///|
/// 上游 `swap_buffers_resets_new_current_buffer` 喵。
test "swap_buffers 复位新当前缓冲" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  match terminal.buffer_at(1).mut_cell(0, 0) {
    Some(cell) => cell.set_symbol("x")
    None => ()
  }
  terminal.swap_buffers()
  inspect(terminal.current(), content="1")
  @debug.assert_eq(
    terminal.buffer_at(1),
    @core.Buffer::empty(terminal.viewport_area()),
  )
}

///|
/// 上游 `clear_fullscreen_clears_backend_and_resets_back_buffer` 喵。
test "clear 全屏清空并复位背衬缓冲" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  let frame = terminal.get_frame()
  match frame.buffer_mut().mut_cell(0, 0) {
    Some(cell) => cell.set_symbol("x")
    None => ()
  }
  terminal.flush()
  backend.assert_buffer_lines(["x  ", "   "])
  match terminal.buffer_at(1).mut_cell(2, 1) {
    Some(cell) => cell.set_symbol("y")
    None => ()
  }
  terminal.clear()
  backend.assert_buffer_lines(["   ", "   "])
  @debug.assert_eq(
    terminal.buffer_at(1 - terminal.current()),
    @core.Buffer::empty(terminal.viewport_area()),
  )
}

///|
/// 上游 `clear_inline_clears_after_viewport_origin_and_resets_back_
/// buffer`：行内清除从视口原点扫到显示区末尾喵。
test "clear 行内从视口原点清到末尾" {
  let backend = @backend.TestBackend::new_with_lines([
    "before 1  ", "before 2  ", "viewport 1", "viewport 2", "after 1   ", "after 2   ",
  ])
  backend.set_cursor_position(@core.Position::new(2, 2))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Inline(2),
  })
  // 上游经 backend_mut 将光标重设回 (2,2)（init 的 append_lines 会
  // 推进后端光标）喵。
  backend.set_cursor_position(@core.Position::new(2, 2))
  match terminal.buffer_at(1).mut_cell(2, 2) {
    Some(cell) => cell.set_symbol("x")
    None => ()
  }
  terminal.clear()
  backend.assert_buffer_lines([
    "before 1  ", "before 2  ", "          ", "          ", "          ", "          ",
  ])
  @debug.assert_eq(
    terminal.buffer_at(1 - terminal.current()),
    @core.Buffer::empty(terminal.viewport_area()),
  )
  // clear 保留后端光标位置喵。
  @debug.assert_eq(backend.cursor_position(), @core.Position::new(2, 2))
}

///|
/// 上游 `clear_fixed_clears_viewport_rows_and_resets_back_buffer`：
/// 全宽到底的固定视口用 AfterCursor 清除喵。
test "clear 固定视口整宽到底" {
  let backend = @backend.TestBackend::new_with_lines([
    "before 1  ", "viewport 1", "viewport 2",
  ])
  backend.set_cursor_position(@core.Position::new(2, 0))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Fixed(@core.Rect::new(0, 1, 10, 2)),
  })
  terminal.clear()
  backend.assert_buffer_lines(["before 1  ", "          ", "          "])
  @debug.assert_eq(
    terminal.buffer_at(1 - terminal.current()),
    @core.Buffer::empty(terminal.viewport_area()),
  )
  @debug.assert_eq(backend.cursor_position(), @core.Position::new(2, 0))
}

///|
/// 上游 `clear_fixed_full_width_not_at_bottom`：整宽但不到底用逐行
/// 清除喵。
test "clear 固定视口整宽不在底部" {
  let backend = @backend.TestBackend::new_with_lines([
    "before 1  ", "viewport 1", "viewport 2", "after 1   ",
  ])
  backend.set_cursor_position(@core.Position::new(1, 0))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Fixed(@core.Rect::new(0, 1, 10, 2)),
  })
  terminal.clear()
  backend.assert_buffer_lines([
    "before 1  ", "          ", "          ", "after 1   ",
  ])
  @debug.assert_eq(backend.cursor_position(), @core.Position::new(1, 0))
}

///|
/// 上游 `clear_fixed_respects_non_full_width_viewport`：非整宽区域
/// 逐格写空格喵。
test "clear 固定视口尊重非整宽区域" {
  let backend = @backend.TestBackend::new_with_lines([
    "before 1  ", "viewport 1", "viewport 2", "after 1   ",
  ])
  backend.set_cursor_position(@core.Position::new(3, 0))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Fixed(@core.Rect::new(1, 1, 3, 2)),
  })
  terminal.clear()
  backend.assert_buffer_lines([
    "before 1  ", "v   port 1", "v   port 2", "after 1   ",
  ])
  @debug.assert_eq(backend.cursor_position(), @core.Position::new(3, 0))
}

///|
/// 上游 `clear_viewport_inline_leaves_cursor_at_viewport_origin` 的
/// clear 等价承载：clear 保留（而非移到视口原点）光标，登记见头注喵。
test "clear 保留光标位置" {
  let backend = @backend.TestBackend::new_with_lines([
    "before 1  ", "before 2  ", "viewport 1", "viewport 2", "after 1   ", "after 2   ",
  ])
  backend.set_cursor_position(@core.Position::new(2, 2))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Inline(2),
  })
  backend.set_cursor_position(@core.Position::new(2, 2))
  terminal.clear()
  @debug.assert_eq(backend.cursor_position(), @core.Position::new(2, 2))
}

///|
/// 上游 `backend_returns_shared_reference` 喵。
test "backend 共享引用可观测光标" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  @debug.assert_eq(terminal.get_cursor_position(), @core.Position::new(0, 0))
}

///|
/// 上游 `backend_mut_allows_mutating_backend_state`：以对象引用共享
/// 承载 backend_mut 直改场景喵。
test "后端直改可被 size 观测" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  backend.resize(4, 3)
  @debug.assert_eq(terminal.size(), @core.Size::new(4, 3))
  backend.assert_buffer_lines(["    ", "    ", "    "])
}

///|
/// 上游 `size_queries_underlying_backend_size` 喵。
test "size 查询底层后端尺寸" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  backend.resize(4, 3)
  let terminal = @terminal.Terminal::new(backend)
  @debug.assert_eq(terminal.size(), @core.Size::new(4, 3))
}

///|
/// 上游 `viewport_to_string` 喵。
test "Viewport Display" {
  inspect(@terminal.Fullscreen.to_display(), content="Fullscreen")
  inspect(@terminal.Inline(5).to_display(), content="Inline(5)")
  inspect(
    @terminal.Fixed(@core.Rect::new(0, 0, 5, 5)).to_display(),
    content="Fixed(5x5+0+0)",
  )
}

///|
/// 上游 `hide_cursor_updates_terminal_state` 喵。
test "hide_cursor 更新终端状态" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  terminal.hide_cursor()
  inspect(terminal.hidden_cursor(), content="true")
  inspect(backend.cursor_visible(), content="false")
}

///|
/// 上游 `show_cursor_updates_terminal_state` 喵。
test "show_cursor 更新终端状态" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  terminal.show_cursor()
  inspect(terminal.hidden_cursor(), content="false")
  inspect(backend.cursor_visible(), content="true")
}

///|
/// 上游 `set_cursor_position_updates_backend_and_tracking` 喵。
test "set_cursor_position 更新后端与追踪" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  terminal.set_cursor_position(@core.Position::new(1, 1))
  @debug.assert_eq(backend.cursor_position(), @core.Position::new(1, 1))
  @debug.assert_eq(terminal.last_known_cursor_pos(), @core.Position::new(1, 1))
}

///|
/// 上游 `draw_hides_cursor_when_frame_cursor_is_not_set` 喵。
test "draw 未设光标时隐藏光标" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  terminal.show_cursor()
  let completed = terminal.draw(fn(frame) {
    match frame.buffer_mut().mut_cell(0, 0) {
      Some(cell) => cell.set_symbol("x")
      None => ()
    }
  })
  inspect(completed.count(), content="0")
  @debug.assert_eq(completed.area(), @core.Rect::new(0, 0, 3, 2))
  @debug.assert_eq(completed.buffer(), @core.Buffer::with_lines(["x  ", "   "]))
  inspect(terminal.hidden_cursor(), content="true")
  inspect(backend.cursor_visible(), content="false")
  inspect(terminal.frame_count(), content="1")
}

///|
/// 上游 `draw_shows_and_positions_cursor_when_frame_cursor_is_set` 喵。
test "draw 设光标时显示并定位" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  terminal.hide_cursor()
  let _ = terminal.draw(fn(frame) {
    frame.set_cursor_position(@core.Position::new(2, 1))
    match frame.buffer_mut().mut_cell(1, 0) {
      Some(cell) => cell.set_symbol("y")
      None => ()
    }
  })
  inspect(terminal.hidden_cursor(), content="false")
  inspect(backend.cursor_visible(), content="true")
  @debug.assert_eq(backend.cursor_position(), @core.Position::new(2, 1))
  @debug.assert_eq(terminal.last_known_cursor_pos(), @core.Position::new(2, 1))
}

///|
/// 上游 `try_draw_propagates_render_errors_without_updating_backend`：
/// 回调报错时终端状态完全不变喵。
test "try_draw 回调报错不更新后端" {
  let backend = @backend.TestBackend::new_with_lines(["aaa", "bbb"])
  let terminal = @terminal.Terminal::new(backend)
  terminal.show_cursor()
  let was_hidden = terminal.hidden_cursor()
  let cursor_visible = backend.cursor_visible()
  let cursor_position = backend.cursor_position()
  let mut hit = false
  try {
    let _ = terminal.try_draw(fn(_frame) -> Unit raise { fail("render failed") })
  } catch {
    Failure(text) => {
      hit = text.contains("render failed")
      inspect(hit, content="true")
    }
    _ => ()
  }
  inspect(terminal.frame_count(), content="0")
  backend.assert_buffer_lines(["aaa", "bbb"])
  inspect(terminal.hidden_cursor() == was_hidden, content="true")
  inspect(backend.cursor_visible() == cursor_visible, content="true")
  inspect(backend.cursor_position() == cursor_position, content="true")
}

///|
/// 上游 `draw_clears_on_fullscreen_resize_before_rendering` 喵。
test "draw 全屏重排先清屏再渲染" {
  let backend = @backend.TestBackend::new_with_lines(["xxx", "yyy"])
  let terminal = @terminal.Terminal::new(backend)
  backend.resize(4, 3)
  let _ = terminal.draw(fn(frame) {
    match frame.buffer_mut().mut_cell(0, 0) {
      Some(cell) => cell.set_symbol("x")
      None => ()
    }
  })
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(0, 0, 4, 3))
  @debug.assert_eq(terminal.last_known_area(), @core.Rect::new(0, 0, 4, 3))
  backend.assert_buffer_lines(["x   ", "    ", "    "])
}

///|
/// 上游 `draw_uses_fixed_viewport_coordinates` 喵。
test "draw 使用固定视口绝对坐标" {
  let backend = @backend.TestBackend::new_with_size(5, 3)
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Fixed(@core.Rect::new(2, 1, 2, 1)),
  })
  let _ = terminal.draw(fn(frame) {
    let area = frame.area()
    match frame.buffer_mut().mut_cell(area.x, area.y) {
      Some(cell) => cell.set_symbol("z")
      None => ()
    }
  })
  backend.assert_buffer_lines(["     ", "  z  ", "     "])
}

///|
/// 上游 `draw_inline_completed_frame_reports_terminal_size` 喵。
test "draw 行内视口完成帧报告终端尺寸" {
  let backend = @backend.TestBackend::new_with_size(6, 5)
  backend.set_cursor_position(@core.Position::new(0, 2))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Inline(3),
  })
  let viewport_area = terminal.viewport_area()
  let completed = terminal.draw(fn(frame) {
    match frame.buffer_mut().mut_cell(viewport_area.x, viewport_area.y) {
      Some(cell) => cell.set_symbol("i")
      None => ()
    }
  })
  @debug.assert_eq(completed.area(), @core.Rect::new(0, 0, 6, 5))
  @debug.assert_eq(completed.buffer().area, viewport_area)
  @debug.assert_eq(
    backend.buffer().get(viewport_area.x, viewport_area.y).symbol(),
    "i",
  )
}

///|
/// 上游 `resize_fullscreen_updates_viewport_and_buffer_areas` 喵。
test "resize 全屏更新视口与缓冲区域" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  backend.resize(4, 3)
  let new_area = @core.Rect::new(0, 0, 4, 3)
  terminal.resize(new_area)
  @debug.assert_eq(terminal.viewport_area(), new_area)
  @debug.assert_eq(terminal.last_known_area(), new_area)
  @debug.assert_eq(terminal.buffer_at(terminal.current()).area, new_area)
  @debug.assert_eq(terminal.buffer_at(1 - terminal.current()).area, new_area)
}

///|
/// 上游 `resize_fullscreen_triggers_clear_and_resets_back_buffer` 喵。
test "resize 全屏触发清屏并复位背衬缓冲" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  let frame = terminal.get_frame()
  match frame.buffer_mut().mut_cell(0, 0) {
    Some(cell) => cell.set_symbol("x")
    None => ()
  }
  terminal.flush()
  backend.assert_buffer_lines(["x  ", "   "])
  backend.resize(4, 3)
  let new_area = @core.Rect::new(0, 0, 4, 3)
  terminal.resize(new_area)
  backend.assert_buffer_lines(["    ", "    ", "    "])
  @debug.assert_eq(
    terminal.buffer_at(1 - terminal.current()),
    @core.Buffer::empty(new_area),
  )
}

///|
/// 上游 `autoresize_fullscreen_uses_backend_size_when_changed` 喵。
test "autoresize 全屏对齐后端尺寸" {
  let backend = @backend.TestBackend::new_with_size(3, 2)
  let terminal = @terminal.Terminal::new(backend)
  backend.resize(5, 4)
  terminal.autoresize()
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(0, 0, 5, 4))
  @debug.assert_eq(terminal.last_known_area(), @core.Rect::new(0, 0, 5, 4))
}

///|
/// 上游 `autoresize_fixed_does_not_change_viewport` 喵。
test "autoresize 固定视口不重排" {
  let backend = @backend.TestBackend::new_with_lines(["xxx", "yyy"])
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Fixed(@core.Rect::new(1, 0, 2, 2)),
  })
  terminal.autoresize()
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(1, 0, 2, 2))
  @debug.assert_eq(terminal.last_known_area(), @core.Rect::new(1, 0, 2, 2))
  backend.assert_buffer_lines(["xxx", "yyy"])
}

///|
/// 上游 `resize_fixed_changes_viewport_area_and_buffer_sizes` 喵。
test "resize 固定视口更新区域与缓冲" {
  let backend = @backend.TestBackend::new_with_size(5, 3)
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Fixed(@core.Rect::new(1, 1, 2, 1)),
  })
  terminal.resize(@core.Rect::new(0, 0, 3, 2))
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(0, 0, 3, 2))
  @debug.assert_eq(terminal.last_known_area(), @core.Rect::new(0, 0, 3, 2))
  @debug.assert_eq(
    terminal.buffer_at(terminal.current()).area,
    terminal.viewport_area(),
  )
  @debug.assert_eq(
    terminal.buffer_at(1 - terminal.current()).area,
    terminal.viewport_area(),
  )
}

///|
/// 上游 `resize_inline_recomputes_origin_using_previous_cursor_offset`：
/// 行内重排以光标相对行保持视口锚定喵。
test "resize 行内按先前光标偏移重算原点" {
  let backend = @backend.TestBackend::new_with_size(10, 10)
  backend.set_cursor_position(@core.Position::new(0, 4))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Inline(4),
  })
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(0, 4, 10, 4))
  // 追踪位 (0,5)、后端光标 (0,6)：先 set_cursor_position 同步两者，
  // 再直改后端光标（上游直接写白盒字段）喵。
  terminal.set_cursor_position(@core.Position::new(0, 5))
  backend.set_cursor_position(@core.Position::new(0, 6))
  backend.resize(10, 12)
  terminal.resize(@core.Rect::new(0, 0, 10, 12))
  // 先前视口顶 y=4、追踪 y=5 → 偏移 1 行；重排时后端光标 y=6 →
  // 新视口顶 = 6 - 1 = 5 喵。
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(0, 5, 10, 4))
  @debug.assert_eq(terminal.last_known_area(), @core.Rect::new(0, 0, 10, 12))
}

///|
/// 上游 `new_fullscreen_initializes_state` 喵。
test "new 全屏初始化状态" {
  let backend = @backend.TestBackend::new_with_size(10, 5)
  let terminal = @terminal.Terminal::new(backend)
  @debug.assert_eq(terminal.viewport(), @terminal.Fullscreen)
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(0, 0, 10, 5))
  @debug.assert_eq(terminal.last_known_area(), @core.Rect::new(0, 0, 10, 5))
  @debug.assert_eq(terminal.last_known_cursor_pos(), @core.Position::new(0, 0))
  inspect(terminal.current(), content="0")
  inspect(terminal.hidden_cursor(), content="false")
  inspect(terminal.frame_count(), content="0")
  @debug.assert_eq(terminal.buffer_at(0).area, terminal.viewport_area())
  @debug.assert_eq(terminal.buffer_at(1).area, terminal.viewport_area())
}

///|
/// 上游 `with_options_fixed_uses_fixed_area` 喵。
test "with_options 固定视口使用固定区域" {
  let backend = @backend.TestBackend::new_with_size(10, 10)
  let viewport : @terminal.Viewport = @terminal.Fixed(
    @core.Rect::new(2, 3, 5, 4),
  )
  let terminal = @terminal.Terminal::with_options(backend, { viewport, })
  @debug.assert_eq(terminal.viewport(), viewport)
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(2, 3, 5, 4))
  @debug.assert_eq(terminal.last_known_area(), @core.Rect::new(2, 3, 5, 4))
  @debug.assert_eq(terminal.last_known_cursor_pos(), @core.Position::new(2, 3))
  @debug.assert_eq(terminal.buffer_at(0).area, terminal.viewport_area())
  @debug.assert_eq(terminal.buffer_at(1).area, terminal.viewport_area())
}

///|
/// 上游 `with_options_inline_anchors_to_cursor_when_space_available` 喵。
test "with_options 行内空间充足时锚定光标行" {
  let backend = @backend.TestBackend::new_with_size(10, 10)
  backend.set_cursor_position(@core.Position::new(0, 3))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Inline(4),
  })
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(0, 3, 10, 4))
  @debug.assert_eq(terminal.last_known_cursor_pos(), @core.Position::new(0, 3))
}

///|
/// 上游 `with_options_inline_shifts_up_when_near_bottom` 喵。
test "with_options 行内近底时上移" {
  let backend = @backend.TestBackend::new_with_size(10, 10)
  backend.set_cursor_position(@core.Position::new(0, 8))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Inline(4),
  })
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(0, 6, 10, 4))
  @debug.assert_eq(terminal.last_known_cursor_pos(), @core.Position::new(0, 8))
}

///|
/// 上游 `with_options_inline_clamps_height_to_terminal` 喵。
test "with_options 行内高度钳制到终端" {
  let backend = @backend.TestBackend::new_with_size(10, 3)
  backend.set_cursor_position(@core.Position::new(0, 0))
  let terminal = @terminal.Terminal::with_options(backend, {
    viewport: @terminal.Inline(10),
  })
  @debug.assert_eq(terminal.viewport_area(), @core.Rect::new(0, 0, 10, 3))
}
