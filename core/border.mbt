///|
/// 边框符号集（上游 `symbols::border::Set`）：八个方位的显示符号喵。
///
/// 与上游一致，集合是纯数据；渲染时由 widget 取用，四角/四边可
/// 独立替换（`Block::border_set`）喵。
pub(all) struct BorderSet {
  top_left : String
  top_right : String
  bottom_left : String
  bottom_right : String
  vertical_left : String
  vertical_right : String
  horizontal_top : String
  horizontal_bottom : String
} derive(Eq, Debug)

///|
/// 单线直角边框（上游 `border::PLAIN`）：`┌ ┐ └ ┘ │ ─` 喵。
pub fn BorderSet::plain() -> BorderSet {
  {
    top_left: "┌",
    top_right: "┐",
    bottom_left: "└",
    bottom_right: "┘",
    vertical_left: "│",
    vertical_right: "│",
    horizontal_top: "─",
    horizontal_bottom: "─",
  }
}

///|
/// 单线圆角边框（上游 `border::ROUNDED`）：`╭ ╮ ╰ ╯` 喵。
pub fn BorderSet::rounded() -> BorderSet {
  {
    top_left: "╭",
    top_right: "╮",
    bottom_left: "╰",
    bottom_right: "╯",
    vertical_left: "│",
    vertical_right: "│",
    horizontal_top: "─",
    horizontal_bottom: "─",
  }
}

///|
/// 双线边框（上游 `border::DOUBLE`）：`╔ ╗ ╚ ╝ ║ ═` 喵。
pub fn BorderSet::double() -> BorderSet {
  {
    top_left: "╔",
    top_right: "╗",
    bottom_left: "╚",
    bottom_right: "╝",
    vertical_left: "║",
    vertical_right: "║",
    horizontal_top: "═",
    horizontal_bottom: "═",
  }
}

///|
/// 粗线边框（上游 `border::THICK`）：`┏ ┓ ┗ ┛ ┃ ━` 喵。
pub fn BorderSet::thick() -> BorderSet {
  {
    top_left: "┏",
    top_right: "┓",
    bottom_left: "┗",
    bottom_right: "┛",
    vertical_left: "┃",
    vertical_right: "┃",
    horizontal_top: "━",
    horizontal_bottom: "━",
  }
}
