///|
/// ANSI 颜色模型（上游 `style::Color`）喵。
///
/// `Reset` 表示回归终端默认色（SGR 39/49）；16 个命名色对位 ANSI 色表
/// （`Gray` = 37/47 亮白前的"银灰"，`White` = 97/107 最亮白）；
/// `Rgb` 为 24 位真彩色（分量 0–255），`Indexed` 为 256 色索引喵。
///
/// 上游旧名对照：`BrightBlack`≡`DarkGray`、`BrightRed`≡`LightRed`……
/// 旧 `White`（37）在复刻时更名为 `Gray`，`BrightWhite` 更名为 `White` 喵。
pub(all) enum Color {
  Reset
  Black
  Red
  Green
  Yellow
  Blue
  Magenta
  Cyan
  Gray
  DarkGray
  LightRed
  LightGreen
  LightYellow
  LightBlue
  LightMagenta
  LightCyan
  White
  Rgb(Int, Int, Int)
  Indexed(Int)
} derive(Eq, Debug)

///|
/// Display 语义（上游 `impl Display for Color`）喵。
///
/// 命名色输出变体名（如 `DarkGray`），`Indexed` 输出纯索引数字，
/// `Rgb` 输出 `#RRGGBB` 大写十六进制喵。
pub fn Color::to_display(self : Color) -> String {
  match self {
    Reset => "Reset"
    Black => "Black"
    Red => "Red"
    Green => "Green"
    Yellow => "Yellow"
    Blue => "Blue"
    Magenta => "Magenta"
    Cyan => "Cyan"
    Gray => "Gray"
    DarkGray => "DarkGray"
    LightRed => "LightRed"
    LightGreen => "LightGreen"
    LightYellow => "LightYellow"
    LightBlue => "LightBlue"
    LightMagenta => "LightMagenta"
    LightCyan => "LightCyan"
    White => "White"
    Rgb(r, g, b) => "#\{hex2(r)}\{hex2(g)}\{hex2(b)}"
    Indexed(i) => "\{i}"
  }
}

///|
/// 从 `0xRRGGBB` 构造真彩色（上游 `Color::from_u32`）喵。
pub fn Color::from_u32(hex : Int) -> Color {
  Color::Rgb((hex >> 16).land(0xFF), (hex >> 8).land(0xFF), hex.land(0xFF))
}

///|
/// 两字符大写十六进制（包私有，`Rgb` Display 专用）喵。
fn hex2(v : Int) -> String {
  let hex = v.land(0xFF).to_string(radix=16).to_upper()
  if hex.length() < 2 {
    "0\{hex}"
  } else {
    hex
  }
}
