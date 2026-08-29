///|
/// Buffer 单元测试：复刻 ratatui-v0.30.2 `buffer/buffer.rs` 与
/// `buffer/diff.rs` 的测试清单喵。
///
/// 登记"待复刻"：
/// - `renders_emoji`×4、`vs16_trailing_cell_unchanged`、
///   `diff_clears_trailing_cell_for_wide_grapheme`、
///   `diff_ignores_style_only_changes_in_trailing_cells`：依赖真实
///   emoji/VS16 宽度语义，随 `unicode/` 全量宽度表落位补齐；
/// - `pos_of`/`index_of` 越界的 `should_panic` 用例：MoonBit 无
///   should_panic 通道，越界以 `guard!` 断言（程序员错误）覆盖。

///|
/// set_string 越界裁剪：行尾外的字符静默丢弃喵。
test "set_string 越界裁剪" {
  let buf = Buffer::new(Rect::new(0, 0, 5, 2))
  buf.set_string(3, 0, "abcdef", Style::default())
  inspect(buf.get(3, 0).symbol(), content="a")
  inspect(buf.get(4, 0).symbol(), content="b")
  // 越界部分被裁剪，保持空白
  inspect(buf.get(5, 0).symbol(), content=" ")
}

///|
/// 非原点坐标系按绝对坐标读写喵。
test "非原点坐标系按绝对坐标读写" {
  let buf = Buffer::new(Rect::new(10, 5, 4, 2))
  buf.set_string(10, 5, "abcd", Style::default())
  inspect(buf.get(10, 5).symbol(), content="a")
  inspect(buf.get(13, 5).symbol(), content="d")
  // 区域外写入被忽略
  buf.set_string(9, 5, "z", Style::default())
  inspect(buf.get(9, 5).symbol(), content=" ")
}

///|
/// 空区域优雅退化喵。
test "空区域优雅退化" {
  let area = Rect::new(0, 0, 0, 3)
  let buf = Buffer::new(area)
  buf.set_string(0, 0, "anything", Style::default())
  inspect(Buffer::new(area).diff(buf).length(), content="0")
}

///|
/// 上游 it_translates_to_and_from_coordinates：索引与坐标互转喵。
test "索引与坐标互转" {
  let buf = Buffer::empty(Rect::new(200, 100, 50, 80))
  let (x0, y0) = buf.pos_of(0)
  inspect(x0, content="200")
  inspect(y0, content="100")
  inspect(buf.index_of(200, 100), content="0")
  let last = buf.cells.length() - 1
  let (xl, yl) = buf.pos_of(last)
  inspect(xl, content="249")
  inspect(yl, content="179")
  inspect(buf.index_of(249, 179), content=last.to_string())
}

///|
/// 上游 test_cell：安全读单元格，越界返回 None 喵。
test "cell 安全读取" {
  let buf = Buffer::with_lines(["Hello", "World"])
  let expected = Cell::empty()
  expected.set_symbol("H")
  @debug.assert_eq(buf.cell(0, 0), Some(expected))
  inspect(buf.cell(10, 10) is None, content="true")
  @debug.assert_eq(buf.cell_at(Position::new(0, 0)), Some(expected))
  inspect(buf.cell_at(Position::new(10, 10)) is None, content="true")
}

///|
/// 上游 index/index_mut：通过单元格引用原地修改喵。
test "mut_cell 原地修改" {
  let buf = Buffer::with_lines(["Cat", "Dog"])
  match buf.mut_cell(0, 0) {
    Some(cell) => cell.set_symbol("B")
    None => ()
  }
  match buf.mut_cell(0, 1) {
    Some(cell) => cell.set_symbol("L")
    None => ()
  }
  @debug.assert_eq(buf, Buffer::with_lines(["Bat", "Log"]))
  inspect(buf.mut_cell(10, 10) is None, content="true")
}

