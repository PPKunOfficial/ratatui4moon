///|
/// Rect 单元测试：逐条复刻 ratatui-v0.30.2 `layout/rect.rs` 与 `rect/ops.rs`
/// 的测试清单喵。
///
/// 参照上游 pinned 于 `/Users/pp/projects/ratatui`（tag `ratatui-v0.30.2`）。
/// 坐标域用 Int 承装，但保留上游 `u16` 饱和语义（`MAX_COORD = 65535`）；
/// Display 断言走 `to_display`；结构体相等断言走 `@debug.assert_eq`。
/// 依赖 Layout 求解器的 `split`/`centered`/`layout` 系列留待 `layout/`
/// 包落位后复刻喵。

///|
/// 上游 to_string：Display 格式 `宽x高+X+Y` 喵。
test "Rect::to_display 格式为 宽x高+X+Y" {
  inspect(Rect::new(1, 2, 3, 4).to_display(), content="3x4+1+2")
}

///|
/// 上游 new：构造字段原样落位喵。
test "Rect::new 构造" {
  @debug.assert_eq(Rect::new(1, 2, 3, 4), { x: 1, y: 2, width: 3, height: 4 })
}

///|
/// 上游 area：宽 × 高 喵。
test "Rect::area 面积" {
  @debug.assert_eq(Rect::new(1, 2, 3, 4).area(), 12L)
}

///|
/// 上游 is_empty：宽或高为零即空喵。
test "Rect::is_empty 判空" {
  inspect(Rect::new(1, 2, 3, 4).is_empty(), content="false")
  inspect(Rect::new(1, 2, 0, 4).is_empty(), content="true")
  inspect(Rect::new(1, 2, 3, 0).is_empty(), content="true")
}

///|
/// 上游 left/top：左上角原样返回喵。
test "Rect::left 与 Rect::top" {
  inspect(Rect::new(1, 2, 3, 4).left(), content="1")
  inspect(Rect::new(1, 2, 3, 4).top(), content="2")
}

///|
/// 上游 right/bottom：第一条区域外坐标喵。
test "Rect::right 与 Rect::bottom" {
  inspect(Rect::new(1, 2, 3, 4).right(), content="4")
  inspect(Rect::new(1, 2, 3, 4).bottom(), content="6")
}

///|
/// 上游 inner：四边各收 margin，收不下退化为零区域喵。
test "Rect::inner 收边" {
  @debug.assert_eq(
    Rect::new(1, 2, 3, 4).inner(Margin::new(1, 2)),
    Rect::new(2, 4, 1, 0),
  )
}

///|
/// 上游 outer：四边各扩 margin，左/上饱和时截宽高，右/下饱和截断喵。
test "Rect::outer 扩边" {
  // 四周都有空间可扩
  @debug.assert_eq(
    Rect::new(100, 200, 10, 20).outer(Margin::new(20, 30)),
    Rect::new(80, 170, 50, 80),
  )
  // 左/上饱和：尺寸按可扩量截断
  @debug.assert_eq(
    Rect::new(10, 20, 10, 20).outer(Margin::new(20, 30)),
    Rect::new(0, 0, 40, 70),
  )
  // 右/下饱和：右/下边界不出 u16 上限
  @debug.assert_eq(
    Rect::new(MAX_COORD - 20, MAX_COORD - 40, 10, 20).outer(Margin::new(20, 30)),
    Rect::new(MAX_COORD - 40, MAX_COORD - 70, 40, 70),
  )
}

///|
/// 上游 offset：整体平移不改尺寸喵。
test "Rect::offset 平移" {
  @debug.assert_eq(
    Rect::new(1, 2, 3, 4).offset(Offset::new(5, 6)),
    Rect::new(6, 8, 3, 4),
  )
}

///|
/// 上游 negative_offset：负向平移喵。
test "Rect::offset 负向平移" {
  @debug.assert_eq(
    Rect::new(4, 3, 3, 4).offset(Offset::new(-2, -1)),
    Rect::new(2, 2, 3, 4),
  )
}

///|
/// 上游 negative_offset_saturate：负向越界饱和到原点喵。
test "Rect::offset 负向越界饱和" {
  @debug.assert_eq(
    Rect::new(1, 2, 3, 4).offset(Offset::new(-5, -6)),
    Rect::new(0, 0, 3, 4),
  )
}

///|
/// 上游 offset_saturate_max：正向越界保持尺寸不出界喵。
test "Rect::offset 正向越界饱和" {
  @debug.assert_eq(
    Rect::new(MAX_COORD - 500, MAX_COORD - 500, 100, 100).offset(
      Offset::new(1000, 1000),
    ),
    Rect::new(MAX_COORD - 100, MAX_COORD - 100, 100, 100),
  )
}

