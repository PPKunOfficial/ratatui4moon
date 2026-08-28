///|
/// 块内边距（上游 `block::Padding`）：内容区四周各让出的格数喵。
pub(all) struct Padding {
  left : Int
  right : Int
  top : Int
  bottom : Int
} derive(Eq, Debug)

///|
/// 零边距（上游 `Padding::ZERO`）喵。
pub fn Padding::zero() -> Padding {
  Padding::new(0, 0, 0, 0)
}

///|
/// 逐边构造（上游 `Padding::new`）喵。
pub fn Padding::new(
  left : Int,
  right : Int,
  top : Int,
  bottom : Int,
) -> Padding {
  { left, right, top, bottom }
}

///|
/// 水平边距（上游 `Padding::horizontal`）喵。
pub fn Padding::horizontal(value : Int) -> Padding {
  Padding::new(value, value, 0, 0)
}

///|
/// 垂直边距（上游 `Padding::vertical`）喵。
pub fn Padding::vertical(value : Int) -> Padding {
  Padding::new(0, 0, value, value)
}

///|
/// 四边等距（上游 `Padding::uniform`，亦即 `From<u16>`）喵。
pub fn Padding::uniform(value : Int) -> Padding {
  Padding::new(value, value, value, value)
}

///|
/// 按比例边距：水平取 2 倍、垂直取原值（上游 `Padding::proportional`）喵。
pub fn Padding::proportional(value : Int) -> Padding {
  Padding::new(value * 2, value * 2, value, value)
}

///|
/// 水平垂直分别指定（上游 `Padding::symmetric`）喵。
pub fn Padding::symmetric(horizontal : Int, vertical : Int) -> Padding {
  Padding::new(horizontal, horizontal, vertical, vertical)
}

///|
/// 仅左边（上游 `Padding::left`）喵。
pub fn Padding::left(value : Int) -> Padding {
  Padding::new(value, 0, 0, 0)
}

///|
/// 仅右边（上游 `Padding::right`）喵。
pub fn Padding::right(value : Int) -> Padding {
  Padding::new(0, value, 0, 0)
}

///|
/// 仅上边（上游 `Padding::top`）喵。
pub fn Padding::top(value : Int) -> Padding {
  Padding::new(0, 0, value, 0)
}

///|
/// 仅下边（上游 `Padding::bottom`）喵。
pub fn Padding::bottom(value : Int) -> Padding {
  Padding::new(0, 0, 0, value)
}