///|
/// 上游 set_string：零宽上限/宽度限制/宽度截断/多行喵。
test "set_string 基础语义" {
  let buffer = Buffer::empty(Rect::new(0, 0, 5, 1))
  // 零上限：什么也不写
  ignore(buffer.set_stringn(0, 0, "aaa", 0, Style::default()))
  @debug.assert_eq(buffer, Buffer::with_lines(["     "]))
  buffer.set_string(0, 0, "aaa", Style::default())
  @debug.assert_eq(buffer, Buffer::with_lines(["aaa  "]))
  // 宽度上限 4
  ignore(buffer.set_stringn(0, 0, "bbbbbbbbbbbbbb", 4, Style::default()))
  @debug.assert_eq(buffer, Buffer::with_lines(["bbbb "]))
  buffer.set_string(0, 0, "12345", Style::default())
  @debug.assert_eq(buffer, Buffer::with_lines(["12345"]))
  // 宽度截断
  buffer.set_string(0, 0, "123456", Style::default())
  @debug.assert_eq(buffer, Buffer::with_lines(["12345"]))
  // 多行
  let buffer = Buffer::empty(Rect::new(0, 0, 5, 2))
  buffer.set_string(0, 0, "12345", Style::default())
  buffer.set_string(0, 1, "67890", Style::default())
  @debug.assert_eq(buffer, Buffer::with_lines(["12345", "67890"]))
}

///|
/// 上游 set_string_multi_width_overwrite：双宽字符覆盖单宽残留喵。
test "set_string 双宽覆盖" {
  let buffer = Buffer::empty(Rect::new(0, 0, 5, 1))
  buffer.set_string(0, 0, "aaaaa", Style::default())
  buffer.set_string(0, 0, "称号", Style::default())
  @debug.assert_eq(buffer, Buffer::with_lines(["称号a"]))
}

///|
/// 上游 set_string_zero_width：前导/尾随零宽字符不占列喵。
test "set_string 零宽字符" {
  let buffer = Buffer::empty(Rect::new(0, 0, 1, 1))
  ignore(buffer.set_stringn(0, 0, "\u{200B}a", 1, Style::default()))
  @debug.assert_eq(buffer, Buffer::with_lines(["a"]))
  buffer.reset()
  ignore(buffer.set_stringn(0, 0, "a\u{200B}", 1, Style::default()))
  @debug.assert_eq(buffer, Buffer::with_lines(["a"]))
}

///|
/// 上游 set_string_double_width：双宽字符占两列且尾列隐藏为空白喵。
test "set_string 双宽占列" {
  let buffer = Buffer::empty(Rect::new(0, 0, 5, 1))
  buffer.set_string(0, 0, "コン", Style::default())
  @debug.assert_eq(buffer, Buffer::with_lines(["コン "]))
  // 只剩 1 列时放不下第二个双宽字符，直接截断
  buffer.set_string(0, 0, "コンピ", Style::default())
  @debug.assert_eq(buffer, Buffer::with_lines(["コン "]))
}

///|
/// 上游 set_line_raw：Line 写入与截断喵。
test "set_line 原始行" {
  let cases = [
    ("", "     "),
    ("1", "1    "),
    ("12345", "12345"),
    ("123456", "12345"),
  ]
  for case in cases {
    let (content, expected) = case
    let buffer = Buffer::empty(Rect::new(0, 0, 5, 1))
    ignore(buffer.set_line(0, 0, Line::raw(content), 5))
    let expected_buffer = Buffer::empty(buffer.area)
    expected_buffer.set_string(0, 0, expected, Style::default())
    @debug.assert_eq(buffer, expected_buffer)
  }
}

///|
/// 上游 set_line_styled：行样式只作用于被写入的单元格喵。
test "set_line 样式行" {
  let content = "12345"
  let color = Style::new().fg(Blue)
  let buffer = Buffer::empty(Rect::new(0, 0, 5, 1))
  ignore(buffer.set_line(0, 0, Line::styled(content, color), 5))
  let written = content.length().clamp(min=0, max=5)
  for x in 0..<5 {
    let fg = buffer.get(x, 0).fg
    if x < written {
      @debug.assert_eq(fg, Blue)
    } else {
      @debug.assert_eq(fg, Reset)
    }
  }
}

///|
/// 上游 set_style：区域内叠加前景色喵。
test "set_style 区域着色" {
  let buffer = Buffer::with_lines(["aaaaa", "bbbbb", "ccccc"])
  buffer.set_style(Rect::new(0, 1, 5, 1), Style::new().fg(Red))
  @debug.assert_eq(
    buffer,
    Buffer::with_lines_of([
      Line::raw("aaaaa"),
      Line::styled("bbbbb", Style::new().fg(Red)),
      Line::raw("ccccc"),
    ]),
  )
}