///|
/// 上游 union：并集外接矩形喵。
test "Rect::union 并集" {
  @debug.assert_eq(
    Rect::new(1, 2, 3, 4).union(Rect::new(2, 3, 4, 5)),
    Rect::new(1, 2, 5, 6),
  )
}

///|
/// 上游 intersection：交集喵。
test "Rect::intersection 交集" {
  @debug.assert_eq(
    Rect::new(1, 2, 3, 4).intersection(Rect::new(2, 3, 4, 5)),
    Rect::new(2, 3, 2, 3),
  )
}

///|
/// 上游 intersection_underflow：不相交时退化为零面积喵。
test "Rect::intersection 不相交退化" {
  @debug.assert_eq(
    Rect::new(1, 1, 2, 2).intersection(Rect::new(4, 4, 2, 2)),
    Rect::new(4, 4, 0, 0),
  )
}

///|
/// 上游 intersects：边界相接也算相交喵。
test "Rect::intersects 判交" {
  inspect(
    Rect::new(1, 2, 3, 4).intersects(Rect::new(2, 3, 4, 5)),
    content="true",
  )
  inspect(
    Rect::new(1, 2, 3, 4).intersects(Rect::new(5, 6, 7, 8)),
    content="false",
  )
}

///|
/// 上游 mutual_intersect：intersection/intersects 双向对称喵。
test "Rect 相交关系双向对称" {
  let cases = [
    (Rect::new(0, 0, 10, 10), Rect::new(10, 10, 20, 20)),
    (Rect::new(0, 0, 10, 10), Rect::new(10, 0, 20, 10)),
    (Rect::new(0, 0, 10, 10), Rect::new(11, 11, 20, 20)),
    (Rect::new(0, 0, 20, 20), Rect::new(5, 5, 10, 10)),
  ]
  for case in cases {
    let (r0, r1) = case
    @debug.assert_eq(r0.intersection(r1), r1.intersection(r0))
    inspect(r0.intersects(r1) == r1.intersects(r0), content="true")
  }
}

///|
/// 上游 contains：边界上的点也在区域内喵。
test "Rect::contains 边界含入" {
  let rect = Rect::new(1, 2, 3, 4)
  inspect(rect.contains(Position::new(1, 2)), content="true")
  inspect(rect.contains(Position::new(3, 2)), content="true")
  inspect(rect.contains(Position::new(1, 5)), content="true")
  inspect(rect.contains(Position::new(3, 5)), content="true")
  inspect(rect.contains(Position::new(0, 2)), content="false")
  inspect(rect.contains(Position::new(4, 2)), content="false")
  inspect(rect.contains(Position::new(1, 1)), content="false")
  inspect(rect.contains(Position::new(1, 6)), content="false")
  inspect(rect.contains(Position::new(0, 1)), content="false")
  inspect(rect.contains(Position::new(4, 6)), content="false")
}

///|
/// 上游 size_truncation：宽高溢出时按 u16 上限截断喵。
test "Rect::new 尺寸截断" {
  @debug.assert_eq(Rect::new(MAX_COORD - 100, MAX_COORD - 1000, 200, 2000), {
    x: MAX_COORD - 100,
    y: MAX_COORD - 1000,
    width: 100,
    height: 1000,
  })
}

///|
/// 上游 size_preservation：未溢出时尺寸原样保留喵。
test "Rect::new 尺寸保留" {
  @debug.assert_eq(Rect::new(MAX_COORD - 100, MAX_COORD - 1000, 100, 1000), {
    x: MAX_COORD - 100,
    y: MAX_COORD - 1000,
    width: 100,
    height: 1000,
  })
}

///|
/// 上游 resize_updates_size：resize 改尺寸保位置喵。
test "Rect::resize 更新尺寸" {
  @debug.assert_eq(
    Rect::new(10, 20, 5, 5).resize(Size::new(30, 40)),
    Rect::new(10, 20, 30, 40),
  )
}

///|
/// 上游 resize_clamps_at_bounds：resize 右/下越界时饱和截断喵。
test "Rect::resize 边界饱和" {
  @debug.assert_eq(
    Rect::new(MAX_COORD - 2, MAX_COORD - 3, 1, 1).resize(Size::new(10, 10)),
    Rect::new(MAX_COORD - 2, MAX_COORD - 3, 2, 3),
  )
}

