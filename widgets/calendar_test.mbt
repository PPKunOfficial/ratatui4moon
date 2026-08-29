// 上游 `calendar.rs` 内联测试逐条复刻喵。
//
// 不可移植登记：上游 `test_today` 调用 `CalendarEventStore::today`
// （std feature，读真实时钟），违反本库"测试零 I/O"铁律，且上游
// 测试本身无行为断言，故不复刻；`today` 构造器一并登记缓议。

///|
/// 上游 `event_store`：未登记日期回落缺省样式，登记日期返回样式，
/// 后写覆盖喵。
test "CalendarEventStore 事件着色" {
  let a = (
    Date::from_calendar_date(2023, January, 1).unwrap(),
    @core.Style::new(),
  )
  let b = (
    Date::from_calendar_date(2023, January, 2).unwrap(),
    @core.Style::new().bg(@core.Red).fg(@core.Blue),
  )
  let s = CalendarEventStore::default()
  s.add(b.0, b.1)
  @debug.assert_eq(s.get_style(a.0), a.1)
  @debug.assert_eq(s.get_style(b.0), b.1)
}

///|
/// 上游 `render_in_minimal_buffer`：1x1 缓冲不 panic 喵。
test "Calendar 极小缓冲渲染" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
  let calendar = Monthly::new(
    Date::from_calendar_date(1984, January, 1).unwrap(),
    CalendarEventStore::default(),
  )
  calendar.render(buffer.area, buffer)
  assert_eq(buffer, @core.Buffer::with_lines([" "]))
}

///|
/// 上游 `render_in_zero_size_buffer`：零尺寸缓冲不 panic 喵。
test "Calendar 零尺寸缓冲渲染" {
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
  let calendar = Monthly::new(
    Date::from_calendar_date(1984, January, 1).unwrap(),
    CalendarEventStore::default(),
  )
  calendar.render(buffer.area, buffer)
}

///|
/// 上游 `calendar_width_reflects_grid_layout`：7 格 ×（1 隔栏 +
/// 2 日宽）= 21 喵。
test "Calendar 宽度反映网格布局" {
  let date = Date::from_calendar_date(2023, January, 1).unwrap()
  let calendar = Monthly::new(date, CalendarEventStore::default())
  inspect(calendar.width(), content="21")
}

///|
/// 上游 `calendar_height_counts_weeks_and_headers`：Feb 2015 四周，
/// 双表头加两行喵。
test "Calendar 高度计周与表头" {
  let date = Date::from_calendar_date(2015, February, 1).unwrap()
  let base_calendar = Monthly::new(date, CalendarEventStore::default())
  inspect(base_calendar.height(), content="4")
  let decorated_calendar = Monthly::new(date, CalendarEventStore::default())
    .show_month_header(@core.Style::new())
    .show_weekdays_header(@core.Style::new())
  inspect(decorated_calendar.height(), content="6")
}

///|
/// 上游 `calendar_dimensions_examples`：三种起讫形状的宽高矩阵
/// （含边框与内边距叠加）喵。
test "Calendar 尺寸示例矩阵" {
  // Feb 2015 起于周日，占 4 行喵。
  let feb_2015 = Date::from_calendar_date(2015, February, 1).unwrap()
  let cal = Monthly::new(feb_2015, CalendarEventStore::default())
  inspect(cal.width(), content="21")
  inspect(cal.height(), content="4")
  let cal = Monthly::new(feb_2015, CalendarEventStore::default())
    .show_month_header(@core.Style::new())
    .show_weekdays_header(@core.Style::new())
  inspect(cal.height(), content="6")
  let cal = Monthly::new(feb_2015, CalendarEventStore::default()).block(
    Block::bordered().padding(Padding::new(2, 3, 1, 2)),
  )
  inspect(cal.width(), content="28")
  inspect(cal.height(), content="9")
  // Feb 2024 起于周四，占 5 行喵。
  let feb_2024 = Date::from_calendar_date(2024, February, 1).unwrap()
  let cal = Monthly::new(feb_2024, CalendarEventStore::default())
  inspect(cal.width(), content="21")
  inspect(cal.height(), content="5")
  let cal = Monthly::new(feb_2024, CalendarEventStore::default())
    .show_month_header(@core.Style::new())
    .show_weekdays_header(@core.Style::new())
  inspect(cal.height(), content="7")
  let cal = Monthly::new(feb_2024, CalendarEventStore::default()).block(
    Block::bordered(),
  )
  inspect(cal.width(), content="23")
  inspect(cal.height(), content="7")
  // Apr 2023 起于周六，占 6 行喵。
  let apr_2023 = Date::from_calendar_date(2023, April, 1).unwrap()
  let cal = Monthly::new(apr_2023, CalendarEventStore::default())
  inspect(cal.width(), content="21")
  inspect(cal.height(), content="6")
  let cal = Monthly::new(apr_2023, CalendarEventStore::default())
    .show_month_header(@core.Style::new())
    .show_weekdays_header(@core.Style::new())
  inspect(cal.height(), content="8")
  let cal = Monthly::new(apr_2023, CalendarEventStore::default()).block(
    Block::bordered().padding(Padding::symmetric(1, 1)),
  )
  inspect(cal.width(), content="25")
  inspect(cal.height(), content="10")
}

///|
/// 上游 `sunday_based_weeks_shapes`：周日/周六/闰月末日的周行数
/// 形状喵。
///
/// 不可移植登记：上游直断包私有 `sunday_based_weeks(date)`；本库
/// 以等价承载——裸月历（无表头/无块）的 `height()` 恰为周行数喵。
test "sunday_based_weeks 形状" {
  let sunday_start = Date::from_calendar_date(2015, February, 11).unwrap()
  let saturday_start = Date::from_calendar_date(2023, April, 9).unwrap()
  let leap_year = Date::from_calendar_date(2024, February, 29).unwrap()
  inspect(
    Monthly::new(sunday_start, CalendarEventStore::default()).height(),
    content="4",
  )
  inspect(
    Monthly::new(saturday_start, CalendarEventStore::default()).height(),
    content="6",
  )
  inspect(
    Monthly::new(leap_year, CalendarEventStore::default()).height(),
    content="5",
  )
}
