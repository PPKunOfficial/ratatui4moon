// Canvas 画布（上游 `ratatui-widgets/src/canvas.rs`）：在 cell 网格上
// 以 Marker 伪像素画 Shape 的组件族，Chart 的绘制基座喵。
//
// 载体折算登记：
// - 上游 `Box<dyn Grid>` 以 GridKind 枚举分派承载（MoonBit 无动态分发
//   指针，枚举即封闭实现集）；
// - 上游 `usize` 坐标以 Int（32 位）承装，越界一律优雅裁剪不 panic，
//   上游 `usize::MAX` 溢出探针测试以 `Int::MAX` 等价承载；
// - 上游 `Canvas<'a, F>` 泛型绘制闭包以 `((Context) -> Unit)?` 承装。

///|
/// 可绘制到 Canvas 的图形契约（上游 `Shape` trait）：自定义图形
/// 实现本 trait 即可参与绘制喵。
pub(open) trait Shape {
  fn draw(Self, Painter) -> Unit
}

///|
/// Canvas 标签（上游 `Label`）：世界坐标 + 待写文本行喵。
pub(all) struct Label {
  x : Double
  y : Double
  line : @core.Line
} derive(Eq, Debug)

///|
/// 层内单元格（上游 `LayerCell`）：多层叠加时符号/前景/背景各自
/// 可缺省，缺省项透出下层喵。
struct LayerCell {
  symbol : Char?
  fg : @core.Color?
  bg : @core.Color?
} derive(Debug)

///|
/// 一层绘制结果（上游 `Layer`）：与画布等长的单元格序列喵。
struct Layer {
  contents : Array[LayerCell]
} derive(Debug)

///|
/// 三种网格的封闭实现集（上游 `Box<dyn Grid>` 的枚举承载）喵。
enum GridKind {
  Pattern(PatternGrid)
  Char(CharGrid)
  HalfBlock(HalfBlockGrid)
} derive(Debug)

///|
/// 网格分辨率（点数）（上游 `Grid::resolution`）喵。
fn GridKind::grid_resolution(self : GridKind) -> (Double, Double) {
  match self {
    Pattern(g) =>
      (
        g.width.to_double() * g.cell_w.to_double(),
        g.height.to_double() * g.cell_h.to_double(),
      )
    Char(g) => (g.width.to_double(), g.height.to_double())
    HalfBlock(g) => (g.width.to_double(), g.height.to_double() * 2.0)
  }
}

///|
/// 在网格点位涂色（上游 `Grid::paint`）：越界一律静默忽略喵。
fn GridKind::grid_paint(
  self : GridKind,
  x : Int,
  y : Int,
  color : @core.Color,
) -> Unit {
  match self {
    Pattern(g) => g.paint(x, y, color)
    Char(g) => g.paint(x, y, color)
    HalfBlock(g) => g.paint(x, y, color)
  }
}

///|
/// 保存当前网格状态为层（上游 `Grid::save`）喵。
fn GridKind::grid_save(self : GridKind) -> Layer {
  match self {
    Pattern(g) => g.save()
    Char(g) => g.save()
    HalfBlock(g) => g.save()
  }
}

///|
/// 复位网格（上游 `Grid::reset`）喵。
fn GridKind::grid_reset(self : GridKind) -> Unit {
  match self {
    Pattern(g) => g.reset()
    Char(g) => g.reset()
    HalfBlock(g) => g.reset()
  }
}

///|
/// 位图单元格（上游 `PatternCell`）：pattern 为 2xW 伪像素的行主序
/// 位图（低 W*H 位），color 是整字符的前景色喵。
struct PatternCell {
  mut pattern : Int
  mut color : @core.Color?
} derive(Debug)

///|
/// 位图网格（上游 `PatternGrid<W, H>` 的非泛型承载）：每格
/// cell_w x cell_h 伪像素，Braille/Quadrant/Sextant/Octant 共用喵。
struct PatternGrid {
  width : Int
  height : Int
  cell_w : Int
  cell_h : Int
  cells : Array[PatternCell]
  char_table : Array[Char]
} derive(Debug)

