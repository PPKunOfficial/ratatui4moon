///|
/// Scrollbar 单元测试：复刻 ratatui-v0.30.2 `widgets/scrollbar.rs`
/// 内联测试清单喵。
///
/// 上游 rstest 参数矩阵以 `for` 循环等价承载，用例数据逐条对应喵。

///|
/// 上游 fixture scrollbar_no_arrows：无箭头、`-` 轨道、`#` 滑块喵。
fn scrollbar_no_arrows() -> Scrollbar {
  Scrollbar::new(ScrollbarOrientation::HorizontalTop)
  .begin_symbol(None)
  .end_symbol(None)
  .track_symbol(Some("-"))
  .thumb_symbol("#")
}

///|
/// 渲染辅助：空缓冲 + 指定状态渲染喵。
fn scrollbar_render(
  scrollbar : Scrollbar,
  width : Int,
  height : Int,
  content_length : Int,
  position : Int,
) -> @core.Buffer {
  let area = @core.Rect::new(0, 0, width, height)
  let buffer = @core.Buffer::empty(area)
  let state = ScrollbarState::new(content_length).with_position(position)
  scrollbar.render_stateful(area, buffer, state)
  buffer
}

///|
/// 上游 scroll_direction_to_string / _from_str 喵。
test "ScrollDirection 显示名与解析" {
  inspect(ScrollDirection::Forward.to_display(), content="Forward")
  inspect(ScrollDirection::Backward.to_display(), content="Backward")
  @debug.debug_inspect(
    ScrollDirection::from_str("Forward"),
    content="Some(Forward)",
  )
  @debug.debug_inspect(
    ScrollDirection::from_str("Backward"),
    content="Some(Backward)",
  )
  @debug.debug_inspect(ScrollDirection::from_str(""), content="None")
}

///|
/// 上游 scrollbar_orientation_to_string / _from_str 喵。
test "ScrollbarOrientation 显示名与解析" {
  inspect(
    ScrollbarOrientation::VerticalRight.to_display(),
    content="VerticalRight",
  )
  inspect(
    ScrollbarOrientation::VerticalLeft.to_display(),
    content="VerticalLeft",
  )
  inspect(
    ScrollbarOrientation::HorizontalBottom.to_display(),
    content="HorizontalBottom",
  )
  inspect(
    ScrollbarOrientation::HorizontalTop.to_display(),
    content="HorizontalTop",
  )
  let orientations = [
    ScrollbarOrientation::VerticalRight,
    ScrollbarOrientation::VerticalLeft,
    ScrollbarOrientation::HorizontalBottom,
    ScrollbarOrientation::HorizontalTop,
  ]
  for orientation in orientations {
    @debug.debug_inspect(
      ScrollbarOrientation::from_str(orientation.to_display()),
      content="Some(\{orientation.to_display()})",
    )
  }
  @debug.debug_inspect(ScrollbarOrientation::from_str(""), content="None")
}

///|
/// 上游 render_scrollbar_simplest：2 格轨道两极位置喵。
test "Scrollbar 最简渲染" {
  let cases : Array[(String, Int, Int)] = [("#-", 0, 2), ("-#", 1, 2)]
  for case in cases {
    let buffer = scrollbar_render(
      scrollbar_no_arrows(),
      case.0.length(),
      1,
      case.2,
      case.1,
    )
    assert_eq(buffer, @core.Buffer::with_lines([case.0]))
  }
}

///|
/// 上游 render_scrollbar_simple：10 格轨道滑块步进矩阵喵。
test "Scrollbar 滑块步进矩阵" {
  let cases : Array[(String, Int, Int)] = [
    ("#####-----", 0, 10),
    ("-#####----", 1, 10),
    ("-#####----", 2, 10),
    ("--#####---", 3, 10),
    ("--#####---", 4, 10),
    ("---#####--", 5, 10),
    ("---#####--", 6, 10),
    ("----#####-", 7, 10),
    ("----#####-", 8, 10),
    ("-----#####", 9, 10),
  ]
  for case in cases {
    let buffer = scrollbar_render(
      scrollbar_no_arrows(),
      case.0.length(),
      1,
      case.2,
      case.1,
    )
    assert_eq(buffer, @core.Buffer::with_lines([case.0]))
  }
}

