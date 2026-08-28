///|
/// 样式与颜色模型喵。
///
/// spike 阶段仅锁基础 16 色 + 加粗；斜体/暗淡/背景色/下划线等按消费方
/// 真实需求增量追加，可后加字段一律 `T?`/`Bool` 带默认喵。

///|
/// 基础 16 色（SGR 30–37 / 90–97）喵。
pub(all) enum Color {
  Black
  Red
  Green
  Yellow
  Blue
  Magenta
  Cyan
  White
  BrightBlack
  BrightRed
  BrightGreen
  BrightYellow
  BrightBlue
  BrightMagenta
  BrightCyan
  BrightWhite
} derive(Eq, Debug)

///|
/// 前景色对应的 SGR 参数码喵。
pub fn Color::fg_code(self : Color) -> Int {
  match self {
    Black => 30
    Red => 31
    Green => 32
    Yellow => 33
    Blue => 34
    Magenta => 35
    Cyan => 36
    White => 37
    BrightBlack => 90
    BrightRed => 91
    BrightGreen => 92
    BrightYellow => 93
    BrightBlue => 94
    BrightMagenta => 95
    BrightCyan => 96
    BrightWhite => 97
  }
}

///|
/// 单元格样式：无加粗、无前景即"默认样式"（不发射任何 SGR）喵。
pub(all) struct Style {
  bold : Bool
  fg : Color?
} derive(Eq, Debug)

///|
/// 默认样式（继承终端外观）喵。
pub fn Style::default() -> Style {
  { bold: false, fg: None }
}

///|
/// 全字段构造喵。跨包构造一律走这里，避免限定字面量噪音。
pub fn Style::of(bold : Bool, fg : Color?) -> Style {
  { bold, fg }
}

///|
/// 是否为默认样式喵。
pub fn Style::is_default(self : Style) -> Bool {
  !self.bold && self.fg is None
}
