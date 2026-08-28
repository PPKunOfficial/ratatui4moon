///|
/// Span 单元测试：复刻 ratatui-v0.30.2 `text/span.rs` 测试清单喵。
///
/// 登记"待复刻"：`Into<Span>`/`to_span` 数字糖、Stylize 速记
/// （`.green()` 等）与 `FromStr` 类转换构造随对应 API 落位补齐。

///|
/// 上游 default：空内容 + 空样式喵。
test "Span::empty 默认" {
  let span = Span::empty()
  inspect(span.content, content="")
  inspect(span.style.is_default(), content="true")
}

///|
/// 上游 raw_str：无样式构造喵。
test "Span::raw" {
  let span = Span::raw("test content")
  inspect(span.content, content="test content")
  inspect(span.style.is_default(), content="true")
}

///|
/// 上游 styled_str：带样式构造喵。
test "Span::styled" {
  let style = Style::new().fg(Red)
  let span = Span::styled("test content", style)
  inspect(span.content, content="test content")
  @debug.assert_eq(span.style, Style::new().fg(Red))
}

///|
/// 上游 set_content：换内容 builder 喵。
test "Span::with_content" {
  let span = Span::empty().with_content("test content")
  inspect(span.content, content="test content")
}

///|
/// 上游 set_style：换样式 builder 喵。
test "Span::with_style" {
  let span = Span::empty().with_style(Style::new().fg(Green))
  @debug.assert_eq(span.style, Style::new().fg(Green))
}

///|
/// 上游 reset_style：样式复位喵。
test "Span::reset_style" {
  let span = Span::styled("test content", Style::new().fg(Green)).reset_style()
  @debug.assert_eq(span.style, Style::reset())
}

///|
/// 上游 patch_style：样式叠加喵。
test "Span::patch_style" {
  let span = Span::styled("test content", Style::new().fg(Green).bg(Yellow)).patch_style(
    Style::new().fg(Red).add_modifier(Modifier::bold()),
  )
  @debug.assert_eq(
    span.style,
    Style::new().fg(Red).bg(Yellow).add_modifier(Modifier::bold()),
  )
}

///|
/// 上游 width：宽度含换行（换行宽 0）喵。
test "Span::width" {
  inspect(Span::raw("").width(), content="0")
  inspect(Span::raw("test").width(), content="4")
  inspect(Span::raw("test content").width(), content="12")
  // 上游注明"待重新审视"的语义：换行不占宽喵
  inspect(Span::raw("test\ncontent").width(), content="12")
}

///|
/// 上游 display_span / display_newline_span / display_styled_span：
/// Display 拼接、换行剔除与精度截断喵。
test "Span::to_display" {
  inspect(Span::raw("test content").to_display(), content="test content")
  inspect(Span::raw("test content").to_display(limit=4), content="test")
  inspect(Span::raw("test\ncontent").to_display(), content="testcontent")
  inspect(
    Span::styled("stylized test content", Style::new().fg(Green)).to_display(),
    content="stylized test content",
  )
  inspect(
    Span::styled("stylized test content", Style::new().fg(Green)).to_display(
      limit=8,
    ),
    content="stylized",
  )
}

///|
/// 上游 left/centered/right_aligned：span 转行并带对齐喵。
test "Span::to_line 对齐" {
  let span = Span::styled("Test Content", Style::new().fg(Green))
  @debug.assert_eq(span.to_line().left_aligned().alignment, Some(Left))
  @debug.assert_eq(span.to_line().centered().alignment, Some(Center))
  @debug.assert_eq(span.to_line().right_aligned().alignment, Some(Right))
}

///|
/// 上游 render：样式逐格施加，尾部保持空白喵。
test "Span::render 基础" {
  let style = Style::new().fg(Green).bg(Yellow)
  let span = Span::styled("test content", style)
  let buf = Buffer::empty(Rect::new(0, 0, 15, 1))
  span.render(buf.area, buf)
  @debug.assert_eq(
    buf,
    Buffer::with_lines_of([
      Line::of_spans([Span::styled("test content", style), Span::raw("   ")]),
    ]),
  )
}

///|
/// 上游 render_out_of_bounds：区域完全出界零写入喵。
test "Span::render 越界" {
  let cases = [(20, 0), (0, 20), (20, 20)]
  for case in cases {
    let (x, y) = case
    let buf = Buffer::empty(Rect::new(0, 0, 10, 1))
    Span::raw("Hello, World!").render(Rect::new(x, y, 10, 1), buf)
    @debug.assert_eq(buf, Buffer::empty(buf.area))
  }
}

