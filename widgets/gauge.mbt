/// Gauge 家族（上游 `widgets/gauge.rs`）：水平进度条两件套喵。
///
/// - `Gauge`：块状填充进度条，标签居中，可选 unicode 八级半格精度；
/// - `LineGauge`：单行细进度条，标签左置，填充/空置符号与样式独立可配。
///
/// 上游 `percent`/`ratio` 以 `assert!` 拒绝越界输入；本库渲染路径
/// 无 panic（铁律 3），越界一律收敛到合法区间（饱和语义）喵。

///|
/// 块状进度条（上游 `widgets::Gauge`）喵。
pub(all) struct Gauge {
  block : Block?
  ratio : Float
  label : @core.Span?
  use_unicode : Bool
  style : @core.Style
  gauge_style : @core.Style
} derive(Eq, Debug)

///|
/// 缺省构造（上游 `Gauge::default`：无块、ratio 0、无标签、无样式）喵。
pub fn Gauge::default() -> Gauge {
  {
    block: None,
    ratio: 0.0,
    label: None,
    use_unicode: false,
    style: @core.Style::new(),
    gauge_style: @core.Style::new(),
  }
}

///|
/// 按百分比设进度（上游 `Gauge::percent`，0–100 喵）。
///
/// 上游越界断言 panic；本库收敛到 [0, 100] 饱和处理喵。
pub fn Gauge::percent(self : Gauge, percent : Int) -> Gauge {
  let percent = percent.clamp(min=0, max=100)
  { ..self, ratio: Float::from_int(percent) / 100.0 }
}

///|
/// 比率饱和到 [0, 1]（上游 `assert!` 越界 panic 的无 panic 等价）喵。
fn clamp_ratio(ratio : Float) -> Float {
  if ratio < (0.0 : Float) {
    (0.0 : Float)
  } else if ratio > (1.0 : Float) {
    (1.0 : Float)
  } else {
    ratio
  }
}

///|
/// 按比率设进度（上游 `Gauge::ratio`，0.0–1.0 喵）。
///
/// 上游越界断言 panic；本库收敛到 [0, 1] 饱和处理喵。
pub fn Gauge::ratio(self : Gauge, ratio : Float) -> Gauge {
  { ..self, ratio: clamp_ratio(ratio) }
}

///|
/// 包边框块（上游 `Gauge::block`：仪表渲染于块内区，块样式不波及进度条）喵。
pub fn Gauge::block(self : Gauge, block : Block) -> Gauge {
  { ..self, block: Some(block) }
}

///|
/// 设居中标签（上游 `Gauge::label`；缺省为填充百分比喵）。
pub fn Gauge::label(self : Gauge, label : @core.Span) -> Gauge {
  { ..self, label: Some(label) }
}

///|
/// 设居中标签字符串（上游 `label` 的 `Into<Span>` 形态）喵。
pub fn Gauge::label_str(self : Gauge, label : String) -> Gauge {
  self.label(@core.Span::raw(label))
}

///|
/// 设组件基础样式（上游 `Gauge::style`：作用于块与非填充背景喵）。
pub fn Gauge::style(self : Gauge, style : @core.Style) -> Gauge {
  { ..self, style, }
}

///|
/// 设进度条样式（上游 `Gauge::gauge_style`：填充区前景/背景喵）。
pub fn Gauge::gauge_style(self : Gauge, style : @core.Style) -> Gauge {
  { ..self, gauge_style: style }
}

///|
/// 开关 unicode 半格精度（上游 `Gauge::use_unicode`：末格八分档喵）。
pub fn Gauge::use_unicode(self : Gauge, unicode : Bool) -> Gauge {
  { ..self, use_unicode: unicode }
}

///|
/// 渲染仪表盘（上游 `Widget for &Gauge`）喵。
pub impl @core.Widget for Gauge with fn render(
  self : Gauge,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  buf.set_style(area, self.style)
  let gauge_area = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  self.render_gauge(gauge_area, buf)
}

