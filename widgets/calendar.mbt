// 月历组件（上游 `ratatui-widgets/src/calendar.rs`）：按月展示日历，
// 支持月/星期表头、周边月日样式与事件着色喵。
//
// 载体折算登记：
// - 上游泛型 `Monthly<'a, DS: DateStyler>` 以 `Monthly[DS]` 承载；
// - 上游 `Date`/`Duration`（time crate）以 `calendar_date.mbt` 的
//   纯 MoonBit 实现承载，`Duration::DAY` 即 Int 1；
// - `CalendarEventStore::today` 依赖真实时钟，违反零 I/O 铁律，
//   不复刻（上游测试亦无行为断言）。

///|
/// 日期样式提供者契约（上游 `DateStyler` trait）：给定日期返回
/// 样式喵。
pub(open) trait DateStyler {
  fn get_style(Self, Date) -> @core.Style
}

///|
/// 基于事件表的日期样式器（上游 `CalendarEventStore`）：同日重复
/// 添加时后写覆盖喵。
pub struct CalendarEventStore {
  mut entries : Array[(Int, @core.Style)]
} derive(Eq, Debug)

///|
/// 空事件表（上游 `CalendarEventStore::default`）喵。
pub fn CalendarEventStore::default() -> CalendarEventStore {
  { entries: [] }
}

///|
/// 添加日期样式（上游 `CalendarEventStore::add`）：last write wins 喵。
pub fn CalendarEventStore::add(
  self : CalendarEventStore,
  date : Date,
  style : @core.Style,
) -> Unit {
  let key = date.epoch_days
  // 后写覆盖：先移除同日旧条目喵。
  let kept : Array[(Int, @core.Style)] = []
  for entry in self.entries {
    let (k, v) = entry
    if k != key {
      kept.push((k, v))
    }
  }
  kept.push((key, style))
  self.entries = kept
}

///|
/// 查日期样式（上游 `lookup_style`：未登记落缺省样式）喵。
fn CalendarEventStore::lookup_style(
  self : CalendarEventStore,
  date : Date,
) -> @core.Style {
  let key = date.epoch_days
  let mut found = @core.Style::new()
  for entry in self.entries {
    let (k, v) = entry
    if k == key {
      found = v
    }
  }
  found
}

///|
/// DateStyler 实现（上游 `impl DateStyler for CalendarEventStore`）喵。
pub impl DateStyler for CalendarEventStore with fn get_style(
  self : CalendarEventStore,
  date : Date,
) -> @core.Style {
  self.lookup_style(date)
}

///|
/// 月历组件（上游 `Monthly`）喵。
pub struct Monthly[DS] {
  display_date : Date
  events : DS
  show_surrounding : @core.Style?
  show_weekday : @core.Style?
  show_month : @core.Style?
  default_style : @core.Style
  block : Block?
} derive(Eq, Debug)

///|
/// 构造月历（上游 `Monthly::new`）：显示 `display_date` 所在月并
/// 以 `events` 着色喵。
pub fn[DS] Monthly::new(display_date : Date, events : DS) -> Monthly[DS] {
  {
    display_date,
    events,
    show_surrounding: None,
    show_weekday: None,
    show_month: None,
    default_style: @core.Style::new(),
    block: None,
  }
}

///|
/// 填充非当月日的槽位（上游 `Monthly::show_surrounding`）：有事件
/// 样式时与之叠加喵。
pub fn[DS] Monthly::show_surrounding(
  self : Monthly[DS],
  style : @core.Style,
) -> Monthly[DS] {
  { ..self, show_surrounding: Some(style) }
}

///|
/// 显示星期表头（上游 `Monthly::show_weekdays_header`）喵。
pub fn[DS] Monthly::show_weekdays_header(
  self : Monthly[DS],
  style : @core.Style,
) -> Monthly[DS] {
  { ..self, show_weekday: Some(style) }
}

///|
/// 显示月份年份表头（上游 `Monthly::show_month_header`）喵。
pub fn[DS] Monthly::show_month_header(
  self : Monthly[DS],
  style : @core.Style,
) -> Monthly[DS] {
  { ..self, show_month: Some(style) }
}

///|
/// 设未着色日期的样式（上游 `Monthly::default_style`）喵。
pub fn[DS] Monthly::default_style(
  self : Monthly[DS],
  style : @core.Style,
) -> Monthly[DS] {
  { ..self, default_style: style }
}

///|
/// 包边框块（上游 `Monthly::block`）喵。
pub fn[DS] Monthly::block(self : Monthly[DS], block : Block) -> Monthly[DS] {
  { ..self, block: Some(block) }
}

///|
/// 渲染所需宽度（上游 `Monthly::width`）喵。
pub fn[DS] Monthly::width(self : Monthly[DS]) -> Int {
  let days_per_week = 7
  let gutter_width = 1
  let day_width = 2
  let mut width = days_per_week * (gutter_width + day_width)
  match self.block {
    Some(block) => {
      let (left, right) = block.horizontal_space()
      width = width + left + right
    }
    None => ()
  }
  width
}