///|
/// 上游 set_style_does_not_panic_when_out_of_area：区域越界求交裁剪喵。
test "set_style 越界裁剪" {
  let buffer = Buffer::with_lines(["aaaaa", "bbbbb", "ccccc"])
  buffer.set_style(Rect::new(0, 1, 10, 3), Style::new().fg(Red))
  @debug.assert_eq(
    buffer,
    Buffer::with_lines_of([
      Line::raw("aaaaa"),
      Line::styled("bbbbb", Style::new().fg(Red)),
      Line::styled("ccccc", Style::new().fg(Red)),
    ]),
  )
}

///|
/// 上游 with_lines：CJK 宽度参与宽度推断喵。
test "with_lines 宽度推断" {
  let buffer = Buffer::with_lines([
    "┌────────┐", "│コンピュ│", "│ーa 上で│",
    "└────────┘",
  ])
  inspect(buffer.area.x, content="0")
  inspect(buffer.area.y, content="0")
  inspect(buffer.area.width, content="10")
  inspect(buffer.area.height, content="4")
}

///|
/// 上游 with_lines_accepts_into_lines：带样式行与 set_string 等价喵。
test "with_lines 样式行等价" {
  let buf = Buffer::empty(Rect::new(0, 0, 3, 2))
  buf.set_string(0, 0, "foo", Style::new().fg(Red))
  buf.set_string(0, 1, "bar", Style::new().fg(Blue))
  @debug.assert_eq(
    buf,
    Buffer::with_lines_of([
      Line::styled("foo", Style::new().fg(Red)),
      Line::styled("bar", Style::new().fg(Blue)),
    ]),
  )
}

///|
/// 上游 control_sequence_rendered_full：控制字符被过滤，其余原样上屏喵。
test "set_string 过滤控制字符（完整）" {
  let text = "I \u{1b}[0;36mwas\u{1b}[0m here!"
  let buffer = Buffer::filled(Rect::new(0, 0, 25, 3), Cell::of("x"))
  buffer.set_string(1, 1, text, Style::new())
  @debug.assert_eq(
    buffer,
    Buffer::with_lines([
      "xxxxxxxxxxxxxxxxxxxxxxxxx", "xI [0;36mwas[0m here!xxxx", "xxxxxxxxxxxxxxxxxxxxxxxxx",
    ]),
  )
}

///|
/// 上游 control_sequence_rendered_partially：截断路径同样过滤控制字符喵。
test "set_string 过滤控制字符（部分）" {
  let text = "I \u{1b}[0;36mwas\u{1b}[0m here!"
  let buffer = Buffer::filled(Rect::new(0, 0, 11, 3), Cell::of("x"))
  buffer.set_string(1, 1, text, Style::new())
  @debug.assert_eq(
    buffer,
    Buffer::with_lines(["xxxxxxxxxxx", "xI [0;36mwa", "xxxxxxxxxxx"]),
  )
}

///|
/// 上游 index_pos_of_u16_max：超过 u16 单行长度的索引换算不回绕喵。
test "索引坐标换算超 u16 单行" {
  let buffer = Buffer::empty(Rect::new(0, 0, 256, 256 + 1))
  inspect(buffer.index_of(255, 255), content="65535")
  let (px1, py1) = buffer.pos_of(65535)
  inspect(px1, content="255")
  inspect(py1, content="255")
  inspect(buffer.index_of(0, 256), content="65536")
  let (px2, py2) = buffer.pos_of(65536)
  inspect(px2, content="0")
  inspect(py2, content="256")
  inspect(buffer.index_of(1, 256), content="65537")
  let (px3, py3) = buffer.pos_of(65791)
  inspect(px3, content="255")
  inspect(py3, content="256")
}

///|
/// 上游 debug_empty_buffer：空缓冲 Debug 呈现喵。
test "空缓冲 Debug" {
  inspect(
    Buffer::empty(Rect::new(0, 0, 0, 0)).to_debug(),
    content="Buffer {\n    area: Rect { x: 0, y: 0, width: 0, height: 0 }\n}",
  )
}

