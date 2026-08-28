///|
/// Line 单元测试：复刻 ratatui-v0.30.2 `text/line.rs` 测试清单喵。
///
/// 登记"待复刻"：
/// - `add_line`（`Line + Line` → `Text`）、`Text` 容器及其测试随
///   Paragraph 前置的 text/text.rs 复刻落位；
/// - `render_truncates_flag`（🇺🇸 国旗 regional indicator）与
///   ZWJ 图形簇用例依赖真实图形簇细分，随 `unicode/` 全量表补齐；
/// - 超过 `u16::MAX` 行宽的溢出用例：本移植坐标为 Int 域，无此溢出。
/// - From/Into/Collect 构造糖与 Stylize 速记为 Rust 语法层，不复刻。

///|
/// 上游 raw_str：无样式构造喵。
test "Line::raw 构造" {
  let line = Line::raw("Hello, world!")
  @debug.assert_eq(line.spans, [Span::raw("Hello, world!")])
  inspect(line.style.is_default(), content="true")
}

///|
/// 上游 styled_str：行级样式构造喵。
test "Line::styled 构造" {
  let style = Style::new().fg(Yellow)
  let line = Line::styled("Hello, world!", style)
  @debug.assert_eq(line.spans, [Span::raw("Hello, world!")])
  @debug.assert_eq(line.style, style)
}

///|
/// 上游 spans_vec：span 序列构造喵。
test "Line::of_spans" {
  let line = Line::of_spans([
    Span::styled("Hello", Style::new().fg(Blue)),
    Span::styled(" world!", Style::new().fg(Green)),
  ])
  @debug.assert_eq(line.spans, [
    Span::styled("Hello", Style::new().fg(Blue)),
    Span::styled(" world!", Style::new().fg(Green)),
  ])
}

///|
/// 上游 style：换行级样式 builder 喵。
test "Line::with_style" {
  let line = Line::empty().with_style(Style::new().fg(Red))
  @debug.assert_eq(line.style, Style::new().fg(Red))
}

///|
/// 上游 alignment：对齐缺省为 None，设置后生效喵。
test "Line::with_alignment" {
  let line = Line::raw("This is left").with_alignment(Left)
  @debug.assert_eq(line.alignment, Some(Left))
  let line = Line::raw("This is default")
  inspect(line.alignment is None, content="true")
}

///|
/// 上游 width：span 宽度求和，空行为 0 喵。
test "Line::width" {
  let line = Line::of_spans([
    Span::styled("My", Style::new().fg(Yellow)),
    Span::raw(" text"),
  ])
  inspect(line.width(), content="7")
  inspect(Line::empty().width(), content="0")
}

///|
/// 上游 patch_style：行级样式叠加喵。
test "Line::patch_style" {
  let raw_line = Line::styled("foobar", Style::new().fg(Yellow))
  let styled_line = Line::styled(
    "foobar",
    Style::new().fg(Yellow).add_modifier(Modifier::italic()),
  )
  inspect(raw_line == styled_line, content="false")
  @debug.assert_eq(
    raw_line.patch_style(Style::new().add_modifier(Modifier::italic())),
    styled_line,
  )
}

///|
/// 上游 reset_style：行级样式复位喵。
test "Line::reset_style" {
  let line = Line::styled(
    "foobar",
    Style::new().fg(Yellow).bg(Red).add_modifier(Modifier::italic()),
  ).reset_style()
  @debug.assert_eq(line.style, Style::reset())
}

///|
/// 上游 from_vec：span 序列原样落位喵。
test "Line::of_spans 原样" {
  let spans = [
    Span::styled("Hello,", Style::new().fg(Red)),
    Span::styled(" world!", Style::new().fg(Green)),
  ]
  let line = Line::of_spans(spans)
  @debug.assert_eq(line.spans, spans)
}

///|
/// 上游 from_span：单 span 转行喵。
test "Line::of_span" {
  let span = Span::styled("Hello, world!", Style::new().fg(Yellow))
  let line = Line::of_span(span)
  @debug.assert_eq(line.spans, [span])
}

///|
/// 上游 add_span：`line + span` 追加且样式承自左行喵。
test "Line 加 Span" {
  let line = Line::raw("Red")
    .with_style(Style::new().fg(Red))
    .op_add(Span::styled("blue", Style::new().fg(Blue)))
  @debug.assert_eq(line, {
    spans: [Span::raw("Red"), Span::styled("blue", Style::new().fg(Blue))],
    style: Style::new().fg(Red),
    alignment: None,
  })
}

