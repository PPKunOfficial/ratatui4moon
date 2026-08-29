///|
/// LineSet 单元测试：复刻 ratatui-v0.30.2 `symbols/line.rs` 内联测试喵。

///|
/// 上游 render 辅助：以集合拼一张 4×4 布线示意图喵。
fn line_set_render(set : LineSet) -> String {
  [
    "\{set.top_left}\{set.horizontal}\{set.horizontal_down}\{set.top_right}",
    "\{set.vertical} \{set.vertical}\{set.vertical}",
    "\{set.vertical_right}\{set.horizontal}\{set.cross}\{set.vertical_left}",
    "\{set.bottom_left}\{set.horizontal}\{set.horizontal_up}\{set.bottom_right}",
  ].join("\n")
}

///|
/// 上游 default：缺省集合为 NORMAL 喵。
test "LineSet 缺省为单线直角" {
  assert_eq(LineSet::default(), LineSet::normal())
}

///|
/// 上游 normal 喵。
test "LineSet 单线直角布线图" {
  inspect(
    line_set_render(LineSet::normal()),
    content="┌─┬┐\n│ ││\n├─┼┤\n└─┴┘",
  )
}

///|
/// 上游 rounded 喵。
test "LineSet 圆角布线图" {
  inspect(
    line_set_render(LineSet::rounded()),
    content="╭─┬╮\n│ ││\n├─┼┤\n╰─┴╯",
  )
}

///|
/// 上游 double 喵。
test "LineSet 双线布线图" {
  inspect(
    line_set_render(LineSet::double()),
    content="╔═╦╗\n║ ║║\n╠═╬╣\n╚═╩╝",
  )
}

///|
/// 上游 thick 喵。
test "LineSet 粗线布线图" {
  inspect(
    line_set_render(LineSet::thick()),
    content="┏━┳┓\n┃ ┃┃\n┣━╋┫\n┗━┻┛",
  )
}