///|
/// 上游 debug_some_example：内容行 + 变化点样式清单喵。
test "缓冲 Debug 呈现" {
  let buffer = Buffer::empty(Rect::new(0, 0, 12, 2))
  buffer.set_string(0, 0, "Hello World!", Style::default())
  buffer.set_string(
    0,
    1,
    "G'day World!",
    Style::new().fg(Green).bg(Yellow).add_modifier(Modifier::bold()),
  )
  inspect(
    buffer.to_debug(),
    content=(
      #|Buffer {
      #|    area: Rect { x: 0, y: 0, width: 12, height: 2 },
      #|    content: [
      #|        "Hello World!",
      #|        "G'day World!",
      #|    ],
      #|    styles: [
      #|        x: 0, y: 0, fg: Reset, bg: Reset, modifier: NONE,
      #|        x: 0, y: 1, fg: Green, bg: Yellow, modifier: BOLD,
      #|    ]
      #|}
    ),
  )
}

///|
/// 上游 diff_empty_empty：全等缓冲零差分喵。
test "diff 空对空" {
  let area = Rect::new(0, 0, 40, 40)
  let prev = Buffer::empty(area)
  let next = Buffer::empty(area)
  inspect(prev.diff(next).length(), content="0")
}

///|
/// 上游 diff_empty_filled：填满差异全量上报喵。
test "diff 空对填充" {
  let area = Rect::new(0, 0, 40, 40)
  let prev = Buffer::empty(area)
  let next = Buffer::filled(area, Cell::of("a"))
  inspect(prev.diff(next).length(), content="1600")
}

///|
/// 上游 diff_filled_filled：同填充零差分喵。
test "diff 填充对填充" {
  let area = Rect::new(0, 0, 40, 40)
  let prev = Buffer::filled(area, Cell::of("a"))
  let next = Buffer::filled(area, Cell::of("a"))
  inspect(prev.diff(next).length(), content="0")
}

///|
/// 上游 diff_single_width：单宽差异逐格上报喵。
test "diff 单宽" {
  let prev = Buffer::with_lines([
    "          ", "┌Title─┐  ", "│      │  ", "│      │  ", "└──────┘  ",
  ])
  let next = Buffer::with_lines([
    "          ", "┌TITLE─┐  ", "│      │  ", "│      │  ", "└──────┘  ",
  ])
  let changes = prev.diff(next)
  inspect(changes.length(), content="4")
  let expected = [(2, 1, "I"), (3, 1, "T"), (4, 1, "L"), (5, 1, "E")]
  for k, item in expected {
    let (x, y, symbol) = item
    inspect(changes[k].0, content=x.to_string())
    inspect(changes[k].1, content=y.to_string())
    @debug.assert_eq(changes[k].2, Cell::of(symbol))
  }
}

///|
/// 上游 diff_multi_width：双宽字形吞掉尾列差异喵。
test "diff 双宽" {
  let prev = Buffer::with_lines([
    "┌Title─┐  ", "└──────┘  ",
  ])
  let next = Buffer::with_lines([
    "┌称号──┐  ", "└──────┘  ",
  ])
  let changes = prev.diff(next)
  // "称" 覆盖 (1,0)-(2,0)，"号" 覆盖 (3,0)-(4,0)，尾列不再上报
  inspect(changes.length(), content="3")
  @debug.assert_eq(changes[0].2, Cell::of("称"))
  @debug.assert_eq(changes[1].2, Cell::of("号"))
  @debug.assert_eq(changes[2].2, Cell::of("─"))
  inspect(changes[0].0, content="1")
  inspect(changes[1].0, content="3")
  inspect(changes[2].0, content="5")
}

///|
/// 上游 diff_multi_width_offset：双宽字形平移时的吞列喵。
test "diff 双宽平移" {
  let prev = Buffer::with_lines(["┌称号──┐"])
  let next = Buffer::with_lines(["┌─称号─┐"])
  let changes = prev.diff(next)
  inspect(changes.length(), content="3")
  @debug.assert_eq(changes[0].2, Cell::of("─"))
  @debug.assert_eq(changes[1].2, Cell::of("称"))
  @debug.assert_eq(changes[2].2, Cell::of("号"))
  inspect(changes[0].0, content="1")
  inspect(changes[1].0, content="2")
  inspect(changes[2].0, content="4")
}

