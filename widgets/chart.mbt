// Chart 图表组件（上游 `ratatui-widgets/src/chart.rs`）：在笛卡尔
// 坐标系中绘制多个 Dataset，含轴标题/标签/图例与四种图型喵。
//
// 载体折算登记：
// - 上游 `Axis::title`/`Dataset::name` 的 `Into<Line>` 糖按 title_str/
//   name_str 构造对位（同 Block 惯例）；
// - 上游 Styled 实现以 `style()`/`set_style()` 方法对位；
// - `Chart::layout` 包私有，测试按仓库惯例以渲染等价承载（登记见
//   chart_test.mbt）。

///|
/// X/Y 轴（上游 `Axis`）：标题在轴末端（X 右、Y 上），含边界与
/// 标签序列及轴样式喵。
pub struct ChartAxis {
  title : @core.Line?
  bounds : (Double, Double)
  labels : Array[@core.Line]
  style : @core.Style
  labels_alignment : @core.Alignment
} derive(Eq, Debug)

///|
/// 缺省轴（上游 `Axis::default`）：无标题、零边界、无标签喵。
pub fn ChartAxis::default() -> ChartAxis {
  {
    title: None,
    bounds: (0.0, 0.0),
    labels: [],
    style: @core.Style::new(),
    labels_alignment: @core.Left,
  }
}

///|
/// 设轴标题（上游 `Axis::title`）喵。
pub fn ChartAxis::title(self : ChartAxis, title : @core.Line) -> ChartAxis {
  { ..self, title: Some(title) }
}

///|
/// 设字符串轴标题（上游 `Into<Line>` 糖）喵。
pub fn ChartAxis::title_str(self : ChartAxis, title : String) -> ChartAxis {
  { ..self, title: Some(@core.Line::raw(title)) }
}

///|
/// 设轴边界（上游 `Axis::bounds`）喵。
pub fn ChartAxis::bounds(
  self : ChartAxis,
  bounds : (Double, Double),
) -> ChartAxis {
  { ..self, bounds, }
}

///|
/// 设轴标签（上游 `Axis::labels`）：X 轴自左向右、Y 轴自下而上，
/// 少于两个标签不渲染喵。
pub fn ChartAxis::labels(
  self : ChartAxis,
  labels : Array[@core.Line],
) -> ChartAxis {
  { ..self, labels, }
}

///|
/// 设字符串轴标签（上游 `Into<Line>` 糖）喵。
pub fn ChartAxis::labels_of_str(
  self : ChartAxis,
  labels : Array[String],
) -> ChartAxis {
  { ..self, labels: labels.map(@core.Line::raw) }
}

///|
/// 设轴样式（上游 `Axis::style`）喵。
pub fn ChartAxis::style(self : ChartAxis, style : @core.Style) -> ChartAxis {
  { ..self, style, }
}

///|
/// 设标签对齐（上游 `Axis::labels_alignment`）：X 轴仅影响首个
/// 标签，Y 轴作用于整列喵。
pub fn ChartAxis::labels_alignment(
  self : ChartAxis,
  alignment : @core.Alignment,
) -> ChartAxis {
  { ..self, labels_alignment: alignment }
}

///|
/// 读取样式（上游 `impl Styled for Axis`）喵。
pub fn ChartAxis::get_style(self : ChartAxis) -> @core.Style {
  self.style
}

///|
/// 写样式（上游 `Styled::set_style`）喵。
pub fn ChartAxis::set_style(self : ChartAxis, style : @core.Style) -> ChartAxis {
  self.style(style)
}

///|
/// 图型（上游 `GraphType`）：散点/连线/柱形/面积喵。
pub(all) enum GraphType {
  Scatter
  Line
  Bar
  Area
} derive(Eq, Debug)

///|
/// 变体名（上游 strum `Display`）喵。
pub fn GraphType::name(self : GraphType) -> String {
  match self {
    Scatter => "Scatter"
    Line => "Line"
    Bar => "Bar"
    Area => "Area"
  }
}

///|
/// 变体名解析（上游 strum `EnumString`）喵。
pub fn GraphType::from_str(s : String) -> GraphType? {
  match s {
    "Scatter" => Some(Scatter)
    "Line" => Some(Line)
    "Bar" => Some(Bar)
    "Area" => Some(Area)
    _ => None
  }
}