///|
/// 上游 clamp（12 组参数化用例）：夹进目标矩形，宽高超限先压尺寸喵。
test "Rect::clamp 夹进目标" {
  let other = Rect::new(10, 10, 100, 100)
  let cases = [
    (Rect::new(20, 20, 10, 10), Rect::new(20, 20, 10, 10)),
    (Rect::new(5, 5, 10, 10), Rect::new(10, 10, 10, 10)),
    (Rect::new(20, 5, 10, 10), Rect::new(20, 10, 10, 10)),
    (Rect::new(105, 5, 10, 10), Rect::new(100, 10, 10, 10)),
    (Rect::new(5, 20, 10, 10), Rect::new(10, 20, 10, 10)),
    (Rect::new(105, 20, 10, 10), Rect::new(100, 20, 10, 10)),
    (Rect::new(5, 105, 10, 10), Rect::new(10, 100, 10, 10)),
    (Rect::new(20, 105, 10, 10), Rect::new(20, 100, 10, 10)),
    (Rect::new(105, 105, 10, 10), Rect::new(100, 100, 10, 10)),
    (Rect::new(5, 20, 200, 10), Rect::new(10, 20, 100, 10)),
    (Rect::new(20, 5, 10, 200), Rect::new(20, 10, 10, 100)),
    (Rect::new(0, 0, 200, 200), Rect::new(10, 10, 100, 100)),
  ]
  for case in cases {
    let (rect, expected) = case
    @debug.assert_eq(rect.clamp(other), expected)
  }
}

///|
/// 上游 rows：按行切片（行高 1）喵。
test "Rect::rows 行迭代" {
  let rows = Rect::new(0, 0, 3, 2).rows().collect()
  @debug.assert_eq(rows, [Rect::new(0, 0, 3, 1), Rect::new(0, 1, 3, 1)])
}

///|
/// 上游 columns：按列切片（列宽 1）喵。
test "Rect::columns 列迭代" {
  let columns = Rect::new(0, 0, 3, 2).columns().collect()
  @debug.assert_eq(columns, [
    Rect::new(0, 0, 1, 2),
    Rect::new(1, 0, 1, 2),
    Rect::new(2, 0, 1, 2),
  ])
}

///|
/// 上游 as_position：取左上角坐标喵。
test "Rect::as_position" {
  let position = Rect::new(1, 2, 3, 4).as_position()
  inspect(position.x, content="1")
  inspect(position.y, content="2")
}

///|
/// 上游 as_size：提取尺寸喵。
test "Rect::as_size" {
  @debug.assert_eq(Rect::new(1, 2, 3, 4).as_size(), Size::new(3, 4))
}

///|
/// 上游 from_position_and_size：从 (Position, Size) 组装喵。
test "Rect::of_position_size" {
  @debug.assert_eq(
    Rect::of_position_size(Position::new(1, 2), Size::new(3, 4)),
    Rect::new(1, 2, 3, 4),
  )
}

///|
/// 上游 from_size：以原点为左上角按尺寸组装喵。
test "Rect::of_size" {
  @debug.assert_eq(Rect::of_size(Size::new(3, 4)), Rect::new(0, 0, 3, 4))
}

///|
/// 上游 ops.rs add_offset：`rect + offset` / `offset + rect` 饱和平移喵。
test "Rect 加 Offset" {
  let cases = [
    (Rect::new(3, 4, 5, 6), Offset::zero(), Rect::new(3, 4, 5, 6)),
    (Rect::new(3, 4, 5, 6), Offset::new(1, 2), Rect::new(4, 6, 5, 6)),
    (Rect::new(3, 4, 5, 6), Offset::new(-1, -2), Rect::new(2, 2, 5, 6)),
    (Rect::new(3, 4, 5, 6), Offset::min(), Rect::new(0, 0, 5, 6)),
    (
      Rect::new(3, 4, 5, 6),
      Offset::max(),
      Rect::new(MAX_COORD - 5, MAX_COORD - 6, 5, 6),
    ),
  ]
  for case in cases {
    let (rect, offset, expected) = case
    @debug.assert_eq(rect.op_add(offset), expected)
    @debug.assert_eq(offset.op_add(rect), expected)
  }
}

///|
/// 上游 ops.rs sub_offset：`rect - offset` 饱和平移喵。
test "Rect 减 Offset" {
  let cases = [
    (Rect::new(3, 4, 5, 6), Offset::zero(), Rect::new(3, 4, 5, 6)),
    (Rect::new(3, 4, 5, 6), Offset::new(1, 2), Rect::new(2, 2, 5, 6)),
    (Rect::new(3, 4, 5, 6), Offset::new(-1, -2), Rect::new(4, 6, 5, 6)),
    (Rect::new(3, 4, 5, 6), Offset::max(), Rect::new(0, 0, 5, 6)),
    // 上游用例为 `rect - (-Offset::MAX)`，等价于反向加 MAX 喵
    (
      Rect::new(3, 4, 5, 6),
      Offset::new(-2147483647, -2147483647),
      Rect::new(MAX_COORD - 5, MAX_COORD - 6, 5, 6),
    ),
  ]
  for case in cases {
    let (rect, offset, expected) = case
    @debug.assert_eq(rect.op_sub(offset), expected)
  }
}
