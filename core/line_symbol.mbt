/// 线条符号常量表（上游 `symbols/line.rs`）：Chart/LineGauge/Scrollbar
/// 等组件的绘制基元喵。
///
/// 上游按"单常量 + 集合（`line::Set`）"双形态导出；MoonBit 无模块嵌套，
/// 常量统一加 `LINE_` 前缀对位上游 `symbols::line::*` 喵。

///|
/// 竖线（上游 `symbols::line::VERTICAL`）喵。
pub const LINE_VERTICAL : String = "│"

///|
/// 双线竖线（上游 `DOUBLE_VERTICAL`）喵。
pub const LINE_DOUBLE_VERTICAL : String = "║"

///|
/// 粗竖线（上游 `THICK_VERTICAL`）喵。
pub const LINE_THICK_VERTICAL : String = "┃"

///|
/// 单双点虚竖线（上游 `LIGHT_DOUBLE_DASH_VERTICAL`）喵。
pub const LINE_LIGHT_DOUBLE_DASH_VERTICAL : String = "╎"

///|
/// 粗双点虚竖线（上游 `HEAVY_DOUBLE_DASH_VERTICAL`）喵。
pub const LINE_HEAVY_DOUBLE_DASH_VERTICAL : String = "╏"

///|
/// 单三点虚竖线（上游 `LIGHT_TRIPLE_DASH_VERTICAL`）喵。
pub const LINE_LIGHT_TRIPLE_DASH_VERTICAL : String = "┆"

///|
/// 粗三点虚竖线（上游 `HEAVY_TRIPLE_DASH_VERTICAL`）喵。
pub const LINE_HEAVY_TRIPLE_DASH_VERTICAL : String = "┇"

///|
/// 单四点虚竖线（上游 `LIGHT_QUADRUPLE_DASH_VERTICAL`）喵。
pub const LINE_LIGHT_QUADRUPLE_DASH_VERTICAL : String = "┊"

///|
/// 粗四点虚竖线（上游 `HEAVY_QUADRUPLE_DASH_VERTICAL`）喵。
pub const LINE_HEAVY_QUADRUPLE_DASH_VERTICAL : String = "┋"

///|
/// 横线（上游 `symbols::line::HORIZONTAL`）喵。
pub const LINE_HORIZONTAL : String = "─"

///|
/// 双线横线（上游 `DOUBLE_HORIZONTAL`）喵。
pub const LINE_DOUBLE_HORIZONTAL : String = "═"

///|
/// 粗横线（上游 `THICK_HORIZONTAL`）喵。
pub const LINE_THICK_HORIZONTAL : String = "━"

///|
/// 单双点虚横线（上游 `LIGHT_DOUBLE_DASH_HORIZONTAL`）喵。
pub const LINE_LIGHT_DOUBLE_DASH_HORIZONTAL : String = "╌"

///|
/// 粗双点虚横线（上游 `HEAVY_DOUBLE_DASH_HORIZONTAL`）喵。
pub const LINE_HEAVY_DOUBLE_DASH_HORIZONTAL : String = "╍"

///|
/// 单三点虚横线（上游 `LIGHT_TRIPLE_DASH_HORIZONTAL`）喵。
pub const LINE_LIGHT_TRIPLE_DASH_HORIZONTAL : String = "┄"

///|
/// 粗三点虚横线（上游 `HEAVY_TRIPLE_DASH_HORIZONTAL`）喵。
pub const LINE_HEAVY_TRIPLE_DASH_HORIZONTAL : String = "┅"

///|
/// 单四点虚横线（上游 `LIGHT_QUADRUPLE_DASH_HORIZONTAL`）喵。
pub const LINE_LIGHT_QUADRUPLE_DASH_HORIZONTAL : String = "┈"

///|
/// 粗四点虚横线（上游 `HEAVY_QUADRUPLE_DASH_HORIZONTAL`）喵。
pub const LINE_HEAVY_QUADRUPLE_DASH_HORIZONTAL : String = "┉"

///|
/// 右上角（上游 `TOP_RIGHT`）喵。
pub const LINE_TOP_RIGHT : String = "┐"

///|
/// 圆角右上角（上游 `ROUNDED_TOP_RIGHT`）喵。
pub const LINE_ROUNDED_TOP_RIGHT : String = "╮"

///|
/// 双线右上角（上游 `DOUBLE_TOP_RIGHT`）喵。
pub const LINE_DOUBLE_TOP_RIGHT : String = "╗"

///|
/// 粗右上角（上游 `THICK_TOP_RIGHT`）喵。
pub const LINE_THICK_TOP_RIGHT : String = "┓"

///|
/// 左上角（上游 `TOP_LEFT`）喵。
pub const LINE_TOP_LEFT : String = "┌"

///|
/// 圆角左上角（上游 `ROUNDED_TOP_LEFT`）喵。
pub const LINE_ROUNDED_TOP_LEFT : String = "╭"

///|
/// 双线左上角（上游 `DOUBLE_TOP_LEFT`）喵。
pub const LINE_DOUBLE_TOP_LEFT : String = "╔"