///|
/// 上游 render_truncates_too_long_content：内容超区域截断喵。
test "Span::render 截断" {
  let style = Style::new().fg(Green).bg(Yellow)
  let span = Span::styled("test content", style)
  let buf = Buffer::empty(Rect::new(0, 0, 10, 1))
  span.render(Rect::new(0, 0, 5, 1), buf)
  @debug.assert_eq(
    buf,
    Buffer::with_lines_of([
      Line::of_spans([Span::styled("test ", style), Span::raw("     ")]),
    ]),
  )
}

///|
/// 上游 render_patches_existing_style：既有单元格样式被 patch 喵。
test "Span::render 叠加既有样式" {
  let style = Style::new().fg(Green).bg(Yellow)
  let span = Span::styled("test content", style)
  let buf = Buffer::empty(Rect::new(0, 0, 15, 1))
  buf.set_style(buf.area, Style::new().add_modifier(Modifier::italic()))
  span.render(buf.area, buf)
  @debug.assert_eq(
    buf,
    Buffer::with_lines_of([
      Line::of_spans([
        Span::styled(
          "test content",
          Style::new().fg(Green).bg(Yellow).add_modifier(Modifier::italic()),
        ),
        Span::styled("   ", Style::new().add_modifier(Modifier::italic())),
      ]),
    ]),
  )
}

///|
/// 上游 render_multi_width_symbol：多宽字形隐藏尾列复位喵。
test "Span::render 多宽字形" {
  let style = Style::new().fg(Green).bg(Yellow)
  let span = Span::styled("test 😃 content", style)
  let buf = Buffer::empty(Rect::new(0, 0, 15, 1))
  span.render(buf.area, buf)
  @debug.assert_eq(
    buf,
    Buffer::with_lines_of([Line::styled("test 😃 content", style)]),
  )
}

///|
/// 上游 render_multi_width_symbol_truncates_entire_symbol：
/// 多宽字形放不下时整只截断喵。
test "Span::render 多宽字形整只截断" {
  let style = Style::new().fg(Green).bg(Yellow)
  let span = Span::styled("test 😃 content", style)
  let buf = Buffer::empty(Rect::new(0, 0, 6, 1))
  span.render(buf.area, buf)
  @debug.assert_eq(
    buf,
    Buffer::with_lines_of([
      Line::of_spans([Span::styled("test ", style), Span::raw(" ")]),
    ]),
  )
}

///|
/// 上游 render_overflowing_area_truncates：区域超缓冲按交集截断喵。
test "Span::render 区域溢出" {
  let style = Style::new().fg(Green).bg(Yellow)
  let span = Span::styled("test content", style)
  let buf = Buffer::empty(Rect::new(0, 0, 15, 1))
  span.render(Rect::new(10, 0, 20, 1), buf)
  @debug.assert_eq(
    buf,
    Buffer::with_lines_of([
      Line::of_spans([Span::raw("          "), Span::styled("test ", style)]),
    ]),
  )
}

///|
/// 上游 render_first_zero_width：前导零宽字形并入首格喵。
test "Span::render 前导零宽" {
  let span = Span::raw("\u{200B}abc")
  let buf = Buffer::empty(Rect::new(0, 0, 3, 1))
  span.render(buf.area, buf)
  @debug.assert_eq(buf.cells, [
    Cell::of("\u{200B}a"),
    Cell::of("b"),
    Cell::of("c"),
  ])
}

///|
/// 上游 render_second_zero_width：第二字形为零宽时并入首格喵。
test "Span::render 次字形零宽" {
  let span = Span::raw("a\u{200B}bc")
  let buf = Buffer::empty(Rect::new(0, 0, 3, 1))
  span.render(buf.area, buf)
  @debug.assert_eq(buf.cells, [
    Cell::of("a\u{200B}"),
    Cell::of("b"),
    Cell::of("c"),
  ])
}

///|
/// 上游 render_middle_zero_width：中部零宽字形并入前格喵。
test "Span::render 中部零宽" {
  let span = Span::raw("ab\u{200B}c")
  let buf = Buffer::empty(Rect::new(0, 0, 3, 1))
  span.render(buf.area, buf)
  @debug.assert_eq(buf.cells, [
    Cell::of("a"),
    Cell::of("b\u{200B}"),
    Cell::of("c"),
  ])
}

///|
/// 上游 render_last_zero_width：尾随零宽字形并入末格喵。
test "Span::render 尾随零宽" {
  let span = Span::raw("abc\u{200B}")
  let buf = Buffer::empty(Rect::new(0, 0, 3, 1))
  span.render(buf.area, buf)
  @debug.assert_eq(buf.cells, [
    Cell::of("a"),
    Cell::of("b"),
    Cell::of("c\u{200B}"),
  ])
}