///|
/// 新建位图网格（上游 `PatternGrid::new`）喵。
fn PatternGrid::new(
  width : Int,
  height : Int,
  cell_w : Int,
  cell_h : Int,
  char_table : Array[Char],
) -> PatternGrid {
  {
    width,
    height,
    cell_w,
    cell_h,
    cells: Array::makei(width * height, _ => { pattern: 0, color: None }),
    char_table,
  }
}

///|
/// 保存为层：0 位图跳过渲染以透出下层（上游 `PatternGrid::save`）喵。
fn PatternGrid::save(self : PatternGrid) -> Layer {
  let contents = Array::new(capacity=self.cells.length())
  for cell in self.cells {
    let symbol : Char? = if cell.pattern == 0 {
      None
    } else {
      Some(self.char_table[cell.pattern])
    }
    contents.push({ symbol, fg: cell.color, bg: None })
  }
  { contents, }
}

///|
/// 复位（上游 `PatternGrid::reset`）喵。
fn PatternGrid::reset(self : PatternGrid) -> Unit {
  for cell in self.cells {
    cell.pattern = 0
    cell.color = None
  }
}

///|
/// 涂点：以 cell_w/cell_h 折算格位并点亮行主序位（上游
/// `PatternGrid::paint` 的饱和运算以负值/越界守卫等价承载）喵。
fn PatternGrid::paint(
  self : PatternGrid,
  x : Int,
  y : Int,
  color : @core.Color,
) -> Unit {
  if x < 0 || y < 0 {
    return
  }
  let col = x / self.cell_w
  let row = y / self.cell_h
  if col >= self.width || row >= self.height {
    return
  }
  let idx = row * self.width + col
  let cell = self.cells[idx]
  cell.pattern = cell.pattern.lor(
    1 << (x % self.cell_w + self.cell_w * (y % self.cell_h)),
  )
  cell.color = Some(color)
}

///|
/// 单字符网格（上游 `CharGrid`）：1x1 分辨率，每格一字符一色喵。
struct CharGrid {
  width : Int
  height : Int
  cells : Array[@core.Color?]
  cell_char : Char
  /// 着色是否同步写背景（上游 `apply_color_to_bg`，Block 标记用）喵。
  apply_color_to_bg : Bool
} derive(Debug)

///|
/// 新建单字符网格（上游 `CharGrid::new`）喵。
fn CharGrid::new(width : Int, height : Int, cell_char : Char) -> CharGrid {
  {
    width,
    height,
    cells: Array::makei(width * height, _ => None),
    cell_char,
    apply_color_to_bg: false,
  }
}

///|
/// 打开背景着色（上游 `CharGrid::apply_color_to_bg`）喵。
fn CharGrid::with_color_to_bg(self : CharGrid) -> CharGrid {
  { ..self, apply_color_to_bg: true }
}

///|
/// 保存为层（上游 `CharGrid::save`）喵。
fn CharGrid::save(self : CharGrid) -> Layer {
  let contents = Array::new(capacity=self.cells.length())
  for color in self.cells {
    let symbol : Char? = match color {
      Some(_) => Some(self.cell_char)
      None => None
    }
    let bg : @core.Color? = match color {
      Some(c) => if self.apply_color_to_bg { Some(c) } else { None }
      None => None
    }
    contents.push({ symbol, fg: color, bg })
  }
  { contents, }
}

///|
/// 复位（上游 `CharGrid::reset`）喵。
fn CharGrid::reset(self : CharGrid) -> Unit {
  for i in 0..<self.cells.length() {
    self.cells[i] = None
  }
}

///|
/// 涂点：越界静默忽略（上游 `CharGrid::paint`）喵。
fn CharGrid::paint(
  self : CharGrid,
  x : Int,
  y : Int,
  color : @core.Color,
) -> Unit {
  if x < 0 || y < 0 || x >= self.width || y >= self.height {
    return
  }
  self.cells[y * self.width + x] = Some(color)
}

