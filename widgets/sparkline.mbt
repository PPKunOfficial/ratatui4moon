/// Sparkline（上游 `widgets/sparkline.rs`）：多行底对齐波形图喵。
///
/// 每根柱由数据集一项驱动，高度按 `value/max` 缩放到区域行数
/// （8 tick/行），缺值项以独立符号与样式呈现"无数据"（区别于 0）喵。

///|
/// 渲染方向（上游 `RenderDirection`）喵。
pub(all) enum RenderDirection {
  LeftToRight
  RightToLeft
} derive(Eq, Debug)

///|
/// 转显示名（上游 `Display`）喵。
pub fn RenderDirection::to_display(self : RenderDirection) -> String {
  match self {
    LeftToRight => "LeftToRight"
    RightToLeft => "RightToLeft"
  }
}

///|
/// 从变体名解析方向（上游 `FromStr`，大小写敏感）喵。
pub fn RenderDirection::from_str(s : String) -> RenderDirection? {
  match s {
    "LeftToRight" => Some(LeftToRight)
    "RightToLeft" => Some(RightToLeft)
    _ => None
  }
}

///|
/// 波形图（上游 `widgets::Sparkline`）喵。
pub(all) struct Sparkline {
  block : Block?
  style : @core.Style
  absent_value_style : @core.Style
  absent_value_symbol : String
  data : Array[SparklineBar]
  max : UInt64?
  bar_set : @core.BarSet
  direction : RenderDirection
} derive(Eq, Debug)

///|
/// 缺省构造（上游 `Sparkline::default`：九级 bar 集合、缺值符号为
/// 空格 `shade::EMPTY`、左到右渲染）喵。
pub fn Sparkline::default() -> Sparkline {
  {
    block: None,
    style: @core.Style::new(),
    absent_value_style: @core.Style::new(),
    absent_value_symbol: @core.SHADE_EMPTY,
    data: [],
    max: None,
    bar_set: @core.BarSet::nine_levels(),
    direction: LeftToRight,
  }
}

///|
/// 包边框块（上游 `Sparkline::block`：波形渲染于块内区）喵。
pub fn Sparkline::block(self : Sparkline, block : Block) -> Sparkline {
  { ..self, block: Some(block) }
}

///|
/// 设组件样式（上游 `Sparkline::style`：柱体取其前景，其余取背景）喵。
pub fn Sparkline::style(self : Sparkline, style : @core.Style) -> Sparkline {
  { ..self, style, }
}

///|
/// 设缺值样式（上游 `Sparkline::absent_value_style`）喵。
pub fn Sparkline::absent_value_style(
  self : Sparkline,
  style : @core.Style,
) -> Sparkline {
  { ..self, absent_value_style: style }
}

///|
/// 设缺值符号（上游 `Sparkline::absent_value_symbol`）喵。
pub fn Sparkline::absent_value_symbol(
  self : Sparkline,
  symbol : String,
) -> Sparkline {
  { ..self, absent_value_symbol: symbol }
}

///|
/// 设数据集（上游 `Sparkline::data` 的 `u64` 序列形态）喵。
pub fn Sparkline::data(self : Sparkline, data : Array[UInt64]) -> Sparkline {
  let bars : Array[SparklineBar] = []
  for value in data {
    bars.push(SparklineBar::of(value))
  }
  { ..self, data: bars }
}

///|
/// 设数据集（上游 `data` 的 `Option<u64>` 序列形态：`None` 为缺值）喵。
pub fn Sparkline::data_of_option(
  self : Sparkline,
  data : Array[UInt64?],
) -> Sparkline {
  let bars : Array[SparklineBar] = []
  for value in data {
    bars.push(SparklineBar::of_opt(value))
  }
  { ..self, data: bars }
}

///|
/// 设数据集（上游 `data` 的 `SparklineBar` 序列形态：柱可带样式）喵。
pub fn Sparkline::data_of_bars(
  self : Sparkline,
  data : Array[SparklineBar],
) -> Sparkline {
  { ..self, data, }
}

///|
/// 设柱高上限（上游 `Sparkline::max`；缺省取数据集最大值）喵。
pub fn Sparkline::max(self : Sparkline, max : UInt64) -> Sparkline {
  { ..self, max: Some(max) }
}

///|
/// 设柱体符号集（上游 `Sparkline::bar_set`）喵。
pub fn Sparkline::bar_set(
  self : Sparkline,
  bar_set : @core.BarSet,
) -> Sparkline {
  { ..self, bar_set, }
}

///|
/// 设渲染方向（上游 `Sparkline::direction`）喵。
pub fn Sparkline::direction(
  self : Sparkline,
  direction : RenderDirection,
) -> Sparkline {
  { ..self, direction, }
}

///|
/// 单根柱（上游 `SparklineBar`）：`value` 为 `None` 表示缺值，
/// 区别于 `Some(0)` 的零值柱喵。
pub(all) struct SparklineBar {
  value : UInt64?
  style : @core.Style?
} derive(Eq, Debug)

///|
/// 从数值构造（上游 `From<u64>`）喵。
pub fn SparklineBar::of(value : UInt64) -> SparklineBar {
  { value: Some(value), style: None }
}

///|
/// 从可选值构造（上游 `From<Option<u64>>`：`None` 即缺值柱）喵。
pub fn SparklineBar::of_opt(value : UInt64?) -> SparklineBar {
  { value, style: None }
}