///|
/// 粗左上角（上游 `THICK_TOP_LEFT`）喵。
pub const LINE_THICK_TOP_LEFT : String = "┏"

///|
/// 右下角（上游 `BOTTOM_RIGHT`）喵。
pub const LINE_BOTTOM_RIGHT : String = "┘"

///|
/// 圆角右下角（上游 `ROUNDED_BOTTOM_RIGHT`）喵。
pub const LINE_ROUNDED_BOTTOM_RIGHT : String = "╯"

///|
/// 双线右下角（上游 `DOUBLE_BOTTOM_RIGHT`）喵。
pub const LINE_DOUBLE_BOTTOM_RIGHT : String = "╝"

///|
/// 粗右下角（上游 `THICK_BOTTOM_RIGHT`）喵。
pub const LINE_THICK_BOTTOM_RIGHT : String = "┛"

///|
/// 左下角（上游 `BOTTOM_LEFT`）喵。
pub const LINE_BOTTOM_LEFT : String = "└"

///|
/// 圆角左下角（上游 `ROUNDED_BOTTOM_LEFT`）喵。
pub const LINE_ROUNDED_BOTTOM_LEFT : String = "╰"

///|
/// 双线左下角（上游 `DOUBLE_BOTTOM_LEFT`）喵。
pub const LINE_DOUBLE_BOTTOM_LEFT : String = "╚"

///|
/// 粗左下角（上游 `THICK_BOTTOM_LEFT`）喵。
pub const LINE_THICK_BOTTOM_LEFT : String = "┗"

///|
/// 左接竖线（上游 `VERTICAL_LEFT`）喵。
pub const LINE_VERTICAL_LEFT : String = "┤"

///|
/// 双线左接竖线（上游 `DOUBLE_VERTICAL_LEFT`）喵。
pub const LINE_DOUBLE_VERTICAL_LEFT : String = "╣"

///|
/// 粗左接竖线（上游 `THICK_VERTICAL_LEFT`）喵。
pub const LINE_THICK_VERTICAL_LEFT : String = "┫"

///|
/// 右接竖线（上游 `VERTICAL_RIGHT`）喵。
pub const LINE_VERTICAL_RIGHT : String = "├"

///|
/// 双线右接竖线（上游 `DOUBLE_VERTICAL_RIGHT`）喵。
pub const LINE_DOUBLE_VERTICAL_RIGHT : String = "╠"

///|
/// 粗右接竖线（上游 `THICK_VERTICAL_RIGHT`）喵。
pub const LINE_THICK_VERTICAL_RIGHT : String = "┣"

///|
/// 下接横线（上游 `HORIZONTAL_DOWN`）喵。
pub const LINE_HORIZONTAL_DOWN : String = "┬"

///|
/// 双线下接横线（上游 `DOUBLE_HORIZONTAL_DOWN`）喵。
pub const LINE_DOUBLE_HORIZONTAL_DOWN : String = "╦"

///|
/// 粗下接横线（上游 `THICK_HORIZONTAL_DOWN`）喵。
pub const LINE_THICK_HORIZONTAL_DOWN : String = "┳"

///|
/// 上接横线（上游 `HORIZONTAL_UP`）喵。
pub const LINE_HORIZONTAL_UP : String = "┴"

///|
/// 双线上接横线（上游 `DOUBLE_HORIZONTAL_UP`）喵。
pub const LINE_DOUBLE_HORIZONTAL_UP : String = "╩"

///|
/// 粗上接横线（上游 `THICK_HORIZONTAL_UP`）喵。
pub const LINE_THICK_HORIZONTAL_UP : String = "┻"

///|
/// 十字交叉（上游 `CROSS`）喵。
pub const LINE_CROSS : String = "┼"

///|
/// 双线十字交叉（上游 `DOUBLE_CROSS`）喵。
pub const LINE_DOUBLE_CROSS : String = "╬"

///|
/// 粗十字交叉（上游 `THICK_CROSS`）喵。
pub const LINE_THICK_CROSS : String = "╋"

///|
/// 线条符号集合（上游 `symbols::line::Set`）：11 个方位的完整线型，
/// Chart/Canvas 布线时整组取用喵。
pub(all) struct LineSet {
  vertical : String
  horizontal : String
  top_right : String
  top_left : String
  bottom_right : String
  bottom_left : String
  vertical_left : String
  vertical_right : String
  horizontal_down : String
  horizontal_up : String
  cross : String
} derive(Eq, Debug)

///|
/// 单线直角集合（上游 `line::NORMAL`，也是缺省集合）喵。
pub fn LineSet::normal() -> LineSet {
  {
    vertical: LINE_VERTICAL,
    horizontal: LINE_HORIZONTAL,
    top_right: LINE_TOP_RIGHT,
    top_left: LINE_TOP_LEFT,
    bottom_right: LINE_BOTTOM_RIGHT,
    bottom_left: LINE_BOTTOM_LEFT,
    vertical_left: LINE_VERTICAL_LEFT,
    vertical_right: LINE_VERTICAL_RIGHT,
    horizontal_down: LINE_HORIZONTAL_DOWN,
    horizontal_up: LINE_HORIZONTAL_UP,
    cross: LINE_CROSS,
  }
}

