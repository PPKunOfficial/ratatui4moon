/// BarChart 家族（上游 `widgets/barchart.rs` + `barchart/{bar,bar_group}.rs`）：
/// 纵/横双向柱状图，柱可带标签、值文本与独立样式，支持分组与组间距喵。

///|
/// 单根柱（上游 `barchart::Bar`）：`value` 为柱高数据；`text_value`
/// 可替换柱内显示文本（如 CJK、单位后缀）喵。
pub(all) struct Bar {
  value : UInt64
  label : @core.Line?
  style : @core.Style
  value_style : @core.Style
  text_value : String?
} derive(Eq, Debug)

///|
/// 以数值构造（上游 `Bar::new`）喵。
pub fn Bar::new(value : UInt64) -> Bar {
  {
    value,
    label: None,
    style: @core.Style::new(),
    value_style: @core.Style::new(),
    text_value: None,
  }
}

///|
/// 缺省构造（上游 `Bar::default`：value 0）喵。
pub fn Bar::default() -> Bar {
  Bar::new(0UL)
}

///|
/// 以标签与数值构造（上游 `Bar::with_label`）喵。
pub fn Bar::with_label(label : @core.Line, value : UInt64) -> Bar {
  { ..Bar::new(value), label: Some(label) }
}

///|
/// 以字符串标签与数值构造（上游 `with_label` 的 `Into<Line>` 形态）喵。
pub fn Bar::with_label_str(label : String, value : UInt64) -> Bar {
  Bar::with_label(@core.Line::raw(label), value)
}

///|
/// 设数值（上游 `Bar::value`）喵。
pub fn Bar::value(self : Bar, value : UInt64) -> Bar {
  { ..self, value, }
}

///|
/// 设标签（上游 `Bar::label`：纵柱打印在柱下、横柱打印在柱内）喵。
pub fn Bar::label(self : Bar, label : @core.Line) -> Bar {
  { ..self, label: Some(label) }
}

///|
/// 设字符串标签（上游 `label` 的 `Into<Line>` 形态）喵。
pub fn Bar::label_str(self : Bar, label : String) -> Bar {
  self.label(@core.Line::raw(label))
}

///|
/// 设柱样式（上游 `Bar::style`：作未显式样式元素的缺省值）喵。
pub fn Bar::style(self : Bar, style : @core.Style) -> Bar {
  { ..self, style, }
}

///|
/// 设值样式（上游 `Bar::value_style`）喵。
pub fn Bar::value_style(self : Bar, style : @core.Style) -> Bar {
  { ..self, value_style: style }
}

///|
/// 设柱内显示文本（上游 `Bar::text_value`；缺省为数值本身）喵。
pub fn Bar::text_value(self : Bar, text_value : String) -> Bar {
  { ..self, text_value: Some(text_value) }
}

///|
/// 渲染柱内值文本（包私有，上游 `render_value_with_different_styles`）：
/// 值文本可能长于柱体——柱内部分用值样式、溢出部分用柱样式分两段
/// 写入喵。
///
/// 上游按 UTF-8 字节边界切分（`char_indices` + `str::len`），此处以
/// `to_bytes().length()` 精确对齐字节语义喵。
fn Bar::render_value_with_different_styles(
  self : Bar,
  buf : @core.Buffer,
  area : @core.Rect,
  bar_length : Int,
  default_value_style : @core.Style,
  bar_style : @core.Style,
) -> Unit {
  let value_str = self.value.to_string()
  let text = match self.text_value {
    Some(t) => t
    None => value_str
  }
  if text.is_empty() {
    return
  }
  let style = default_value_style.patch(self.value_style)
  // 柱内段：以值样式写，最多 bar_length 列喵。
  ignore(buf.set_stringn(area.x, area.y, text, bar_length, style))
  let text_bytes = utf8_byte_length(text)
  if text_bytes > bar_length {
    // 溢出段：以柱样式续写剩余字符喵。
    let (first, second) = split_at_byte_boundary(text, bar_length)
    let style = bar_style.patch(self.style)
    ignore(
      buf.set_stringn(
        area.x + utf8_byte_length(first),
        area.y,
        second,
        area.width - utf8_byte_length(first),
        style,
      ),
    )
  }
}