///|
/// 上游 merge_diff_idempotent：合并后差分为空喵。
test "merge 后 diff 幂等" {
  let prev = Buffer::with_lines(["123"])
  let next = Buffer::with_lines(["456"])
  prev.merge(next)
  inspect(prev.diff(next).length(), content="0")
}

///|
/// 上游 merge_diff_forcedwidth：ForcedWidth 与差分指令一并合并喵。
test "merge 保留 ForcedWidth" {
  let prev = Buffer::with_lines(["123"])
  let next = Buffer::empty(Rect::new(0, 0, 3, 1))
  match next.mut_cell(0, 0) {
    Some(cell) => {
      cell.set_symbol("456")
      cell.set_diff_option(CellDiffOption::ForcedWidth(3))
    }
    None => ()
  }
  prev.merge(next)
  inspect(prev.diff(next).length(), content="0")
}

///|
/// 上游 merge_diff_link：OSC8 链接占位挤进单格且差分为空喵。
test "merge 链接占位" {
  let prev = Buffer::with_lines(["____"])
  let next = Buffer::empty(Rect::new(0, 0, 4, 1))
  match next.mut_cell(0, 0) {
    Some(cell) => {
      cell.set_symbol(
        "\u{1b}]8;;http://example.com\u{1b}\\link\u{1b}]8;;\u{1b}\\",
      )
      cell.set_diff_option(CellDiffOption::ForcedWidth(4))
    }
    None => ()
  }
  prev.merge(next)
  inspect(prev.diff(next).length(), content="0")
}

///|
/// 上游 merge_diff_split_link：链接序列拆进多格仍差分为空喵。
test "merge 拆分链接占位" {
  let prev = Buffer::with_lines(["________"])
  let next = Buffer::empty(Rect::new(0, 0, 8, 1))
  match next.mut_cell(0, 0) {
    Some(cell) => {
      cell.set_symbol("\u{1b}]8;;http://example.com\u{1b}\\🔗")
      cell.set_diff_option(CellDiffOption::ForcedWidth(2))
    }
    None => ()
  }
  let inner = ["l", "i", "n", "k"]
  for k, symbol in inner {
    match next.mut_cell(2 + k, 0) {
      Some(cell) => cell.set_symbol(symbol)
      None => ()
    }
  }
  match next.mut_cell(7, 0) {
    Some(cell) => {
      cell.set_symbol("🔗\u{1b}]8;;\u{1b}\\")
      cell.set_diff_option(CellDiffOption::ForcedWidth(2))
    }
    None => ()
  }
  prev.merge(next)
  inspect(prev.diff(next).length(), content="0")
}

///|
/// 上游 merge_diff_image_sequences：kitty 图片占位序列合并喵。
test "merge 图片占位序列" {
  let prev = Buffer::empty(Rect::new(0, 0, 20, 1))
  let placeholder_start = "\u{1b}[s\u{1b}[38;2;0;0;0m\u{10EEEE}\u{305}\u{305}\u{305}"
  match prev.mut_cell(0, 0) {
    Some(cell) => {
      cell.set_symbol(placeholder_start)
      cell.set_diff_option(CellDiffOption::ForcedWidth(1))
    }
    None => ()
  }
  match prev.mut_cell(1, 0) {
    Some(cell) => cell.set_char('\u{10EEEE}')
    None => ()
  }
  match prev.mut_cell(2, 0) {
    Some(cell) => cell.set_char('\u{10EEEE}')
    None => ()
  }
  match prev.mut_cell(3, 0) {
    Some(cell) => {
      cell.set_symbol("\u{10EEEE}\u{1b}[u")
      cell.set_diff_option(CellDiffOption::ForcedWidth(1))
    }
    None => ()
  }
  let buffer = Buffer::filled(Rect::new(0, 0, 20, 1), Cell::of("x"))
  buffer.merge(prev)
  inspect(buffer.diff(prev).length(), content="0")
}

///|
/// 上游 diff_skip：Skip 指令的单元格不上报喵。
test "diff 跳过 Skip 单元格" {
  let prev = Buffer::with_lines(["123"])
  let next = Buffer::with_lines(["456"])
  for i in 1..<3 {
    match next.mut_cell(i, 0) {
      Some(cell) => cell.set_diff_option(CellDiffOption::Skip)
      None => ()
    }
  }
  let changes = prev.diff(next)
  inspect(changes.length(), content="1")
  @debug.assert_eq(changes[0].2, Cell::of("4"))
  inspect(changes[0].0, content="0")
}

