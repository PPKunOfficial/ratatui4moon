///|
/// Paragraph 单元测试：复刻 ratatui-v0.30.2 `widgets/paragraph.rs`
/// 测试清单喵。
///
/// 登记"待复刻"：`can_be_stylized` 的 Stylize 链糖、半宽浊点
/// 图形簇用例（ｶﾞ 依赖 unicode-segmentation，随 unicode/ 落位）。

///|
/// 上游 test_case：以期望缓冲尺寸新建缓冲渲染比对喵。
fn test_case(paragraph : Paragraph, expected : @core.Buffer) -> Unit raise {
  let buffer = @core.Buffer::empty(
    @core.Rect::new(0, 0, expected.area.width, expected.area.height),
  )
  paragraph.render(buffer.area, buffer)
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 zero_width_char_at_end_of_line：行尾零宽字符不破坏渲染喵。
test "Paragraph 行尾零宽字符" {
  let line = "foo\u{200B}"
  let paragraphs = [
    Paragraph::of_str(line),
    Paragraph::of_str(line).wrap(Wrap::of(false)),
    Paragraph::of_str(line).wrap(Wrap::of(true)),
  ]
  for paragraph in paragraphs {
    test_case(paragraph, @core.Buffer::with_lines(["foo"]))
    test_case(paragraph, @core.Buffer::with_lines(["foo   "]))
    test_case(paragraph, @core.Buffer::with_lines(["foo   ", "      "]))
    test_case(paragraph, @core.Buffer::with_lines(["foo", "   "]))
  }
}

///|
/// 上游 test_render_empty_paragraph：空文本渲染为空白喵。
test "Paragraph 空文本" {
  let paragraphs = [
    Paragraph::of_str(""),
    Paragraph::of_str("").wrap(Wrap::of(false)),
    Paragraph::of_str("").wrap(Wrap::of(true)),
  ]
  for paragraph in paragraphs {
    test_case(paragraph, @core.Buffer::with_lines([" "]))
    test_case(paragraph, @core.Buffer::with_lines(["          "]))
    test_case(
      paragraph,
      @core.Buffer::with_lines([
        "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ",
        "     ",
      ]),
    )
    test_case(paragraph, @core.Buffer::with_lines([" ", " "]))
  }
}

///|
/// 上游 test_render_single_line_paragraph 喵。
test "Paragraph 单行" {
  let text = "Hello, world!"
  let paragraphs = [
    Paragraph::of_str(text),
    Paragraph::of_str(text).wrap(Wrap::of(false)),
    Paragraph::of_str(text).wrap(Wrap::of(true)),
  ]
  for paragraph in paragraphs {
    test_case(paragraph, @core.Buffer::with_lines(["Hello, world!  "]))
    test_case(paragraph, @core.Buffer::with_lines(["Hello, world!"]))
    test_case(
      paragraph,
      @core.Buffer::with_lines(["Hello, world!  ", "               "]),
    )
    test_case(
      paragraph,
      @core.Buffer::with_lines(["Hello, world!", "             "]),
    )
  }
}

///|
/// 上游 test_render_multi_line_paragraph 喵。
test "Paragraph 多行" {
  let text = "This is a\nmultiline\nparagraph."
  let paragraphs = [
    Paragraph::of_str(text),
    Paragraph::of_str(text).wrap(Wrap::of(false)),
    Paragraph::of_str(text).wrap(Wrap::of(true)),
  ]
  for paragraph in paragraphs {
    test_case(
      paragraph,
      @core.Buffer::with_lines(["This is a ", "multiline ", "paragraph."]),
    )
    test_case(
      paragraph,
      @core.Buffer::with_lines([
        "This is a      ", "multiline      ", "paragraph.     ",
      ]),
    )
    test_case(
      paragraph,
      @core.Buffer::with_lines([
        "This is a      ", "multiline      ", "paragraph.     ", "               ",
        "               ",
      ]),
    )
  }
}

///|
/// 上游 test_render_paragraph_with_block：带边框块的截断与折行喵。
test "Paragraph 带边框块" {
  let text = "Hello, worlds!"
  let truncated_paragraph = Paragraph::of_str(text).block(
    Block::bordered().title_str("Title"),
  )
  let wrapped_paragraph = truncated_paragraph.wrap(Wrap::of(false))
  let trimmed_paragraph = truncated_paragraph.wrap(Wrap::of(true))
  let paragraphs = [truncated_paragraph, wrapped_paragraph, trimmed_paragraph]
  for paragraph in paragraphs {
    test_case(
      paragraph,
      @core.Buffer::with_lines([
        "┌Title─────────┐", "│Hello, worlds!│", "└──────────────┘",
      ]),
    )
    test_case(
      paragraph,
      @core.Buffer::with_lines([
        "┌Title───────────┐", "│Hello, worlds!  │",
        "└────────────────┘",
      ]),
    )
    test_case(
      paragraph,
      @core.Buffer::with_lines([
        "┌Title────────────┐", "│Hello, worlds!   │",
        "│                 │", "└─────────────────┘",
      ]),
    )
  }
  test_case(
    truncated_paragraph,
    @core.Buffer::with_lines([
      "┌Title───────┐", "│Hello, world│", "│            │",
      "└────────────┘",
    ]),
  )
  test_case(
    wrapped_paragraph,
    @core.Buffer::with_lines([
      "┌Title──────┐", "│Hello,     │", "│worlds!    │",
      "└───────────┘",
    ]),
  )
  test_case(
    trimmed_paragraph,
    @core.Buffer::with_lines([
      "┌Title──────┐", "│Hello,     │", "│worlds!    │",
      "└───────────┘",
    ]),
  )
}

///|
/// 上游 test_render_line_styled：行级样式喵。
test "Paragraph 行样式" {
  let l0 = @core.Line::raw("unformatted")
  let l1 = @core.Line::styled("bold text", @core.Style::new().bold())
  let l2 = @core.Line::styled("cyan text", @core.Style::new().cyan())
  let l3 = @core.Line::styled("dim text", @core.Style::new().dim())
  let paragraph = Paragraph::new(@core.Text::of_lines([l0, l1, l2, l3]))
  let expected = @core.Buffer::with_lines([
    "unformatted", "bold text", "cyan text", "dim text",
  ])
  expected.set_style(@core.Rect::new(0, 1, 9, 1), @core.Style::new().bold())
  expected.set_style(@core.Rect::new(0, 2, 9, 1), @core.Style::new().cyan())
  expected.set_style(@core.Rect::new(0, 3, 8, 1), @core.Style::new().dim())
  test_case(paragraph, expected)
}

///|
/// 上游 test_render_line_spans_styled：span 级样式喵。
test "Paragraph span 样式" {
  let l0 = @core.Line::of_spans([
    @core.Span::styled("bold", @core.Style::new().bold()),
    @core.Span::raw(" and "),
    @core.Span::styled("cyan", @core.Style::new().cyan()),
  ])
  let l1 = @core.Line::of_spans([@core.Span::raw("unformatted")])
  let paragraph = Paragraph::new(@core.Text::of_lines([l0, l1]))
  let expected = @core.Buffer::with_lines(["bold and cyan", "unformatted"])
  expected.set_style(@core.Rect::new(0, 0, 4, 1), @core.Style::new().bold())
  expected.set_style(@core.Rect::new(9, 0, 4, 1), @core.Style::new().cyan())
  test_case(paragraph, expected)
}

///|
/// 上游 test_render_paragraph_with_block_with_bottom_title_and_border 喵。
test "Paragraph 底部标题块" {
  let block = Block::new()
    .borders(Borders::bottom())
    .title_position(TitlePosition::Bottom)
    .title_str("Title")
  let paragraph = Paragraph::of_str("Hello, world!").block(block)
  test_case(
    paragraph,
    @core.Buffer::with_lines([
      "Hello, world!  ", "Title──────────",
    ]),
  )
}

///|
/// 上游 test_render_paragraph_with_word_wrap：trim 两种模式的折行喵。
test "Paragraph 折行" {
  let text = "This is a long line of text that should wrap      and contains a superultramegagigalong word."
  let wrapped_paragraph = Paragraph::of_str(text).wrap(Wrap::of(false))
  let trimmed_paragraph = Paragraph::of_str(text).wrap(Wrap::of(true))
  test_case(
    wrapped_paragraph,
    @core.Buffer::with_lines([
      "This is a long line", "of text that should", "wrap      and      ", "contains a         ",
      "superultramegagigal", "ong word.          ",
    ]),
  )
  test_case(
    wrapped_paragraph,
    @core.Buffer::with_lines([
      "This is a   ", "long line of", "text that   ", "should wrap ", "    and     ",
      "contains a  ", "superultrame", "gagigalong  ", "word.       ",
    ]),
  )
  test_case(
    trimmed_paragraph,
    @core.Buffer::with_lines([
      "This is a long line", "of text that should", "wrap      and      ", "contains a         ",
      "superultramegagigal", "ong word.          ",
    ]),
  )
  test_case(
    trimmed_paragraph,
    @core.Buffer::with_lines([
      "This is a   ", "long line of", "text that   ", "should wrap ", "and contains",
      "a           ", "superultrame", "gagigalong  ", "word.       ",
    ]),
  )
}

///|
/// 上游 test_render_wrapped_paragraph_with_whitespace_only_line 喵。
test "Paragraph 纯空白行折行" {
  let text = @core.Text::of_lines([
    @core.Line::raw("A"),
    @core.Line::raw("  "),
    @core.Line::raw("B"),
    @core.Line::raw("  a"),
    @core.Line::raw("C"),
  ])
  let paragraph = Paragraph::new(text).wrap(Wrap::of(false))
  let text = @core.Text::of_lines([
    @core.Line::raw("A"),
    @core.Line::raw("  "),
    @core.Line::raw("B"),
    @core.Line::raw("  a"),
    @core.Line::raw("C"),
  ])
  let trimmed_paragraph = Paragraph::new(text).wrap(Wrap::of(true))
  test_case(paragraph, @core.Buffer::with_lines(["A", "  ", "B", "  a", "C"]))
  test_case(
    trimmed_paragraph,
    @core.Buffer::with_lines(["A", "", "B", "a", "C"]),
  )
}

///|
/// 上游 test_render_paragraph_with_line_truncation：截断与水平滚动喵。
test "Paragraph 截断与滚动" {
  let text = "This is a long line of text that should be truncated."
  let truncated_paragraph = Paragraph::of_str(text)
  test_case(
    truncated_paragraph,
    @core.Buffer::with_lines(["This is a long line of"]),
  )
  test_case(
    truncated_paragraph,
    @core.Buffer::with_lines(["This is a long line of te"]),
  )
  test_case(
    truncated_paragraph,
    @core.Buffer::with_lines(["This is a long line of "]),
  )
  test_case(
    truncated_paragraph.scroll((0, 2)),
    @core.Buffer::with_lines(["is is a long line of te"]),
  )
}

///|
/// 上游 test_render_paragraph_with_left_alignment 喵。
test "Paragraph 左对齐" {
  let text = "Hello, world!"
  let truncated_paragraph = Paragraph::of_str(text).left_aligned()
  let wrapped_paragraph = truncated_paragraph.wrap(Wrap::of(false))
  let trimmed_paragraph = truncated_paragraph.wrap(Wrap::of(true))
  let paragraphs = [truncated_paragraph, wrapped_paragraph, trimmed_paragraph]
  for paragraph in paragraphs {
    test_case(paragraph, @core.Buffer::with_lines(["Hello, world!  "]))
    test_case(paragraph, @core.Buffer::with_lines(["Hello, world!"]))
  }
  test_case(truncated_paragraph, @core.Buffer::with_lines(["Hello, wor"]))
  test_case(
    wrapped_paragraph,
    @core.Buffer::with_lines(["Hello,    ", "world!    "]),
  )
  test_case(
    trimmed_paragraph,
    @core.Buffer::with_lines(["Hello,    ", "world!    "]),
  )
}

///|
/// 上游 test_render_paragraph_with_center_alignment 喵。
test "Paragraph 居中" {
  let text = "Hello, world!"
  let truncated_paragraph = Paragraph::of_str(text).centered()
  let wrapped_paragraph = truncated_paragraph.wrap(Wrap::of(false))
  let trimmed_paragraph = truncated_paragraph.wrap(Wrap::of(true))
  let paragraphs = [truncated_paragraph, wrapped_paragraph, trimmed_paragraph]
  for paragraph in paragraphs {
    test_case(paragraph, @core.Buffer::with_lines([" Hello, world! "]))
    test_case(paragraph, @core.Buffer::with_lines(["  Hello, world! "]))
    test_case(paragraph, @core.Buffer::with_lines(["  Hello, world!  "]))
    test_case(paragraph, @core.Buffer::with_lines(["Hello, world!"]))
  }
  test_case(truncated_paragraph, @core.Buffer::with_lines(["Hello, wor"]))
  test_case(
    wrapped_paragraph,
    @core.Buffer::with_lines(["  Hello,  ", "  world!  "]),
  )
  test_case(
    trimmed_paragraph,
    @core.Buffer::with_lines(["  Hello,  ", "  world!  "]),
  )
}

///|
/// 上游 test_render_paragraph_with_right_alignment 喵。
test "Paragraph 右对齐" {
  let text = "Hello, world!"
  let truncated_paragraph = Paragraph::of_str(text).right_aligned()
  let wrapped_paragraph = truncated_paragraph.wrap(Wrap::of(false))
  let trimmed_paragraph = truncated_paragraph.wrap(Wrap::of(true))
  let paragraphs = [truncated_paragraph, wrapped_paragraph, trimmed_paragraph]
  for paragraph in paragraphs {
    test_case(paragraph, @core.Buffer::with_lines(["  Hello, world!"]))
    test_case(paragraph, @core.Buffer::with_lines(["Hello, world!"]))
  }
  test_case(truncated_paragraph, @core.Buffer::with_lines(["Hello, wor"]))
  test_case(
    wrapped_paragraph,
    @core.Buffer::with_lines(["    Hello,", "    world!"]),
  )
  test_case(
    trimmed_paragraph,
    @core.Buffer::with_lines(["    Hello,", "    world!"]),
  )
}

///|
/// 上游 test_render_paragraph_with_scroll_offset：垂直/水平滚动喵。
test "Paragraph 滚动偏移" {
  let text = "This is a\ncool\nmultiline\nparagraph."
  let truncated_paragraph = Paragraph::of_str(text).scroll((2, 0))
  let wrapped_paragraph = truncated_paragraph.wrap(Wrap::of(false))
  let trimmed_paragraph = truncated_paragraph.wrap(Wrap::of(true))
  let paragraphs = [truncated_paragraph, wrapped_paragraph, trimmed_paragraph]
  for paragraph in paragraphs {
    test_case(
      paragraph,
      @core.Buffer::with_lines(["multiline   ", "paragraph.  ", "            "]),
    )
    test_case(paragraph, @core.Buffer::with_lines(["multiline   "]))
  }
  test_case(
    truncated_paragraph.scroll((2, 4)),
    @core.Buffer::with_lines(["iline   ", "graph.  "]),
  )
  test_case(
    wrapped_paragraph,
    @core.Buffer::with_lines(["cool   ", "multili", "ne     "]),
  )
}

///|
/// 上游 test_render_paragraph_with_zero_width_area / zero_height_area 喵。
test "Paragraph 零尺寸区域" {
  let text = "Hello, world!"
  let paragraphs = [
    Paragraph::of_str(text),
    Paragraph::of_str(text).wrap(Wrap::of(false)),
    Paragraph::of_str(text).wrap(Wrap::of(true)),
  ]
  for paragraph in paragraphs {
    let area = @core.Rect::new(0, 0, 0, 3)
    test_case(paragraph, @core.Buffer::empty(area))
    test_case(paragraph.scroll((2, 4)), @core.Buffer::empty(area))
    let area = @core.Rect::new(0, 0, 10, 0)
    test_case(paragraph, @core.Buffer::empty(area))
    test_case(paragraph.scroll((2, 4)), @core.Buffer::empty(area))
  }
}

///|
/// 上游 test_render_paragraph_with_styled_text：段落样式铺底 +
/// span 样式叠加喵。
test "Paragraph 文本样式" {
  fn make_text() -> @core.Text {
    @core.Text::of_line(
      @core.Line::of_spans([
        @core.Span::styled("Hello, ", @core.Style::new().fg(@core.Color::Red)),
        @core.Span::styled("world!", @core.Style::new().fg(@core.Color::Blue)),
      ]),
    )
  }
  let expected_buffer = @core.Buffer::with_lines(["Hello, world!"])
  expected_buffer.set_style(
    @core.Rect::new(0, 0, 7, 1),
    @core.Style::new().fg(@core.Color::Red).bg(@core.Color::Green),
  )
  expected_buffer.set_style(
    @core.Rect::new(7, 0, 6, 1),
    @core.Style::new().fg(@core.Color::Blue).bg(@core.Color::Green),
  )
  let paragraphs = [
    Paragraph::new(make_text()),
    Paragraph::new(make_text()).wrap(Wrap::of(false)),
    Paragraph::new(make_text()).wrap(Wrap::of(true)),
  ]
  for paragraph in paragraphs {
    test_case(
      paragraph.style(@core.Style::new().bg(@core.Color::Green)),
      expected_buffer,
    )
  }
}

///|
/// 上游 test_render_paragraph_with_special_characters 喵。
test "Paragraph 特殊字符" {
  let text = "Hello, <world>!"
  let paragraphs = [
    Paragraph::of_str(text),
    Paragraph::of_str(text).wrap(Wrap::of(false)),
    Paragraph::of_str(text).wrap(Wrap::of(true)),
  ]
  for paragraph in paragraphs {
    test_case(paragraph, @core.Buffer::with_lines(["Hello, <world>!"]))
    test_case(paragraph, @core.Buffer::with_lines(["Hello, <world>!     "]))
    test_case(
      paragraph,
      @core.Buffer::with_lines(["Hello, <world>!     ", "                    "]),
    )
    test_case(
      paragraph,
      @core.Buffer::with_lines(["Hello, <world>!", "               "]),
    )
  }
}

///|
/// 上游 test_render_paragraph_with_ascii_and_background：背景铺满区域喵。
test "Paragraph ASCII 背景铺满" {
  let text = "abc"
  let paragraph = Paragraph::of_str(text).style(
    @core.Style::new().bg(@core.Color::Green),
  )
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  paragraph.render(@core.Rect::new(0, 0, 10, 1), buffer)
  for x in 0..<10 {
    @debug.assert_eq(buffer.get(x, 0).bg, @core.Color::Green)
  }
}

///|
/// 上游 test_render_paragraph_with_fullwidth_and_background：全角字符
/// 双宽占位 + 背景铺满喵。
test "Paragraph 全角背景" {
  let text = "あいう"
  let paragraph = Paragraph::of_str(text).style(
    @core.Style::new().bg(@core.Color::Green),
  )
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  paragraph.render(@core.Rect::new(0, 0, 10, 1), buffer)
  @debug.assert_eq(buffer.get(0, 0).symbol(), "あ")
  inspect(buffer.get(0, 0).cell_width(), content="2")
  @debug.assert_eq(buffer.get(2, 0).symbol(), "い")
  inspect(buffer.get(2, 0).cell_width(), content="2")
  @debug.assert_eq(buffer.get(4, 0).symbol(), "う")
  inspect(buffer.get(4, 0).cell_width(), content="2")
  for x in 0..<10 {
    @debug.assert_eq(buffer.get(x, 0).bg, @core.Color::Green)
  }
}

///|
/// 上游 test_render_paragraph_with_unicode_characters：CJK/emoji 混排喵。
test "Paragraph Unicode 字符" {
  let text = "こんにちは, 世界! 😃"
  let truncated_paragraph = Paragraph::of_str(text)
  let wrapped_paragraph = Paragraph::of_str(text).wrap(Wrap::of(false))
  let trimmed_paragraph = Paragraph::of_str(text).wrap(Wrap::of(true))
  let paragraphs = [truncated_paragraph, wrapped_paragraph, trimmed_paragraph]
  for paragraph in paragraphs {
    test_case(
      paragraph,
      @core.Buffer::with_lines(["こんにちは, 世界! 😃"]),
    )
    test_case(
      paragraph,
      @core.Buffer::with_lines(["こんにちは, 世界! 😃     "]),
    )
  }
  test_case(
    truncated_paragraph,
    @core.Buffer::with_lines(["こんにちは, 世 "]),
  )
  test_case(
    wrapped_paragraph,
    @core.Buffer::with_lines(["こんにちは,    ", "世界! 😃      "]),
  )
  test_case(
    trimmed_paragraph,
    @core.Buffer::with_lines(["こんにちは,    ", "世界! 😃      "]),
  )
}

///|
/// 上游 widgets_paragraph_count_rendered_lines：折行行数统计喵。
test "Paragraph::line_count" {
  inspect(Paragraph::of_str("Hello World").line_count(20), content="1")
  inspect(Paragraph::of_str("Hello World").line_count(10), content="1")
  let paragraph = Paragraph::of_str("Hello World").wrap(Wrap::of(false))
  inspect(paragraph.line_count(20), content="1")
  inspect(paragraph.line_count(10), content="2")
  let paragraph = Paragraph::of_str("Hello World").wrap(Wrap::of(true))
  inspect(paragraph.line_count(20), content="1")
  inspect(paragraph.line_count(10), content="2")
  let text = "Hello World ".repeat(100).trim().to_owned()
  let paragraph = Paragraph::of_str(text)
  inspect(paragraph.line_count(11), content="1")
  inspect(paragraph.line_count(6), content="1")
  let paragraph = paragraph.wrap(Wrap::of(false))
  inspect(paragraph.line_count(11), content="100")
  inspect(paragraph.line_count(6), content="200")
  let paragraph = paragraph.wrap(Wrap::of(true))
  inspect(paragraph.line_count(11), content="100")
  inspect(paragraph.line_count(6), content="200")
}

///|
/// 上游 widgets_paragraph_rendered_line_count_accounts_block：块占行计入喵。
test "Paragraph::line_count 计入块" {
  let paragraph = Paragraph::of_str("Hello World").block(Block::new())
  inspect(paragraph.line_count(20), content="1")
  inspect(paragraph.line_count(10), content="1")
  let paragraph = paragraph.block(Block::new().borders(Borders::top()))
  inspect(paragraph.line_count(20), content="2")
  inspect(paragraph.line_count(10), content="2")
  let paragraph = paragraph.block(Block::new().borders(Borders::bottom()))
  inspect(paragraph.line_count(20), content="2")
  inspect(paragraph.line_count(10), content="2")
  let paragraph = paragraph.block(
    Block::new().borders(Borders::top().union(Borders::bottom())),
  )
  inspect(paragraph.line_count(20), content="3")
  inspect(paragraph.line_count(10), content="3")
  let paragraph = paragraph.block(Block::bordered())
  inspect(paragraph.line_count(20), content="3")
  inspect(paragraph.line_count(10), content="3")
  let paragraph = paragraph.block(Block::bordered()).wrap(Wrap::of(true))
  inspect(paragraph.line_count(20), content="3")
  inspect(paragraph.line_count(10), content="4")
  let paragraph = paragraph.block(Block::bordered()).wrap(Wrap::of(false))
  inspect(paragraph.line_count(20), content="3")
  inspect(paragraph.line_count(10), content="4")
}

///|
/// 上游 widgets_paragraph_line_width / line_width_accounts_for_block 喵。
test "Paragraph::line_width" {
  inspect(Paragraph::of_str("Hello World").line_width(), content="11")
  let paragraph = Paragraph::of_str("Hello World").block(Block::new())
  inspect(paragraph.line_width(), content="11")
  let paragraph = paragraph.block(Block::bordered())
  inspect(paragraph.line_width(), content="13")
  let paragraph = paragraph.block(
    Block::bordered().padding(Padding::uniform(2)),
  )
  inspect(paragraph.line_width(), content="17")
}

///|
/// 上游 left/centered/right_aligned 与文本对齐继承喵。
test "Paragraph 对齐" {
  @debug.assert_eq(
    Paragraph::of_str("Hello, world!").left_aligned().alignment,
    @core.Alignment::Left,
  )
  @debug.assert_eq(
    Paragraph::of_str("Hello, world!").centered().alignment,
    @core.Alignment::Center,
  )
  @debug.assert_eq(
    Paragraph::of_str("Hello, world!").right_aligned().alignment,
    @core.Alignment::Right,
  )
  // 上游 inherit_text_alignment_*：Paragraph::new 继承**文本级**对齐喵
  let text = @core.Text::raw("Hello, world!").left_aligned()
  @debug.assert_eq(Paragraph::new(text).alignment, @core.Alignment::Left)
  let text = @core.Text::raw("Hello, world!").centered()
  @debug.assert_eq(Paragraph::new(text).alignment, @core.Alignment::Center)
  let text = @core.Text::raw("Hello, world!").right_aligned()
  @debug.assert_eq(Paragraph::new(text).alignment, @core.Alignment::Right)
}

///|
/// 上游 paragraph_block_text_style：文本级样式经段落渲染生效喵。
test "Paragraph 块内文本样式" {
  let text = @core.Text::styled(
    "Styled text",
    @core.Style::new().fg(@core.Color::Green),
  )
  let paragraph = Paragraph::new(text).block(Block::bordered())
  let buf = @core.Buffer::empty(@core.Rect::new(0, 0, 20, 3))
  paragraph.render(@core.Rect::new(0, 0, 20, 3), buf)
  let expected = @core.Buffer::with_lines([
    "┌──────────────────┐", "│Styled text       │",
    "└──────────────────┘",
  ])
  expected.set_style(
    @core.Rect::new(1, 1, 11, 1),
    @core.Style::new().fg(@core.Color::Green),
  )
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 test_render_paragraph_out_of_bounds：完全出界零写入喵。
test "Paragraph 出界" {
  let areas = [
    @core.Rect::new(0, 5, 15, 1),
    @core.Rect::new(20, 0, 15, 1),
    @core.Rect::new(20, 5, 15, 1),
  ]
  for area in areas {
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 4))
    Paragraph::of_str("Hello, World!").render(area, buffer)
    @debug.assert_eq(buffer, @core.Buffer::empty(buffer.area))
  }
}

///|
/// 上游 partial_out_of_bounds：部分出界按交集渲染喵。
test "Paragraph 部分出界" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 15, 3))
  Paragraph::of_str("Hello World").render(@core.Rect::new(10, 0, 10, 3), buffer)
  @debug.assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "          Hello", "               ", "               ",
    ]),
  )
}

///|
/// 上游 render_in_minimal_buffer / render_in_zero_size_buffer 喵。
test "Paragraph 极小与零尺寸缓冲" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  Paragraph::of_str("I'm too big for this buffer").render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["I"]))
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  Paragraph::of_str("I'm too big for this buffer").render(buffer.area, buffer)
  inspect(buffer.cells.length(), content="0")
}
