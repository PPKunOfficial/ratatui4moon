///|
/// 符号合并策略（上游 `symbols::merge`）：把两个 Box Drawing 符号
/// 合成一个，用于边框折叠（collapse borders）喵。
///
/// `Replace` 直接用后符号；`Exact` 仅在存在精确合成字符时合并；
/// `Fuzzy` 在精确合成不存在时按"末次并入符号优先"降级
/// （虚线→实线、圆角→直角、双线/粗线二选一、双线/实线不存在组合二选一）。
/// 虚线与实线、圆角与其他、双线与粗线等组合在 Unicode Box Drawing
/// 块中无对应字符，Exact 会回退为 Replace 语义喵。

///|
/// 单边线型（上游包私有 `LineStyle`）喵。
priv enum LineStyle {
  Nothing
  Plain
  Rounded
  Double
  Thick
  DoubleDash
  DoubleDashThick
  TripleDash
  TripleDashThick
  QuadrupleDash
  QuadrupleDashThick
} derive(Eq)

///|
/// 合成边框符号：右/上/左/下四个方向的线型（上游包私有 `BorderSymbol`）喵。
priv struct BorderSymbol {
  right : LineStyle
  up : LineStyle
  left : LineStyle
  down : LineStyle
} derive(Eq)

///|
/// 构造合成符号（包私有）喵。
fn BorderSymbol::of(
  right : LineStyle,
  up : LineStyle,
  left : LineStyle,
  down : LineStyle,
) -> BorderSymbol {
  { right, up, left, down }
}