///|
/// 渲染柱值（包私有，上游 `Bar::render_value`）：值 0 不显示；宽度
/// 放不下时不显示（值恰好占满一格需 ticks ≥ 8）喵。
fn Bar::render_value(
  self : Bar,
  buf : @core.Buffer,
  max_width : Int,
  x : Int,
  y : Int,
  default_value_style : @core.Style,
  ticks : UInt64,
) -> Unit {
  if self.value != 0UL {
    let value_str = self.value.to_string()
    let value_label = match self.text_value {
      Some(t) => t
      None => value_str
    }
    let width = @core.symbol_width(value_label)
    if width < max_width || (width == max_width && ticks >= 8UL) {
      // 居中偏移对齐上游 `.len()`（UTF-8 字节数）语义喵。
      let len = utf8_byte_length(value_label)
      let offset = if len > max_width { 0 } else { (max_width - len) >> 1 }
      ignore(
        buf.set_string(
          x + offset,
          y,
          value_label,
          default_value_style.patch(self.value_style),
        ),
      )
    }
  }
}

///|
/// 渲染柱标签（包私有，上游 `Bar::render_label`）：在 `max_width` 内
/// 居中；先对标签子区域染标签样式再渲染行喵。
fn Bar::render_label(
  self : Bar,
  buf : @core.Buffer,
  max_width : Int,
  x : Int,
  y : Int,
  default_label_style : @core.Style,
) -> Unit {
  let width = match self.label {
    Some(l) => {
      let w = l.width()
      if w > max_width {
        max_width
      } else {
        w
      }
    }
    None => 0
  }
  let area = @core.Rect::new(x + (max_width - width) / 2, y, width, 1)
  buf.set_style(area, default_label_style)
  match self.label {
    Some(label) => label.render(area, buf)
    None => ()
  }
}

///|
/// 柱组（上游 `barchart::BarGroup`）：组标签打印在组柱下方（可对齐）喵。
pub(all) struct BarGroup {
  label : @core.Line?
  bars : Array[Bar]
} derive(Eq, Debug)

///|
/// 以柱序列构造（上游 `BarGroup::new`）喵。
pub fn BarGroup::new(bars : Array[Bar]) -> BarGroup {
  { label: None, bars }
}

///|
/// 缺省构造（上游 `BarGroup::default`）喵。
pub fn BarGroup::default() -> BarGroup {
  BarGroup::new([])
}

///|
/// 以 (标签, 数值) 对序列构造（上游 `From<&[(&str, u64)]>`：每对生成
/// 带标签的柱）喵。
pub fn BarGroup::of_pairs(pairs : Array[(String, UInt64)]) -> BarGroup {
  let bars : Array[Bar] = []
  for pair in pairs {
    bars.push(Bar::with_label_str(pair.0, pair.1))
  }
  { label: None, bars }
}

///|
/// 以标签与柱序列构造（上游 `BarGroup::with_label`）喵。
pub fn BarGroup::with_label(label : @core.Line, bars : Array[Bar]) -> BarGroup {
  { label: Some(label), bars }
}

///|
/// 以字符串标签与柱序列构造（上游 `with_label` 的 `Into<Line>` 形态）喵。
pub fn BarGroup::with_label_str(label : String, bars : Array[Bar]) -> BarGroup {
  BarGroup::with_label(@core.Line::raw(label), bars)
}

///|
/// 设组标签（上游 `BarGroup::label`）喵。
pub fn BarGroup::label(self : BarGroup, label : @core.Line) -> BarGroup {
  { ..self, label: Some(label) }
}

///|
/// 设字符串组标签（上游 `label` 的 `Into<Line>` 形态）喵。
pub fn BarGroup::label_str(self : BarGroup, label : String) -> BarGroup {
  self.label(@core.Line::raw(label))
}

///|
/// 设柱序列（上游 `BarGroup::bars`）喵。
pub fn BarGroup::bars(self : BarGroup, bars : Array[Bar]) -> BarGroup {
  { ..self, bars, }
}

///|
/// 组内最大柱值（包私有，上游 `BarGroup::max`）喵。
fn BarGroup::max_value(self : BarGroup) -> UInt64? {
  let mut max : UInt64? = None
  for bar in self.bars {
    match max {
      Some(m) => if bar.value > m { max = Some(bar.value) }
      None => max = Some(bar.value)
    }
  }
  max
}