///|
/// 上游 always_update_cells_are_emitted_even_when_identical：
/// AlwaysUpdate 无视相等照常上报喵。
test "diff AlwaysUpdate 恒上报" {
  let prev = Buffer::with_lines(["abc"])
  let next = Buffer::with_lines(["abc"])
  match prev.mut_cell(1, 0) {
    Some(cell) => cell.set_diff_option(CellDiffOption::AlwaysUpdate)
    None => ()
  }
  match next.mut_cell(1, 0) {
    Some(cell) => cell.set_diff_option(CellDiffOption::AlwaysUpdate)
    None => ()
  }
  let changes = prev.diff(next)
  inspect(changes.length(), content="1")
  inspect(changes[0].0, content="1")
  inspect(changes[0].1, content="0")
  @debug.assert_eq(changes[0].2.symbol(), "b")
}

///|
/// 上游 forced_width_skips_trailing：ForcedWidth 吞掉后续列喵。
test "diff ForcedWidth 吞列" {
  let prev = Buffer::with_lines(["abcd"])
  let next = Buffer::with_lines(["xbcd"])
  match next.mut_cell(0, 0) {
    Some(cell) => cell.set_diff_option(CellDiffOption::ForcedWidth(2))
    None => ()
  }
  let changes = prev.diff(next)
  inspect(changes.length(), content="1")
  @debug.assert_eq(changes[0].2.symbol(), "x")
}

///|
/// 上游 skip_cells_are_skipped（diff.rs）：Skip 指令只命中目标格喵。
test "diff Skip 只跳过目标格" {
  let prev = Buffer::with_lines(["abc"])
  let next = Buffer::with_lines(["xyz"])
  match next.mut_cell(1, 0) {
    Some(cell) => cell.set_diff_option(CellDiffOption::Skip)
    None => ()
  }
  let changes = prev.diff(next)
  inspect(changes.length(), content="2")
  @debug.assert_eq(changes[0].2.symbol(), "x")
  @debug.assert_eq(changes[1].2, Cell::of("z"))
}

///|
/// 上游 uncovered_trailing_cells_emitted_when_wide_char_style_changes：
/// CJK 宽字形带底色被窄字符替换时，尾列必须强刷清底色喵。
test "diff 宽字形样式可见时强刷尾列" {
  let rect = Rect::new(0, 0, 12, 1)
  let prev = Buffer::empty(rect)
  prev.set_string(0, 0, "你好，世界！", Style::new().bg(Blue))
  let next = Buffer::empty(rect)
  next.set_string(0, 0, "Hello", Style::default())
  let changes = prev.diff(next)
  // 列 5/7/9/11 是 "，世 界 ！" 的尾列：两缓冲同为空白，但终端上
  // 曾被画成蓝底，必须显式刷新喵
  for x in [5, 7, 9, 11] {
    let mut found = false
    for change in changes {
      if change.0 == x && change.1 == 0 {
        found = true
        break
      }
    }
    inspect(found, content="true")
  }
}

///|
/// 上游 uncovered_trailing_cells_emitted_when_wide_chars_partially_replaced：
/// 同底色宽字形被部分替换时，尾列残留同样必须强刷喵。
test "diff 同底色宽字形部分替换强刷尾列" {
  let rect = Rect::new(0, 0, 12, 1)
  let prev = Buffer::empty(rect)
  prev.set_string(0, 0, "你好，世界！", Style::new().bg(Blue))
  let next = Buffer::empty(rect)
  next.set_string(0, 0, "喵呜www", Style::new().bg(Blue))
  let changes = prev.diff(next)
  // 列 7 是 "世" 的尾列：新旧同为蓝底，但终端画过蓝底必须清除喵
  let mut found = false
  for change in changes {
    if change.0 == 7 && change.1 == 0 {
      found = true
      break
    }
  }
  inspect(found, content="true")
}

