// Block 阴影（上游 `block/shadow.rs`）：Block 后方可配置的阴影层，
// 先铺样式、再按效果改写符号/背景喵。
//
// 载体折算登记：
// - 上游 `Effect::Custom(Arc<dyn CellEffect>)` 以"注册表 + id 寻址"
//   承载（MoonBit 闭包无 Eq/Debug，闭包本体不入派生类型；id 结构
//   相等 ≡ 上游 `Arc::ptr_eq` 的对象同一性语义）；注册表随
//   Shadow::custom 调用单调追加，生命周期与进程一致（上游 Arc 随
//   Shadow 释放，本库登记为已知偏差）；
// - 上游 Shadow 的 Hash 不承载（MoonBit 无 Hash 派生，消费方为零）。

///|
/// 阴影效果契约（上游 `CellEffect` trait）：对阴影区域单元格施加
/// 自定义改写喵。
pub(open) trait CellEffect {
  fn apply(
    Self,
    shadow_area : @core.Rect,
    base_area : @core.Rect,
    buf : @core.Buffer,
  ) -> Unit
}

///|
/// 自定义效果注册表：Custom 变体以 id 寻址闭包喵。
let custom_effects : Array[(@core.Rect, @core.Rect, @core.Buffer) -> Unit] = []

///|
/// 阴影效果（上游 `Effect`）：Overlay 仅样式、Symbol 填符号、
/// Custom 用户效果喵。
pub(all) enum Effect {
  Overlay
  Symbol(String)
  Custom(Int)
} derive(Eq, Debug)

///|
/// 阴影（上游 `Shadow`）：效果 + 样式 + 相对原区域的偏移喵。
pub(all) struct Shadow {
  effect : Effect
  style : @core.Style
  offset : @core.Offset
} derive(Eq, Debug)

///|
/// 仅应用样式的阴影（上游 `Shadow::overlay`）：不改写符号喵。
pub fn Shadow::overlay() -> Shadow {
  {
    effect: Overlay,
    style: @core.Style::new(),
    offset: @core.Offset::new(1, 1),
  }
}

///|
/// 全块符号填充阴影（上游 `Shadow::block`）喵。
pub fn Shadow::block() -> Shadow {
  Shadow::symbol(@core.SHADE_FULL)
}

///|
/// 浅色 shade 填充阴影（上游 `Shadow::light_shade`）喵。
pub fn Shadow::light_shade() -> Shadow {
  Shadow::symbol(@core.SHADE_LIGHT)
}

///|
/// 中色 shade 填充阴影（上游 `Shadow::medium_shade`）喵。
pub fn Shadow::medium_shade() -> Shadow {
  Shadow::symbol(@core.SHADE_MEDIUM)
}

///|
/// 深色 shade 填充阴影（上游 `Shadow::dark_shade`）喵。
pub fn Shadow::dark_shade() -> Shadow {
  Shadow::symbol(@core.SHADE_DARK)
}

///|
/// 以给定符号填充的阴影（上游 `Shadow::symbol`）喵。
pub fn Shadow::symbol(symbol : String) -> Shadow {
  {
    effect: Symbol(symbol),
    style: @core.Style::new(),
    offset: @core.Offset::new(1, 1),
  }
}

///|
/// 以自定义效果创建阴影（上游 `Shadow::custom`）喵。
pub fn Shadow::custom(effect : &CellEffect) -> Shadow {
  custom_effects.push((shadow_area, base_area, buf) => {
    effect.apply(shadow_area, base_area, buf)
  })
  {
    effect: Custom(custom_effects.length() - 1),
    style: @core.Style::new(),
    offset: @core.Offset::new(1, 1),
  }
}

///|
/// 以自定义效果创建阴影（上游 `Shadow::new`，`custom` 别名）喵。
pub fn Shadow::new(effect : &CellEffect) -> Shadow {
  Shadow::custom(effect)
}

///|
/// 缺省阴影（上游 `Shadow::default` = `overlay`）喵。
pub fn Shadow::default() -> Shadow {
  Shadow::overlay()
}

///|
/// 设阴影区样式（上游 `Shadow::style`）喵。
pub fn Shadow::style(self : Shadow, style : @core.Style) -> Shadow {
  { ..self, style, }
}

///|
/// 设阴影偏移（上游 `Shadow::offset`）：横向正值向右、纵向正值
/// 向下喵。
pub fn Shadow::offset(self : Shadow, offset : @core.Offset) -> Shadow {
  { ..self, offset, }
}

///|
/// Widget 实现（上游 `impl Widget for &Shadow`）：阴影区 = 原区域
/// 偏移后与缓冲相交；先铺样式再应用效果，与原区域重叠的格子跳过喵。
pub impl @core.Widget for Shadow with fn render(self, area, buf) {
  let shadow_area = area.offset(self.offset).intersection(buf.area)
  for_each_shadow_cell(shadow_area, area, buf, (x, y, buf) => {
    match buf.mut_cell(x, y) {
      Some(cell) => cell.set_style(self.style)
      None => ()
    }
  })
  match self.effect {
    Overlay => ()
    Symbol(symbol) =>
      for_each_shadow_cell(shadow_area, area, buf, (x, y, buf) => {
        match buf.mut_cell(x, y) {
          Some(cell) => cell.set_symbol(symbol)
          None => ()
        }
      })
    Custom(id) =>
      if id >= 0 && id < custom_effects.length() {
        custom_effects[id](shadow_area, area, buf)
      }
  }
}

///|
/// 变暗效果（上游 `Dimmed`）：置 DIM 修饰位；RGB 背景逐通道减半，
/// 其余背景换纯黑喵。
pub(all) struct Dimmed {
  priv _unit : Unit
} derive(Eq, Debug)

///|
/// 创建 `Dimmed` 效果（上游 `dimmed()`）喵。
pub fn dimmed() -> Dimmed {
  { _unit: () }
}

///|
/// CellEffect 实现（上游 `impl CellEffect for Dimmed`）喵。
pub impl CellEffect for Dimmed with fn apply(
  _self : Dimmed,
  shadow_area : @core.Rect,
  base_area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  for_each_shadow_cell(shadow_area, base_area, buf, (x, y, buf) => {
    match buf.mut_cell(x, y) {
      Some(cell) => {
        cell.modifier = cell.modifier.insert(@core.Modifier::dim())
        match cell.bg {
          @core.Rgb(r, g, b) => cell.bg = @core.Rgb(r / 2, g / 2, b / 2)
          _ => cell.bg = @core.Black
        }
      }
      None => ()
    }
  })
}

///|
/// 遍历阴影区且跳过与原区域重叠的格子（上游 `for_each_shadow_cell`，
/// 包私有）喵。
fn for_each_shadow_cell(
  shadow_area : @core.Rect,
  base_area : @core.Rect,
  buf : @core.Buffer,
  f : (Int, Int, @core.Buffer) -> Unit,
) -> Unit {
  for y in shadow_area.top()..<shadow_area.bottom() {
    for x in shadow_area.left()..<shadow_area.right() {
      if base_area.contains(@core.Position::new(x, y)) {
        continue
      }
      f(x, y, buf)
    }
  }
}