///|
/// 设柱样式（上游 `SparklineBar::style`：与波形图样式 patch 叠加）喵。
pub fn SparklineBar::style(
  self : SparklineBar,
  style : @core.Style,
) -> SparklineBar {
  { ..self, style: Some(style) }
}

///|
/// 渲染波形（上游 `Widget for &Sparkline`：块内区，样式逐柱 patch）喵。
pub impl @core.Widget for Sparkline with fn render(
  self : Sparkline,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let inner = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  self.render_sparkline(inner, buf)
}

///|
/// 按方向逐柱自底向上填充（包私有，上游 `render_sparkline`）喵。
fn Sparkline::render_sparkline(
  self : Sparkline,
  spark_area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  if spark_area.is_empty() {
    return
  }
  // 柱高上限：显式 max 优先，否则取数据集最大值，空集回退 1 喵。
  let max_height : UInt64 = match self.max {
    Some(m) => m
    None => {
      let mut max_v : UInt64? = None
      for bar in self.data {
        match bar.value {
          Some(v) =>
            max_v = match max_v {
              Some(m) => Some(if v > m { v } else { m })
              None => Some(v)
            }
          None => ()
        }
      }
      match max_v {
        Some(m) => m
        None => 1UL
      }
    }
  }
  let max_index = if spark_area.width < self.data.length() {
    spark_area.width
  } else {
    self.data.length()
  }
  for i in 0..<max_index {
    let item = self.data[i]
    let x = match self.direction {
      LeftToRight => spark_area.left() + i
      RightToLeft => spark_area.right() - i - 1
    }
    // 缺值柱：全高 ticks + 缺值符号/样式；数值柱：缩放高度、样式随柱喵。
    let (initial_height, symbol, bar_style) : (UInt64, String?, @core.Style?) = match
      item.value {
      Some(v) =>
        (scale_height(v, max_height, spark_area.height), None, item.style)
      None =>
        (
          spark_area.height.to_uint64() * 8UL,
          Some(self.absent_value_symbol),
          Some(self.absent_value_style),
        )
    }
    let mut height = initial_height
    // 自底向上逐行写入；符号未定则按剩余高度取档喵。
    for t in 0..<spark_area.height {
      let j = spark_area.height - 1 - t
      let symbol = match symbol {
        Some(s) => s
        None => self.symbol_for_height(height)
      }
      if height > 8UL {
        height = height - 8UL
      } else {
        height = 0UL
      }
      match buf.mut_cell(x, spark_area.top() + j) {
        Some(cell) => {
          cell.set_symbol(symbol)
          cell.set_style(
            self.style.patch(
              match bar_style {
                Some(s) => s
                None => @core.Style::new()
              },
            ),
          )
        }
        None => ()
      }
    }
  }
}

///|
/// 剩余高度 tick 转填充档符号（上游 `symbol_for_height`：0–7 分档，
/// 8 及以上满格）喵。
fn Sparkline::symbol_for_height(self : Sparkline, height : UInt64) -> String {
  let set = self.bar_set
  match height {
    0UL => set.empty
    1UL => set.one_eighth
    2UL => set.one_quarter
    3UL => set.three_eighths
    4UL => set.half
    5UL => set.five_eighths
    6UL => set.three_quarters
    7UL => set.seven_eighths
    _ => set.full
  }
}

///|
/// 按比例缩放柱高（上游 `scale_height`：`floor(value × max_ticks / max)`，
/// tick 上限 `max_height × 8`）喵。
///
/// 上游以 u128 承载中间乘积；MoonBit 无 UInt128，此处用 32 位半乘法
/// 拼出 128 位乘积后做逐位长除，全 u64 域精确（u64::MAX 用例佐证），
/// 绝不用浮点近似喵。
fn scale_height(value : UInt64, max : UInt64, max_height : Int) -> UInt64 {
  if max == 0UL {
    return 0UL
  }
  let max_ticks = (max_height * 8).to_uint64()
  // value ≥ max 时商已 ≥ max_ticks：直接饱和（同时规避商超 64 位）喵。
  if value >= max {
    return max_ticks
  }
  // value < max：商 < max_ticks ≤ 2^20。N = value × max_ticks ≤ 2^84，
  // 32 位半乘法展开后重拼成 64 位对齐的 128 位寄存器 hi:lo 喵。
  let m = max_ticks
  let vh = value >> 32
  let vl = value & 0xFFFFFFFFUL
  let p_low = vl * m
  let p_high = vh * m
  // N = p_high×2^32 + p_low = H×2^32 + L（L < 2^32，H < 2^53）
  let big_h = p_high + (p_low >> 32)
  let big_l = p_low & 0xFFFFFFFFUL
  let hi = big_h >> 32
  let lo = ((big_h & 0xFFFFFFFFUL) << 32) | big_l
  // 128/64 逐位长除：先 65 位溢出以进位标记承载，一次条件减法收位喵。
  let mut q : UInt64 = 0UL
  let mut r : UInt64 = 0UL
  for t in 0..<128 {
    let i = 127 - t
    let bit = (if i >= 64 { hi >> (i - 64) } else { lo >> i }) & 1UL
    let carry = r >> 63
    r = (r << 1) | bit
    q = q << 1
    if carry != 0UL || r >= max {
      r = r - max
      q = q | 1UL
    }
  }
  q
}