///|
/// 图例位置（上游 `LegendPosition`）：缺省右上喵。
pub(all) enum LegendPosition {
  Top
  TopRight
  TopLeft
  Left
  Right
  Bottom
  BottomRight
  BottomLeft
} derive(Eq, Debug)

///|
/// 缺省位置（上游 `LegendPosition::default` = `TopRight`）喵。
pub fn LegendPosition::default() -> LegendPosition {
  TopRight
}

///|
/// 在图区内定出图例矩形（上游 `LegendPosition::layout`）：随轴
/// 标题宽度避让，放不下落 None 喵。
fn LegendPosition::place(
  self : LegendPosition,
  area : @core.Rect,
  legend_width : Int,
  legend_height : Int,
  x_title_width : Int,
  y_title_width : Int,
) -> @core.Rect? {
  let mut height_margin = area.height - legend_height
  if x_title_width != 0 {
    height_margin -= 1
  }
  if y_title_width != 0 {
    height_margin -= 1
  }
  if height_margin < 0 {
    return None
  }
  let (x, y) = match self {
    TopRight =>
      if legend_width + y_title_width > area.width {
        (area.right() - legend_width, area.y + 1)
      } else {
        (area.right() - legend_width, area.y)
      }
    TopLeft =>
      if y_title_width != 0 {
        (area.x, area.y + 1)
      } else {
        (area.x, area.y)
      }
    Top => {
      let x = (area.width - legend_width) / 2
      if area.x + y_title_width > x {
        (area.x + x, area.y + 1)
      } else {
        (area.x + x, area.y)
      }
    }
    Left => {
      let mut y = (area.height - legend_height) / 2
      if y_title_width != 0 {
        y += 1
      }
      if x_title_width != 0 {
        y = (y - 1).max(0)
      }
      (area.x, area.y + y)
    }
    Right => {
      let mut y = (area.height - legend_height) / 2
      if y_title_width != 0 {
        y += 1
      }
      if x_title_width != 0 {
        y = (y - 1).max(0)
      }
      (area.right() - legend_width, area.y + y)
    }
    BottomLeft =>
      if x_title_width + legend_width > area.width {
        (area.x, area.bottom() - legend_height - 1)
      } else {
        (area.x, area.bottom() - legend_height)
      }
    BottomRight =>
      if x_title_width != 0 {
        (area.right() - legend_width, area.bottom() - legend_height - 1)
      } else {
        (area.right() - legend_width, area.bottom() - legend_height)
      }
    Bottom => {
      let x = area.x + (area.width - legend_width) / 2
      if x + legend_width > area.right() - x_title_width {
        (x, area.bottom() - legend_height - 1)
      } else {
        (x, area.bottom() - legend_height)
      }
    }
  }
  Some(@core.Rect::new(x, y, legend_width, legend_height))
}

///|
/// 数据集（上游 `Dataset`）：命名后进图例；数据为 (x, y) 世界
/// 坐标点列，Y 轴自下而上喵。
pub struct ChartDataset {
  name : @core.Line?
  data : Array[(Double, Double)]
  marker : @core.Marker
  graph_type : GraphType
  style : @core.Style
  fill_to_y : Double
} derive(Eq, Debug)

///|
/// 缺省数据集（上游 `Dataset::default`）：散点 + 重置样式喵。
pub fn ChartDataset::default() -> ChartDataset {
  {
    name: None,
    data: [],
    marker: @core.Marker::default(),
    graph_type: Scatter,
    style: @core.Style::new(),
    fill_to_y: 0.0,
  }
}

///|
/// 设数据集名（上游 `Dataset::name`）喵。
pub fn ChartDataset::name(
  self : ChartDataset,
  name : @core.Line,
) -> ChartDataset {
  { ..self, name: Some(name) }
}

///|
/// 设字符串数据集名（上游 `Into<Line>` 糖）喵。
pub fn ChartDataset::name_str(
  self : ChartDataset,
  name : String,
) -> ChartDataset {
  { ..self, name: Some(@core.Line::raw(name)) }
}

///|
/// 设数据点列（上游 `Dataset::data`）喵。
pub fn ChartDataset::data(
  self : ChartDataset,
  data : Array[(Double, Double)],
) -> ChartDataset {
  { ..self, data, }
}