///|
/// 渲染所需高度（上游 `Monthly::height`）：周行数 + 两个可选表头
/// + 块纵向空间喵。
pub fn[DS] Monthly::height(self : Monthly[DS]) -> Int {
  let mut height = sunday_based_weeks(self.display_date)
  if self.show_month is Some(_) {
    height += 1
  }
  if self.show_weekday is Some(_) {
    height += 1
  }
  match self.block {
    Some(block) => {
      let (top, bottom) = block.vertical_space()
      height = height + top + bottom
    }
    None => ()
  }
  height
}

///|
/// 仅保留缺省样式背景（上游 `Monthly::default_bg`）喵。
fn[DS] Monthly::default_bg(self : Monthly[DS]) -> @core.Style {
  match self.default_style.bg {
    None => @core.Style::new()
    Some(c) => @core.Style::new().bg(c)
  }
}

///|
/// 日期着色（上游 `Monthly::format_date`）：当月走缺省+事件样式，
/// 非当月视 show_surrounding 而定喵。
fn[DS : DateStyler] Monthly::format_date(
  self : Monthly[DS],
  date : Date,
) -> @core.Span {
  if date.month() == self.display_date.month() {
    @core.Span::styled(
      pad_two(date.day()),
      self.default_style.patch(self.events.get_style(date)),
    )
  } else {
    match self.show_surrounding {
      None => @core.Span::styled("  ", self.default_bg())
      Some(s) => {
        let style = self.default_style
          .patch(s)
          .patch(self.events.get_style(date))
        @core.Span::styled(pad_two(date.day()), style)
      }
    }
  }
}

///|
/// Widget 实现（上游 `impl Widget for Monthly`）喵。
pub impl[DS : DateStyler] @core.Widget for Monthly[DS] with fn render(
  self : Monthly[DS],
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let block_area = match self.block {
    Some(block) => {
      block.render(area, buf)
      block.inner(area)
    }
    None => area
  }
  self.render_monthly(block_area, buf)
}

///|
/// 月历主体渲染（上游 `render_monthly`）：起笔于当月 1 日前的那个
/// 周日，逐周逐日写行喵。
fn[DS : DateStyler] Monthly::render_monthly(
  self : Monthly[DS],
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let layout = @layout.Layout::vertical([
    @core.Length(if self.show_month is Some(_) { 1 } else { 0 }),
    @core.Length(if self.show_weekday is Some(_) { 1 } else { 0 }),
    @core.Fill(1),
  ])
  let rects = layout.split(area)
  let month_header = rects[0]
  let days_header = rects[1]
  let days_area = rects[2]
  // 绘月份名与年份喵。
  match self.show_month {
    Some(style) =>
      @core.Line::styled(
        "\{self.display_date.month().name()} \{self.display_date.year()}",
        style,
      )
      .centered()
      .render(month_header, buf)
    None => ()
  }
  // 绘星期表头喵。
  match self.show_weekday {
    Some(style) =>
      @core.Span::styled(" Su Mo Tu We Th Fr Sa", style).render(
        days_header, buf,
      )
    None => ()
  }
  // 日历起点为 1 日前的那个周日（或 1 日恰为周日时即当天）喵。
  let first_of_month = match self.display_date.replace_day(1) {
    Some(d) => d
    None => return
  }
  let offset = first_of_month.weekday_number_from_sunday()
  let mut curr_day = first_of_month.sub_days(offset)
  let mut y = days_area.y
  // 覆盖含当月日期的所有周边周行喵。
  while curr_day.month() != self.display_date.month().next() {
    let spans : Array[@core.Span] = []
    for i in 0..<7 {
      // 画隔栏：首列用缺省样式，其余用缺省背景，免去 format_date
      // 里处理空格样式喵。
      if i == 0 {
        spans.push(@core.Span::styled(" ", @core.Style::new()))
      } else {
        spans.push(@core.Span::styled(" ", self.default_bg()))
      }
      spans.push(self.format_date(curr_day))
      curr_day = curr_day.add_days(1)
    }
    if buf.area.height > y {
      ignore(
        buf.set_line(days_area.x, y, @core.Line::of_spans(spans), area.width),
      )
    }
    y += 1
  }
}

///|
/// 计算渲染 `display_date` 所需的周日基准周行数（上游
/// `sunday_based_weeks`）：首末两日的周序号差 + 1 喵。
fn sunday_based_weeks(display_date : Date) -> Int {
  let first_of_month = match display_date.replace_day(1) {
    Some(d) => d
    None => return 0
  }
  let last_of_month = match
    first_of_month.replace_day(
      first_of_month.month().length(first_of_month.year()),
    ) {
    Some(d) => d
    None => return 0
  }
  let first_week = first_of_month.sunday_based_week()
  let last_week = last_of_month.sunday_based_week()
  (last_week - first_week).max(0) + 1
}

///|
/// 两位右对齐日号（上游 `format!("{:2?}", day)`）喵。
fn pad_two(day : Int) -> String {
  let s = day.to_string()
  if s.length() < 2 {
    " " + s
  } else {
    s
  }
}