///|
/// 缺省集合（上游 `Set::default` = `NORMAL`）喵。
pub fn LineSet::default() -> LineSet {
  LineSet::normal()
}

///|
/// 单线圆角集合（上游 `line::ROUNDED`：仅四角换圆角，余同 NORMAL）喵。
pub fn LineSet::rounded() -> LineSet {
  {
    ..LineSet::normal(),
    top_right: LINE_ROUNDED_TOP_RIGHT,
    top_left: LINE_ROUNDED_TOP_LEFT,
    bottom_right: LINE_ROUNDED_BOTTOM_RIGHT,
    bottom_left: LINE_ROUNDED_BOTTOM_LEFT,
  }
}

///|
/// 双线集合（上游 `line::DOUBLE`）喵。
pub fn LineSet::double() -> LineSet {
  {
    vertical: LINE_DOUBLE_VERTICAL,
    horizontal: LINE_DOUBLE_HORIZONTAL,
    top_right: LINE_DOUBLE_TOP_RIGHT,
    top_left: LINE_DOUBLE_TOP_LEFT,
    bottom_right: LINE_DOUBLE_BOTTOM_RIGHT,
    bottom_left: LINE_DOUBLE_BOTTOM_LEFT,
    vertical_left: LINE_DOUBLE_VERTICAL_LEFT,
    vertical_right: LINE_DOUBLE_VERTICAL_RIGHT,
    horizontal_down: LINE_DOUBLE_HORIZONTAL_DOWN,
    horizontal_up: LINE_DOUBLE_HORIZONTAL_UP,
    cross: LINE_DOUBLE_CROSS,
  }
}

///|
/// 粗线集合（上游 `line::THICK`）喵。
pub fn LineSet::thick() -> LineSet {
  {
    vertical: LINE_THICK_VERTICAL,
    horizontal: LINE_THICK_HORIZONTAL,
    top_right: LINE_THICK_TOP_RIGHT,
    top_left: LINE_THICK_TOP_LEFT,
    bottom_right: LINE_THICK_BOTTOM_RIGHT,
    bottom_left: LINE_THICK_BOTTOM_LEFT,
    vertical_left: LINE_THICK_VERTICAL_LEFT,
    vertical_right: LINE_THICK_VERTICAL_RIGHT,
    horizontal_down: LINE_THICK_HORIZONTAL_DOWN,
    horizontal_up: LINE_THICK_HORIZONTAL_UP,
    cross: LINE_THICK_CROSS,
  }
}

///|
/// 单双点虚线集合（上游 `line::LIGHT_DOUBLE_DASHED`：线/竖换虚线，余同 NORMAL）喵。
pub fn LineSet::light_double_dashed() -> LineSet {
  {
    ..LineSet::normal(),
    vertical: LINE_LIGHT_DOUBLE_DASH_VERTICAL,
    horizontal: LINE_LIGHT_DOUBLE_DASH_HORIZONTAL,
  }
}

///|
/// 粗双点虚线集合（上游 `line::HEAVY_DOUBLE_DASHED`：线/竖换虚线，余同 THICK）喵。
pub fn LineSet::heavy_double_dashed() -> LineSet {
  {
    ..LineSet::thick(),
    vertical: LINE_HEAVY_DOUBLE_DASH_VERTICAL,
    horizontal: LINE_HEAVY_DOUBLE_DASH_HORIZONTAL,
  }
}

///|
/// 单三点虚线集合（上游 `line::LIGHT_TRIPLE_DASHED`）喵。
pub fn LineSet::light_triple_dashed() -> LineSet {
  {
    ..LineSet::normal(),
    vertical: LINE_LIGHT_TRIPLE_DASH_VERTICAL,
    horizontal: LINE_LIGHT_TRIPLE_DASH_HORIZONTAL,
  }
}

///|
/// 粗三点虚线集合（上游 `line::HEAVY_TRIPLE_DASHED`）喵。
pub fn LineSet::heavy_triple_dashed() -> LineSet {
  {
    ..LineSet::thick(),
    vertical: LINE_HEAVY_TRIPLE_DASH_VERTICAL,
    horizontal: LINE_HEAVY_TRIPLE_DASH_HORIZONTAL,
  }
}

///|
/// 单四点虚线集合（上游 `line::LIGHT_QUADRUPLE_DASHED`）喵。
pub fn LineSet::light_quadruple_dashed() -> LineSet {
  {
    ..LineSet::normal(),
    vertical: LINE_LIGHT_QUADRUPLE_DASH_VERTICAL,
    horizontal: LINE_LIGHT_QUADRUPLE_DASH_HORIZONTAL,
  }
}

///|
/// 粗四点虚线集合（上游 `line::HEAVY_QUADRUPLE_DASHED`）喵。
pub fn LineSet::heavy_quadruple_dashed() -> LineSet {
  {
    ..LineSet::thick(),
    vertical: LINE_HEAVY_QUADRUPLE_DASH_VERTICAL,
    horizontal: LINE_HEAVY_QUADRUPLE_DASH_HORIZONTAL,
  }
}