///|
/// 上游 render_scrollbar_nobar：content_length 0 整条不渲染喵。
test "Scrollbar 零内容不渲染" {
  let buffer = scrollbar_render(scrollbar_no_arrows(), 10, 1, 0, 0)
  assert_eq(buffer, @core.Buffer::with_lines(["          "]))
}

///|
/// 上游 render_scrollbar_fullbar / _almost_fullbar：满条与近满条喵。
test "Scrollbar 满条矩阵" {
  let cases : Array[(String, Int, Int)] = [
    ("##########", 0, 1),
    ("#########-", 0, 2),
    ("-#########", 1, 2),
  ]
  for case in cases {
    let buffer = scrollbar_render(
      scrollbar_no_arrows(),
      case.0.length(),
      1,
      case.2,
      case.1,
    )
    assert_eq(buffer, @core.Buffer::with_lines([case.0]))
  }
}

///|
/// 上游 render_scrollbar_without_symbols：缺省双横集合（═ 轨道 /
/// █ 滑块）无箭头，含越界位置收敛喵。
test "Scrollbar 缺省符号矩阵" {
  let cases : Array[(String, Int, Int)] = [
    ("█████═════", 0, 10),
    ("═█████════", 1, 10),
    ("═█████════", 2, 10),
    ("══█████═══", 3, 10),
    ("══█████═══", 4, 10),
    ("═══█████══", 5, 10),
    ("═══█████══", 6, 10),
    ("════█████═", 7, 10),
    ("════█████═", 8, 10),
    ("═════█████", 9, 10),
    ("═════█████", 100, 10),
  ]
  for case in cases {
    let scrollbar = Scrollbar::new(ScrollbarOrientation::HorizontalBottom)
      .begin_symbol(None)
      .end_symbol(None)
    let buffer = scrollbar_render(scrollbar, case.0.length(), 1, case.2, case.1)
    assert_eq(buffer, @core.Buffer::with_lines([case.0]))
  }
}

///|
/// 上游 render_scrollbar_without_track_symbols：轨道关闭，仅滑块
/// 落位，两侧留白喵。
test "Scrollbar 无轨道矩阵" {
  let cases : Array[(String, Int, Int)] = [
    ("█████     ", 0, 10),
    (" █████    ", 1, 10),
    (" █████    ", 2, 10),
    ("  █████   ", 3, 10),
    ("  █████   ", 4, 10),
    ("   █████  ", 5, 10),
    ("   █████  ", 6, 10),
    ("    █████ ", 7, 10),
    ("    █████ ", 8, 10),
    ("     █████", 9, 10),
    ("     █████", 100, 10),
  ]
  for case in cases {
    let scrollbar = Scrollbar::new(ScrollbarOrientation::HorizontalBottom)
      .track_symbol(None)
      .begin_symbol(None)
      .end_symbol(None)
    let buffer = scrollbar_render(scrollbar, case.0.length(), 1, case.2, case.1)
    assert_eq(buffer, @core.Buffer::with_lines([case.0]))
  }
}

///|
/// 上游 render_scrollbar_without_track_symbols_over_content：底衬
/// `-` 字符充当轨道视觉，滚动条只写滑块喵。
test "Scrollbar 无轨道底衬矩阵" {
  let cases : Array[(String, Int, Int)] = [
    ("█████-----", 0, 10),
    ("-█████----", 1, 10),
    ("-█████----", 2, 10),
    ("--█████---", 3, 10),
    ("--█████---", 4, 10),
    ("---█████--", 5, 10),
    ("---█████--", 6, 10),
    ("----█████-", 7, 10),
    ("----█████-", 8, 10),
    ("-----█████", 9, 10),
    ("-----█████", 100, 10),
  ]
  for case in cases {
    let area = @core.Rect::new(0, 0, case.0.length(), 1)
    let buffer = @core.Buffer::empty(area)
    for x in 0..<area.width {
      match buffer.mut_cell(x, 0) {
        Some(cell) => cell.set_symbol("-")
        None => ()
      }
    }
    let scrollbar = Scrollbar::new(ScrollbarOrientation::HorizontalBottom)
      .track_symbol(None)
      .begin_symbol(None)
      .end_symbol(None)
    let state = ScrollbarState::new(case.2).with_position(case.1)
    scrollbar.render_stateful(area, buffer, state)
    assert_eq(buffer, @core.Buffer::with_lines([case.0]))
  }
}