///|
/// 设标记（上游 `Dataset::marker`）喵。
pub fn ChartDataset::marker(
  self : ChartDataset,
  marker : @core.Marker,
) -> ChartDataset {
  { ..self, marker, }
}

///|
/// 设图型（上游 `Dataset::graph_type`）喵。
pub fn ChartDataset::graph_type(
  self : ChartDataset,
  graph_type : GraphType,
) -> ChartDataset {
  { ..self, graph_type, }
}

///|
/// 设样式（上游 `Dataset::style`）喵。
pub fn ChartDataset::style(
  self : ChartDataset,
  style : @core.Style,
) -> ChartDataset {
  { ..self, style, }
}

///|
/// 设面积图填充基线（上游 `Dataset::fill_to_y`）喵。
pub fn ChartDataset::fill_to_y(
  self : ChartDataset,
  fill_to_y : Double,
) -> ChartDataset {
  { ..self, fill_to_y, }
}

///|
/// 读取样式（上游 `impl Styled for Dataset`）喵。
pub fn ChartDataset::get_style(self : ChartDataset) -> @core.Style {
  self.style
}

///|
/// 写样式（上游 `Styled::set_style`）喵。
pub fn ChartDataset::set_style(
  self : ChartDataset,
  style : @core.Style,
) -> ChartDataset {
  self.style(style)
}

///|
/// 图表内部布局（上游 `ChartLayout`）：各元素的落位集合喵。
struct ChartLayout {
  title_x : @core.Position?
  title_y : @core.Position?
  label_x : Int?
  label_y : Int?
  axis_x : Int?
  axis_y : Int?
  legend_area : @core.Rect?
  graph_area : @core.Rect
} derive(Debug)

///|
/// 图表组件（上游 `Chart`）喵。
pub struct Chart {
  block : Block?
  x_axis : ChartAxis
  y_axis : ChartAxis
  datasets : Array[ChartDataset]
  style : @core.Style
  hidden_legend_constraints : (@core.Constraint, @core.Constraint)
  legend_position : LegendPosition?
} derive(Eq, Debug)

///|
/// 以数据集建图（上游 `Chart::new`）：缺省隐藏约束为 1/4 比例、
/// 图例右上喵。
pub fn Chart::new(datasets : Array[ChartDataset]) -> Chart {
  {
    block: None,
    x_axis: ChartAxis::default(),
    y_axis: ChartAxis::default(),
    datasets,
    style: @core.Style::new(),
    hidden_legend_constraints: (@core.Ratio(1, 4), @core.Ratio(1, 4)),
    legend_position: Some(LegendPosition::default()),
  }
}

///|
/// 包边框块（上游 `Chart::block`）喵。
pub fn Chart::block(self : Chart, block : Block) -> Chart {
  { ..self, block: Some(block) }
}

///|
/// 设整图样式（上游 `Chart::style`）：轴与数据集样式优先喵。
pub fn Chart::style(self : Chart, style : @core.Style) -> Chart {
  { ..self, style, }
}

///|
/// 设 X 轴（上游 `Chart::x_axis`）喵。
pub fn Chart::x_axis(self : Chart, axis : ChartAxis) -> Chart {
  { ..self, x_axis: axis }
}

///|
/// 设 Y 轴（上游 `Chart::y_axis`）喵。
pub fn Chart::y_axis(self : Chart, axis : ChartAxis) -> Chart {
  { ..self, y_axis: axis }
}

///|
/// 设图例显隐约束（上游 `Chart::hidden_legend_constraints`）：
/// 宽高各一约束，超出即隐藏；`Min` 恒显示喵。
pub fn Chart::hidden_legend_constraints(
  self : Chart,
  constraints : (@core.Constraint, @core.Constraint),
) -> Chart {
  { ..self, hidden_legend_constraints: constraints }
}

///|
/// 设图例位置或隐藏（上游 `Chart::legend_position`）喵。
pub fn Chart::legend_position(
  self : Chart,
  position : LegendPosition?,
) -> Chart {
  { ..self, legend_position: position }
}

///|
/// 读取样式（上游 `impl Styled for Chart`）喵。
pub fn Chart::get_style(self : Chart) -> @core.Style {
  self.style
}