///|
/// 解析 Box Drawing 符号为合成符号；非边框符号返回 `None`
/// （上游 `FromStr for BorderSymbol`）喵。
fn BorderSymbol::parse(symbol : String) -> BorderSymbol? {
  match symbol {
    "─" => Some(BorderSymbol::of(Plain, Nothing, Plain, Nothing))
    "━" => Some(BorderSymbol::of(Thick, Nothing, Thick, Nothing))
    "│" => Some(BorderSymbol::of(Nothing, Plain, Nothing, Plain))
    "┃" => Some(BorderSymbol::of(Nothing, Thick, Nothing, Thick))
    "┄" => Some(BorderSymbol::of(TripleDash, Nothing, TripleDash, Nothing))
    "┅" =>
      Some(BorderSymbol::of(TripleDashThick, Nothing, TripleDashThick, Nothing))
    "┆" => Some(BorderSymbol::of(Nothing, TripleDash, Nothing, TripleDash))
    "┇" =>
      Some(BorderSymbol::of(Nothing, TripleDashThick, Nothing, TripleDashThick))
    "┈" =>
      Some(BorderSymbol::of(QuadrupleDash, Nothing, QuadrupleDash, Nothing))
    "┉" =>
      Some(
        BorderSymbol::of(
          QuadrupleDashThick,
          Nothing,
          QuadrupleDashThick,
          Nothing,
        ),
      )
    "┊" =>
      Some(BorderSymbol::of(Nothing, QuadrupleDash, Nothing, QuadrupleDash))
    "┋" =>
      Some(
        BorderSymbol::of(
          Nothing,
          QuadrupleDashThick,
          Nothing,
          QuadrupleDashThick,
        ),
      )
    "┌" => Some(BorderSymbol::of(Plain, Nothing, Nothing, Plain))
    "┍" => Some(BorderSymbol::of(Thick, Nothing, Nothing, Plain))
    "┎" => Some(BorderSymbol::of(Plain, Nothing, Nothing, Thick))
    "┏" => Some(BorderSymbol::of(Thick, Nothing, Nothing, Thick))
    "┐" => Some(BorderSymbol::of(Nothing, Nothing, Plain, Plain))
    "┑" => Some(BorderSymbol::of(Nothing, Nothing, Thick, Plain))
    "┒" => Some(BorderSymbol::of(Nothing, Nothing, Plain, Thick))
    "┓" => Some(BorderSymbol::of(Nothing, Nothing, Thick, Thick))
    "└" => Some(BorderSymbol::of(Plain, Plain, Nothing, Nothing))
    "┕" => Some(BorderSymbol::of(Thick, Plain, Nothing, Nothing))
    "┖" => Some(BorderSymbol::of(Plain, Thick, Nothing, Nothing))
    "┗" => Some(BorderSymbol::of(Thick, Thick, Nothing, Nothing))
    "┘" => Some(BorderSymbol::of(Nothing, Plain, Plain, Nothing))
    "┙" => Some(BorderSymbol::of(Nothing, Plain, Thick, Nothing))
    "┚" => Some(BorderSymbol::of(Nothing, Thick, Plain, Nothing))
    "┛" => Some(BorderSymbol::of(Nothing, Thick, Thick, Nothing))
    "├" => Some(BorderSymbol::of(Plain, Plain, Nothing, Plain))
    "┝" => Some(BorderSymbol::of(Thick, Plain, Nothing, Plain))
    "┞" => Some(BorderSymbol::of(Plain, Thick, Nothing, Plain))
    "┟" => Some(BorderSymbol::of(Plain, Plain, Nothing, Thick))
    "┠" => Some(BorderSymbol::of(Plain, Thick, Nothing, Thick))
    "┡" => Some(BorderSymbol::of(Thick, Thick, Nothing, Plain))
    "┢" => Some(BorderSymbol::of(Thick, Plain, Nothing, Thick))
    "┣" => Some(BorderSymbol::of(Thick, Thick, Nothing, Thick))
    "┤" => Some(BorderSymbol::of(Nothing, Plain, Plain, Plain))
    "┥" => Some(BorderSymbol::of(Nothing, Plain, Thick, Plain))
    "┦" => Some(BorderSymbol::of(Nothing, Thick, Plain, Plain))
    "┧" => Some(BorderSymbol::of(Nothing, Plain, Plain, Thick))
    "┨" => Some(BorderSymbol::of(Nothing, Thick, Plain, Thick))
    "┩" => Some(BorderSymbol::of(Nothing, Thick, Thick, Plain))
    "┪" => Some(BorderSymbol::of(Nothing, Plain, Thick, Thick))
    "┫" => Some(BorderSymbol::of(Nothing, Thick, Thick, Thick))
    "┬" => Some(BorderSymbol::of(Plain, Nothing, Plain, Plain))
    "┭" => Some(BorderSymbol::of(Plain, Nothing, Thick, Plain))
    "┮" => Some(BorderSymbol::of(Thick, Nothing, Plain, Plain))
    "┯" => Some(BorderSymbol::of(Thick, Nothing, Thick, Plain))
    "┰" => Some(BorderSymbol::of(Plain, Nothing, Plain, Thick))
    "┱" => Some(BorderSymbol::of(Plain, Nothing, Thick, Thick))
    "┲" => Some(BorderSymbol::of(Thick, Nothing, Plain, Thick))
    "┳" => Some(BorderSymbol::of(Thick, Nothing, Thick, Thick))
    "┴" => Some(BorderSymbol::of(Plain, Plain, Plain, Nothing))
    "┵" => Some(BorderSymbol::of(Plain, Plain, Thick, Nothing))
    "┶" => Some(BorderSymbol::of(Thick, Plain, Plain, Nothing))
    "┷" => Some(BorderSymbol::of(Thick, Plain, Thick, Nothing))
    "┸" => Some(BorderSymbol::of(Plain, Thick, Plain, Nothing))
    "┹" => Some(BorderSymbol::of(Plain, Thick, Thick, Nothing))
    "┺" => Some(BorderSymbol::of(Thick, Thick, Plain, Nothing))
    "┻" => Some(BorderSymbol::of(Thick, Thick, Thick, Nothing))
    "┼" => Some(BorderSymbol::of(Plain, Plain, Plain, Plain))
    "┽" => Some(BorderSymbol::of(Plain, Plain, Thick, Plain))
    "┾" => Some(BorderSymbol::of(Thick, Plain, Plain, Plain))
    "┿" => Some(BorderSymbol::of(Thick, Plain, Thick, Plain))
    "╀" => Some(BorderSymbol::of(Plain, Thick, Plain, Plain))
    "╁" => Some(BorderSymbol::of(Plain, Plain, Plain, Thick))
    "╂" => Some(BorderSymbol::of(Plain, Thick, Plain, Thick))
    "╃" => Some(BorderSymbol::of(Plain, Thick, Thick, Plain))
    "╄" => Some(BorderSymbol::of(Thick, Thick, Plain, Plain))
    "╅" => Some(BorderSymbol::of(Plain, Plain, Thick, Thick))
    "╆" => Some(BorderSymbol::of(Thick, Plain, Plain, Thick))
    "╇" => Some(BorderSymbol::of(Thick, Thick, Thick, Plain))
    "╈" => Some(BorderSymbol::of(Thick, Plain, Thick, Thick))
    "╉" => Some(BorderSymbol::of(Plain, Thick, Thick, Thick))
    "╊" => Some(BorderSymbol::of(Thick, Thick, Plain, Thick))
    "╋" => Some(BorderSymbol::of(Thick, Thick, Thick, Thick))
    "╌" => Some(BorderSymbol::of(DoubleDash, Nothing, DoubleDash, Nothing))
    "╍" =>
      Some(BorderSymbol::of(DoubleDashThick, Nothing, DoubleDashThick, Nothing))
    "╎" => Some(BorderSymbol::of(Nothing, DoubleDash, Nothing, DoubleDash))
    "╏" =>
      Some(BorderSymbol::of(Nothing, DoubleDashThick, Nothing, DoubleDashThick))
    "═" => Some(BorderSymbol::of(Double, Nothing, Double, Nothing))
    "║" => Some(BorderSymbol::of(Nothing, Double, Nothing, Double))
    "╒" => Some(BorderSymbol::of(Double, Nothing, Nothing, Plain))
    "╓" => Some(BorderSymbol::of(Plain, Nothing, Nothing, Double))
    "╔" => Some(BorderSymbol::of(Double, Nothing, Nothing, Double))
    "╕" => Some(BorderSymbol::of(Nothing, Nothing, Double, Plain))
    "╖" => Some(BorderSymbol::of(Nothing, Nothing, Plain, Double))
    "╗" => Some(BorderSymbol::of(Nothing, Nothing, Double, Double))
    "╘" => Some(BorderSymbol::of(Double, Plain, Nothing, Nothing))
    "╙" => Some(BorderSymbol::of(Plain, Double, Nothing, Nothing))
    "╚" => Some(BorderSymbol::of(Double, Double, Nothing, Nothing))
    "╛" => Some(BorderSymbol::of(Nothing, Plain, Double, Nothing))
    "╜" => Some(BorderSymbol::of(Nothing, Double, Plain, Nothing))
    "╝" => Some(BorderSymbol::of(Nothing, Double, Double, Nothing))
    "╞" => Some(BorderSymbol::of(Double, Plain, Nothing, Plain))
    "╟" => Some(BorderSymbol::of(Plain, Double, Nothing, Double))
    "╠" => Some(BorderSymbol::of(Double, Double, Nothing, Double))
    "╡" => Some(BorderSymbol::of(Nothing, Plain, Double, Plain))
    "╢" => Some(BorderSymbol::of(Nothing, Double, Plain, Double))
    "╣" => Some(BorderSymbol::of(Nothing, Double, Double, Double))
    "╤" => Some(BorderSymbol::of(Double, Nothing, Double, Plain))
    "╥" => Some(BorderSymbol::of(Plain, Nothing, Plain, Double))
    "╦" => Some(BorderSymbol::of(Double, Nothing, Double, Double))
    "╧" => Some(BorderSymbol::of(Double, Plain, Double, Nothing))
    "╨" => Some(BorderSymbol::of(Plain, Double, Plain, Nothing))
    "╩" => Some(BorderSymbol::of(Double, Double, Double, Nothing))
    "╪" => Some(BorderSymbol::of(Double, Plain, Double, Plain))
    "╫" => Some(BorderSymbol::of(Plain, Double, Plain, Double))
    "╬" => Some(BorderSymbol::of(Double, Double, Double, Double))
    "╭" => Some(BorderSymbol::of(Rounded, Nothing, Nothing, Rounded))
    "╮" => Some(BorderSymbol::of(Nothing, Nothing, Rounded, Rounded))
    "╯" => Some(BorderSymbol::of(Nothing, Rounded, Rounded, Nothing))
    "╰" => Some(BorderSymbol::of(Rounded, Rounded, Nothing, Nothing))
    "╴" => Some(BorderSymbol::of(Nothing, Nothing, Plain, Nothing))
    "╵" => Some(BorderSymbol::of(Nothing, Plain, Nothing, Nothing))
    "╶" => Some(BorderSymbol::of(Plain, Nothing, Nothing, Nothing))
    "╷" => Some(BorderSymbol::of(Nothing, Nothing, Nothing, Plain))
    "╸" => Some(BorderSymbol::of(Nothing, Nothing, Thick, Nothing))
    "╹" => Some(BorderSymbol::of(Nothing, Thick, Nothing, Nothing))
    "╺" => Some(BorderSymbol::of(Thick, Nothing, Nothing, Nothing))
    "╻" => Some(BorderSymbol::of(Nothing, Nothing, Nothing, Thick))
    "╼" => Some(BorderSymbol::of(Thick, Nothing, Plain, Nothing))
    "╽" => Some(BorderSymbol::of(Nothing, Plain, Nothing, Thick))
    "╾" => Some(BorderSymbol::of(Plain, Nothing, Thick, Nothing))
    "╿" => Some(BorderSymbol::of(Nothing, Thick, Nothing, Plain))
    _ => None
  }
}

