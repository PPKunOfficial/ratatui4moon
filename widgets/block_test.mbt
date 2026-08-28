///|
/// Block 单元测试：复刻 ratatui-v0.30.2 `widgets/block.rs` 与
/// `block/padding.rs` 测试清单喵。
///
/// 登记"待复刻"：
/// - 虚线/象限边框集（`render_light_double_dashed` 等）与
///   `BorderType` 其余变体，随符号集扩充落位；
/// - `merge_borders`（边框合并策略）与 `shadow` 系列；
/// - Stylize 速记、`From<u16>` 转换糖；
/// - u16 溢出类回归用例（本移植坐标为 Int 域，无此溢出）。

///|
/// 上游 create_with_all_borders：bordered 即全边框喵。
test "Block::bordered 全边框" {
  @debug.assert_eq(Block::bordered().borders, Borders::all())
}

///|
/// 上游 inner_takes_into_account_the_borders（22 组参数化用例）喵。
test "Block::inner 计入边框" {
  let cases = [
    (Borders::empty(), @core.Rect::new(0, 0, 0, 0), @core.Rect::new(0, 0, 0, 0)),
    (Borders::empty(), @core.Rect::new(0, 0, 1, 1), @core.Rect::new(0, 0, 1, 1)),
    (Borders::left(), @core.Rect::new(0, 0, 0, 0), @core.Rect::new(0, 0, 0, 0)),
    (Borders::left(), @core.Rect::new(0, 0, 0, 1), @core.Rect::new(0, 0, 0, 1)),
    (Borders::left(), @core.Rect::new(0, 0, 1, 1), @core.Rect::new(1, 0, 0, 1)),
    (Borders::left(), @core.Rect::new(0, 0, 2, 1), @core.Rect::new(1, 0, 1, 1)),
    (Borders::top(), @core.Rect::new(0, 0, 1, 0), @core.Rect::new(0, 0, 1, 0)),
    (Borders::top(), @core.Rect::new(0, 0, 1, 1), @core.Rect::new(0, 1, 1, 0)),
    (Borders::top(), @core.Rect::new(0, 0, 1, 2), @core.Rect::new(0, 1, 1, 1)),
    (Borders::right(), @core.Rect::new(0, 0, 0, 0), @core.Rect::new(0, 0, 0, 0)),
    (Borders::right(), @core.Rect::new(0, 0, 0, 1), @core.Rect::new(0, 0, 0, 1)),
    (Borders::right(), @core.Rect::new(0, 0, 1, 1), @core.Rect::new(0, 0, 0, 1)),
    (Borders::right(), @core.Rect::new(0, 0, 2, 1), @core.Rect::new(0, 0, 1, 1)),
    (
      Borders::bottom(),
      @core.Rect::new(0, 0, 1, 0),
      @core.Rect::new(0, 0, 1, 0),
    ),
    (
      Borders::bottom(),
      @core.Rect::new(0, 0, 1, 1),
      @core.Rect::new(0, 0, 1, 0),
    ),
    (
      Borders::bottom(),
      @core.Rect::new(0, 0, 1, 2),
      @core.Rect::new(0, 0, 1, 1),
    ),
    (Borders::all(), @core.Rect::new(0, 0, 0, 0), @core.Rect::new(0, 0, 0, 0)),
    (Borders::all(), @core.Rect::new(0, 0, 1, 1), @core.Rect::new(1, 1, 0, 0)),
    (Borders::all(), @core.Rect::new(0, 0, 2, 2), @core.Rect::new(1, 1, 0, 0)),
    (Borders::all(), @core.Rect::new(0, 0, 3, 3), @core.Rect::new(1, 1, 1, 1)),
  ]
  for case in cases {
    let (borders, area, expected) = case
    @debug.assert_eq(Block::new().borders(borders).inner(area), expected)
  }
}

///|
/// 上游 inner_takes_into_account_the_title：标题行也吃掉一行内容区喵。
test "Block::inner 计入标题" {
  let alignments = [
    @core.Alignment::Left,
    @core.Alignment::Center,
    @core.Alignment::Right,
  ]
  for alignment in alignments {
    let block = Block::new().title(
      @core.Line::raw("Test").with_alignment(alignment),
    )
    @debug.assert_eq(
      block.inner(@core.Rect::new(0, 0, 0, 1)),
      @core.Rect::new(0, 1, 0, 0),
    )
  }
}