///|
/// 半块网格（上游 `HalfBlockGrid`）：1x2 伪像素分辨率，借前后景
/// 双色承载，行数两倍于终端行数喵。
struct HalfBlockGrid {
  width : Int
  height : Int
  /// 按 (行, 列) 存伪像素颜色，行数为 height*2 喵。
  pixels : Array[Array[@core.Color?]]
} derive(Debug)

///|
/// 新建半块网格（上游 `HalfBlockGrid::new`）喵。
fn HalfBlockGrid::new(width : Int, height : Int) -> HalfBlockGrid {
  {
    width,
    height,
    pixels: Array::makei(height * 2, _ => Array::makei(width, _ => None)),
  }
}

///|
/// 保存为层：逐垂直像素对判定字符（上游 `HalfBlockGrid::save`）喵。
///
/// 状态表：
/// 1. 上缺/下缺 → 空缺；2. 下有/上缺 → 下半块（前景=下色）；
/// 3. 上有/下缺 → 上半块（前景=上色）；4. 双有色 → 上半块
/// （前景=上色，背景=下色），同色时改全块便于测试锚定喵。
fn HalfBlockGrid::save(self : HalfBlockGrid) -> Layer {
  let contents = Array::new(capacity=self.width * self.height)
  for row in 0..<self.height {
    let upper_row = self.pixels[row * 2]
    let lower_row = self.pixels[row * 2 + 1]
    for col in 0..<self.width {
      let upper = upper_row[col]
      let lower = lower_row[col]
      let (symbol, fg, bg) : (Char?, @core.Color?, @core.Color?) = match
        (upper, lower) {
        (None, None) => (None, None, None)
        (None, Some(lower)) => (Some(@core.HALF_BLOCK_LOWER), Some(lower), None)
        (Some(upper), None) => (Some(@core.HALF_BLOCK_UPPER), Some(upper), None)
        (Some(upper), Some(lower)) =>
          if lower == upper {
            (Some(@core.HALF_BLOCK_FULL), Some(upper), Some(lower))
          } else {
            (Some(@core.HALF_BLOCK_UPPER), Some(upper), Some(lower))
          }
      }
      contents.push({ symbol, fg, bg })
    }
  }
  { contents, }
}

///|
/// 复位（上游 `HalfBlockGrid::reset`）喵。
fn HalfBlockGrid::reset(self : HalfBlockGrid) -> Unit {
  for i in 0..<self.pixels.length() {
    self.pixels[i] = Array::makei(self.width, _ => None)
  }
}

///|
/// 涂点：越界静默忽略（上游直接下标写入会 panic，按无 panic 铁律
/// 改守卫裁剪并登记）喵。
fn HalfBlockGrid::paint(
  self : HalfBlockGrid,
  x : Int,
  y : Int,
  color : @core.Color,
) -> Unit {
  if x < 0 || y < 0 || x >= self.width || y >= self.height * 2 {
    return
  }
  self.pixels[y][x] = Some(color)
}

///|
/// 画布绘制器（上游 `Painter`）：Shape 借它把世界坐标折算为网格
/// 点位并涂色，角色类似终端侧的 Buffer 喵。
pub struct Painter {
  context : Context
  resolution : (Double, Double)
} derive(Debug)

///|
/// 从上下文构造绘制器（上游 `From<&mut Context> for Painter`）喵。
pub fn Painter::of(context : Context) -> Painter {
  { context, resolution: context.grid.grid_resolution() }
}

///|
/// 世界坐标 → 网格点位（上游 `Painter::get_point`）：越界或退化
/// 边界落 None；恰好落在格中心的点向上取整喵。
///
/// 世界坐标原点在画布左下角，网格点位原点在左上角喵。
pub fn Painter::get_point(
  self : Painter,
  x : Double,
  y : Double,
) -> (Int, Int)? {
  let (left, right) = self.context.x_bounds
  let (bottom, top) = self.context.y_bounds
  if x < left || x > right || y < bottom || y > top {
    return None
  }
  let width = right - left
  let height = top - bottom
  if width <= 0.0 || height <= 0.0 {
    return None
  }
  let gx = ((x - left) * (self.resolution.0 - 1.0) / width).round().to_int()
  let gy = ((top - y) * (self.resolution.1 - 1.0) / height).round().to_int()
  Some((gx, gy))
}

