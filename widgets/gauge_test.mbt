///|
/// Gauge 单元测试：复刻 ratatui-v0.30.2 `widgets/gauge.rs` 内联测试清单喵。
///
/// 不可移植用例登记：
/// - `gauge_invalid_percentage` / `gauge_invalid_ratio_upper_bound` /
///   `gauge_invalid_ratio_lower_bound`：上游以 `assert!` panic 拒绝越界，
///   `should_panic` 语义不可移植；本库按铁律 3（无 panic）收敛为饱和
///   处理，对应用例改写为饱和行为验证（见"越界饱和"三条）喵。
/// - `line_gauge_can_be_stylized_with_deprecated_gauge_style` /
///   `line_gauge_deprecated_line_set`：上游 0.27/0.30 起弃用的
///   `gauge_style()`/`line_set()` 构造器不复刻，语义由
///   `filled_style`/`unfilled_style`/`filled_symbol`/`unfilled_symbol` 覆盖喵。

///|
/// 上游 gauge_invalid_percentage：百分比越界饱和到 1.0 喵。
test "Gauge 越界百分比饱和上界" {
  inspect(Gauge::default().percent(110).ratio, content="1")
}

///|
/// 上游 gauge_invalid_ratio_upper_bound：比率越界饱和到 1.0 喵。
test "Gauge 越界比率饱和上界" {
  inspect(Gauge::default().ratio(1.1).ratio, content="1")
}

///|
/// 上游 gauge_invalid_ratio_lower_bound：负比率饱和到 0.0 喵。
test "Gauge 越界比率饱和下界" {
  inspect(Gauge::default().ratio(-0.5).ratio, content="0")
}

///|
/// 上游 gauge_can_be_stylized：样式速记与显式构造等价喵。
test "Gauge 可被样式化" {
  let gauge = Gauge::default().style(
    @core.Style::new().black().on_white().bold().not_dim(),
  )
  assert_eq(
    gauge.style,
    @core.Style::new()
    .fg(@core.Color::Black)
    .bg(@core.Color::White)
    .add_modifier(@core.Modifier::bold())
    .remove_modifier(@core.Modifier::dim()),
  )
}

///|
/// 上游 line_gauge_can_be_stylized：样式速记与显式构造等价喵。
test "LineGauge 可被样式化" {
  let gauge = LineGauge::default().style(
    @core.Style::new().black().on_white().bold().not_dim(),
  )
  assert_eq(
    gauge.style,
    @core.Style::new()
    .fg(@core.Color::Black)
    .bg(@core.Color::White)
    .add_modifier(@core.Modifier::bold())
    .remove_modifier(@core.Modifier::dim()),
  )
}

///|
/// 上游 line_gauge_set_filled_symbol 喵。
test "LineGauge 设填充符号" {
  inspect(
    LineGauge::default().filled_symbol("▰").filled_symbol,
    content="▰",
  )
}

///|
/// 上游 line_gauge_set_unfilled_symbol 喵。
test "LineGauge 设空置符号" {
  inspect(
    LineGauge::default().unfilled_symbol("▱").unfilled_symbol,
    content="▱",
  )
}

///|
/// 上游 line_gauge_default：缺省字段逐项相等喵。
test "LineGauge 缺省构造" {
  let expected : LineGauge = {
    block: None,
    ratio: 0.0,
    label: None,
    style: @core.Style::new(),
    filled_symbol: @core.LINE_HORIZONTAL,
    unfilled_symbol: @core.LINE_HORIZONTAL,
    filled_style: @core.Style::new(),
    unfilled_style: @core.Style::new(),
  }
  assert_eq(LineGauge::default(), expected)
}

///|
/// 上游 render_in_minimal_buffer_gauge：1×1 缓冲不 panic，标签截断为
/// "5" 且填充段被标签区间覆盖喵。
test "极小缓冲渲染 Gauge" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  let gauge = Gauge::default().percent(50)
  gauge.render(buffer.area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines(["5"]))
}

///|
/// 上游 render_in_minimal_buffer_line_gauge：1×1 缓冲不 panic，缺省
/// 标签 " 50%" 截断为单个空格喵。
test "极小缓冲渲染 LineGauge" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  let line_gauge = LineGauge::default().ratio(0.5)
  line_gauge.render(buffer.area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines([" "]))
}

///|
/// 上游 render_in_zero_size_buffer_gauge：零尺寸缓冲不 panic 喵。
test "零尺寸缓冲渲染 Gauge" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  let gauge = Gauge::default().percent(50)
  gauge.render(buffer.area, buffer)
  inspect(buffer.cells.length(), content="0")
}

///|
/// 上游 render_in_zero_size_buffer_line_gauge：零尺寸缓冲不 panic 喵。
test "零尺寸缓冲渲染 LineGauge" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  let line_gauge = LineGauge::default().ratio(0.5)
  line_gauge.render(buffer.area, buffer)
  inspect(buffer.cells.length(), content="0")
}