///|
/// 写样式（上游 `Styled::set_style`）喵。
pub fn Chart::set_style(self : Chart, style : @core.Style) -> Chart {
  self.style(style)
}

///|
/// 计算内部布局（上游 `Chart::layout`）：面积过小时整体不渲染，
/// 轴/标签/图例随空间自动隐藏喵。
fn Chart::layout(self : Chart, area : @core.Rect) -> ChartLayout? {
  if area.height == 0 || area.width == 0 {
    return None
  }
  let mut x = area.x
  let mut y = area.bottom() - 1
  let has_y_labels = self.y_axis.labels.length() > 0
  let mut label_x : Int? = None
  if self.x_axis.labels.length() > 0 && y > area.y {
    label_x = Some(y)
    y -= 1
  }
  let label_y : Int? = if has_y_labels { Some(x) } else { None }
  x += self.max_width_of_labels_left_of_y_axis(area, has_y_labels)
  let mut axis_x : Int? = None
  if self.x_axis.labels.length() > 0 && y > area.y {
    axis_x = Some(y)
    y -= 1
  }
  let mut axis_y : Int? = None
  if has_y_labels && x + 1 < area.right() {
    axis_y = Some(x)
    x += 1
  }
  let graph_width = (area.right() - x).max(0)
  let graph_height = (y - area.y).max(0) + 1
  let graph_area = @core.Rect::new(x, area.y, graph_width, graph_height)
  let mut title_x : @core.Position? = None
  match self.x_axis.title {
    Some(title) => {
      let w = title.width()
      if w < graph_area.width && graph_area.height > 2 {
        title_x = Some(@core.Position::new(x + graph_area.width - w, y))
      }
    }
    None => ()
  }
  let mut title_y : @core.Position? = None
  match self.y_axis.title {
    Some(title) => {
      let w = title.width()
      if w + 1 < graph_area.width && graph_area.height > 2 {
        title_y = Some(@core.Position::new(x, area.y))
      }
    }
    None => ()
  }
  let mut legend_area : @core.Rect? = None
  match self.legend_position {
    Some(position) => {
      let widths : Array[Int] = []
      let mut named = 0
      for dataset in self.datasets {
        match dataset.name {
          Some(name) => {
            widths.push(name.width())
            named += 1
          }
          None => ()
        }
      }
      // 无命名数据集不出图例（上游 `legends.max()` 为 None）喵。
      if named > 0 {
        let mut inner_width = widths[0]
        for w in widths {
          if w > inner_width {
            inner_width = w
          }
        }
        let legend_width = inner_width + 2
        let legend_height = named + 2
        let max_legend_width = @layout.Layout::horizontal([
            self.hidden_legend_constraints.0,
          ])
          .flex(@core.Flex::Start)
          .split(graph_area)[0]
        let max_legend_height = @layout.Layout::vertical([
            self.hidden_legend_constraints.1,
          ])
          .flex(@core.Flex::Start)
          .split(graph_area)[0]
        let x_title_width = match title_x {
          Some(_) => self.x_axis.title.unwrap().width()
          None => 0
        }
        let y_title_width = match title_y {
          Some(_) => self.y_axis.title.unwrap().width()
          None => 0
        }
        if inner_width > 0 &&
          legend_width <= max_legend_width.width &&
          legend_height <= max_legend_height.height {
          legend_area = position.place(
            graph_area, legend_width, legend_height, x_title_width, y_title_width,
          )
        }
      }
    }
    None => ()
  }
  Some({
    title_x,
    title_y,
    label_x,
    label_y,
    axis_x,
    axis_y,
    legend_area,
    graph_area,
  })
}

///|
/// Y 轴标签与 X 首标签可占的左缘最大宽（上游
/// `max_width_of_labels_left_of_y_axis`）：至多占整宽三分之一喵。
fn Chart::max_width_of_labels_left_of_y_axis(
  self : Chart,
  area : @core.Rect,
  has_y_axis : Bool,
) -> Int {
  let mut max_width = 0
  for label in self.y_axis.labels {
    let w = label.width()
    if w > max_width {
      max_width = w
    }
  }
  if self.x_axis.labels.length() > 0 {
    let first_x_label = self.x_axis.labels[0]
    let first_label_width = first_x_label.width()
    let width_left_of_y_axis = match self.x_axis.labels_alignment {
      @core.Left =>
        // 首标签末字符应落在 Y 轴之下而非其左喵。
        (first_label_width - (if has_y_axis { 1 } else { 0 })).max(0)
      @core.Center => first_label_width / 2
      @core.Right => 0
    }
    if width_left_of_y_axis > max_width {
      max_width = width_left_of_y_axis
    }
  }
  max_width.min(area.width / 3)
}