///|
/// 上游 render_scrollbar_with_symbols：`<#->` 四件套横向矩阵，含
/// 10/15/500 三档越界收敛喵。
test "Scrollbar 带箭头横向矩阵" {
  let cases : Array[(String, Int, Int)] = [
    ("<####---->", 0, 10),
    ("<####---->", 1, 10),
    ("<-####--->", 2, 10),
    ("<-####--->", 3, 10),
    ("<--####-->", 4, 10),
    ("<--####-->", 5, 10),
    ("<---####->", 6, 10),
    ("<---####->", 7, 10),
    ("<---####->", 8, 10),
    ("<----####>", 9, 10),
    ("<----####>", 10, 10),
    ("<----####>", 15, 10),
    ("<----####>", 500, 10),
  ]
  for case in cases {
    let scrollbar = Scrollbar::new(ScrollbarOrientation::HorizontalTop)
      .begin_symbol(Some("<"))
      .end_symbol(Some(">"))
      .track_symbol(Some("-"))
      .thumb_symbol("#")
    let buffer = scrollbar_render(scrollbar, case.0.length(), 1, case.2, case.1)
    assert_eq(buffer, @core.Buffer::with_lines([case.0]))
  }
}

///|
/// 上游 render_scrollbar_horizontal_bottom：双行区域贴底渲染喵。
test "Scrollbar 横向贴底" {
  let cases : Array[(String, Int, Int)] = [
    ("█████═════", 0, 10),
    ("═█████════", 1, 10),
    ("═█████════", 2, 10),
    ("══█████═══", 3, 10),
    ("══█████═══", 4, 10),
    ("═══█████══", 5, 10),
    ("═══█████══", 6, 10),
    ("════█████═", 7, 10),
    ("════█████═", 8, 10),
    ("═════█████", 9, 10),
    ("═════█████", 100, 10),
  ]
  for case in cases {
    let scrollbar = Scrollbar::new(ScrollbarOrientation::HorizontalBottom)
      .begin_symbol(None)
      .end_symbol(None)
    let buffer = scrollbar_render(scrollbar, case.0.length(), 2, case.2, case.1)
    let blank = " ".repeat(case.0.length())
    assert_eq(buffer, @core.Buffer::with_lines([blank, case.0]))
  }
}

///|
/// 上游 render_scrollbar_horizontal_top：双行区域贴顶渲染喵。
test "Scrollbar 横向贴顶" {
  let cases : Array[(String, Int, Int)] = [
    ("█████═════", 0, 10),
    ("═█████════", 1, 10),
    ("═█████════", 2, 10),
    ("══█████═══", 3, 10),
    ("══█████═══", 4, 10),
    ("═══█████══", 5, 10),
    ("═══█████══", 6, 10),
    ("════█████═", 7, 10),
    ("════█████═", 8, 10),
    ("═════█████", 9, 10),
    ("═════█████", 100, 10),
  ]
  for case in cases {
    let scrollbar = Scrollbar::new(ScrollbarOrientation::HorizontalTop)
      .begin_symbol(None)
      .end_symbol(None)
    let buffer = scrollbar_render(scrollbar, case.0.length(), 2, case.2, case.1)
    let blank = " ".repeat(case.0.length())
    assert_eq(buffer, @core.Buffer::with_lines([case.0, blank]))
  }
}