///|
/// 合成符号反向查找对应字符；无可表示字符返回 `None`
/// （上游 `TryFrom<BorderSymbol> for &str`）喵。
fn BorderSymbol::to_symbol(self : BorderSymbol) -> String? {
  match (self.right, self.up, self.left, self.down) {
    (Plain, Nothing, Plain, Nothing) => Some("─")
    (Thick, Nothing, Thick, Nothing) => Some("━")
    (Nothing, Plain, Nothing, Plain) => Some("│")
    (Nothing, Thick, Nothing, Thick) => Some("┃")
    (TripleDash, Nothing, TripleDash, Nothing) => Some("┄")
    (TripleDashThick, Nothing, TripleDashThick, Nothing) => Some("┅")
    (Nothing, TripleDash, Nothing, TripleDash) => Some("┆")
    (Nothing, TripleDashThick, Nothing, TripleDashThick) => Some("┇")
    (QuadrupleDash, Nothing, QuadrupleDash, Nothing) => Some("┈")
    (QuadrupleDashThick, Nothing, QuadrupleDashThick, Nothing) => Some("┉")
    (Nothing, QuadrupleDash, Nothing, QuadrupleDash) => Some("┊")
    (Nothing, QuadrupleDashThick, Nothing, QuadrupleDashThick) => Some("┋")
    (Plain, Nothing, Nothing, Plain) => Some("┌")
    (Thick, Nothing, Nothing, Plain) => Some("┍")
    (Plain, Nothing, Nothing, Thick) => Some("┎")
    (Thick, Nothing, Nothing, Thick) => Some("┏")
    (Nothing, Nothing, Plain, Plain) => Some("┐")
    (Nothing, Nothing, Thick, Plain) => Some("┑")
    (Nothing, Nothing, Plain, Thick) => Some("┒")
    (Nothing, Nothing, Thick, Thick) => Some("┓")
    (Plain, Plain, Nothing, Nothing) => Some("└")
    (Thick, Plain, Nothing, Nothing) => Some("┕")
    (Plain, Thick, Nothing, Nothing) => Some("┖")
    (Thick, Thick, Nothing, Nothing) => Some("┗")
    (Nothing, Plain, Plain, Nothing) => Some("┘")
    (Nothing, Plain, Thick, Nothing) => Some("┙")
    (Nothing, Thick, Plain, Nothing) => Some("┚")
    (Nothing, Thick, Thick, Nothing) => Some("┛")
    (Plain, Plain, Nothing, Plain) => Some("├")
    (Thick, Plain, Nothing, Plain) => Some("┝")
    (Plain, Thick, Nothing, Plain) => Some("┞")
    (Plain, Plain, Nothing, Thick) => Some("┟")
    (Plain, Thick, Nothing, Thick) => Some("┠")
    (Thick, Thick, Nothing, Plain) => Some("┡")
    (Thick, Plain, Nothing, Thick) => Some("┢")
    (Thick, Thick, Nothing, Thick) => Some("┣")
    (Nothing, Plain, Plain, Plain) => Some("┤")
    (Nothing, Plain, Thick, Plain) => Some("┥")
    (Nothing, Thick, Plain, Plain) => Some("┦")
    (Nothing, Plain, Plain, Thick) => Some("┧")
    (Nothing, Thick, Plain, Thick) => Some("┨")
    (Nothing, Thick, Thick, Plain) => Some("┩")
    (Nothing, Plain, Thick, Thick) => Some("┪")
    (Nothing, Thick, Thick, Thick) => Some("┫")
    (Plain, Nothing, Plain, Plain) => Some("┬")
    (Plain, Nothing, Thick, Plain) => Some("┭")
    (Thick, Nothing, Plain, Plain) => Some("┮")
    (Thick, Nothing, Thick, Plain) => Some("┯")
    (Plain, Nothing, Plain, Thick) => Some("┰")
    (Plain, Nothing, Thick, Thick) => Some("┱")
    (Thick, Nothing, Plain, Thick) => Some("┲")
    (Thick, Nothing, Thick, Thick) => Some("┳")
    (Plain, Plain, Plain, Nothing) => Some("┴")
    (Plain, Plain, Thick, Nothing) => Some("┵")
    (Thick, Plain, Plain, Nothing) => Some("┶")
    (Thick, Plain, Thick, Nothing) => Some("┷")
    (Plain, Thick, Plain, Nothing) => Some("┸")
    (Plain, Thick, Thick, Nothing) => Some("┹")
    (Thick, Thick, Plain, Nothing) => Some("┺")
    (Thick, Thick, Thick, Nothing) => Some("┻")
    (Plain, Plain, Plain, Plain) => Some("┼")
    (Plain, Plain, Thick, Plain) => Some("┽")
    (Thick, Plain, Plain, Plain) => Some("┾")
    (Thick, Plain, Thick, Plain) => Some("┿")
    (Plain, Thick, Plain, Plain) => Some("╀")
    (Plain, Plain, Plain, Thick) => Some("╁")
    (Plain, Thick, Plain, Thick) => Some("╂")
    (Plain, Thick, Thick, Plain) => Some("╃")
    (Thick, Thick, Plain, Plain) => Some("╄")
    (Plain, Plain, Thick, Thick) => Some("╅")
    (Thick, Plain, Plain, Thick) => Some("╆")
    (Thick, Thick, Thick, Plain) => Some("╇")
    (Thick, Plain, Thick, Thick) => Some("╈")
    (Plain, Thick, Thick, Thick) => Some("╉")
    (Thick, Thick, Plain, Thick) => Some("╊")
    (Thick, Thick, Thick, Thick) => Some("╋")
    (DoubleDash, Nothing, DoubleDash, Nothing) => Some("╌")
    (DoubleDashThick, Nothing, DoubleDashThick, Nothing) => Some("╍")
    (Nothing, DoubleDash, Nothing, DoubleDash) => Some("╎")
    (Nothing, DoubleDashThick, Nothing, DoubleDashThick) => Some("╏")
    (Double, Nothing, Double, Nothing) => Some("═")
    (Nothing, Double, Nothing, Double) => Some("║")
    (Double, Nothing, Nothing, Plain) => Some("╒")
    (Plain, Nothing, Nothing, Double) => Some("╓")
    (Double, Nothing, Nothing, Double) => Some("╔")
    (Nothing, Nothing, Double, Plain) => Some("╕")
    (Nothing, Nothing, Plain, Double) => Some("╖")
    (Nothing, Nothing, Double, Double) => Some("╗")
    (Double, Plain, Nothing, Nothing) => Some("╘")
    (Plain, Double, Nothing, Nothing) => Some("╙")
    (Double, Double, Nothing, Nothing) => Some("╚")
    (Nothing, Plain, Double, Nothing) => Some("╛")
    (Nothing, Double, Plain, Nothing) => Some("╜")
    (Nothing, Double, Double, Nothing) => Some("╝")
    (Double, Plain, Nothing, Plain) => Some("╞")
    (Plain, Double, Nothing, Double) => Some("╟")
    (Double, Double, Nothing, Double) => Some("╠")
    (Nothing, Plain, Double, Plain) => Some("╡")
    (Nothing, Double, Plain, Double) => Some("╢")
    (Nothing, Double, Double, Double) => Some("╣")
    (Double, Nothing, Double, Plain) => Some("╤")
    (Plain, Nothing, Plain, Double) => Some("╥")
    (Double, Nothing, Double, Double) => Some("╦")
    (Double, Plain, Double, Nothing) => Some("╧")
    (Plain, Double, Plain, Nothing) => Some("╨")
    (Double, Double, Double, Nothing) => Some("╩")
    (Double, Plain, Double, Plain) => Some("╪")
    (Plain, Double, Plain, Double) => Some("╫")
    (Double, Double, Double, Double) => Some("╬")
    (Rounded, Nothing, Nothing, Rounded) => Some("╭")
    (Nothing, Nothing, Rounded, Rounded) => Some("╮")
    (Nothing, Rounded, Rounded, Nothing) => Some("╯")
    (Rounded, Rounded, Nothing, Nothing) => Some("╰")
    (Nothing, Nothing, Plain, Nothing) => Some("╴")
    (Nothing, Plain, Nothing, Nothing) => Some("╵")
    (Plain, Nothing, Nothing, Nothing) => Some("╶")
    (Nothing, Nothing, Nothing, Plain) => Some("╷")
    (Nothing, Nothing, Thick, Nothing) => Some("╸")
    (Nothing, Thick, Nothing, Nothing) => Some("╹")
    (Thick, Nothing, Nothing, Nothing) => Some("╺")
    (Nothing, Nothing, Nothing, Thick) => Some("╻")
    (Thick, Nothing, Plain, Nothing) => Some("╼")
    (Nothing, Plain, Nothing, Thick) => Some("╽")
    (Plain, Nothing, Thick, Nothing) => Some("╾")
    (Nothing, Thick, Nothing, Plain) => Some("╿")
    _ => None
  }
}