///|
/// 上游 push_span / extend：原地追加喵。
test "Line::push_span 与 push_spans" {
  let line = Line::raw("A")
  line.push_span(Span::raw("B"))
  line.push_span(Span::raw("C"))
  @debug.assert_eq(line.spans, [Span::raw("A"), Span::raw("B"), Span::raw("C")])
  let line = Line::raw("Hello, ")
  line.push_spans([Span::raw("world! "), Span::raw("How are you?")])
  @debug.assert_eq(line.spans, [
    Span::raw("Hello, "),
    Span::raw("world! "),
    Span::raw("How are you?"),
  ])
}

///|
/// 上游 into_string / display_line_from_vec：内容拼接喵。
test "Line::to_display" {
  let line = Line::of_spans([
    Span::styled("Hello,", Style::new().fg(Red)),
    Span::styled(" world!", Style::new().fg(Green)),
  ])
  inspect(line.to_display(), content="Hello, world!")
  inspect(
    Line::styled("Hello, world!", Style::new().fg(Green)).to_display(),
    content="Hello, world!",
  )
}

///|
/// 上游 styled_graphemes：base → 行样式 → span 样式三层叠加喵。
test "Line::styled_graphemes" {
  let red = Style::new().fg(Red)
  let green = Style::new().fg(Green)
  let blue = Style::new().fg(Blue)
  let line = Line::of_spans([
    Span::styled("He", red),
    Span::styled("ll", green),
    Span::styled("o!", blue),
  ])
  let graphemes = line.styled_graphemes(Style::new().bg(White))
  let expected = [
    ("H", Style::new().fg(Red).bg(White)),
    ("e", Style::new().fg(Red).bg(White)),
    ("l", Style::new().fg(Green).bg(White)),
    ("l", Style::new().fg(Green).bg(White)),
    ("o", Style::new().fg(Blue).bg(White)),
    ("!", Style::new().fg(Blue).bg(White)),
  ]
  inspect(graphemes.length(), content="6")
  for k, item in expected {
    let (symbol, style) = item
    @debug.assert_eq(graphemes[k].symbol, symbol)
    @debug.assert_eq(graphemes[k].style, style)
  }
}

///|
/// 上游 left/centered/right_aligned喵。
test "Line 对齐速记" {
  @debug.assert_eq(
    Line::raw("Hello, world!").left_aligned().alignment,
    Some(Left),
  )
  @debug.assert_eq(
    Line::raw("Hello, world!").centered().alignment,
    Some(Center),
  )
  @debug.assert_eq(
    Line::raw("Hello, world!").right_aligned().alignment,
    Some(Right),
  )
}

