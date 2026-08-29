// 上游 `canvas.rs` 内联测试逐条复刻：rstest 参数矩阵以数组循环
// 承载；usize 溢出探针以 Int 域等价承载（见 canvas.mbt 头登记）喵。

///|
/// 上游 `test_horizontal_with_vertical`：横线 + 竖线在 10 种 marker
/// 下的叠加矩阵，未涂区域保持底衬 "x" 喵。
test "Canvas 横竖线叠加全 marker 矩阵" {
  let cases : Array[(@core.Marker, Array[String])] = [
    (
      @core.Block,
      ["█xxxx", "█xxxx", "█xxxx", "█xxxx", "█████"],
    ),
    (
      @core.HalfBlock,
      ["█xxxx", "█xxxx", "█xxxx", "█xxxx", "█▄▄▄▄"],
    ),
    (@core.Bar, ["▄xxxx", "▄xxxx", "▄xxxx", "▄xxxx", "▄▄▄▄▄"]),
    (
      @core.Braille,
      ["⡇xxxx", "⡇xxxx", "⡇xxxx", "⡇xxxx", "⣇⣀⣀⣀⣀"],
    ),
    (
      @core.Quadrant,
      ["▌xxxx", "▌xxxx", "▌xxxx", "▌xxxx", "▙▄▄▄▄"],
    ),
    (
      @core.Sextant,
      ["▌xxxx", "▌xxxx", "▌xxxx", "▌xxxx", "🬲🬭🬭🬭🬭"],
    ),
    (
      @core.Octant,
      ["▌xxxx", "▌xxxx", "▌xxxx", "▌xxxx", "𜷀▂▂▂▂"],
    ),
    (@core.Custom('×'), ["×xxxx", "×xxxx", "×xxxx", "×xxxx", "×××××"]),
    (@core.Custom('+'), ["+xxxx", "+xxxx", "+xxxx", "+xxxx", "+++++"]),
    (@core.Dot, ["•xxxx", "•xxxx", "•xxxx", "•xxxx", "•••••"]),
  ]
  let area = @core.Rect::new(0, 0, 5, 5)
  for case in cases {
    let (marker, expected) = case
    let buf = @core.Buffer::filled(area, @core.Cell::of("x"))
    let horizontal_line = CanvasLine::new(0.0, 0.0, 10.0, 0.0, @core.Reset)
    let vertical_line = CanvasLine::new(0.0, 0.0, 0.0, 10.0, @core.Reset)
    Canvas::default()
    .marker(marker)
    .paint(ctx => {
      ctx.draw(vertical_line)
      ctx.draw(horizontal_line)
    })
    .x_bounds((0.0, 10.0))
    .y_bounds((0.0, 10.0))
    .render(area, buf)
    assert_eq(buf, @core.Buffer::with_lines(expected))
  }
}

///|
/// 上游 `test_diagonal_lines`：双对角线在 10 种 marker 下的叠加
/// 矩阵喵。
test "Canvas 对角线叠加全 marker 矩阵" {
  let cases : Array[(@core.Marker, Array[String])] = [
    (
      @core.Block,
      ["█xxx█", "x█x█x", "xx█xx", "x█x█x", "█xxx█"],
    ),
    (
      @core.HalfBlock,
      ["█xxx█", "x█x█x", "xx█xx", "x█x█x", "█xxx█"],
    ),
    (@core.Bar, ["▄xxx▄", "x▄x▄x", "xx▄xx", "x▄x▄x", "▄xxx▄"]),
    (
      @core.Braille,
      ["⢣xxx⡜", "x⢣x⡜x", "xx⣿xx", "x⡜x⢣x", "⡜xxx⢣"],
    ),
    (
      @core.Quadrant,
      ["▚xxx▞", "x▚x▞x", "xx█xx", "x▞x▚x", "▞xxx▚"],
    ),
    (
      @core.Sextant,
      ["🬧xxx🬔", "x🬧x🬔x", "xx█xx", "x🬘x🬣x", "🬘xxx🬣"],
    ),
    (
      @core.Octant,
      ["▚xxx▞", "x▚x▞x", "xx█xx", "x▞x▚x", "▞xxx▚"],
    ),
    (@core.Custom('×'), ["×xxx×", "x×x×x", "xx×xx", "x×x×x", "×xxx×"]),
    (@core.Custom('+'), ["+xxx+", "x+x+x", "xx+xx", "x+x+x", "+xxx+"]),
    (@core.Dot, ["•xxx•", "x•x•x", "xx•xx", "x•x•x", "•xxx•"]),
  ]
  let area = @core.Rect::new(0, 0, 5, 5)
  for case in cases {
    let (marker, expected) = case
    let buf = @core.Buffer::filled(area, @core.Cell::of("x"))
    let diagonal_up = CanvasLine::new(0.0, 0.0, 10.0, 10.0, @core.Reset)
    let diagonal_down = CanvasLine::new(0.0, 10.0, 10.0, 0.0, @core.Reset)
    Canvas::default()
    .marker(marker)
    .paint(ctx => {
      ctx.draw(diagonal_down)
      ctx.draw(diagonal_up)
    })
    .x_bounds((0.0, 10.0))
    .y_bounds((0.0, 10.0))
    .render(area, buf)
    assert_eq(buf, @core.Buffer::with_lines(expected))
  }
}