///|
/// 上游 inner_takes_into_account_border_and_title：边框与标题同计，
/// 上下边框可与对侧标题共存喵。
test "Block::inner 计入边框与标题" {
  let cases = [
    (
      Block::new().title_top_str("Test").borders(Borders::top()),
      @core.Rect::new(0, 1, 0, 1),
    ),
    (
      Block::new().title_top_str("Test").borders(Borders::bottom()),
      @core.Rect::new(0, 1, 0, 0),
    ),
    (
      Block::new().title_bottom_str("Test").borders(Borders::top()),
      @core.Rect::new(0, 1, 0, 0),
    ),
    (
      Block::new().title_bottom_str("Test").borders(Borders::bottom()),
      @core.Rect::new(0, 0, 0, 1),
    ),
  ]
  for case in cases {
    let (block, expected) = case
    @debug.assert_eq(block.inner(@core.Rect::new(0, 0, 0, 2)), expected)
  }
}

///|
/// 上游 vertical_space_takes_into_account_borders（8 组用例）喵。
test "vertical_space 计入边框" {
  let cases = [
    (Borders::empty(), (0, 0)),
    (Borders::top(), (1, 0)),
    (Borders::bottom(), (0, 1)),
    (Borders::left(), (0, 0)),
    (Borders::top().union(Borders::right()), (1, 0)),
    (Borders::top().union(Borders::bottom()), (1, 1)),
    (Borders::top().union(Borders::left()), (1, 0)),
    (Borders::bottom().union(Borders::right()), (0, 1)),
  ]
  for case in cases {
    let (borders, expected) = case
    @debug.assert_eq(Block::new().borders(borders).vertical_space(), expected)
  }
}

///|
/// 上游 vertical_space_takes_into_account_padding（7 组用例）喵。
test "vertical_space 计入 padding" {
  let cases = [
    (Borders::top(), Padding::new(0, 0, 1, 0), (2, 0)),
    (Borders::right(), Padding::new(0, 0, 1, 0), (1, 0)),
    (Borders::bottom(), Padding::new(0, 0, 1, 0), (1, 1)),
    (Borders::left(), Padding::new(0, 0, 1, 0), (1, 0)),
    (
      Borders::top().union(Borders::bottom()),
      Padding::new(100, 100, 4, 5),
      (5, 6),
    ),
    (Borders::empty(), Padding::new(100, 100, 10, 13), (10, 13)),
    (Borders::all(), Padding::new(100, 100, 1, 3), (2, 4)),
  ]
  for case in cases {
    let (borders, padding, expected) = case
    @debug.assert_eq(
      Block::new().borders(borders).padding(padding).vertical_space(),
      expected,
    )
  }
}

///|
/// 上游 vertical_space_takes_into_account_titles喵。
test "vertical_space 计入标题" {
  @debug.assert_eq(Block::new().title_top_str("Test").vertical_space(), (1, 0))
  @debug.assert_eq(
    Block::new().title_bottom_str("Test").vertical_space(),
    (0, 1),
  )
}

///|
/// 上游 vertical_space_takes_into_account_borders_and_title（8 组）喵。
test "vertical_space 计入边框与标题" {
  let cases = [
    (Borders::top(), TitlePosition::Top, (1, 0)),
    (Borders::right(), TitlePosition::Top, (1, 0)),
    (Borders::bottom(), TitlePosition::Top, (1, 1)),
    (Borders::left(), TitlePosition::Top, (1, 0)),
    (Borders::top(), TitlePosition::Bottom, (1, 1)),
    (Borders::right(), TitlePosition::Bottom, (0, 1)),
    (Borders::bottom(), TitlePosition::Bottom, (0, 1)),
    (Borders::left(), TitlePosition::Bottom, (0, 1)),
  ]
  for case in cases {
    let (borders, position, expected) = case
    @debug.assert_eq(
      Block::new()
      .borders(borders)
      .title_position(position)
      .title_str("Test")
      .vertical_space(),
      expected,
    )
  }
}

///|
/// 上游 horizontal_space_takes_into_account_borders喵。
test "horizontal_space 计入边框" {
  @debug.assert_eq(Block::bordered().horizontal_space(), (1, 1))
  @debug.assert_eq(
    Block::new().borders(Borders::left()).horizontal_space(),
    (1, 0),
  )
  @debug.assert_eq(
    Block::new().borders(Borders::right()).horizontal_space(),
    (0, 1),
  )
}