///|
/// 上游 render：行样式铺满区域 + span 样式逐段叠加喵。
test "Line::render 基础" {
  let blue = Style::new().fg(Blue)
  let green = Style::new().fg(Green)
  let italic = Style::new().add_modifier(Modifier::italic())
  let line = Line::of_spans([
    Span::styled("Hello ", blue),
    Span::styled("world!", green),
  ]).with_style(italic)
  let buf = Buffer::empty(Rect::new(0, 0, 15, 1))
  line.render(Rect::new(0, 0, 15, 1), buf)
  let expected = Buffer::with_lines(["Hello world!   "])
  expected.set_style(Rect::new(0, 0, 15, 1), italic)
  expected.set_style(Rect::new(0, 0, 6, 1), blue)
  expected.set_style(Rect::new(6, 0, 6, 1), green)
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 render_out_of_bounds：完全出界零写入喵。
test "Line::render 越界" {
  let buf = Buffer::empty(Rect::new(0, 0, 10, 1))
  let line = Line::of_spans([
    Span::styled("Hello ", Style::new().fg(Blue)),
    Span::styled("world!", Style::new().fg(Green)),
  ]).with_style(Style::new().add_modifier(Modifier::italic()))
  line.render(Rect::new(20, 20, 10, 1), buf)
  @debug.assert_eq(buf, Buffer::empty(buf.area))
}

///|
/// 上游 render_only_styles_line_area：行样式只铺到区域宽度喵。
test "Line::render 样式范围" {
  let blue = Style::new().fg(Blue)
  let green = Style::new().fg(Green)
  let italic = Style::new().add_modifier(Modifier::italic())
  let line = Line::of_spans([
    Span::styled("Hello ", blue),
    Span::styled("world!", green),
  ]).with_style(italic)
  let buf = Buffer::empty(Rect::new(0, 0, 20, 1))
  line.render(Rect::new(0, 0, 15, 1), buf)
  let expected = Buffer::with_lines(["Hello world!        "])
  expected.set_style(Rect::new(0, 0, 15, 1), italic)
  expected.set_style(Rect::new(0, 0, 6, 1), blue)
  expected.set_style(Rect::new(6, 0, 6, 1), green)
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 render_only_styles_first_line：只渲染区域首行喵。
test "Line::render 只染首行" {
  let blue = Style::new().fg(Blue)
  let green = Style::new().fg(Green)
  let italic = Style::new().add_modifier(Modifier::italic())
  let line = Line::of_spans([
    Span::styled("Hello ", blue),
    Span::styled("world!", green),
  ]).with_style(italic)
  let buf = Buffer::empty(Rect::new(0, 0, 20, 2))
  line.render(buf.area, buf)
  let expected = Buffer::with_lines([
    "Hello world!        ", "                    ",
  ])
  expected.set_style(Rect::new(0, 0, 20, 1), italic)
  expected.set_style(Rect::new(0, 0, 6, 1), blue)
  expected.set_style(Rect::new(6, 0, 6, 1), green)
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 render_truncates：超区域右截断喵。
test "Line::render 截断" {
  let buf = Buffer::empty(Rect::new(0, 0, 10, 1))
  Line::raw("Hello world!").render(Rect::new(0, 0, 5, 1), buf)
  @debug.assert_eq(buf, Buffer::with_lines(["Hello     "]))
}

///|
/// 上游 render_centered：完整行居中喵。
test "Line::render 居中" {
  let blue = Style::new().fg(Blue)
  let green = Style::new().fg(Green)
  let italic = Style::new().add_modifier(Modifier::italic())
  let line = Line::of_spans([
      Span::styled("Hello ", blue),
      Span::styled("world!", green),
    ])
    .with_style(italic)
    .centered()
  let buf = Buffer::empty(Rect::new(0, 0, 15, 1))
  line.render(Rect::new(0, 0, 15, 1), buf)
  let expected = Buffer::with_lines([" Hello world!  "])
  expected.set_style(Rect::new(0, 0, 15, 1), italic)
  expected.set_style(Rect::new(1, 0, 6, 1), blue)
  expected.set_style(Rect::new(7, 0, 6, 1), green)
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 render_right_aligned：完整行右对齐喵。
test "Line::render 右对齐" {
  let blue = Style::new().fg(Blue)
  let green = Style::new().fg(Green)
  let italic = Style::new().add_modifier(Modifier::italic())
  let line = Line::of_spans([
      Span::styled("Hello ", blue),
      Span::styled("world!", green),
    ])
    .with_style(italic)
    .right_aligned()
  let buf = Buffer::empty(Rect::new(0, 0, 15, 1))
  line.render(Rect::new(0, 0, 15, 1), buf)
  let expected = Buffer::with_lines(["   Hello world!"])
  expected.set_style(Rect::new(0, 0, 15, 1), italic)
  expected.set_style(Rect::new(3, 0, 6, 1), blue)
  expected.set_style(Rect::new(9, 0, 6, 1), green)
  @debug.assert_eq(buf, expected)
}

///|
/// 上游 render_truncates_left/right/center：放不下时按对齐裁左喵。
test "Line::render 对齐裁左" {
  let buf = Buffer::empty(Rect::new(0, 0, 5, 1))
  Line::raw("Hello world").left_aligned().render(buf.area, buf)
  @debug.assert_eq(buf, Buffer::with_lines(["Hello"]))
  let buf = Buffer::empty(Rect::new(0, 0, 5, 1))
  Line::raw("Hello world").right_aligned().render(buf.area, buf)
  @debug.assert_eq(buf, Buffer::with_lines(["world"]))
  let buf = Buffer::empty(Rect::new(0, 0, 5, 1))
  Line::raw("Hello world").centered().render(buf.area, buf)
  @debug.assert_eq(buf, Buffer::with_lines(["lo wo"]))
}

///|
/// 上游 regression_1032：多字节行的截断不炸且按宽度取舍喵。
test "Line::render 多字节截断回归" {
  let line = Line::raw(
    "🦀 RFC8628 OAuth 2.0 Device Authorization GrantでCLIからGithubのaccess tokenを取得する",
  )
  let buf = Buffer::empty(Rect::new(0, 0, 83, 1))
  line.render(buf.area, buf)
  @debug.assert_eq(
    buf,
    Buffer::with_lines([
      "🦀 RFC8628 OAuth 2.0 Device Authorization GrantでCLIからGithubのaccess tokenを取得 ",
    ]),
  )
}

///|
/// 上游 crab_emoji_width：螃蟹 emoji 单字形宽 2 喵。
test "🦀 宽度语义" {
  let crab = "🦀"
  let mut chars = 0
  for _ in crab {
    chars += 1
  }
  inspect(chars, content="1")
  inspect(symbol_width(crab), content="2")
}

///|
/// 上游 render_truncates_emoji：左右对齐下的 emoji 整字形取舍喵。
test "Line::render emoji 截断（左右对齐）" {
  let cases = [
    (Alignment::Left, 4, "1234"),
    (Alignment::Left, 5, "1234 "),
    (Alignment::Left, 6, "1234🦀"),
    (Alignment::Left, 7, "1234🦀7"),
    (Alignment::Right, 4, "7890"),
    (Alignment::Right, 5, " 7890"),
    (Alignment::Right, 6, "🦀7890"),
    (Alignment::Right, 7, "4🦀7890"),
  ]
  for case in cases {
    let (alignment, buf_width, expected) = case
    let line = Line::raw("1234🦀7890").with_alignment(alignment)
    let buf = Buffer::empty(Rect::new(0, 0, buf_width, 1))
    line.render(buf.area, buf)
    @debug.assert_eq(buf, Buffer::with_lines([expected]))
  }
}

///|
/// 上游 render_truncates_emoji_center：居中裁剪与 emoji 左右半的
/// 交互（奇偶宽度全枚举）喵。
test "Line::render emoji 截断（居中）" {
  let cases = [
    (6, 0, ""),
    (6, 1, " "),
    (6, 2, "🦀"),
    (6, 3, "b🦀"),
    (6, 4, "b🦀c"),
    (7, 0, ""),
    (7, 1, " "),
    (7, 2, "🦀"),
    (7, 3, "🦀c"),
    (7, 4, "b🦀c"),
    (8, 0, ""),
    (8, 1, " "),
    (8, 2, " c"),
    (8, 3, "🦀c"),
    (8, 4, "🦀cd"),
    (8, 5, "b🦀cd"),
    (9, 0, ""),
    (9, 1, "c"),
    (9, 2, " c"),
    (9, 3, " cd"),
    (9, 4, "🦀cd"),
    (9, 5, "🦀cde"),
    (9, 6, "b🦀cde"),
  ]
  for case in cases {
    let (line_width, buf_width, expected) = case
    let value = match line_width {
      6 => "ab🦀cd"
      7 => "ab🦀cde"
      8 => "ab🦀cdef"
      _ => "ab🦀cdefg"
    }
    let line = Line::raw(value).centered()
    let buf = Buffer::empty(Rect::new(0, 0, buf_width, 1))
    line.render(buf.area, buf)
    @debug.assert_eq(buf, Buffer::with_lines([expected]))
  }
}

///|
/// 上游 render_truncates_away_from_0x0：非原点区域渲染且截断
/// 不覆写缓冲既有内容喵。
test "Line::render 非原点截断" {
  let cases = [
    (Alignment::Left, "XXa🦀bcXXX"),
    (Alignment::Center, "XX🦀bc🦀XX"),
    (Alignment::Right, "XXXbc🦀dXX"),
  ]
  for case in cases {
    let (alignment, expected) = case
    let line = Line::of_spans([Span::raw("a🦀b"), Span::raw("c🦀d")]).with_alignment(
      alignment,
    )
    let buf = Buffer::filled(Rect::new(0, 0, 10, 1), Cell::of("X"))
    line.render(Rect::new(2, 0, 6, 1), buf)
    @debug.assert_eq(buf, Buffer::with_lines([expected]))
  }
}

///|
/// 上游 render_right_aligned_multi_span：右对齐多 span 时首段
/// 按跳过宽度补白喵。
test "Line::render 右对齐多 span" {
  let cases = [
    (4, "c🦀d"),
    (5, "bc🦀d"),
    (6, "Xbc🦀d"),
    (7, "🦀bc🦀d"),
    (8, "a🦀bc🦀d"),
  ]
  for case in cases {
    let (buf_width, expected) = case
    let line = Line::of_spans([Span::raw("a🦀b"), Span::raw("c🦀d")]).right_aligned()
    let area = Rect::new(0, 0, buf_width, 1)
    let buf = Buffer::filled(area, Cell::of("X"))
    line.render(buf.area, buf)
    @debug.assert_eq(buf, Buffer::with_lines([expected]))
  }
}