///|
/// 按比率填充并居中写标签（包私有，上游 `Gauge::render_gauge`）喵。
///
/// 填充至 `end` 列；标签覆盖区间以"空格 + 前/背景互换"呈现被标签
/// 遮挡的填充段（注意上游判据是 `x > label_col + width`，覆盖区间
/// 比标签宽一格，为一比一保留的语义）喵。
fn Gauge::render_gauge(
  self : Gauge,
  gauge_area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  if gauge_area.is_empty() {
    return
  }
  buf.set_style(gauge_area, self.gauge_style)
  // 标签缺省为填充百分比（上游 `f64::round`：半远离零取整）喵。
  let default_label = @core.Span::raw(
    "\{(self.ratio * 100.0).round().to_int()}%",
  )
  let label = match self.label {
    Some(l) => l
    None => default_label
  }
  let clamped_label_width = gauge_area.width.min(label.width())
  let label_col = gauge_area.left() +
    (gauge_area.width - clamped_label_width) / 2
  let label_row = gauge_area.top() + gauge_area.height / 2
  // unicode 走 floor + 半格符号，非 unicode 走 round（上游一致）喵。
  let filled_width = Float::from_int(gauge_area.width) * self.ratio
  let end = gauge_area.left() +
    (if self.use_unicode {
      filled_width.floor().to_int()
    } else {
      filled_width.round().to_int()
    })
  let filled_fg = match self.gauge_style.fg {
    Some(c) => c
    None => @core.Reset
  }
  let filled_bg = match self.gauge_style.bg {
    Some(c) => c
    None => @core.Reset
  }
  for y in gauge_area.top()..<gauge_area.bottom() {
    // 填充段：标签行覆盖区间写空格并互换前/背景，其余写满格块喵。
    for x in gauge_area.left()..<end {
      match buf.mut_cell(x, y) {
        Some(cell) =>
          if x < label_col ||
            x > label_col + clamped_label_width ||
            y != label_row {
            cell.set_symbol(@core.BLOCK_FULL)
            cell.set_fg(filled_fg)
            cell.set_bg(filled_bg)
          } else {
            cell.set_symbol(" ")
            cell.set_fg(filled_bg)
            cell.set_bg(filled_fg)
          }
        None => ()
      }
    }
    if self.use_unicode && self.ratio < 1.0 {
      // 末格半块符号：`filled_width % 1.0` 的非负等价式喵。
      match buf.mut_cell(end, y) {
        Some(cell) =>
          cell.set_symbol(
            get_unicode_block(filled_width - filled_width.floor()),
          )
        None => ()
      }
    }
  }
  // 标签最后写：以 span 样式 patch 进既有单元格（缺省样式不改色）喵。
  ignore(buf.set_span(label_col, label_row, label, clamped_label_width))
}

///|
/// 半格分数转填充块符号（上游 `get_unicode_block`：`frac × 8` 四舍五入
/// 取档，0 与越档回退空格）喵。
fn get_unicode_block(frac : Float) -> String {
  match (frac * 8.0).round().to_int() {
    1 => @core.BLOCK_ONE_EIGHTH
    2 => @core.BLOCK_ONE_QUARTER
    3 => @core.BLOCK_THREE_EIGHTHS
    4 => @core.BLOCK_HALF
    5 => @core.BLOCK_FIVE_EIGHTHS
    6 => @core.BLOCK_THREE_QUARTERS
    7 => @core.BLOCK_SEVEN_EIGHTHS
    8 => @core.BLOCK_FULL
    _ => " "
  }
}

///|
/// 单行细进度条（上游 `widgets::LineGauge`）喵。
pub(all) struct LineGauge {
  block : Block?
  ratio : Float
  label : @core.Line?
  style : @core.Style
  filled_symbol : String
  unfilled_symbol : String
  filled_style : @core.Style
  unfilled_style : @core.Style
} derive(Eq, Debug)

///|
/// 缺省构造（上游 `LineGauge::default`：填充/空置均为单横线 `─`）喵。
pub fn LineGauge::default() -> LineGauge {
  {
    block: None,
    ratio: 0.0,
    label: None,
    style: @core.Style::new(),
    filled_symbol: @core.LINE_HORIZONTAL,
    unfilled_symbol: @core.LINE_HORIZONTAL,
    filled_style: @core.Style::new(),
    unfilled_style: @core.Style::new(),
  }
}

///|
/// 包边框块（上游 `LineGauge::block`）喵。
pub fn LineGauge::block(self : LineGauge, block : Block) -> LineGauge {
  { ..self, block: Some(block) }
}