///|
/// 渲染组标签（包私有，上游 `BarGroup::render_label`）：按行自带
/// 对齐（居中/右）在给定区域内缩进，先染样式再渲染行喵。
fn BarGroup::render_label(
  self : BarGroup,
  buf : @core.Buffer,
  area : @core.Rect,
  default_label_style : @core.Style,
) -> Unit {
  match self.label {
    Some(label) => {
      let width = label.width()
      let x = match label.alignment {
        Some(@core.Center) => {
          let slack = if area.width > width { area.width - width } else { 0 }
          area.x + slack / 2
        }
        Some(@core.Right) => {
          let slack = if area.width > width { area.width - width } else { 0 }
          area.x + slack
        }
        _ => area.x
      }
      let area = @core.Rect::new(x, area.y, width, area.height)
      buf.set_style(area, default_label_style)
      label.render(area, buf)
    }
    None => ()
  }
}

///|
/// 柱状图（上游 `widgets::BarChart`）喵。
pub(all) struct BarChart {
  block : Block?
  bar_width : Int
  bar_gap : Int
  group_gap : Int
  bar_set : @core.BarSet
  bar_style : @core.Style
  value_style : @core.Style
  label_style : @core.Style
  style : @core.Style
  data : Array[BarGroup]
  max : UInt64?
  direction : @core.Direction
} derive(Eq, Debug)

///|
/// 缺省构造（上游 `BarChart::default`：柱宽/柱距 1、组距 0、九级
/// 符号集、纵柱）喵。
pub fn BarChart::default() -> BarChart {
  {
    block: None,
    bar_width: 1,
    bar_gap: 1,
    group_gap: 0,
    bar_set: @core.BarSet::nine_levels(),
    bar_style: @core.Style::new(),
    value_style: @core.Style::new(),
    label_style: @core.Style::new(),
    style: @core.Style::new(),
    data: [],
    max: None,
    direction: @core.Vertical,
  }
}

///|
/// 以柱序列构造纵向柱状图（上游 `BarChart::new`/`vertical`）喵。
pub fn BarChart::of_bars(bars : Array[Bar]) -> BarChart {
  {
    ..BarChart::default(),
    data: BarChart::non_empty_groups([BarGroup::new(bars)]),
  }
}

///|
/// 以柱序列构造横向柱状图（上游 `BarChart::horizontal`）喵。
pub fn BarChart::horizontal(bars : Array[Bar]) -> BarChart {
  { ..BarChart::of_bars(bars), direction: @core.Horizontal }
}

///|
/// 以柱组序列构造分组柱状图（上游 `BarChart::grouped`）喵。
pub fn BarChart::grouped(groups : Array[BarGroup]) -> BarChart {
  { ..BarChart::default(), data: BarChart::non_empty_groups(groups) }
}

///|
/// 过滤空柱组（包私有，上游 `non_empty_groups`）喵。
fn BarChart::non_empty_groups(groups : Array[BarGroup]) -> Array[BarGroup] {
  let out : Array[BarGroup] = []
  for group in groups {
    if !group.bars.is_empty() {
      out.push(group)
    }
  }
  out
}

///|
/// 追加柱组（上游 `BarChart::data`；空组忽略）喵。
pub fn BarChart::data(self : BarChart, group : BarGroup) -> BarChart {
  if !group.bars.is_empty() {
    let data = self.data.copy()
    data.push(group)
    return { ..self, data, }
  }
  self
}

///|
/// 以 (标签, 数值) 对追加柱组（上游 `data` 的 `(&str, u64)` 切片形态）喵。
pub fn BarChart::data_pairs(
  self : BarChart,
  pairs : Array[(String, UInt64)],
) -> BarChart {
  self.data(BarGroup::of_pairs(pairs))
}

///|
/// 包边框块（上游 `BarChart::block`）喵。
pub fn BarChart::block(self : BarChart, block : Block) -> BarChart {
  { ..self, block: Some(block) }
}

///|
/// 设柱高上限值（上游 `BarChart::max`；缺省取数据集最大值）喵。
pub fn BarChart::max(self : BarChart, max : UInt64) -> BarChart {
  { ..self, max: Some(max) }
}

///|
/// 设柱缺省样式（上游 `BarChart::bar_style`：被逐柱样式 patch）喵。
pub fn BarChart::bar_style(self : BarChart, style : @core.Style) -> BarChart {
  { ..self, bar_style: style }
}

///|
/// 设柱宽（上游 `BarChart::bar_width`：横柱即高度；标签同宽）喵。
pub fn BarChart::bar_width(self : BarChart, width : Int) -> BarChart {
  { ..self, bar_width: width }
}

///|
/// 设柱间距（上游 `BarChart::bar_gap`：标签不会越过柱身借用间距）喵。
pub fn BarChart::bar_gap(self : BarChart, gap : Int) -> BarChart {
  { ..self, bar_gap: gap }
}