///|
/// 上游 horizontal_space_takes_into_account_padding喵。
test "horizontal_space 计入 padding" {
  @debug.assert_eq(
    Block::new().padding(Padding::new(1, 1, 100, 100)).horizontal_space(),
    (1, 1),
  )
  @debug.assert_eq(
    Block::new().padding(Padding::new(3, 5, 0, 0)).horizontal_space(),
    (3, 5),
  )
  @debug.assert_eq(
    Block::new().padding(Padding::new(0, 1, 100, 100)).horizontal_space(),
    (0, 1),
  )
  @debug.assert_eq(
    Block::new().padding(Padding::new(1, 0, 100, 100)).horizontal_space(),
    (1, 0),
  )
}

///|
/// 上游 horizontal_space_takes_into_account_borders_and_padding（8 组）喵。
test "horizontal_space 计入边框与 padding" {
  let cases = [
    (Block::bordered(), Padding::new(1, 1, 1, 1), (2, 2)),
    (Block::bordered(), Padding::new(1, 0, 0, 0), (2, 1)),
    (Block::bordered(), Padding::new(0, 1, 0, 0), (1, 2)),
    (Block::bordered(), Padding::new(0, 0, 1, 0), (1, 1)),
    (Block::bordered(), Padding::new(0, 0, 0, 1), (1, 1)),
    (Block::new().borders(Borders::left()), Padding::new(1, 0, 0, 0), (2, 0)),
    (Block::new().borders(Borders::left()), Padding::new(0, 1, 0, 0), (1, 1)),
    (Block::new().borders(Borders::right()), Padding::new(0, 1, 0, 0), (0, 2)),
    (Block::new().borders(Borders::right()), Padding::new(1, 0, 0, 0), (1, 1)),
  ]
  for case in cases {
    let (block, padding, expected) = case
    @debug.assert_eq(block.padding(padding).horizontal_space(), expected)
  }
}

///|
/// 上游 title_top_bottom：三对齐标题组按位置落位喵。
test "Block 标题上中下三对齐" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 11, 3))
  Block::bordered()
  .title_top(@core.Line::raw("A").left_aligned())
  .title_top(@core.Line::raw("B").centered())
  .title_top(@core.Line::raw("C").right_aligned())
  .title_bottom(@core.Line::raw("D").left_aligned())
  .title_bottom(@core.Line::raw("E").centered())
  .title_bottom(@core.Line::raw("F").right_aligned())
  .render(buffer.area, buffer)
  @debug.assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "┌A───B───C┐", "│         │", "└D───E───F┘",
    ]),
  )
}

///|
/// 上游 title_alignment：块级缺省对齐喵。
test "Block::title_alignment" {
  let cases = [
    (@core.Alignment::Left, "test    "),
    (@core.Alignment::Center, "  test  "),
    (@core.Alignment::Right, "    test"),
  ]
  for case in cases {
    let (alignment, expected) = case
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 8, 1))
    Block::new()
    .title_alignment(alignment)
    .title_str("test")
    .render(buffer.area, buffer)
    @debug.assert_eq(buffer, @core.Buffer::with_lines([expected]))
  }
}

///|
/// 上游 title_alignment_overrides_block_title_alignment：标题自带
/// 对齐覆盖块级缺省喵。
test "标题对齐覆盖块级对齐" {
  let cases = [
    (@core.Alignment::Right, @core.Alignment::Left, "test    "),
    (@core.Alignment::Left, @core.Alignment::Center, "  test  "),
    (@core.Alignment::Center, @core.Alignment::Right, "    test"),
  ]
  for case in cases {
    let (block_alignment, title_alignment, expected) = case
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 8, 1))
    Block::new()
    .title_alignment(block_alignment)
    .title(@core.Line::raw("test").with_alignment(title_alignment))
    .render(buffer.area, buffer)
    @debug.assert_eq(buffer, @core.Buffer::with_lines([expected]))
  }
}

///|
/// 上游 render_right_aligned_empty_title：空标题不炸不占位喵。
test "右对齐空标题" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 15, 3))
  Block::new()
  .title_alignment(@core.Alignment::Right)
  .title_str("")
  .render(buffer.area, buffer)
  @debug.assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "               ", "               ", "               ",
    ]),
  )
}

///|
/// 上游 title_position：缺省位置设为底部喵。
test "Block::title_position" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 4, 2))
  Block::new()
  .title_position(TitlePosition::Bottom)
  .title_str("test")
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["    ", "test"]))
}

///|
/// 上游 title_content_style：标题内容自带样式喵。
test "标题内容样式" {
  let alignments = [
    @core.Alignment::Left,
    @core.Alignment::Center,
    @core.Alignment::Right,
  ]
  let style = @core.Style::new().fg(@core.Color::Yellow)
  for alignment in alignments {
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 4, 1))
    Block::new()
    .title_alignment(alignment)
    .title(@core.Line::of_span(@core.Span::styled("test", style)))
    .render(buffer.area, buffer)
    @debug.assert_eq(
      buffer,
      @core.Buffer::with_lines_of([@core.Line::styled("test", style)]),
    )
  }
}