///|
/// 上游 render_scrollbar_vertical_left / _vertical_right：纵向左右
/// 两缘矩阵，含三档越界收敛喵。
test "Scrollbar 纵向左右矩阵" {
  let cases : Array[(String, Int, Int)] = [
    ("<####---->", 0, 10),
    ("<####---->", 1, 10),
    ("<-####--->", 2, 10),
    ("<-####--->", 3, 10),
    ("<--####-->", 4, 10),
    ("<--####-->", 5, 10),
    ("<---####->", 6, 10),
    ("<---####->", 7, 10),
    ("<---####->", 8, 10),
    ("<----####>", 9, 10),
    ("<----####>", 10, 10),
    ("<----####>", 15, 10),
    ("<----####>", 500, 10),
  ]
  for case in cases {
    for
      orientation in [
        ScrollbarOrientation::VerticalLeft,
        ScrollbarOrientation::VerticalRight,
      ] {
      let scrollbar = Scrollbar::new(orientation)
        .begin_symbol(Some("<"))
        .end_symbol(Some(">"))
        .track_symbol(Some("-"))
        .thumb_symbol("#")
      let buffer = scrollbar_render(
        scrollbar,
        5,
        case.0.length(),
        case.2,
        case.1,
      )
      let rows : Array[String] = []
      for c in case.0.iter() {
        rows.push(
          match orientation {
            ScrollbarOrientation::VerticalLeft => "\{c}    "
            ScrollbarOrientation::VerticalRight => "    \{c}"
            _ => ""
          },
        )
      }
      assert_eq(buffer, @core.Buffer::with_lines(rows))
    }
  }
}

///|
/// 上游 custom_viewport_length：视口长度 2 的滑块步进矩阵喵。
test "Scrollbar 自定义视口长度" {
  let cases : Array[(String, Int, Int)] = [
    ("##--------", 0, 10),
    ("-##-------", 1, 10),
    ("--##------", 2, 10),
    ("---##-----", 3, 10),
    ("----##----", 4, 10),
    ("-----##---", 5, 10),
    ("-----##---", 6, 10),
    ("------##--", 7, 10),
    ("-------##-", 8, 10),
    ("--------##", 9, 10),
    ("--------##", 10, 10),
  ]
  for case in cases {
    let area = @core.Rect::new(0, 0, case.0.length(), 1)
    let buffer = @core.Buffer::empty(area)
    let state = ScrollbarState::new(case.2)
      .with_position(case.1)
      .with_viewport_content_length(2)
    scrollbar_no_arrows().render_stateful(area, buffer, state)
    assert_eq(buffer, @core.Buffer::with_lines([case.0]))
  }
}

///|
/// 上游 thumb_visible_on_very_small_track：内容远长于视口时滑块
/// 保底可见（PR #959 回归）喵。
test "Scrollbar 极小轨道滑块可见" {
  let cases : Array[(String, Int, Int)] = [
    ("#----", 0, 100),
    ("#----", 10, 100),
    ("-#---", 20, 100),
    ("-#---", 30, 100),
    ("--#--", 40, 100),
    ("--#--", 50, 100),
    ("---#-", 60, 100),
    ("---#-", 70, 100),
    ("----#", 80, 100),
    ("----#", 90, 100),
    ("----#", 100, 100),
  ]
  for case in cases {
    let area = @core.Rect::new(0, 0, case.0.length(), 1)
    let buffer = @core.Buffer::empty(area)
    let state = ScrollbarState::new(case.2)
      .with_position(case.1)
      .with_viewport_content_length(2)
    scrollbar_no_arrows().render_stateful(area, buffer, state)
    assert_eq(buffer, @core.Buffer::with_lines([case.0]))
  }
}

///|
/// 上游 do_not_render_with_empty_area：零宽/零高区域不 panic 喵。
test "Scrollbar 空区域不渲染" {
  let scrollbar = Scrollbar::new(ScrollbarOrientation::VerticalRight)
    .begin_symbol(Some("<"))
    .end_symbol(Some(">"))
    .track_symbol(Some("-"))
    .thumb_symbol("#")
  for dimensions in [(10, 0), (0, 10)] {
    let zero_area = @core.Rect::new(0, 0, dimensions.0, dimensions.1)
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 10))
    let state = ScrollbarState::new(10)
    scrollbar.render_stateful(zero_area, buffer, state)
  }
}

