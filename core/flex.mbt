///|
/// 布局弹性对齐模式（上游 `layout::Flex`）：约束总长不足/超出
/// 区域时的剩余空间分配方式，缺省 `Start`（左/上对齐，等价旧版
/// Legacy 在等分时的行为差异见上游文档）喵。
pub(all) enum Flex {
  Legacy
  Start
  End
  Center
  SpaceBetween
  SpaceEvenly
  SpaceAround
} derive(Eq, Debug)

///|
/// Display 语义（上游 strum Display：变体名）喵。
pub fn Flex::to_display(self : Flex) -> String {
  match self {
    Legacy => "Legacy"
    Start => "Start"
    End => "End"
    Center => "Center"
    SpaceBetween => "SpaceBetween"
    SpaceEvenly => "SpaceEvenly"
    SpaceAround => "SpaceAround"
  }
}

///|
/// 缺省弹性模式（上游 `Flex::default` = `Start`）喵。
pub fn Flex::default() -> Flex {
  Start
}
