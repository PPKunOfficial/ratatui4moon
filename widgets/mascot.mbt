// Ratatui 吉祥物组件（上游 `ratatui-widgets/src/mascot.rs`）：32x16
// 半块字符画布绘出的吉祥物，颜色硬编码、眼睛可切换喵。
//
// 渲染模型：画布每两行合成一排终端格（上行=半块上半、下行=下半），
// 前景取"可见半块"字符的颜色、背景取另一半的颜色喵。

///|
/// 吉祥物眼睛状态（上游 `MascotEyeColor`）喵。
pub(all) enum MascotEyeColor {
  /// 睁眼（缺省）喵。
  Default
  /// 眨眼（红眼）喵。
  Red
} derive(Eq, Debug)

///|
/// 缺省眼睛状态（上游 `MascotEyeColor::default`）喵。
pub fn MascotEyeColor::default() -> MascotEyeColor {
  Default
}

///|
/// 吉祥物组件（上游 `RatatuiMascot`）喵。
pub(all) struct RatatuiMascot {
  eye_state : MascotEyeColor
  /// 鼠身颜色喵。
  rat_color : @core.Color
  /// 眼睛颜色（睁眼）喵。
  rat_eye_color : @core.Color
  /// 眼睛颜色（眨眼）喵。
  rat_eye_blink : @core.Color
  /// 帽子颜色喵。
  hat_color : @core.Color
  /// 终端屏幕颜色喵。
  term_color : @core.Color
  /// 终端边框颜色喵。
  term_border_color : @core.Color
  /// 终端光标颜色喵。
  term_cursor_color : @core.Color
} derive(Eq, Debug)

///|
/// 缺省吉祥物（上游 `Default for RatatuiMascot`：256 色硬编码）喵。
pub fn RatatuiMascot::default() -> RatatuiMascot {
  {
    eye_state: Default,
    rat_color: @core.Indexed(252),
    hat_color: @core.Indexed(231),
    rat_eye_color: @core.Indexed(236),
    rat_eye_blink: @core.Indexed(196),
    term_color: @core.Indexed(232),
    term_border_color: @core.Indexed(237),
    term_cursor_color: @core.Indexed(248),
  }
}

///|
/// 新建吉祥物（上游 `RatatuiMascot::new`）喵。
pub fn RatatuiMascot::new() -> RatatuiMascot {
  RatatuiMascot::default()
}

///|
/// 设眼睛状态（上游 `RatatuiMascot::set_eye`）喵。
pub fn RatatuiMascot::set_eye(
  self : RatatuiMascot,
  rat_eye : MascotEyeColor,
) -> RatatuiMascot {
  { ..self, eye_state: rat_eye }
}

///|
/// 画布字符 → 颜色映射（上游 `RatatuiMascot::color_for`）：空白落
/// None（不改色）喵。
fn RatatuiMascot::color_for(self : RatatuiMascot, c : Char) -> @core.Color? {
  match c {
    'h' => Some(self.hat_color)
    'e' =>
      Some(
        match self.eye_state {
          Default => self.rat_eye_color
          Red => self.rat_eye_blink
        },
      )
    '█' => Some(self.rat_color)
    '░' => Some(self.term_color)
    '▓' => Some(self.term_cursor_color)
    '▒' => Some(self.term_border_color)
    _ => None
  }
}

///|
/// Widget 实现（上游 `impl Widget for RatatuiMascot`）喵。
pub impl @core.Widget for RatatuiMascot with fn render(
  self : RatatuiMascot,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  let area = area.intersection(buf.area)
  if area.is_empty() {
    return
  }
  let empty : Char = ' '
  let term : Char = '░'
  let term_border : Char = '▒'
  let row_count = mascot_canvas_rows.length() / 2
  for y in 0..<row_count {
    let line1 : Array[Char] = mascot_canvas_rows[y * 2].iter().collect()
    let line2 : Array[Char] = mascot_canvas_rows[y * 2 + 1].iter().collect()
    let width = line1.length().min(line2.length())
    for x in 0..<width {
      let ch1 = line1[x]
      let ch2 = line2[x]
      let gx = area.x + x
      let gy = area.y + y
      // 越出（已裁剪的）区域则跳过喵。
      if gx >= area.right() || gy >= area.bottom() {
        continue
      }
      match buf.mut_cell(gx, gy) {
        Some(cell) => {
          // 前景取非空白/非终端一侧的颜色，背景取另一半喵。
          let fg_bg : (@core.Color?, @core.Color?) = if ch1 == empty &&
            ch2 == empty {
            (None, None)
          } else if ch2 == empty {
            (self.color_for(ch1), None)
          } else if ch1 == empty {
            (self.color_for(ch2), None)
          } else if ch1 == term && ch2 == term_border {
            (self.color_for(term_border), self.color_for(term))
          } else if ch1 == term {
            (self.color_for(ch2), self.color_for(term))
          } else if ch2 == term {
            (self.color_for(ch1), self.color_for(term))
          } else {
            (self.color_for(ch1), self.color_for(ch2))
          }
          // 符号：空白留空、终端底衬写空格、按可见半块取 ▀/▄/█ 喵。
          let symbol : Char? = if ch1 == empty && ch2 == empty {
            None
          } else if ch1 == term && ch2 == term {
            Some(empty)
          } else if ch2 == empty || ch2 == term {
            Some('▀')
          } else if ch1 == empty || ch1 == term {
            Some('▄')
          } else if ch1 == ch2 {
            Some('█')
          } else {
            Some('▀')
          }
          match fg_bg.0 {
            Some(fg) => cell.fg = fg
            None => ()
          }
          match fg_bg.1 {
            Some(bg) => cell.bg = bg
            None => ()
          }
          match symbol {
            Some(symb) => cell.set_char(symb)
            None => ()
          }
        }
        None => ()
      }
    }
  }
}
