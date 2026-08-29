// 日历支持类型（对位上游 `time` crate 的 Date/Month/Duration 使用面）：
// 纯 MoonBit 的公历（proleptic Gregorian）日期算术，零 I/O 喵。
//
// 载体折算登记：
// - 上游 `Date` 为 time crate 类型，此处以同名的纯 MoonBit 实现承载，
//   仅覆盖 calendar.rs 用到的 API 面（构造/字段/换日/周日基准周数）；
// - `Duration`/`Duration::DAY` 以 Int 天数承载，`+/- Duration` 落
//   `add_days`/`sub_days`；
// - `CalendarEventStore::today` 依赖真实时钟（std feature），违反
//   测试零 I/O 铁律，不复刻（上游该测试亦无行为断言）。

///|
/// 公历月份（上游 `time::Month`）喵。
pub(all) enum Month {
  January
  February
  March
  April
  May
  June
  July
  August
  September
  October
  November
  December
} derive(Eq, Debug)

///|
/// 月份序号（1–12）喵。
pub fn Month::number(self : Month) -> Int {
  match self {
    January => 1
    February => 2
    March => 3
    April => 4
    May => 5
    June => 6
    July => 7
    August => 8
    September => 9
    October => 10
    November => 11
    December => 12
  }
}

///|
/// 月份全名（上游 `Display for Month`）喵。
pub fn Month::name(self : Month) -> String {
  match self {
    January => "January"
    February => "February"
    March => "March"
    April => "April"
    May => "May"
    June => "June"
    July => "July"
    August => "August"
    September => "September"
    October => "October"
    November => "November"
    December => "December"
  }
}

///|
/// 下一个月（上游 `Month::next`，十二月回卷一月）喵。
pub fn Month::next(self : Month) -> Month {
  match self {
    January => February
    February => March
    March => April
    April => May
    May => June
    June => July
    July => August
    August => September
    September => October
    October => November
    November => December
    December => January
  }
}

///|
/// 该月天数（上游 `Month::length(year)`，含闰年）喵。
pub fn Month::length(self : Month, year : Int) -> Int {
  match self {
    January => 31
    February => if is_leap_year(year) { 29 } else { 28 }
    March => 31
    April => 30
    May => 31
    June => 30
    July => 31
    August => 31
    September => 30
    October => 31
    November => 30
    December => 31
  }
}

///|
/// 闰年判定（格里历规则）喵。
pub fn is_leap_year(year : Int) -> Bool {
  (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

///|
/// 公历日期（上游 `time::Date`）：年/月/日 + 历元天数缓存喵。
pub(all) struct Date {
  year : Int
  month : Month
  day : Int
  /// 自 1970-01-01（含）起的天数，可为负喵。
  epoch_days : Int
} derive(Eq, Debug)

///|
/// 由年/月/日构造（上游 `Date::from_calendar_date`）：日超出当月
/// 天数落 None 喵。
pub fn Date::from_calendar_date(year : Int, month : Month, day : Int) -> Date? {
  if day < 1 || day > month.length(year) {
    return None
  }
  Some({
    year,
    month,
    day,
    epoch_days: days_from_civil(year, month.number(), day),
  })
}

///|
pub fn Date::year(self : Date) -> Int {
  self.year
}

///|
pub fn Date::month(self : Date) -> Month {
  self.month
}

///|
pub fn Date::day(self : Date) -> Int {
  self.day
}

///|
/// 替换日（上游 `Date::replace_day`）：非法日落 None 喵。
pub fn Date::replace_day(self : Date, day : Int) -> Date? {
  Date::from_calendar_date(self.year, self.month, day)
}

///|
/// 距周日的历史天数（上游 `weekday().number_days_from_sunday()`）：
/// 周日为 0，周一为 1，……周六为 6 喵。
pub fn Date::weekday_number_from_sunday(self : Date) -> Int {
  floor_mod(self.epoch_days + 4, 7)
}

///|
/// 周日基准周序号（上游 `Date::sunday_based_week`）：仅差值有意义，
/// 以含 1969-12-28（周日）的周为第 0 周（历元对齐 -4 天后除以 7）喵。
pub fn Date::sunday_based_week(self : Date) -> Int {
  (self.epoch_days + 4).div(7)
}

///|
/// 加 n 天（上游 `+ Duration`）喵。
pub fn Date::add_days(self : Date, n : Int) -> Date {
  civil_from_days(self.epoch_days + n)
}

///|
/// 减 n 天（上游 `- Duration`）喵。
pub fn Date::sub_days(self : Date, n : Int) -> Date {
  civil_from_days(self.epoch_days - n)
}

///|
/// 向下取整除法（处理负年份路径）喵。
fn floor_div(a : Int, b : Int) -> Int {
  let q = a / b
  if a % b != 0 && (a < 0) != (b < 0) {
    q - 1
  } else {
    q
  }
}

///|
/// 非负模（处理负数路径）喵。
fn floor_mod(a : Int, b : Int) -> Int {
  a - floor_div(a, b) * b
}

///|
/// 儒略日数 → 公历（Howard Hinnant `civil_from_days` 算法）喵。
fn civil_from_days(z : Int) -> Date {
  let z = z + 719468
  let era = floor_div(z, 146097)
  let doe = z - era * 146097
  let yoe = (
      doe -
      floor_div(doe, 1460) +
      floor_div(doe, 36524) -
      floor_div(doe, 146096)
    ) /
    365
  let y = yoe + era * 400
  let doy = doe - (365 * yoe + floor_div(yoe, 4) - floor_div(yoe, 100))
  let mp = (5 * doy + 2) / 153
  let d = doy - (153 * mp + 2) / 5 + 1
  let m = if mp < 10 { mp + 3 } else { mp - 9 }
  let year = if m <= 2 { y + 1 } else { y }
  let month = match m {
    1 => January
    2 => February
    3 => March
    4 => April
    5 => May
    6 => June
    7 => July
    8 => August
    9 => September
    10 => October
    11 => November
    _ => December
  }
  Date::from_calendar_date(year, month, d).unwrap()
}

///|
/// 公历 → 儒略日数（Howard Hinnant `days_from_civil` 算法）喵。
fn days_from_civil(y : Int, m : Int, d : Int) -> Int {
  let y = if m <= 2 { y - 1 } else { y }
  let era = floor_div(y, 400)
  let yoe = y - era * 400
  let doy = (153 * (if m > 2 { m - 3 } else { m + 9 }) + 2) / 5 + d - 1
  let doe = yoe * 365 + floor_div(yoe, 4) - floor_div(yoe, 100) + doy
  era * 146097 + doe - 719468
}