///|
/// 线型合并：后符号优先（Nothing 视为缺省），上游 `LineStyle::merge` 喵。
fn LineStyle::merge_with(self : LineStyle, other : LineStyle) -> LineStyle {
  if other is Nothing {
    self
  } else {
    other
  }
}

///|
/// 是否为纯直线（上下/左右各自同型，且有一向为缺省）喵。
fn BorderSymbol::is_straight(self : BorderSymbol) -> Bool {
  (self.up == self.down && self.left == self.right) &&
  (self.up is Nothing || self.left is Nothing)
}

///|
/// 是否为纯角符号（两相邻向同型、另两向缺省）喵。
fn BorderSymbol::is_corner(self : BorderSymbol) -> Bool {
  match (self.up, self.right, self.down, self.left) {
    (up, right, Nothing, Nothing) => up == right
    (Nothing, right, down, Nothing) => right == down
    (Nothing, Nothing, down, left) => down == left
    (up, Nothing, Nothing, left) => up == left
    _ => false
  }
}

///|
/// 任一方向含指定线型喵。
fn BorderSymbol::contains(self : BorderSymbol, style : LineStyle) -> Bool {
  self.up == style ||
  self.right == style ||
  self.down == style ||
  self.left == style
}

///|
/// 把所有 `from` 线型替换为 `to` 喵。
fn BorderSymbol::replace(
  self : BorderSymbol,
  from : LineStyle,
  to : LineStyle,
) -> BorderSymbol {
  BorderSymbol::of(
    if self.right == from {
      to
    } else {
      self.right
    },
    if self.up == from {
      to
    } else {
      self.up
    },
    if self.left == from {
      to
    } else {
      self.left
    },
    if self.down == from {
      to
    } else {
      self.down
    },
  )
}

