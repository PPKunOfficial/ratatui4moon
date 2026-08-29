///|
/// Sparkline 单元测试：复刻 ratatui-v0.30.2 `widgets/sparkline.rs`
/// 内联测试清单喵。
///
/// 不可移植用例登记：
/// - `it_can_be_created_from_{vec,array,slice}_of_{u64,option_u64}`
///   六条：Rust 的 Vec/Array/Slice 三容器形态在 MoonBit 统一为
///   `Array`，合并为 data/data_of_option 两条创建用例喵。

///|
/// 上游 render 辅助：以 'x' 填满 1 行宽 `width` 缓冲后渲染喵。
fn sparkline_render(widget : Sparkline, width : Int) -> @core.Buffer {
  let area = @core.Rect::new(0, 0, width, 1)
  let buffer = @core.Buffer::filled(area, @core.Cell::of("x"))
  widget.render(area, buffer)
  buffer
}

///|
/// 上游 render_direction_to_string 喵。
test "RenderDirection 显示名" {
  inspect(RenderDirection::LeftToRight.to_display(), content="LeftToRight")
  inspect(RenderDirection::RightToLeft.to_display(), content="RightToLeft")
}

///|
/// 上游 render_direction_from_str：未知名回退 None 喵。
test "RenderDirection 解析" {
  @debug.debug_inspect(
    RenderDirection::from_str("LeftToRight"),
    content="Some(LeftToRight)",
  )
  @debug.debug_inspect(
    RenderDirection::from_str("RightToLeft"),
    content="Some(RightToLeft)",
  )
  @debug.debug_inspect(RenderDirection::from_str(""), content="None")
}

///|
/// 上游 it_can_be_created_from_vec_of_u64 / _option_u64（三容器形态
/// 合并）：u64 与 Option<u64> 数据集构造喵。
test "Sparkline 数据集构造" {
  let from_u64 = Sparkline::default().data([1UL, 2UL, 3UL]).data
  let expected_u64 = [
    SparklineBar::of(1UL),
    SparklineBar::of(2UL),
    SparklineBar::of(3UL),
  ]
  assert_eq(from_u64, expected_u64)
  let from_option = Sparkline::default().data_of_option([
      Some(1UL),
      None,
      Some(3UL),
    ]).data
  let expected_option = [
    SparklineBar::of(1UL),
    SparklineBar::of_opt(None),
    SparklineBar::of(3UL),
  ]
  assert_eq(from_option, expected_option)
}

///|
/// 上游 it_does_not_panic_if_max_is_zero：全零数据集缺省上限为 0，
/// 缩放回退空档符号，不 panic 喵。
test "Sparkline 全零数据集" {
  let widget = Sparkline::default().data([0UL, 0UL, 0UL])
  let buffer = sparkline_render(widget, 6)
  assert_eq(buffer, @core.Buffer::with_lines(["   xxx"]))
}

///|
/// 上游 it_does_not_panic_if_max_is_set_to_zero：显式 max(0) 同样
/// 回退空档符号，不 panic 喵。
test "Sparkline 显式 max 为零" {
  let widget = Sparkline::default().data([0UL, 1UL, 2UL]).max(0UL)
  let buffer = sparkline_render(widget, 6)
  assert_eq(buffer, @core.Buffer::with_lines(["   xxx"]))
}

///|
/// 上游 it_draws：单行九级波形喵。
test "Sparkline 单行波形" {
  let widget = Sparkline::default().data([
    0UL, 1UL, 2UL, 3UL, 4UL, 5UL, 6UL, 7UL, 8UL,
  ])
  let buffer = sparkline_render(widget, 12)
  assert_eq(buffer, @core.Buffer::with_lines([" ▁▂▃▄▅▆▇█xxx"]))
}

///|
/// 上游 it_draws_double_height：两行波形自底向上分配 tick 喵。
test "Sparkline 双行波形" {
  let widget = Sparkline::default().data([
    0UL, 1UL, 2UL, 3UL, 4UL, 5UL, 6UL, 7UL, 8UL,
  ])
  let area = @core.Rect::new(0, 0, 12, 2)
  let buffer = @core.Buffer::filled(area, @core.Cell::of("x"))
  widget.render(area, buffer)
  assert_eq(
    buffer,
    @core.Buffer::with_lines([
      "     ▂▄▆█xxx", " ▂▄▆█████xxx",
    ]),
  )
}

