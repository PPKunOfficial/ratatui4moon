///|
/// Style / Modifier 单元测试：复刻 ratatui-v0.30.2 `style.rs` 测试清单喵。
///
/// 上游 `should_panic`/const 语境（`style_can_be_const`）与 Stylize
/// 速记（`.red()`/`.on_blue()` 等约 50 个糖方法）、From 转换构造
/// 留待对应 API 落位后复刻；上游 Style 文档中"多份样式施加到
/// **Cell**"的两则示例（reset 复位、修饰累积）随 Cell 复刻迁移——
/// Cell::set_style 是单字段 insert/remove 折叠语义，与 `Style::patch`
/// 的 sub 跟踪不同喵。

///|
/// 上游 combined_patch_gives_same_result_as_individual_patch：patch
/// 合并律——先合并再施加与逐个施加等价（9⁴ 全组合）喵。
test "Style::patch 合并律" {
  let styles = [
    Style::new(),
    Style::new().fg(Yellow),
    Style::new().bg(Yellow),
    Style::new().add_modifier(Modifier::bold()),
    Style::new().remove_modifier(Modifier::bold()),
    Style::new().add_modifier(Modifier::italic()),
    Style::new().remove_modifier(Modifier::italic()),
    Style::new().add_modifier(Modifier::italic().insert(Modifier::bold())),
    Style::new().remove_modifier(Modifier::italic().insert(Modifier::bold())),
  ]
  for a in styles {
    for b in styles {
      for c in styles {
        for d in styles {
          @debug.assert_eq(
            Style::new().patch(a).patch(b).patch(c).patch(d),
            Style::new().patch(a.patch(b.patch(c.patch(d)))),
          )
        }
      }
    }
  }
}

///|
/// 上游 modifier_debug：Debug 呈现为位名连接（`NONE`/单名/多名/全量）喵。
test "Modifier::to_debug" {
  inspect(Modifier::empty().to_debug(), content="NONE")
  inspect(Modifier::bold().to_debug(), content="BOLD")
  inspect(Modifier::dim().to_debug(), content="DIM")
  inspect(Modifier::italic().to_debug(), content="ITALIC")
  inspect(Modifier::underlined().to_debug(), content="UNDERLINED")
  inspect(Modifier::slow_blink().to_debug(), content="SLOW_BLINK")
  inspect(Modifier::rapid_blink().to_debug(), content="RAPID_BLINK")
  inspect(Modifier::reversed().to_debug(), content="REVERSED")
  inspect(Modifier::hidden().to_debug(), content="HIDDEN")
  inspect(Modifier::crossed_out().to_debug(), content="CROSSED_OUT")
  inspect(
    Modifier::bold().insert(Modifier::dim()).to_debug(),
    content="BOLD | DIM",
  )
  inspect(
    Modifier::all().to_debug(),
    content="BOLD | DIM | ITALIC | UNDERLINED | SLOW_BLINK | RAPID_BLINK | REVERSED | HIDDEN | CROSSED_OUT",
  )
}

///|
/// 上游 has_modifier_checks：add/sub 双向消解下的修饰位生效判定喵。
test "Style::has_modifier" {
  // 基本存在性
  let style = Style::new().add_modifier(
    Modifier::bold().insert(Modifier::italic()),
  )
  inspect(style.has_modifier(Modifier::bold()), content="true")
  inspect(style.has_modifier(Modifier::italic()), content="true")
  inspect(style.has_modifier(Modifier::underlined()), content="false")
  // remove 抵消后不再生效
  let style = Style::new()
    .add_modifier(Modifier::bold().insert(Modifier::italic()))
    .remove_modifier(Modifier::italic())
  inspect(style.has_modifier(Modifier::bold()), content="true")
  inspect(style.has_modifier(Modifier::italic()), content="false")
  // patch 一份 remove 样式同样抵消
  let patched = Style::new()
    .add_modifier(Modifier::bold().insert(Modifier::italic()))
    .patch(Style::new().remove_modifier(Modifier::italic()))
  inspect(patched.has_modifier(Modifier::bold()), content="true")
  inspect(patched.has_modifier(Modifier::italic()), content="false")
}

///|
/// 上游 add_modifier 文档示例：add 互斥消解（新 add 清掉同位 sub）喵。
test "Style::add_modifier 与 sub_modifier 互斥消解" {
  let style = Style::new().add_modifier(Modifier::bold())
  let diff = Style::new().add_modifier(Modifier::italic())
  let patched = style.patch(diff)
  @debug.assert_eq(
    patched.add_modifier,
    Modifier::bold().insert(Modifier::italic()),
  )
  inspect(patched.sub_modifier.is_empty(), content="true")
}

///|
/// 上游 remove_modifier 文档示例：remove 进入 sub 方向喵。
test "Style::remove_modifier 进入 sub 方向" {
  let style = Style::new().add_modifier(
    Modifier::bold().insert(Modifier::italic()),
  )
  let diff = Style::new().remove_modifier(Modifier::italic())
  let patched = style.patch(diff)
  @debug.assert_eq(patched.add_modifier, Modifier::bold())
  @debug.assert_eq(patched.sub_modifier, Modifier::italic())
}

///|
/// 上游 fg/bg 文档示例：patch 的颜色覆盖语义喵。
test "Style patch 颜色覆盖" {
  let style = Style::new().fg(Blue)
  let diff = Style::new().fg(Red)
  @debug.assert_eq(style.patch(diff), Style::new().fg(Red))
  let style = Style::new().bg(Blue)
  let diff = Style::new().bg(Red)
  @debug.assert_eq(style.patch(diff), Style::new().bg(Red))
}

///|
/// 上游 patch 文档示例：None 字段不覆盖喵。
test "Style patch None 不覆盖" {
  let style_1 = Style::new().fg(Yellow)
  let style_2 = Style::new().bg(Red)
  let combined = style_1.patch(style_2)
  @debug.assert_eq(
    Style::new().patch(style_1).patch(style_2),
    Style::new().patch(combined),
  )
  @debug.assert_eq(combined, {
    fg: Some(Yellow),
    bg: Some(Red),
    add_modifier: Modifier::empty(),
    sub_modifier: Modifier::empty(),
  })
}

///|
/// is_default：new/default 为空，任何字段被设即非空喵。
test "Style::is_default 判定" {
  inspect(Style::new().is_default(), content="true")
  inspect(Style::default().is_default(), content="true")
  inspect(Style::new().fg(Red).is_default(), content="false")
  inspect(Style::new().bg(Red).is_default(), content="false")
  inspect(
    Style::new().add_modifier(Modifier::bold()).is_default(),
    content="false",
  )
  inspect(
    Style::new().remove_modifier(Modifier::bold()).is_default(),
    content="false",
  )
}