///|
/// 渲染 X 轴标签（上游 `render_x_labels`）：首标签按对齐落位、
/// 中间标签居中、末标签右对齐喵。
fn Chart::render_x_labels(
  self : Chart,
  buf : @core.Buffer,
  layout : ChartLayout,
  chart_area : @core.Rect,
  graph_area : @core.Rect,
) -> Unit {
  let y = match layout.label_x {
    Some(y) => y
    None => return
  }
  let labels = self.x_axis.labels
  let labels_len = labels.length()
  if labels_len < 2 {
    return
  }
  let width_between_ticks = graph_area.width / labels_len
  let label_area = self.first_x_label_area(
    y,
    labels[0].width(),
    width_between_ticks,
    chart_area,
    graph_area,
  )
  let label_alignment = match self.x_axis.labels_alignment {
    @core.Left => @core.Right
    @core.Center => @core.Center
    @core.Right => @core.Left
  }
  Chart::render_label(buf, labels[0], label_area, label_alignment)
  for i in 0..<(labels_len - 2) {
    // 中间标签整体右移一格，保证至少一列间隔喵。
    let x = graph_area.x + (i + 1) * width_between_ticks + 1
    let label_area = @core.Rect::new(x, y, (width_between_ticks - 1).max(0), 1)
    Chart::render_label(buf, labels[i + 1], label_area, @core.Center)
  }
  let x = graph_area.right() - width_between_ticks
  let label_area = @core.Rect::new(x, y, width_between_ticks, 1)
  // 末标签右对齐贴住图区右缘喵。
  Chart::render_label(buf, labels[labels_len - 1], label_area, @core.Right)
}

///|
/// 计算 X 首标签的落位矩形（上游 `first_x_label_area`）喵。
fn Chart::first_x_label_area(
  self : Chart,
  y : Int,
  label_width : Int,
  max_width_after_y_axis : Int,
  chart_area : @core.Rect,
  graph_area : @core.Rect,
) -> @core.Rect {
  let (min_x, max_x) = match self.x_axis.labels_alignment {
    @core.Left => (chart_area.x, graph_area.x)
    @core.Center =>
      (chart_area.x, graph_area.x + max_width_after_y_axis.min(label_width))
    @core.Right =>
      ((graph_area.x - 1).max(0), graph_area.x + max_width_after_y_axis)
  }
  @core.Rect::new(min_x, y, max_x - min_x, 1)
}

///|
/// 在标签区域内按对齐写一行（上游 `render_label`）喵。
fn Chart::render_label(
  buf : @core.Buffer,
  label : @core.Line,
  label_area : @core.Rect,
  alignment : @core.Alignment,
) -> Unit {
  let label = match alignment {
    @core.Left => label.left_aligned()
    @core.Center => label.centered()
    @core.Right => label.right_aligned()
  }
  label.render(label_area, buf)
}

///|
/// 渲染 Y 轴标签（上游 `render_y_labels`）：自上而下均匀分布喵。
fn Chart::render_y_labels(
  self : Chart,
  buf : @core.Buffer,
  layout : ChartLayout,
  chart_area : @core.Rect,
  graph_area : @core.Rect,
) -> Unit {
  let x = match layout.label_y {
    Some(x) => x
    None => return
  }
  let labels = self.y_axis.labels
  let labels_len = labels.length()
  if labels_len < 2 {
    return
  }
  for i, label in labels {
    let dy = i * (graph_area.height - 1) / (labels_len - 1)
    if dy < graph_area.bottom() {
      let label_area = @core.Rect::new(
        x,
        (graph_area.bottom() - 1 - dy).max(0),
        (graph_area.x - chart_area.x - 1).max(0),
        1,
      )
      Chart::render_label(buf, label, label_area, self.y_axis.labels_alignment)
    }
  }
}