///|
/// 涂一个网格点（上游 `Painter::paint`）喵。
pub fn Painter::paint(
  self : Painter,
  x : Int,
  y : Int,
  color : @core.Color,
) -> Unit {
  self.context.grid.grid_paint(x, y, color)
}

///|
/// 画布边界（上游 `Painter::bounds`）：X 与 Y 边界各一对喵。
pub fn Painter::bounds(self : Painter) -> ((Double, Double), (Double, Double)) {
  (self.context.x_bounds, self.context.y_bounds)
}

///|
/// Canvas 绘制上下文（上游 `Context`）：承载网格、层与标签的
/// 画布状态，角色类似终端侧的 Frame 喵。
pub struct Context {
  width : Int
  height : Int
  x_bounds : (Double, Double)
  y_bounds : (Double, Double)
  mut grid : GridKind
  mut dirty : Bool
  layers : Array[Layer]
  labels : Array[Label]
} derive(Debug)

///|
/// 新建上下文（上游 `Context::new`）：marker 决定网格类型喵。
pub fn Context::new(
  width : Int,
  height : Int,
  x_bounds : (Double, Double),
  y_bounds : (Double, Double),
  marker : @core.Marker,
) -> Context {
  {
    width,
    height,
    x_bounds,
    y_bounds,
    grid: Context::marker_to_grid(width, height, marker),
    dirty: false,
    layers: [],
    labels: [],
  }
}

///|
/// marker → 网格类型映射（上游 `Context::marker_to_grid`）喵。
fn Context::marker_to_grid(
  width : Int,
  height : Int,
  marker : @core.Marker,
) -> GridKind {
  let dot = @core.DOT.iter().next().unwrap()
  let block = @core.BLOCK_FULL.iter().next().unwrap()
  let bar = @core.BAR_HALF.iter().next().unwrap()
  match marker {
    @core.Block => Char(CharGrid::new(width, height, block).with_color_to_bg())
    @core.Bar => Char(CharGrid::new(width, height, bar))
    @core.Braille =>
      Pattern(PatternGrid::new(width, height, 2, 4, @core.braille_table))
    @core.HalfBlock => HalfBlock(HalfBlockGrid::new(width, height))
    @core.Quadrant =>
      Pattern(PatternGrid::new(width, height, 2, 2, @core.quadrants))
    @core.Sextant =>
      Pattern(PatternGrid::new(width, height, 2, 3, @core.sextants))
    @core.Octant =>
      Pattern(PatternGrid::new(width, height, 2, 4, @core.octants))
    @core.Custom(ch) => Char(CharGrid::new(width, height, ch))
    @core.Dot => Char(CharGrid::new(width, height, dot))
  }
}

///|
/// 换 marker：先保存未收尾的层再换网格（上游 `Context::marker`）喵。
pub fn Context::marker(self : Context, marker : @core.Marker) -> Unit {
  self.finish()
  self.grid = Context::marker_to_grid(self.width, self.height, marker)
}

///|
/// 画一个 Shape（上游 `Context::draw`）喵。
pub fn Context::draw(self : Context, shape : &Shape) -> Unit {
  self.dirty = true
  let painter = Painter::of(self)
  shape.draw(painter)
}

///|
/// 把当前网格存为一层并复位（上游 `Context::layer`）：多图形按
/// 层次叠加用喵。
pub fn Context::layer(self : Context) -> Unit {
  self.layers.push(self.grid.grid_save())
  self.grid.grid_reset()
  self.dirty = false
}

///|
/// 在世界坐标打印文本行（上游 `Context::print`）：标签总在最上层，
/// 不受分层影响喵。
pub fn Context::print(
  self : Context,
  x : Double,
  y : Double,
  line : @core.Line,
) -> Unit {
  self.labels.push({ x, y, line })
}

///|
/// 收尾：仍有未保存的绘制则存层（上游 `Context::finish`）喵。
fn Context::finish(self : Context) -> Unit {
  if self.dirty {
    self.layer()
  }
}