///|
/// 上游 render_handles_u64_max_value：u64::MAX 满量程渲染不溢出喵。
test "Sparkline u64 上限值" {
  let widget = Sparkline::default()
    .data([18446744073709551615UL])
    .max(18446744073709551615UL)
  let area = @core.Rect::new(0, 0, 1, 3)
  let buffer = @core.Buffer::empty(area)
  widget.render(area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines(["█", "█", "█"]))
}

///|
/// 上游 render_keeps_integer_precision_for_large_values：
/// (u64::MAX − 1)/u64::MAX 缩放须保持整数精度得 ▇（浮点会误为 █）喵。
test "Sparkline 大数值整数精度" {
  let widget = Sparkline::default()
    .data([18446744073709551614UL])
    .max(18446744073709551615UL)
  let area = @core.Rect::new(0, 0, 1, 1)
  let buffer = @core.Buffer::empty(area)
  widget.render(area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines(["▇"]))
}

///|
/// 本库 128 位长除加固用例（上游以 u128 原生承载，无对位测试）：
/// max 越过 2^63 时长除余数须走 65 位进位路径——
/// floor(2^63 × 8 / (2^63 + 1)) = 7 → ▇；若用浮点或忽略进位会误得 8 → █；
/// 另附 3/7 缩放的跨行分配（floor(3 × 16 / 7) = 6 → 底行 ▆ 顶行空格）喵。
test "Sparkline scale_height 128 位精确性" {
  let high = Sparkline::default()
    .data([9223372036854775808UL])
    .max(9223372036854775809UL)
  let area = @core.Rect::new(0, 0, 1, 1)
  let buffer = @core.Buffer::empty(area)
  high.render(area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines(["▇"]))
  let split = Sparkline::default().data([3UL]).max(7UL)
  let area2 = @core.Rect::new(0, 0, 1, 2)
  let buffer2 = @core.Buffer::empty(area2)
  split.render(area2, buffer2)
  assert_eq(buffer2, @core.Buffer::with_lines([" ", "▆"]))
}

///|
/// 上游 it_renders_left_to_right 喵。
test "Sparkline 左到右" {
  let widget = Sparkline::default()
    .data([0UL, 1UL, 2UL, 3UL, 4UL, 5UL, 6UL, 7UL, 8UL])
    .direction(RenderDirection::LeftToRight)
  let buffer = sparkline_render(widget, 12)
  assert_eq(buffer, @core.Buffer::with_lines([" ▁▂▃▄▅▆▇█xxx"]))
}

///|
/// 上游 it_renders_right_to_left：首值贴右缘喵。
test "Sparkline 右到左" {
  let widget = Sparkline::default()
    .data([0UL, 1UL, 2UL, 3UL, 4UL, 5UL, 6UL, 7UL, 8UL])
    .direction(RenderDirection::RightToLeft)
  let buffer = sparkline_render(widget, 12)
  assert_eq(buffer, @core.Buffer::with_lines(["xxx█▇▆▅▄▃▂▁ "]))
}

///|
/// 上游 it_renders_with_absent_value_style：缺值柱用缺值符号与样式，
/// 其余柱正常波形喵。
test "Sparkline 缺值样式" {
  let widget = Sparkline::default()
    .absent_value_style(@core.Style::new().fg(@core.Color::Red))
    .absent_value_symbol(@core.SHADE_FULL)
    .data_of_option([
      None,
      Some(1UL),
      Some(2UL),
      Some(3UL),
      Some(4UL),
      Some(5UL),
      Some(6UL),
      Some(7UL),
      Some(8UL),
    ])
  let buffer = sparkline_render(widget, 12)
  let expected = @core.Buffer::with_lines(["█▁▂▃▄▅▆▇█xxx"])
  expected.set_style(
    @core.Rect::new(0, 0, 1, 1),
    @core.Style::new().fg(@core.Color::Red),
  )
  assert_eq(buffer, expected)
}

