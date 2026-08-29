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

///|
/// 双破折线边框（上游 `border::LIGHT_DOUBLE_DASHED`）：`┌╌╌╌┐` 喵。
pub fn BorderSet::light_double_dashed() -> BorderSet {
  {
    top_left: "┌",
    top_right: "┐",
    bottom_left: "└",
    bottom_right: "┘",
    vertical_left: "╎",
    vertical_right: "╎",
    horizontal_top: "╌",
    horizontal_bottom: "╌",
  }
}

///|
/// 粗双破折线边框（上游 `border::HEAVY_DOUBLE_DASHED`）喵。
pub fn BorderSet::heavy_double_dashed() -> BorderSet {
  {
    top_left: "┏",
    top_right: "┓",
    bottom_left: "┗",
    bottom_right: "┛",
    vertical_left: "╏",
    vertical_right: "╏",
    horizontal_top: "╍",
    horizontal_bottom: "╍",
  }
}

///|
/// 三破折线边框（上游 `border::LIGHT_TRIPLE_DASHED`）喵。
pub fn BorderSet::light_triple_dashed() -> BorderSet {
  {
    top_left: "┌",
    top_right: "┐",
    bottom_left: "└",
    bottom_right: "┘",
    vertical_left: "┆",
    vertical_right: "┆",
    horizontal_top: "┄",
    horizontal_bottom: "┄",
  }
}

///|
/// 粗三破折线边框（上游 `border::HEAVY_TRIPLE_DASHED`）喵。
pub fn BorderSet::heavy_triple_dashed() -> BorderSet {
  {
    top_left: "┏",
    top_right: "┓",
    bottom_left: "┗",
    bottom_right: "┛",
    vertical_left: "┇",
    vertical_right: "┇",
    horizontal_top: "┅",
    horizontal_bottom: "┅",
  }
}

///|
/// 四破折线边框（上游 `border::LIGHT_QUADRUPLE_DASHED`）喵。
pub fn BorderSet::light_quadruple_dashed() -> BorderSet {
  {
    top_left: "┌",
    top_right: "┐",
    bottom_left: "└",
    bottom_right: "┘",
    vertical_left: "┊",
    vertical_right: "┊",
    horizontal_top: "┈",
    horizontal_bottom: "┈",
  }
}

///|
/// 粗四破折线边框（上游 `border::HEAVY_QUADRUPLE_DASHED`）喵。
pub fn BorderSet::heavy_quadruple_dashed() -> BorderSet {
  {
    top_left: "┏",
    top_right: "┓",
    bottom_left: "┗",
    bottom_right: "┛",
    vertical_left: "┋",
    vertical_right: "┋",
    horizontal_top: "┉",
    horizontal_bottom: "┉",
  }
}

///|
/// 内缩象限边框（上游 `border::QUADRANT_INSIDE`，半格像素内缩）喵。
pub fn BorderSet::quadrant_inside() -> BorderSet {
  {
    top_left: "▗",
    top_right: "▖",
    bottom_left: "▝",
    bottom_right: "▘",
    vertical_left: "▐",
    vertical_right: "▌",
    horizontal_top: "▄",
    horizontal_bottom: "▀",
  }
}

///|
/// 外扩象限边框（上游 `border::QUADRANT_OUTSIDE`，半格像素外扩）喵。
pub fn BorderSet::quadrant_outside() -> BorderSet {
  {
    top_left: "▛",
    top_right: "▜",
    bottom_left: "▙",
    bottom_right: "▟",
    vertical_left: "▌",
    vertical_right: "▐",
    horizontal_top: "▀",
    horizontal_bottom: "▄",
  }
}

///|
/// 上八分块横线（上游 `border::ONE_EIGHTH_TOP_EIGHT`）喵。
pub const BORDER_ONE_EIGHTH_TOP_EIGHT : String = "▔"

///|
/// 下八分块横线（上游 `border::ONE_EIGHTH_BOTTOM_EIGHT`）喵。
pub const BORDER_ONE_EIGHTH_BOTTOM_EIGHT : String = "▁"

