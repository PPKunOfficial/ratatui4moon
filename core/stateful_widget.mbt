///|
/// 带状态组件（上游 `widgets::StatefulWidget` 的 MoonBit 形式化）喵。
///
/// 上游以关联类型承载：`impl StatefulWidget for List { type State =
/// ListState }`，状态按帧以 `&mut` 借用。MoonBit trait 暂无关联类型
/// 与类型参数，等价形式化：**状态显式打包进组件值**
/// `Stateful[W, S]`，各组件对具体实例化实现本 trait（如
/// `impl StatefulWidget for Stateful[List, ListState]`）。
/// 所有权模型差异（状态由包装值持有而非按帧借用）已登记 parity.md 喵。
pub(open) trait StatefulWidget {
  fn render(Self, Rect, Buffer) -> Unit
}

///|
/// 状态打包组件：组件 + 其状态（上游 `type State` 关联的等价形态）喵。
pub(all) struct Stateful[W, S] {
  widget : W
  mut state : S
}

///|
/// 构造带状态组件（上游 `render_widget(widget.with_state(state))` 位）喵。
pub fn[W, S] Stateful::of(widget : W, state : S) -> Stateful[W, S] {
  { widget, state }
}

///|
/// 读状态喵。
pub fn[W, S] Stateful::state(self : Stateful[W, S]) -> S {
  self.state
}

///|
/// 写状态（渲染后由调用方检查滚动/选中结果）喵。
pub fn[W, S] Stateful::set_state(self : Stateful[W, S], state : S) -> Unit {
  self.state = state
}
