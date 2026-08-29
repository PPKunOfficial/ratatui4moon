/// 滚动条符号集合（上游 `symbols/scrollbar.rs`）：轨道/滑块/两端
/// 箭头四件套，Scrollbar 组件整组取用喵。
///
/// ```text
/// <--▮------->
/// ^  ^   ^   ^
/// │  │   │   └ end
/// │  │   └──── track
/// │  └──────── thumb
/// └─────────── begin
/// ```

///|
/// 滚动条符号集合（上游 `symbols::scrollbar::Set`）喵。
pub(all) struct ScrollbarSet {
  track : String
  thumb : String
  begin : String
  end : String
} derive(Eq, Debug)

///|
/// 双线竖向集合（上游 `scrollbar::DOUBLE_VERTICAL`：`║` 轨道 +
/// `▲▼` 箭头，VerticalRight/VerticalLeft 缺省）喵。
pub fn ScrollbarSet::double_vertical() -> ScrollbarSet {
  { track: LINE_DOUBLE_VERTICAL, thumb: BLOCK_FULL, begin: "▲", end: "▼" }
}

///|
/// 双线横向集合（上游 `scrollbar::DOUBLE_HORIZONTAL`：`═` 轨道 +
/// `◄►` 箭头，HorizontalBottom/HorizontalTop 缺省）喵。
pub fn ScrollbarSet::double_horizontal() -> ScrollbarSet {
  { track: LINE_DOUBLE_HORIZONTAL, thumb: BLOCK_FULL, begin: "◄", end: "►" }
}

///|
/// 单线竖向集合（上游 `scrollbar::VERTICAL`：`│` 轨道 + `↑↓` 箭头）喵。
pub fn ScrollbarSet::vertical() -> ScrollbarSet {
  { track: LINE_VERTICAL, thumb: BLOCK_FULL, begin: "↑", end: "↓" }
}

///|
/// 单线横向集合（上游 `scrollbar::HORIZONTAL`：`─` 轨道 + `←→` 箭头）喵。
pub fn ScrollbarSet::horizontal() -> ScrollbarSet {
  { track: LINE_HORIZONTAL, thumb: BLOCK_FULL, begin: "←", end: "→" }
}