///|
/// 上游 it_renders_with_absent_value_style_double_height：缺值柱
/// 双行同符号喵。
test "Sparkline 缺值样式双行" {
  let widget = Sparkline::default()
    .absent_value_style(@core.Style::new().fg(@core.Color::Red))
    .absent_value_symbol(@core.SHADE_FULL)
    .data_of_option([
      None,
      Some(1UL),
      Some(2UL),
      Some(3UL),
      Some(4UL),
      Some(5UL),
      Some(6UL),
      Some(7UL),
      Some(8UL),
    ])
  let area = @core.Rect::new(0, 0, 12, 2)
  let buffer = @core.Buffer::filled(area, @core.Cell::of("x"))
  widget.render(area, buffer)
  let expected = @core.Buffer::with_lines([
    "█    ▂▄▆█xxx", "█▂▄▆█████xxx",
  ])
  expected.set_style(
    @core.Rect::new(0, 0, 1, 2),
    @core.Style::new().fg(@core.Color::Red),
  )
  assert_eq(buffer, expected)
}

///|
/// 上游 it_renders_with_custom_absent_value_style：自定义缺值符号喵。
test "Sparkline 自定义缺值符号" {
  let widget = Sparkline::default()
    .absent_value_symbol("*")
    .data_of_option([
      None,
      Some(1UL),
      Some(2UL),
      Some(3UL),
      Some(4UL),
      Some(5UL),
      Some(6UL),
      Some(7UL),
      Some(8UL),
    ])
  let buffer = sparkline_render(widget, 12)
  assert_eq(buffer, @core.Buffer::with_lines(["*▁▂▃▄▅▆▇█xxx"]))
}

///|
/// 上游 it_renders_with_custom_bar_styles：逐柱样式与波形图样式
/// patch 叠加喵。
test "Sparkline 逐柱样式" {
  let widget = Sparkline::default().data_of_bars([
    SparklineBar::of(0UL).style(@core.Style::new().fg(@core.Color::Red)),
    SparklineBar::of(1UL).style(@core.Style::new().fg(@core.Color::Red)),
    SparklineBar::of(2UL).style(@core.Style::new().fg(@core.Color::Red)),
    SparklineBar::of(3UL).style(@core.Style::new().fg(@core.Color::Green)),
    SparklineBar::of(4UL).style(@core.Style::new().fg(@core.Color::Green)),
    SparklineBar::of(5UL).style(@core.Style::new().fg(@core.Color::Green)),
    SparklineBar::of(6UL).style(@core.Style::new().fg(@core.Color::Blue)),
    SparklineBar::of(7UL).style(@core.Style::new().fg(@core.Color::Blue)),
    SparklineBar::of(8UL).style(@core.Style::new().fg(@core.Color::Blue)),
  ])
  let buffer = sparkline_render(widget, 12)
  let expected = @core.Buffer::with_lines([" ▁▂▃▄▅▆▇█xxx"])
  expected.set_style(
    @core.Rect::new(0, 0, 3, 1),
    @core.Style::new().fg(@core.Color::Red),
  )
  expected.set_style(
    @core.Rect::new(3, 0, 3, 1),
    @core.Style::new().fg(@core.Color::Green),
  )
  expected.set_style(
    @core.Rect::new(6, 0, 3, 1),
    @core.Style::new().fg(@core.Color::Blue),
  )
  assert_eq(buffer, expected)
}

///|
/// 上游 can_be_stylized：样式速记与显式构造等价喵。
test "Sparkline 可被样式化" {
  let sparkline = Sparkline::default().style(
    @core.Style::new().black().on_white().bold().not_dim(),
  )
  assert_eq(
    sparkline.style,
    @core.Style::new()
    .fg(@core.Color::Black)
    .bg(@core.Color::White)
    .add_modifier(@core.Modifier::bold())
    .remove_modifier(@core.Modifier::dim()),
  )
}

///|
/// 上游 render_in_minimal_buffer：1×1 缓冲截断到首柱，不 panic 喵。
test "极小缓冲渲染 Sparkline" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  let sparkline = Sparkline::default()
    .data([1UL, 2UL, 3UL, 4UL, 5UL, 6UL, 7UL, 8UL, 9UL, 10UL])
    .max(10UL)
  sparkline.render(buffer.area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines([" "]))
}

///|
/// 上游 render_in_zero_size_buffer：零尺寸缓冲不 panic 喵。
test "零尺寸缓冲渲染 Sparkline" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  let sparkline = Sparkline::default()
    .data([1UL, 2UL, 3UL, 4UL, 5UL, 6UL, 7UL, 8UL, 9UL, 10UL])
    .max(10UL)
  sparkline.render(buffer.area, buffer)
  inspect(buffer.cells.length(), content="0")
}