///|
/// 上游 block_title_style：块级标题样式喵。
test "块级标题样式" {
  let alignments = [
    @core.Alignment::Left,
    @core.Alignment::Center,
    @core.Alignment::Right,
  ]
  let style = @core.Style::new().fg(@core.Color::Yellow)
  for alignment in alignments {
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 4, 1))
    Block::new()
    .title_alignment(alignment)
    .title_style(style)
    .title_str("test")
    .render(buffer.area, buffer)
    @debug.assert_eq(
      buffer,
      @core.Buffer::with_lines_of([@core.Line::styled("test", style)]),
    )
  }
}

///|
/// 上游 title_style_overrides_block_title_style：标题内容样式覆盖
/// 块级标题样式的 fg，bg 叠加喵。
test "标题样式覆盖" {
  let alignments = [
    @core.Alignment::Left,
    @core.Alignment::Center,
    @core.Alignment::Right,
  ]
  let block_style = @core.Style::new()
    .fg(@core.Color::Green)
    .bg(@core.Color::Red)
  let title_style = @core.Style::new().fg(@core.Color::Yellow)
  for alignment in alignments {
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 4, 1))
    Block::new()
    .title_alignment(alignment)
    .title_style(block_style)
    .title(@core.Line::of_span(@core.Span::styled("test", title_style)))
    .render(buffer.area, buffer)
    @debug.assert_eq(
      buffer,
      @core.Buffer::with_lines_of([
        @core.Line::styled(
          "test",
          @core.Style::new().fg(@core.Color::Yellow).bg(@core.Color::Red),
        ),
      ]),
    )
  }
}

///|
/// 上游 title_border_style：边框染色铺满边框格，标题覆写其上喵。
test "标题与边框样式" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 3))
  Block::bordered()
  .title_str("test")
  .border_style(@core.Style::new().fg(@core.Color::Yellow))
  .render(buffer.area, buffer)
  let expected = @core.Buffer::with_lines([
    "┌test────┐", "│        │", "└────────┘",
  ])
  expected.set_style(
    @core.Rect::new(0, 0, 10, 3),
    @core.Style::new().fg(@core.Color::Yellow),
  )
  expected.set_style(@core.Rect::new(1, 1, 8, 1), @core.Style::reset())
  @debug.assert_eq(buffer, expected)
}

///|
/// 上游 render_plain_border：单线直角喵。
test "Block 单线边框" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 3))
  Block::bordered().border_type(BorderType::Plain).render(buffer.area, buffer)
  @debug.assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "┌────────┐", "│        │", "└────────┘",
    ]),
  )
}

///|
/// 上游 render_rounded_border：单线圆角喵。
test "Block 圆角边框" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 3))
  Block::bordered().border_type(BorderType::Rounded).render(buffer.area, buffer)
  @debug.assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "╭────────╮", "│        │", "╰────────╯",
    ]),
  )
}

///|
/// 上游 render_double_border：双线边框喵。
test "Block 双线边框" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 3))
  Block::bordered().border_type(BorderType::Double).render(buffer.area, buffer)
  @debug.assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "╔════════╗", "║        ║", "╚════════╝",
    ]),
  )
}

///|
/// THICK 符号集渲染路径（上游 border::THICK）喵。
test "Block 粗线边框" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 3))
  Block::bordered().border_type(BorderType::Thick).render(buffer.area, buffer)
  @debug.assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "┏━━━━━━━━┓", "┃        ┃", "┗━━━━━━━━┛",
    ]),
  )
}

///|
/// 上游 left_titles：左对齐标题依次左排喵。
test "左对齐标题" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Block::new().title_str("L12").title_str("L34").render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["L12 L34   "]))
}

///|
/// 上游 center_titles：居中标题成组居中喵。
test "居中标题" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Block::new()
  .title(@core.Line::raw("C12").centered())
  .title(@core.Line::raw("C34").centered())
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines([" C12 C34  "]))
}

///|
/// 上游 right_titles：右对齐标题成组右排喵。
test "右对齐标题" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Block::new()
  .title(@core.Line::raw("R12").right_aligned())
  .title(@core.Line::raw("R34").right_aligned())
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["   R12 R34"]))
}

