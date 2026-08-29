///|
/// 八分块常量锚定（上游 `border::ONE_EIGHTH_*`）喵。
test "八分块常量锚定" {
  inspect(BORDER_ONE_EIGHTH_TOP_EIGHT, content="▔")
  inspect(BORDER_ONE_EIGHTH_BOTTOM_EIGHT, content="▁")
  inspect(BORDER_ONE_EIGHTH_LEFT_EIGHT, content="▏")
  inspect(BORDER_ONE_EIGHTH_RIGHT_EIGHT, content="▕")
}

///|
/// McGugan 宽/瘦体与比例边框抽检（上游 `ONE_EIGHTH_WIDE/TALL`、
/// `PROPORTIONAL_WIDE/TALL` 关键位）喵。
test "McGugan 与比例边框抽检" {
  let wide = BorderSet::one_eighth_wide()
  inspect(wide.horizontal_top, content="▁")
  inspect(wide.horizontal_bottom, content="▔")
  inspect(wide.vertical_left, content="▏")
  let tall = BorderSet::one_eighth_tall()
  inspect(tall.horizontal_top, content="▔")
  inspect(tall.vertical_left, content="▕")
  let pw = BorderSet::proportional_wide()
  inspect(pw.horizontal_top, content="▄")
  inspect(pw.vertical_left, content="█")
  let pt = BorderSet::proportional_tall()
  inspect(pt.horizontal_top, content="▀")
  inspect(pt.vertical_left, content="█")
}

///|
/// 实心/空白边框（上游 `border::FULL`/`EMPTY`）喵。
test "实心与空白边框" {
  let full = BorderSet::full()
  inspect(full.top_left, content="█")
  inspect(full.horizontal_bottom, content="█")
  let empty = BorderSet::empty_set()
  inspect(empty.top_left, content=" ")
  inspect(empty.vertical_right, content=" ")
}

///|
/// render 辅助：以 ░ 占位的 4x4 边框渲染视图（上游 tests::render）喵。
fn border_render(set : BorderSet) -> String {
  let out = StringBuilder()
  out.write_string("░░░░░░\n")
  out.write_string(
    "░\{set.top_left}\{set.horizontal_top}\{set.horizontal_top}\{set.top_right}░\n",
  )
  out.write_string("░\{set.vertical_left}░░\{set.vertical_right}░\n")
  out.write_string("░\{set.vertical_left}░░\{set.vertical_right}░\n")
  out.write_string(
    "░\{set.bottom_left}\{set.horizontal_bottom}\{set.horizontal_bottom}\{set.bottom_right}░\n",
  )
  out.write_string("░░░░░░")
  out.to_string()
}

///|
/// 上游 `one_eighth_wide` 喵。
test "border::ONE_EIGHTH_WIDE 快照" {
  inspect(
    border_render(BorderSet::one_eighth_wide()),
    content=(
      #|░░░░░░
      #|░▁▁▁▁░
      #|░▏░░▕░
      #|░▏░░▕░
      #|░▔▔▔▔░
      #|░░░░░░
    ),
  )
}

///|
/// 上游 `one_eighth_tall` 喵。
test "border::ONE_EIGHTH_TALL 快照" {
  inspect(
    border_render(BorderSet::one_eighth_tall()),
    content=(
      #|░░░░░░
      #|░▕▔▔▏░
      #|░▕░░▏░
      #|░▕░░▏░
      #|░▕▁▁▏░
      #|░░░░░░
    ),
  )
}

///|
/// 上游 `proportional_wide` 喵。
test "border::PROPORTIONAL_WIDE 快照" {
  inspect(
    border_render(BorderSet::proportional_wide()),
    content=(
      #|░░░░░░
      #|░▄▄▄▄░
      #|░█░░█░
      #|░█░░█░
      #|░▀▀▀▀░
      #|░░░░░░
    ),
  )
}

///|
/// 上游 `proportional_tall` 喵。
test "border::PROPORTIONAL_TALL 快照" {
  inspect(
    border_render(BorderSet::proportional_tall()),
    content=(
      #|░░░░░░
      #|░█▀▀█░
      #|░█░░█░
      #|░█░░█░
      #|░█▄▄█░
      #|░░░░░░
    ),
  )
}

///|
/// 上游 `full` 喵。
test "border::FULL 快照" {
  inspect(
    border_render(BorderSet::full()),
    content=(
      #|░░░░░░
      #|░████░
      #|░█░░█░
      #|░█░░█░
      #|░████░
      #|░░░░░░
    ),
  )
}

///|
/// 上游 `empty` 喵。
test "border::EMPTY 快照" {
  inspect(
    border_render(BorderSet::empty_set()),
    content=(
      #|░░░░░░
      #|░    ░
      #|░ ░░ ░
      #|░ ░░ ░
      #|░    ░
      #|░░░░░░
    ),
  )
}
