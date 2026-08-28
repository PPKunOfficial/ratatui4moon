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

///|
/// 从字符串解析颜色（上游 `FromStr for Color`）喵。
///
/// 支持命名色与常见别名（`bright`≡`light`、`grey`/`silver`≡`gray`、
/// `light black`≡`darkgray` 等，分隔符 `空格`/`-`/`_` 忽略）、
/// 纯数字索引（0–255）与 `#RRGGBB` 十六进制；无法解析返回 `None` 喵。
pub fn Color::from_str(s : String) -> Color? {
  let mut norm = s.to_lower()
  norm = norm.replace_all(old=" ", new="")
  norm = norm.replace_all(old="-", new="")
  norm = norm.replace_all(old="_", new="")
  norm = norm.replace_all(old="bright", new="light")
  norm = norm.replace_all(old="grey", new="gray")
  norm = norm.replace_all(old="silver", new="gray")
  norm = norm.replace_all(old="lightblack", new="darkgray")
  norm = norm.replace_all(old="lightwhite", new="white")
  norm = norm.replace_all(old="lightgray", new="white")
  match norm {
    "reset" => Some(Reset)
    "black" => Some(Black)
    "red" => Some(Red)
    "green" => Some(Green)
    "yellow" => Some(Yellow)
    "blue" => Some(Blue)
    "magenta" => Some(Magenta)
    "cyan" => Some(Cyan)
    "gray" => Some(Gray)
    "darkgray" => Some(DarkGray)
    "lightred" => Some(LightRed)
    "lightgreen" => Some(LightGreen)
    "lightyellow" => Some(LightYellow)
    "lightblue" => Some(LightBlue)
    "lightmagenta" => Some(LightMagenta)
    "lightcyan" => Some(LightCyan)
    "white" => Some(White)
    _ =>
      match parse_u8(s) {
        Some(index) => Some(Indexed(index))
        None =>
          match parse_hex_color(s) {
            Some((r, g, b)) => Some(Rgb(r, g, b))
            None => None
          }
      }
  }
}

///|
/// 解析 0–255 无符号整数（上游 `u8::from_str`：仅数字、允许前导零、
/// 越界失败；包私有）喵。
fn parse_u8(s : String) -> Int? {
  let chars : Array[Char] = []
  for ch in s {
    chars.push(ch)
  }
  if chars.length() == 0 || chars.length() > 3 {
    return None
  }
  let mut value = 0
  for ch in chars {
    let cp = ch.to_int()
    if cp < 0x30 || cp > 0x39 {
      return None
    }
    value = value * 10 + (cp - 0x30)
  }
  if value > 255 {
    None
  } else {
    Some(value)
  }
}

///|
/// 解析 `#RRGGBB` 十六进制色（上游 `parse_hex_color`，包私有）喵。
fn parse_hex_color(input : String) -> (Int, Int, Int)? {
  let chars : Array[Char] = []
  for ch in input {
    chars.push(ch)
  }
  if chars.length() != 7 || chars[0] != '#' {
    return None
  }
  fn hex_pair(high : Char, low : Char) -> Int? {
    let h = hex_val(high)
    let l = hex_val(low)
    match (h, l) {
      (Some(hv), Some(lv)) => Some(hv * 16 + lv)
      _ => None
    }
  }
  match
    (
      hex_pair(chars[1], chars[2]),
      hex_pair(chars[3], chars[4]),
      hex_pair(chars[5], chars[6]),
    ) {
    (Some(r), Some(g), Some(b)) => Some((r, g, b))
    _ => None
  }
}

///|
/// 单个十六进制数字转数值（包私有）喵。
fn hex_val(ch : Char) -> Int? {
  let cp = ch.to_int()
  if cp >= 0x30 && cp <= 0x39 {
    Some(cp - 0x30)
  } else if cp >= 0x41 && cp <= 0x46 {
    Some(cp - 0x41 + 10)
  } else if cp >= 0x61 && cp <= 0x66 {
    Some(cp - 0x61 + 10)
  } else {
    None
  }
}