///|
/// 上游 render_in_minimal_buffer：1×1 缓冲四方位不 panic 喵。
test "Scrollbar 极小缓冲渲染" {
  for
    orientation in [
      ScrollbarOrientation::VerticalLeft,
      ScrollbarOrientation::VerticalRight,
      ScrollbarOrientation::HorizontalTop,
      ScrollbarOrientation::HorizontalBottom,
    ] {
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 1, 1))
    let scrollbar = Scrollbar::new(orientation)
    let state = ScrollbarState::new(10).with_position(5)
    scrollbar.render_stateful(buffer.area, buffer, state)
    assert_eq(buffer, @core.Buffer::with_lines([" "]))
  }
}

///|
/// 上游 render_in_zero_size_buffer：零尺寸缓冲四方位不 panic 喵。
test "Scrollbar 零尺寸缓冲渲染" {
  for
    orientation in [
      ScrollbarOrientation::VerticalLeft,
      ScrollbarOrientation::VerticalRight,
      ScrollbarOrientation::HorizontalTop,
      ScrollbarOrientation::HorizontalBottom,
    ] {
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 0, 0))
    let scrollbar = Scrollbar::new(orientation)
    let state = ScrollbarState::new(10).with_position(5)
    scrollbar.render_stateful(buffer.area, buffer, state)
  }
}

///|
/// 上游 part_lengths_returns_zeros_when_track_len_is_zero / _when_
/// area_dimension_is_zero_even_without_arrows：轨道长度归零时三段
/// 全零喵。
///
/// 不可移植登记：上游对包私有 `part_lengths` 直断元组；本库
/// `*_test.mbt` 仅见 `pub` API，以渲染等价承载——轨道归零即整条
/// 不渲染，目标区域保持空白喵。
test "Scrollbar 零轨道不渲染" {
  let scrollbar = Scrollbar::new(ScrollbarOrientation::HorizontalTop)
    .begin_symbol(Some("<"))
    .end_symbol(Some(">"))
    .track_symbol(Some("-"))
    .thumb_symbol("#")
  let state = ScrollbarState::new(10)
    .with_position(5)
    .with_viewport_content_length(2)
  let cases : Array[(ScrollbarOrientation, @core.Rect)] = [
    (ScrollbarOrientation::HorizontalTop, @core.Rect::new(0, 0, 2, 1)),
    (ScrollbarOrientation::HorizontalTop, @core.Rect::new(0, 0, 1, 1)),
    (ScrollbarOrientation::VerticalLeft, @core.Rect::new(0, 0, 1, 2)),
    (ScrollbarOrientation::VerticalLeft, @core.Rect::new(0, 0, 1, 1)),
  ]
  for case in cases {
    let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 10))
    scrollbar.render_stateful(case.1, buffer, state)
    assert_eq(buffer, @core.Buffer::empty(@core.Rect::new(0, 0, 10, 10)))
  }
  let no_arrows = Scrollbar::new(ScrollbarOrientation::HorizontalTop)
    .begin_symbol(None)
    .end_symbol(None)
    .track_symbol(Some("-"))
    .thumb_symbol("#")
  let state2 = ScrollbarState::new(10)
    .with_position(3)
    .with_viewport_content_length(2)
  let buffer = @core.Buffer::empty(@core.Rect::new(0, 0, 10, 10))
  no_arrows.render_stateful(@core.Rect::new(0, 0, 0, 1), buffer, state2)
  assert_eq(buffer, @core.Buffer::empty(@core.Rect::new(0, 0, 10, 10)))
}

///|
/// 上游 thumb_stays_within_track_for_large_thumb_at_end +
/// render_scrollbar_keeps_end_symbol_for_large_thumb：issue #2582
/// 回归——大滑块贴底不越轨、end 箭头不被挤掉（渲染级等价承载：
/// 三段和恒等于轨道长由 end 箭头原位可见佐证）喵。
test "Scrollbar 大滑块贴底回归" {
  let scrollbar = Scrollbar::new(ScrollbarOrientation::HorizontalTop)
    .begin_symbol(Some("<"))
    .end_symbol(Some(">"))
    .track_symbol(Some("-"))
    .thumb_symbol("#")
  let rendered = scrollbar_render(scrollbar, 24, 1, 9, 8)
  assert_eq(rendered, @core.Buffer::with_lines(["<-----#################>"]))
}