///|
/// 按比率设进度（上游 `LineGauge::ratio`，0.0–1.0 喵）。
///
/// 上游越界断言 panic；本库收敛到 [0, 1] 饱和处理喵。
pub fn LineGauge::ratio(self : LineGauge, ratio : Float) -> LineGauge {
  { ..self, ratio: clamp_ratio(ratio) }
}

///|
/// 设填充段符号（上游 `LineGauge::filled_symbol`）喵。
pub fn LineGauge::filled_symbol(self : LineGauge, symbol : String) -> LineGauge {
  { ..self, filled_symbol: symbol }
}

///|
/// 设空置段符号（上游 `LineGauge::unfilled_symbol`）喵。
pub fn LineGauge::unfilled_symbol(
  self : LineGauge,
  symbol : String,
) -> LineGauge {
  { ..self, unfilled_symbol: symbol }
}

///|
/// 设左置标签（上游 `LineGauge::label`；缺省为右对齐三格百分比喵）。
pub fn LineGauge::label(self : LineGauge, label : @core.Line) -> LineGauge {
  { ..self, label: Some(label) }
}

///|
/// 设左置标签字符串（上游 `label` 的 `Into<Line>` 形态）喵。
pub fn LineGauge::label_str(self : LineGauge, label : String) -> LineGauge {
  self.label(@core.Line::raw(label))
}

///|
/// 设组件基础样式（上游 `LineGauge::style`：作用于块与非进度条背景喵）。
pub fn LineGauge::style(self : LineGauge, style : @core.Style) -> LineGauge {
  { ..self, style, }
}

///|
/// 设填充段样式（上游 `LineGauge::filled_style`）喵。
pub fn LineGauge::filled_style(
  self : LineGauge,
  style : @core.Style,
) -> LineGauge {
  { ..self, filled_style: style }
}

///|
/// 设空置段样式（上游 `LineGauge::unfilled_style`）喵。
pub fn LineGauge::unfilled_style(
  self : LineGauge,
  style : @core.Style,
) -> LineGauge {
  { ..self, unfilled_style: style }
}

///|
/// 渲染单行进度条（上游 `Widget for &LineGauge`）喵。
pub impl @core.Widget for LineGauge with fn render(
  self : LineGauge,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  buf.set_style(area, self.style)
  let gauge_area = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  if gauge_area.is_empty() {
    return
  }
  let default_label = @core.Line::raw(line_gauge_default_label(self.ratio))
  let label = match self.label {
    Some(l) => l
    None => default_label
  }
  let (col, row) = buf.set_line(
    gauge_area.left(),
    gauge_area.top(),
    label,
    gauge_area.width,
  )
  let start = col + 1
  if start >= gauge_area.right() {
    return
  }
  let remaining = Float::from_int(gauge_area.right() - start) * self.ratio
  let end = start + remaining.floor().to_int()
  for x in start..<end {
    match buf.mut_cell(x, row) {
      Some(cell) => {
        cell.set_symbol(self.filled_symbol)
        cell.set_style(self.filled_style)
      }
      None => ()
    }
  }
  for x in end..<gauge_area.right() {
    match buf.mut_cell(x, row) {
      Some(cell) => {
        cell.set_symbol(self.unfilled_symbol)
        cell.set_style(self.unfilled_style)
      }
      None => ()
    }
  }
}

///|
/// 缺省标签：整数百分比右对齐三格（上游 `format!("{:3.0}%", …)`）喵。
///
/// Rust 显示格式化的 `.0` 精度按"半偶舍入"取整（`12.5 → "12"`），
/// 与 `f64::round` 的半远离零不同，此处一比一保留喵。
fn line_gauge_default_label(ratio : Float) -> String {
  let n = line_gauge_percent_int(ratio * 100.0)
  let s = n.to_string()
  let padded = if s.length() >= 3 {
    s
  } else if s.length() == 2 {
    " \{s}"
  } else {
    "  \{s}"
  }
  "\{padded}%"
}

///|
/// 半偶舍入到整数（Rust `{:.0}` 显示语义：恰为 .5 时取偶数档）喵。
fn line_gauge_percent_int(pct : Float) -> Int {
  let trunced = pct.trunc()
  if pct - trunced == 0.5 {
    let t = trunced.to_int()
    if t % 2 == 0 {
      t
    } else {
      t + 1
    }
  } else {
    pct.round().to_int()
  }
}