///|
/// 设柱符号集（上游 `BarChart::bar_set`）喵。
pub fn BarChart::bar_set(self : BarChart, bar_set : @core.BarSet) -> BarChart {
  { ..self, bar_set, }
}

///|
/// 设值缺省样式（上游 `BarChart::value_style`）喵。
pub fn BarChart::value_style(self : BarChart, style : @core.Style) -> BarChart {
  { ..self, value_style: style }
}

///|
/// 设标签缺省样式（上游 `BarChart::label_style`）喵。
pub fn BarChart::label_style(self : BarChart, style : @core.Style) -> BarChart {
  { ..self, label_style: style }
}

///|
/// 设组间距（上游 `BarChart::group_gap`）喵。
pub fn BarChart::group_gap(self : BarChart, gap : Int) -> BarChart {
  { ..self, group_gap: gap }
}

///|
/// 设整图样式（上游 `BarChart::style`：作用于一切未显式样式元素）喵。
pub fn BarChart::style(self : BarChart, style : @core.Style) -> BarChart {
  { ..self, style, }
}

///|
/// 设柱方向（上游 `BarChart::direction`）喵。
pub fn BarChart::direction(
  self : BarChart,
  direction : @core.Direction,
) -> BarChart {
  { ..self, direction, }
}

///|
/// 渲染柱状图（上游 `Widget for &BarChart`：空区/空数据/零柱宽
/// 直接跳过）喵。
pub impl @core.Widget for BarChart with fn render(
  self : BarChart,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  buf.set_style(area, self.style)
  let inner = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  if inner.is_empty() || self.data.is_empty() || self.bar_width == 0 {
    return
  }
  match self.direction {
    @core.Horizontal => self.render_horizontal(buf, inner)
    @core.Vertical => self.render_vertical(buf, inner)
  }
}

///|
/// 可见柱的 tick 序列（包私有，上游 `group_ticks`）：一格 8 tick，
/// 空间不足时截断组内柱数喵。
fn BarChart::group_ticks(
  self : BarChart,
  available_space : Int,
  bar_max_length : Int,
) -> Array[Array[UInt64]] {
  let max = self.maximum_data_value()
  let out : Array[Array[UInt64]] = []
  let mut space = available_space
  for group in self.data {
    if space == 0 {
      break
    }
    let n_bars = group.bars.length()
    let prev_gap = if n_bars > 0 { n_bars - 1 } else { 0 }
    let group_width = n_bars * self.bar_width + prev_gap * self.bar_gap
    let taken : Int = if space > group_width {
      let rest = space - group_width - self.group_gap - self.bar_gap
      space = if rest > 0 { rest } else { 0 }
      n_bars
    } else {
      let max_bars = (space + self.bar_gap) / (self.bar_width + self.bar_gap)
      if max_bars > 0 {
        space = 0
        max_bars
      } else {
        break
      }
    }
    let ticks : Array[UInt64] = []
    for i in 0..<taken {
      if i < group.bars.length() {
        ticks.push(scale_height(group.bars[i].value, max, bar_max_length))
      }
    }
    out.push(ticks)
  }
  out
}

///|
/// 数据集最大值，至少为 1（包私有，上游 `maximum_data_value`）喵。
fn BarChart::maximum_data_value(self : BarChart) -> UInt64 {
  let max = match self.max {
    Some(m) => m
    None => {
      let mut best : UInt64 = 0UL
      for group in self.data {
        match group.max_value() {
          Some(v) => if v > best { best = v }
          None => ()
        }
      }
      best
    }
  }
  if max < 1UL {
    1UL
  } else {
    max
  }
}

///|
/// 标签可见性信息（包私有，上游 `LabelInfo`）喵。
priv struct LabelInfo {
  group_label_visible : Bool
  bar_label_visible : Bool
  height : Int
}

///|
/// 计算标签行数与可见性（包私有，上游 `label_info`）：仅柱标签或仅
/// 组标签占 1 行，两者都有占 2 行；可用高度为 0 时全不可见喵。
fn BarChart::label_info(self : BarChart, available_height : Int) -> LabelInfo {
  if available_height == 0 {
    return { group_label_visible: false, bar_label_visible: false, height: 0 }
  }
  let mut bar_label_visible = false
  for group in self.data {
    for bar in group.bars {
      if bar.label is Some(_) {
        bar_label_visible = true
      }
    }
  }
  if available_height == 1 && bar_label_visible {
    return { group_label_visible: false, bar_label_visible: true, height: 1 }
  }
  let mut group_label_visible = false
  for group in self.data {
    if group.label is Some(_) {
      group_label_visible = true
    }
  }
  let group_rows = if group_label_visible { 1 } else { 0 }
  let bar_rows = if bar_label_visible { 1 } else { 0 }
  { group_label_visible, bar_label_visible, height: group_rows + bar_rows }
}