///|
/// 上游 no_force_update_when_wide_char_has_default_style：
/// 默认样式的宽字形收窄不强刷尾列（零噪音）喵。
test "diff 默认样式宽字形不强刷" {
  let rect = Rect::new(0, 0, 12, 1)
  let prev = Buffer::empty(rect)
  prev.set_string(0, 0, "你好，世界！", Style::default())
  let next = Buffer::empty(rect)
  next.set_string(0, 0, "Hello", Style::default())
  let changes = prev.diff(next)
  for x in [5, 7, 9, 11] {
    let mut found = false
    for change in changes {
      if change.0 == x && change.1 == 0 {
        found = true
        break
      }
    }
    inspect(found, content="false")
  }
}

///|
/// 上游 shrinking_wide_glyph_clears_trailing_cell：全角字形清场时
/// 两列都要上报（#2585 回归）喵。
test "diff 收缩宽字形清尾列" {
  let rect = Rect::new(0, 0, 2, 1)
  let prev = Buffer::empty(rect)
  prev.set_string(0, 0, "＋", Style::new())
  match prev.mut_cell(0, 0) {
    Some(cell) => cell.set_bg(Red)
    None => ()
  }
  inspect(prev.get(0, 0).symbol(), content="＋")
  inspect(prev.get(1, 0).symbol(), content=" ")
  let next = Buffer::empty(rect)
  let changes = prev.diff(next)
  inspect(changes.length(), content="2")
  inspect(changes[0].0, content="0")
  inspect(changes[1].0, content="1")
  @debug.assert_eq(changes[0].2, Cell::empty())
  @debug.assert_eq(changes[1].2, Cell::empty())
}

///|
/// 上游 shrinking_wide_glyph_clears_trailing_background：
/// 宽字形蓝底残留的尾列必须刷新喵。
test "diff 收缩宽字形清尾列底色" {
  let rect = Rect::new(0, 0, 2, 1)
  let prev = Buffer::empty(rect)
  prev.set_string(0, 0, "＋", Style::new().bg(Blue))
  let next = Buffer::empty(rect)
  let changes = prev.diff(next)
  let mut found = false
  for change in changes {
    if change.0 == 1 && change.1 == 0 {
      found = true
      break
    }
  }
  inspect(found, content="true")
}

///|
/// 上游 trailing_range_cell_style_change_is_emitted：尾列强刷段内
/// 纯样式变化也必须上报喵。
test "diff 尾列段内样式变化上报" {
  let rect = Rect::new(0, 0, 3, 1)
  let prev = Buffer::empty(rect)
  prev.set_string(0, 0, "你", Style::new().bg(Blue))
  match prev.mut_cell(1, 0) {
    Some(cell) => {
      cell.set_symbol("X")
      cell.set_fg(Red)
      cell.set_bg(Reset)
    }
    None => ()
  }
  let next = Buffer::empty(rect)
  next.set_string(0, 0, "a", Style::default())
  match next.mut_cell(1, 0) {
    Some(cell) => {
      cell.set_symbol("X")
      cell.set_fg(Green)
      cell.set_bg(Reset)
    }
    None => ()
  }
  let changes = prev.diff(next)
  let mut found = false
  for change in changes {
    if change.0 == 1 && change.1 == 0 {
      found = true
      break
    }
  }
  inspect(found, content="true")
}

///|
/// 上游 trailing_range_wide_char_trailing_not_corrupted：强刷段内
/// 遇到宽字形时不得对它的尾列误写空白喵。
test "diff 强刷段内宽字形不误写尾列" {
  let rect = Rect::new(0, 0, 4, 1)
  let prev = Buffer::empty(rect)
  prev.set_string(0, 0, "你好", Style::new().bg(Blue))
  let next = Buffer::empty(rect)
  next.set_string(0, 0, "a", Style::new().bg(Blue))
  next.set_string(1, 0, "好", Style::new().bg(Blue))
  let changes = prev.diff(next)
  // 列 2 是 next 中 "好" 的尾列，不得收到空白覆盖喵
  let mut corrupted = false
  let mut has_hao = false
  for change in changes {
    if change.0 == 2 && change.1 == 0 {
      corrupted = true
    }
    if change.0 == 1 && change.1 == 0 && change.2.symbol() == "好" {
      has_hao = true
    }
  }
  inspect(corrupted, content="false")
  inspect(has_hao, content="true")
}