///|
/// Widget 实现（上游 `impl Widget for Chart`）喵。
pub impl @core.Widget for Chart with fn render(self, area, buf) {
  buf.set_style(area, self.style)
  let chart_area = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  let layout = match self.layout(chart_area) {
    Some(layout) => layout
    None => return
  }
  let graph_area = layout.graph_area
  // 采样整图当前样式，用于复位叠在图上的组件（图例/轴名）喵。
  let original_style = buf.get(area.x, area.y).style()
  self.render_x_labels(buf, layout, chart_area, graph_area)
  self.render_y_labels(buf, layout, chart_area, graph_area)
  match layout.axis_x {
    Some(y) =>
      for x in graph_area.x..<graph_area.right() {
        match buf.mut_cell(x, y) {
          Some(cell) => {
            cell.set_symbol(@core.LINE_HORIZONTAL)
            cell.set_style(self.x_axis.style)
          }
          None => ()
        }
      }
    None => ()
  }
  match layout.axis_y {
    Some(x) =>
      for y in graph_area.y..<graph_area.bottom() {
        match buf.mut_cell(x, y) {
          Some(cell) => {
            cell.set_symbol(@core.LINE_VERTICAL)
            cell.set_style(self.y_axis.style)
          }
          None => ()
        }
      }
    None => ()
  }
  match (layout.axis_x, layout.axis_y) {
    (Some(y), Some(x)) =>
      match buf.mut_cell(x, y) {
        Some(cell) => {
          cell.set_symbol(@core.LINE_BOTTOM_LEFT)
          cell.set_style(self.x_axis.style)
        }
        None => ()
      }
    _ => ()
  }
  Canvas::default()
  .background_color(self.style.bg.unwrap_or(@core.Reset))
  .x_bounds(self.x_axis.bounds)
  .y_bounds(self.y_axis.bounds)
  .paint(ctx => {
    for dataset in self.datasets {
      ctx.marker(dataset.marker)
      let color = dataset.style.fg.unwrap_or(@core.Reset)
      ctx.draw({ coords: dataset.data, color })
      let n = dataset.data.length()
      match dataset.graph_type {
        Line =>
          if n >= 2 {
            for i in 0..<(n - 1) {
              let (x1, y1) = dataset.data[i]
              let (x2, y2) = dataset.data[i + 1]
              ctx.draw(CanvasLine::new(x1, y1, x2, y2, color))
            }
          }
        Bar =>
          for point in dataset.data {
            let (x, y) = point
            ctx.draw(CanvasLine::new(x, 0.0, x, y, color))
          }
        Area =>
          if n >= 2 {
            for i in 0..<(n - 1) {
              let (x1, y1) = dataset.data[i]
              let (x2, y2) = dataset.data[i + 1]
              ctx.draw(
                FilledCanvasLine::new(x1, y1, x2, y2, dataset.fill_to_y, color),
              )
            }
          }
        Scatter => ()
      }
    }
  })
  .render(graph_area, buf)
  match layout.title_x {
    Some(pos) => {
      let title = self.x_axis.title.unwrap()
      let width = (graph_area.right() - pos.x).min(title.width()).max(0)
      buf.set_style(@core.Rect::new(pos.x, pos.y, width, 1), original_style)
      ignore(buf.set_line(pos.x, pos.y, title, width))
    }
    None => ()
  }
  match layout.title_y {
    Some(pos) => {
      let title = self.y_axis.title.unwrap()
      let width = (graph_area.right() - pos.x).min(title.width()).max(0)
      buf.set_style(@core.Rect::new(pos.x, pos.y, width, 1), original_style)
      ignore(buf.set_line(pos.x, pos.y, title, width))
    }
    None => ()
  }
  match layout.legend_area {
    Some(legend_area) => {
      buf.set_style(legend_area, original_style)
      Block::bordered().render(legend_area, buf)
      let mut i = 0
      for dataset in self.datasets {
        match dataset.name {
          Some(name) => {
            let name = name.patch_style(dataset.style)
            name.render(
              @core.Rect::new(
                legend_area.x + 1,
                legend_area.y + 1 + i,
                legend_area.width - 2,
                1,
              ),
              buf,
            )
            i += 1
          }
          None => ()
        }
      }
    }
    None => ()
  }
}