///|
/// 画布组件（上游 `Canvas`）：把 Shape 画进带 world 坐标系的
/// 伪像素网格，缺省盲文 2x4 分辨率喵。
pub struct Canvas {
  block : Block?
  x_bounds : (Double, Double)
  y_bounds : (Double, Double)
  paint_func : ((Context) -> Unit)?
  background_color : @core.Color
  marker : @core.Marker
}

///|
/// 缺省画布（上游 `Canvas::default`）：无块、零边界、盲文标记、
/// 背景色 Reset 喵。
pub fn Canvas::default() -> Canvas {
  {
    block: None,
    x_bounds: (0.0, 0.0),
    y_bounds: (0.0, 0.0),
    paint_func: None,
    background_color: @core.Reset,
    marker: @core.Braille,
  }
}

///|
/// 包边框块（上游 `Canvas::block`）喵。
pub fn Canvas::block(self : Canvas, block : Block) -> Canvas {
  { ..self, block: Some(block) }
}

///|
/// X 边界（上游 `Canvas::x_bounds`）喵。
pub fn Canvas::x_bounds(self : Canvas, bounds : (Double, Double)) -> Canvas {
  { ..self, x_bounds: bounds }
}

///|
/// Y 边界（上游 `Canvas::y_bounds`）喵。
pub fn Canvas::y_bounds(self : Canvas, bounds : (Double, Double)) -> Canvas {
  { ..self, y_bounds: bounds }
}

///|
/// 挂绘制闭包（上游 `Canvas::paint`）喵。
pub fn Canvas::paint(self : Canvas, f : (Context) -> Unit) -> Canvas {
  { ..self, paint_func: Some(f) }
}

///|
/// 背景色（上游 `Canvas::background_color`）喵。
pub fn Canvas::background_color(self : Canvas, color : @core.Color) -> Canvas {
  { ..self, background_color: color }
}

///|
/// 换标记（上游 `Canvas::marker`）喵。
pub fn Canvas::marker(self : Canvas, marker : @core.Marker) -> Canvas {
  { ..self, marker, }
}

///|
/// Widget 实现（上游 `impl Widget for Canvas`）喵。
pub impl @core.Widget for Canvas with fn render(self, area, buf) {
  let canvas_area = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  if canvas_area.is_empty() {
    return
  }
  buf.set_style(canvas_area, @core.Style::new().bg(self.background_color))
  let width = canvas_area.width
  let paint_func = match self.paint_func {
    Some(f) => f
    None => return
  }
  let ctx = Context::new(
    canvas_area.width,
    canvas_area.height,
    self.x_bounds,
    self.y_bounds,
    self.marker,
  )
  paint_func(ctx)
  ctx.finish()
  for layer in ctx.layers {
    for i, layer_cell in layer.contents {
      let x = i % width + canvas_area.x
      let y = i / width + canvas_area.y
      match buf.mut_cell(x, y) {
        Some(cell) => {
          match layer_cell.symbol {
            Some(symbol) => cell.set_char(symbol)
            None => ()
          }
          match layer_cell.fg {
            Some(fg) => cell.set_fg(fg)
            None => ()
          }
          match layer_cell.bg {
            Some(bg) => cell.set_bg(bg)
            None => ()
          }
        }
        None => ()
      }
    }
  }
  let (left, right) = self.x_bounds
  let (bottom, top) = self.y_bounds
  let bound_width = (right - left).abs()
  let bound_height = (top - bottom).abs()
  let res_w = (canvas_area.width - 1).to_double()
  let res_h = (canvas_area.height - 1).to_double()
  for label in ctx.labels {
    if label.x >= left &&
      label.x <= right &&
      label.y <= top &&
      label.y >= bottom {
      let x = ((label.x - left) * res_w / bound_width).to_int() + canvas_area.x
      let y = ((top - label.y) * res_h / bound_height).to_int() + canvas_area.y
      ignore(buf.set_line(x, y, label.line, canvas_area.right() - x))
    }
  }
}