///|
/// 就近降级：虚线→实线（角符号才保留圆角）、双线/粗线二选一、
/// 不可表示的双线/实线组合二选一（上游 `BorderSymbol::fuzzy`）喵。
fn BorderSymbol::fuzzy(
  self : BorderSymbol,
  other : BorderSymbol,
) -> BorderSymbol {
  let mut self2 = self
  // 虚线只在纯直线上有合成字符
  if !self2.is_straight() {
    self2 = self2
      .replace(DoubleDash, Plain)
      .replace(TripleDash, Plain)
      .replace(QuadrupleDash, Plain)
      .replace(DoubleDashThick, Thick)
      .replace(TripleDashThick, Thick)
      .replace(QuadrupleDashThick, Thick)
  }
  // 圆角只有角符号变体
  if !self2.is_corner() {
    self2 = self2.replace(Rounded, Plain)
  }
  // 双线与粗线没有合成字符：按末次并入的符号二选一
  if self2.contains(Double) && self2.contains(Thick) {
    if other.contains(Double) {
      self2 = self2.replace(Thick, Double)
    } else {
      self2 = self2.replace(Double, Thick)
    }
  }
  // 部分实线+双线组合不可表示：按末次并入的符号二选一
  if self2.to_symbol() is None {
    if other.contains(Double) {
      self2 = self2.replace(Plain, Double)
    } else {
      self2 = self2.replace(Double, Plain)
    }
  }
  self2
}