///|
/// 横向渲染：标签列在左、柱体自上而下成行（包私有，上游
/// `render_horizontal`）喵。
fn BarChart::render_horizontal(
  self : BarChart,
  buf : @core.Buffer,
  area : @core.Rect,
) -> Unit {
  // 最长柱标签宽度决定标签列宽喵。
  let mut label_size = 0
  for group in self.data {
    for bar in group.bars {
      match bar.label {
        Some(label) => {
          let w = label.width()
          if w > label_size {
            label_size = w
          }
        }
        None => ()
      }
    }
  }
  let label_x = area.x
  let margin = if label_size != 0 { 1 } else { 0 }
  let bars_width = area.width - label_size - margin
  let bars_area = @core.Rect::new(
    area.x + label_size + margin,
    area.y,
    if bars_width > 0 {
      bars_width
    } else {
      0
    },
    area.height,
  )
  let group_ticks = self.group_ticks(bars_area.height, bars_area.width)
  // 逐组逐柱：柱体行、值/标签行、组标签行喵。
  let mut bar_y = bars_area.top()
  let group_count = if group_ticks.length() < self.data.length() {
    group_ticks.length()
  } else {
    self.data.length()
  }
  for gi in 0..<group_count {
    let ticks_vec = group_ticks[gi]
    let group = self.data[gi]
    let bar_count = if ticks_vec.length() < group.bars.length() {
      ticks_vec.length()
    } else {
      group.bars.length()
    }
    for bi in 0..<bar_count {
      let ticks = ticks_vec[bi]
      let bar = group.bars[bi]
      let bar_length = (ticks / 8UL).to_int()
      let bar_style = self.bar_style.patch(bar.style)
      for y in 0..<self.bar_width {
        let y = bar_y + y
        for x in 0..<bars_area.width {
          let symbol = if x < bar_length {
            self.bar_set.full
          } else {
            self.bar_set.empty
          }
          match buf.mut_cell(bars_area.left() + x, y) {
            Some(cell) => {
              cell.set_symbol(symbol)
              cell.set_style(bar_style)
            }
            None => ()
          }
        }
      }
      let bar_value_area = @core.Rect::new(
        bars_area.x,
        bar_y + (self.bar_width >> 1),
        bars_area.width,
        bars_area.height,
      )
      match bar.label {
        Some(label) =>
          ignore(buf.set_line(label_x, bar_value_area.top(), label, label_size))
        None => ()
      }
      bar.render_value_with_different_styles(
        buf,
        bar_value_area,
        bar_length,
        self.value_style,
        self.bar_style,
      )
      bar_y += self.bar_gap + self.bar_width
    }
    // 组标签只在组间距非零且仍在可见区时打印喵。
    let label_y = bar_y - self.bar_gap
    if self.group_gap > 0 && label_y < bars_area.bottom() {
      let label_rect = @core.Rect::new(
        bars_area.x,
        label_y,
        bars_area.width,
        bars_area.height,
      )
      group.render_label(buf, label_rect, self.label_style)
      bar_y += self.group_gap
    }
  }
}

///|
/// 纵向渲染（包私有，上游 `render_vertical`）：先柱体后标签/值喵。
fn BarChart::render_vertical(
  self : BarChart,
  buf : @core.Buffer,
  area : @core.Rect,
) -> Unit {
  let avail = if area.height > 0 { area.height - 1 } else { 0 }
  let label_info = self.label_info(avail)
  let bars_height = area.height - label_info.height
  let bars_area = @core.Rect::new(
    area.x,
    area.y,
    area.width,
    if bars_height > 0 {
      bars_height
    } else {
      0
    },
  )
  let group_ticks = self.group_ticks(bars_area.width, bars_area.height)
  self.render_vertical_bars(bars_area, buf, group_ticks)
  self.render_labels_and_values(area, buf, label_info, group_ticks)
}

