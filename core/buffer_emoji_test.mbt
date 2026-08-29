// 上游 `buffer/buffer.rs` 与 `buffer/diff.rs` 中依赖真实 emoji/VS16
// 宽度语义的测试，随 `unicode/` 全量宽度表落位补齐（此前登记于
// buffer_test.mbt 头注释"待复刻"）喵。

///|
/// 上游 `renders_emoji`（rstest 四组）：emoji/VS16/ZWJ 序列按单簇
/// 写入，隐藏尾列复位为空白喵。
test "set_string 渲染 emoji 序列" {
  let cases = [
    ("🤷", "🤷xxxxx"),
    ("🐻‍❄️", "🐻‍❄️xxxxx"),
    ("👁️‍🗨️", "👁️‍🗨️xxxxx"),
    ("⌨️", "⌨️xxxxx"),
  ]
  for case in cases {
    let (input, expected) = case
    let buffer = Buffer::filled(Rect::new(0, 0, 7, 1), Cell::of("x"))
    ignore(buffer.set_string(0, 0, input, Style::new()))
    assert_eq(buffer, Buffer::with_lines([expected]))
  }
}

///|
/// 上游 `diff_clears_trailing_cell_for_wide_grapheme`：宽图形簇
/// 覆写窄文本后，diff 同时给出首格与被清空的尾格喵。
test "diff 宽图形簇清除尾列" {
  let prev = Buffer::with_lines(["ab"])
  inspect(prev.area.width, content="2")
  let next = Buffer::with_lines(["  "])
  ignore(next.set_string(0, 0, "⌨️", Style::new()))
  assert_eq(next, Buffer::with_lines(["⌨️"]))
  let diff = prev.diff(next)
  let has_head = {
    let mut found = false
    for entry in diff {
      let (x, y, cell) = entry
      if x == 0 && y == 0 && cell.symbol() == "⌨️" {
        found = true
      }
    }
    found
  }
  inspect(has_head, content="true")
  let has_cleared_trailing = {
    let mut found = false
    for entry in diff {
      let (x, y, cell) = entry
      if x == 1 && y == 0 && cell.symbol() == " " {
        found = true
      }
    }
    found
  }
  inspect(has_cleared_trailing, content="true")
}

///|
/// 上游 `diff_ignores_style_only_changes_in_trailing_cells`：宽
/// VS16 emoji 的隐藏尾列符号不变仅样式变时，不产生 diff 更新喵。
test "diff 忽略尾列纯样式变化" {
  let rect = Rect::new(0, 0, 3, 1)
  let prev = Buffer::empty(rect)
  match prev.mut_cell(0, 0) {
    Some(cell) => {
      cell.set_symbol(" ")
      cell.set_fg(LightBlue)
    }
    None => ()
  }
  match prev.mut_cell(1, 0) {
    Some(cell) => {
      cell.set_symbol(" ")
      cell.set_fg(LightBlue)
    }
    None => ()
  }
  match prev.mut_cell(2, 0) {
    Some(cell) => cell.set_symbol("x")
    None => ()
  }
  let next = Buffer::empty(rect)
  match next.mut_cell(0, 0) {
    Some(cell) => {
      cell.set_symbol("⚠️")
      cell.set_fg(Reset)
    }
    None => ()
  }
  match next.mut_cell(1, 0) {
    Some(cell) => {
      cell.set_symbol(" ")
      cell.set_fg(Reset)
    }
    None => ()
  }
  match next.mut_cell(2, 0) {
    Some(cell) => cell.set_symbol("x")
    None => ()
  }
  let diff = prev.diff(next)
  let has_head = {
    let mut found = false
    for entry in diff {
      let (x, _, _) = entry
      if x == 0 {
        found = true
      }
    }
    found
  }
  inspect(has_head, content="true")
  let has_trailing = {
    let mut found = false
    for entry in diff {
      let (x, _, _) = entry
      if x == 1 {
        found = true
      }
    }
    found
  }
  inspect(has_trailing, content="false")
}

///|
/// 上游 `vs16_trailing_cell_unchanged`（buffer/diff.rs）：两缓冲
/// 仅主格样式不同时，diff 恰含一条更新（尾列完全一致不出现）喵。
test "diff VS16 尾列不变" {
  let rect = Rect::new(0, 0, 4, 1)
  let prev = Buffer::empty(rect)
  ignore(prev.set_string(0, 0, "⌨️", Style::new()))
  ignore(prev.set_string(2, 0, "ab", Style::new()))
  let next = Buffer::empty(rect)
  ignore(next.set_string(0, 0, "⌨️", Style::new().fg(Red)))
  ignore(next.set_string(2, 0, "ab", Style::new()))
  let diff = prev.diff(next)
  inspect(diff.length(), content="1")
  let (x, y, _) = diff[0]
  inspect(x, content="0")
  inspect(y, content="0")
}