///|
/// 两个合成符号合并：逐向线型合并后按策略降级（包私有）喵。
fn BorderSymbol::merge_with(
  self : BorderSymbol,
  other : BorderSymbol,
  strategy : MergeStrategy,
) -> BorderSymbol {
  let exact_result = BorderSymbol::of(
    self.right.merge_with(other.right),
    self.up.merge_with(other.up),
    self.left.merge_with(other.left),
    self.down.merge_with(other.down),
  )
  match strategy {
    Replace => other
    Fuzzy => exact_result.fuzzy(other)
    Exact => exact_result
  }
}

///|
/// 合并策略（上游 `symbols::merge::MergeStrategy`）喵。
pub(all) enum MergeStrategy {
  Replace
  Exact
  Fuzzy
} derive(Eq, Debug)

///|
/// 按策略合并两符号（上游 `MergeStrategy::merge`）喵。
///
/// 非 Box Drawing 符号参与时：`Replace` 用后符号；其余策略下
/// 非边框符号优先（"普通文字不被边框吃掉"）喵。
pub fn MergeStrategy::merge(
  self : MergeStrategy,
  prev : String,
  next : String,
) -> String {
  if self is Replace {
    return next
  }
  let prev_symbol = BorderSymbol::parse(prev)
  let next_symbol = BorderSymbol::parse(next)
  match (prev_symbol, next_symbol) {
    (Some(p), Some(n)) =>
      match p.merge_with(n, self).to_symbol() {
        Some(s) => s
        None => next
      }
    (None, Some(_)) => prev
    (_, None) => next
  }
}