///|
/// 左八分块竖线（上游 `border::ONE_EIGHTH_LEFT_EIGHT`）喵。
pub const BORDER_ONE_EIGHTH_LEFT_EIGHT : String = "▏"

///|
/// 右八分块竖线（上游 `border::ONE_EIGHTH_RIGHT_EIGHT`）喵。
pub const BORDER_ONE_EIGHTH_RIGHT_EIGHT : String = "▕"

///|
/// McGugan 宽体边框（上游 `border::ONE_EIGHTH_WIDE`）喵。
pub fn BorderSet::one_eighth_wide() -> BorderSet {
  {
    top_left: BORDER_ONE_EIGHTH_BOTTOM_EIGHT,
    top_right: BORDER_ONE_EIGHTH_BOTTOM_EIGHT,
    bottom_left: BORDER_ONE_EIGHTH_TOP_EIGHT,
    bottom_right: BORDER_ONE_EIGHTH_TOP_EIGHT,
    vertical_left: BORDER_ONE_EIGHTH_LEFT_EIGHT,
    vertical_right: BORDER_ONE_EIGHTH_RIGHT_EIGHT,
    horizontal_top: BORDER_ONE_EIGHTH_BOTTOM_EIGHT,
    horizontal_bottom: BORDER_ONE_EIGHTH_TOP_EIGHT,
  }
}

///|
/// McGugan 瘦体边框（上游 `border::ONE_EIGHTH_TALL`）喵。
pub fn BorderSet::one_eighth_tall() -> BorderSet {
  {
    top_left: BORDER_ONE_EIGHTH_RIGHT_EIGHT,
    top_right: BORDER_ONE_EIGHTH_LEFT_EIGHT,
    bottom_left: BORDER_ONE_EIGHTH_RIGHT_EIGHT,
    bottom_right: BORDER_ONE_EIGHTH_LEFT_EIGHT,
    vertical_left: BORDER_ONE_EIGHTH_RIGHT_EIGHT,
    vertical_right: BORDER_ONE_EIGHTH_LEFT_EIGHT,
    horizontal_top: BORDER_ONE_EIGHTH_TOP_EIGHT,
    horizontal_bottom: BORDER_ONE_EIGHTH_BOTTOM_EIGHT,
  }
}

///|
/// 宽体比例边框（上游 `border::PROPORTIONAL_WIDE`）：上下半块 +
/// 两侧全块，横竖视觉等宽喵。
pub fn BorderSet::proportional_wide() -> BorderSet {
  {
    top_left: "▄",
    top_right: "▄",
    bottom_left: "▀",
    bottom_right: "▀",
    vertical_left: "█",
    vertical_right: "█",
    horizontal_top: "▄",
    horizontal_bottom: "▀",
  }
}

///|
/// 瘦体比例边框（上游 `border::PROPORTIONAL_TALL`）：四角与竖线
/// 全块、上下半块，横竖视觉等高喵。
pub fn BorderSet::proportional_tall() -> BorderSet {
  {
    top_left: "█",
    top_right: "█",
    bottom_left: "█",
    bottom_right: "█",
    vertical_left: "█",
    vertical_right: "█",
    horizontal_top: "▀",
    horizontal_bottom: "▄",
  }
}

///|
/// 实心边框（上游 `border::FULL`）：八边全块喵。
pub fn BorderSet::full() -> BorderSet {
  {
    top_left: BLOCK_FULL,
    top_right: BLOCK_FULL,
    bottom_left: BLOCK_FULL,
    bottom_right: BLOCK_FULL,
    vertical_left: BLOCK_FULL,
    vertical_right: BLOCK_FULL,
    horizontal_top: BLOCK_FULL,
    horizontal_bottom: BLOCK_FULL,
  }
}

///|
/// 空白边框（上游 `border::EMPTY`）：八边空格，用于只染样式不画线喵。
pub fn BorderSet::empty_set() -> BorderSet {
  {
    top_left: " ",
    top_right: " ",
    bottom_left: " ",
    bottom_right: " ",
    vertical_left: " ",
    vertical_right: " ",
    horizontal_top: " ",
    horizontal_bottom: " ",
  }
}