///|
/// 纵向柱体：每格自底向上按剩余 ticks 取档（包私有，上游
/// `render_vertical_bars`）喵。
fn BarChart::render_vertical_bars(
  self : BarChart,
  area : @core.Rect,
  buf : @core.Buffer,
  group_ticks : Array[Array[UInt64]],
) -> Unit {
  let mut bar_x = area.left()
  let group_count = if group_ticks.length() < self.data.length() {
    group_ticks.length()
  } else {
    self.data.length()
  }
  for gi in 0..<group_count {
    let ticks_vec = group_ticks[gi]
    let group = self.data[gi]
    let bar_count = if ticks_vec.length() < group.bars.length() {
      ticks_vec.length()
    } else {
      group.bars.length()
    }
    for bi in 0..<bar_count {
      let mut ticks = ticks_vec[bi]
      let bar = group.bars[bi]
      for t in 0..<area.height {
        let j = area.height - 1 - t
        let symbol = match ticks {
          0UL => self.bar_set.empty
          1UL => self.bar_set.one_eighth
          2UL => self.bar_set.one_quarter
          3UL => self.bar_set.three_eighths
          4UL => self.bar_set.half
          5UL => self.bar_set.five_eighths
          6UL => self.bar_set.three_quarters
          7UL => self.bar_set.seven_eighths
          _ => self.bar_set.full
        }
        let bar_style = self.bar_style.patch(bar.style)
        for x in 0..<self.bar_width {
          match buf.mut_cell(bar_x + x, area.top() + j) {
            Some(cell) => {
              cell.set_symbol(symbol)
              cell.set_style(bar_style)
            }
            None => ()
          }
        }
        ticks = if ticks > 8UL { ticks - 8UL } else { 0UL }
      }
      bar_x += self.bar_gap + self.bar_width
    }
    bar_x += self.group_gap
  }
}

///|
/// 纵向标签与值行（包私有，上游 `render_labels_and_values`）喵。
fn BarChart::render_labels_and_values(
  self : BarChart,
  area : @core.Rect,
  buf : @core.Buffer,
  label_info : LabelInfo,
  group_ticks : Array[Array[UInt64]],
) -> Unit {
  let mut bar_x = area.left()
  let bar_y = area.bottom() - label_info.height - 1
  let group_count = if group_ticks.length() < self.data.length() {
    group_ticks.length()
  } else {
    self.data.length()
  }
  for gi in 0..<group_count {
    let group = self.data[gi]
    let ticks_vec = group_ticks[gi]
    if group.bars.is_empty() {
      continue
    }
    if label_info.group_label_visible {
      let cols = self.bar_width + self.bar_gap
      let label_max_width = ticks_vec.length() * cols - self.bar_gap
      let group_area = @core.Rect::new(
        bar_x,
        area.bottom() - 1,
        if label_max_width > 0 {
          label_max_width
        } else {
          0
        },
        1,
      )
      group.render_label(buf, group_area, self.label_style)
    }
    let bar_count = if ticks_vec.length() < group.bars.length() {
      ticks_vec.length()
    } else {
      group.bars.length()
    }
    for bi in 0..<bar_count {
      let bar = group.bars[bi]
      let ticks = ticks_vec[bi]
      if label_info.bar_label_visible {
        bar.render_label(
          buf,
          self.bar_width,
          bar_x,
          bar_y + 1,
          self.label_style,
        )
      }
      bar.render_value(
        buf,
        self.bar_width,
        bar_x,
        bar_y,
        self.value_style,
        ticks,
      )
      bar_x += self.bar_gap + self.bar_width
    }
    bar_x += self.group_gap
  }
}

///|
/// UTF-8 字节长度（上游 `str::len` 对位；字节边界切分用）喵。
fn utf8_byte_length(text : String) -> Int {
  @utf8.encode(text).length()
}

///|
/// 按字节边界切分（上游 `char_indices().take_while(|(i,_)| i < n)` +
/// `split_at` 语义）：前缀为起点字节序号 < `byte_limit` 的完整字符序列，
/// 切分点落在多字节字符内部时回退到字符边界喵。
fn split_at_byte_boundary(text : String, byte_limit : Int) -> (String, String) {
  let first = StringBuilder()
  let second = StringBuilder()
  let mut in_second = false
  let mut offset = 0
  for ch in text.iter() {
    if in_second {
      second.write_char(ch)
    } else if offset < byte_limit {
      first.write_char(ch)
      offset += @utf8.encode(ch.to_string()).length()
    } else {
      in_second = true
      second.write_char(ch)
    }
  }
  (first.to_string(), second.to_string())
}