///|
/// 上游 left_titles_truncated：左标题超宽截断、后标题仍落位喵。
test "左对齐标题截断" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Block::new()
  .title_str("L12345")
  .title_str("L67890")
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["L12345 L67"]))
}

///|
/// 上游 center_titles_truncated：居中标题超宽左右裁剪喵。
test "居中标题截断" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Block::new()
  .title(@core.Line::raw("C12345").centered())
  .title(@core.Line::raw("C67890").centered())
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["12345 C678"]))
}

///|
/// 上游 right_titles_truncated：右标题超宽左侧截断喵。
test "右对齐标题截断" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Block::new()
  .title(@core.Line::raw("R12345").right_aligned())
  .title(@core.Line::raw("R67890").right_aligned())
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["345 R67890"]))
}

///|
/// 上游 center_title_truncates_left_title：居中标题覆写左标题喵。
test "居中标题截断左标题" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Block::new()
  .title_str("L1234")
  .title(@core.Line::raw("C5678").centered())
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["L1C5678   "]))
}

///|
/// 上游 right_title_truncates_left_title：右标题覆写左标题喵。
test "右标题截断左标题" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Block::new()
  .title_str("L12345")
  .title(@core.Line::raw("R67890").right_aligned())
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["L123R67890"]))
}

///|
/// 上游 right_title_truncates_center_title：右标题覆写居中标题喵。
test "右标题截断居中标题" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 1))
  Block::new()
  .title(@core.Line::raw("C12345").centered())
  .title(@core.Line::raw("R67890").right_aligned())
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["  C1R67890"]))
}

///|
/// 上游 render_in_minimal_buffer：1×1 缓冲渲染不炸且画出左上角喵。
test "极小缓冲渲染" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  Block::bordered()
  .title_str("I'm too big for this buffer")
  .padding(Padding::uniform(10))
  .render(buffer.area, buffer)
  @debug.assert_eq(buffer, @core.Buffer::with_lines(["┌"]))
}

///|
/// 上游 render_in_zero_size_buffer：零尺寸缓冲渲染不炸喵。
test "零尺寸缓冲渲染" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  Block::bordered()
  .title_str("I'm too big for this buffer")
  .padding(Padding::uniform(10))
  .render(buffer.area, buffer)
  inspect(buffer.cells.length(), content="0")
}

///|
/// Block 绘制四角与边线（spike 保留用例，改用 bordered）喵。
test "Block 绘制四角与边线" {
  let buf = @core.Buffer::new(@core.Rect::new(0, 0, 4, 3))
  Block::bordered().render(@core.Rect::new(0, 0, 4, 3), buf)
  inspect(buf.get(0, 0).symbol(), content="┌")
  inspect(buf.get(3, 0).symbol(), content="┐")
  inspect(buf.get(0, 2).symbol(), content="└")
  inspect(buf.get(3, 2).symbol(), content="┘")
  inspect(buf.get(1, 0).symbol(), content="─")
  inspect(buf.get(2, 0).symbol(), content="─")
  inspect(buf.get(0, 1).symbol(), content="│")
  inspect(buf.get(3, 1).symbol(), content="│")
  // 内部不被 Block 碰
  inspect(buf.get(1, 1).symbol(), content=" ")
  inspect(buf.get(2, 1).symbol(), content=" ")
}

///|
/// Block 在非原点区域与偏移坐标对齐喵。
test "Block 在非原点区域与偏移坐标对齐" {
  let area = @core.Rect::new(10, 5, 5, 3)
  let buf = @core.Buffer::new(area)
  Block::bordered().render(area, buf)
  inspect(buf.get(10, 5).symbol(), content="┌")
  inspect(buf.get(14, 7).symbol(), content="┘")
  inspect(buf.get(12, 5).symbol(), content="─")
  inspect(buf.get(14, 6).symbol(), content="│")
}

///|
/// Block 样式作用于边框：基样式铺满区域，边框格承样式喵。
test "Block 样式作用于边框" {
  let buf = @core.Buffer::new(@core.Rect::new(0, 0, 3, 2))
  let block = Block::new()
    .style(
      @core.Style::new()
      .fg(@core.Color::Red)
      .add_modifier(@core.Modifier::bold()),
    )
    .borders(Borders::all())
  block.render(@core.Rect::new(0, 0, 3, 2), buf)
  inspect(
    buf.get(0, 0).style().has_modifier(@core.Modifier::bold()),
    content="true",
  )
  @debug.assert_eq(buf.get(0, 0).style().fg, Some(@core.Color::Red))
  @debug.assert_eq(buf.get(2, 1).style().fg, Some(@core.Color::Red))
}