///|
/// 上游 `check_canvas_paint_max` / `check_canvas_paint_overflow` 的
/// 渲染等价承载喵。
///
/// 不可移植登记：上游对包私有 `PatternGrid`/`CharGrid` 以
/// `usize::MAX` 级坐标直断涂点；本库包私有项不可从测试文件直测
/// （仓库惯例），且 `Painter::get_point` 的界检使极端网格点位经
/// 公开 API 不可达，故以"极端画布宽度 + 越界图形 + 全 marker"
/// 的公开渲染链路等价承载：验证网格分配与涂点守卫不 panic 不扰动，
/// `usize::MAX` 以 Int 域折算喵。
test "Canvas 极端尺寸与越界涂点不 panic" {
  let area = @core.Rect::new(0, 0, 65535, 3)
  let markers = [
    @core.Octant,
    @core.Braille,
    @core.Quadrant,
    @core.Sextant,
    @core.HalfBlock,
    @core.Dot,
    @core.Block,
    @core.Bar,
    @core.Custom('d'),
  ]
  for marker in markers {
    let buf = @core.Buffer::empty(area)
    Canvas::default()
    .marker(marker)
    .paint(ctx => {
      // 满幅对角线：裁剪后全界涂点喵。
      ctx.draw(CanvasLine::new(0.0, 0.0, 1.0, 1.0, @core.Red))
      // 远越界点：get_point 落 None 喵。
      ctx.draw(Points::new([(1.0e18, -1.0e18), (-1.0e18, 1.0e18)], @core.Red))
      // 退化边界上的点：折算无 panic 喵。
      ctx.draw(Points::new([(0.0, 0.0), (1.0, 1.0)], @core.Red))
    })
    .x_bounds((0.0, 1.0))
    .y_bounds((0.0, 1.0))
    .render(area, buf)
  }
  // 退化边界（宽度为 0）渲染不 panic 喵。
  let tiny = @core.Buffer::empty(@core.Rect::new(0, 0, 2, 1))
  Canvas::default()
  .paint(ctx => ctx.draw(CanvasLine::new(0.0, 0.0, 1.0, 1.0, @core.Red)))
  .x_bounds((1.0, 1.0))
  .y_bounds((0.0, 1.0))
  .render(tiny.area, tiny)
}

///|
/// 上游 `render_in_minimal_buffer`：1x1 缓冲渲染不 panic 喵。
test "Canvas 极小缓冲渲染" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  let canvas = Canvas::default()
    .x_bounds((0.0, 10.0))
    .y_bounds((0.0, 10.0))
    .paint(_ctx => ())
  canvas.render(buffer.area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines([" "]))
}

///|
/// 上游 `render_in_zero_size_buffer`：零尺寸缓冲渲染不 panic 喵。
test "Canvas 零尺寸缓冲渲染" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  let canvas = Canvas::default()
    .x_bounds((0.0, 10.0))
    .y_bounds((0.0, 10.0))
    .paint(_ctx => ())
  canvas.render(buffer.area, buffer)
}