///|
/// 上游 merge（第一组）：纵向堆叠合并喵。
test "merge 纵向堆叠" {
  let one = Buffer::filled(Rect::new(0, 0, 2, 2), Cell::of("1"))
  let two = Buffer::filled(Rect::new(0, 2, 2, 2), Cell::of("2"))
  one.merge(two)
  @debug.assert_eq(one, Buffer::with_lines(["11", "11", "22", "22"]))
}

///|
/// 上游 merge（第二组）：分离区域合并喵。
test "merge 分离区域" {
  let one = Buffer::filled(Rect::new(2, 2, 2, 2), Cell::of("1"))
  let two = Buffer::filled(Rect::new(0, 0, 2, 2), Cell::of("2"))
  one.merge(two)
  @debug.assert_eq(one, Buffer::with_lines(["22  ", "22  ", "  11", "  11"]))
}

///|
/// 上游 merge_with_offset：偏移合并，并集区域与内容对位喵。
test "merge 偏移区域" {
  let one = Buffer::filled(Rect::new(3, 3, 2, 2), Cell::of("1"))
  let two = Buffer::filled(Rect::new(1, 1, 3, 4), Cell::of("2"))
  one.merge(two)
  // 并集区域 (1,1)-(4,4)
  inspect(one.area.x, content="1")
  inspect(one.area.y, content="1")
  inspect(one.area.width, content="4")
  inspect(one.area.height, content="4")
  // 内容对位："1" 只在 two 未覆盖的 (4,3)/(4,4) 幸存喵
  let rows = ["222 ", "222 ", "2221", "2221"]
  for y, row in rows {
    for x, ch in row {
      inspect(one.get(x + 1, y + 1).symbol() == ch.to_string(), content="true")
    }
  }
}

///|
/// 上游 merge_skip：差分指令随合并保留喵。
test "merge 保留差分指令" {
  let one = Buffer::filled(
    Rect::new(0, 0, 2, 2),
    with_option(Cell::of("1"), CellDiffOption::None),
  )
  let two = Buffer::filled(
    Rect::new(0, 1, 2, 2),
    with_option(Cell::of("2"), CellDiffOption::Skip),
  )
  one.merge(two)
  let expected = [
    CellDiffOption::None,
    CellDiffOption::None,
    CellDiffOption::Skip,
    CellDiffOption::Skip,
    CellDiffOption::Skip,
    CellDiffOption::Skip,
  ]
  for i, option in expected {
    @debug.assert_eq(one.cells[i].diff_option, option)
  }
}

///|
/// 带差分指令的单元格构造（辅助函数）喵。
fn with_option(cell : Cell, option : CellDiffOption) -> Cell {
  let cell = Cell::of_cell(cell)
  cell.set_diff_option(option)
  cell
}

///|
/// 上游 `assert_buffer_eq_does_not_panic_on_equal_buffers` 喵。
test "assert_buffer_eq 等值缓冲不断言失败" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 5, 1))
  let other_buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 5, 1))
  @core.Buffer::assert_buffer_eq(buffer, other_buffer)
}

///|
/// 上游 `assert_buffer_eq_panics_on_unequal_area`：区域不等即断言
/// 失败（should_panic 以 try? 承载）喵。
test "assert_buffer_eq 区域不等断言失败" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 5, 1))
  let other_buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 6, 1))
  let mut failed = false
  @core.Buffer::assert_buffer_eq(buffer, other_buffer) catch {
    Failure(text) => {
      failed = true
      inspect(text.contains("buffer areas not equal"), content="true")
    }
    _ => ()
  }
  inspect(failed, content="true")
}

///|
/// 上游 `assert_buffer_eq_panics_on_unequal_style`：内容不等断言
/// 失败并附 diff 喵。
test "assert_buffer_eq 内容不等断言失败" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 5, 1))
  let other_buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 5, 1))
  ignore(other_buffer.set_string(0, 0, " ", @core.Style::new().fg(@core.Red)))
  let mut failed = false
  @core.Buffer::assert_buffer_eq(buffer, other_buffer) catch {
    Failure(text) => {
      failed = true
      inspect(text.contains("buffer contents not equal"), content="true")
    }
    _ => ()
  }
  inspect(failed, content="true")
}
