///|
/// Masked 单元测试：复刻 ratatui-v0.30.2 `text/masked.rs` 测试清单喵。

///|
/// 上游 new：保存原文与遮罩字符喵。
test "Masked::of 构造" {
  let masked = Masked::of("12345", 'x')
  inspect(masked.inner, content="12345")
  inspect(masked.mask_char(), content="x")
}

///|
/// 上游 value：呈现为遮罩串喵。
test "Masked::value" {
  inspect(Masked::of("12345", 'x').value(), content="xxxxx")
}

///|
/// 上游 mask_char 喵。
test "Masked::mask_char" {
  inspect(Masked::of("12345", 'x').mask_char(), content="x")
}

///|
/// 上游 debug：Debug 呈现原文（刻意设计）喵。
test "Masked::to_debug" {
  inspect(Masked::of("12345", 'x').to_debug(), content="12345")
}

///|
/// 上游 display：呈现遮罩串，可截断喵。
test "Masked::to_display" {
  inspect(Masked::of("12345", 'x').to_display(), content="xxxxx")
  inspect(Masked::of("12345", 'x').to_display(limit=3), content="xxx")
}

///|
/// 上游 into_text：转文本为遮罩串的单行喵。
test "Masked::to_text" {
  @debug.assert_eq(Masked::of("12345", 'x').to_text(), Text::raw("xxxxx"))
}

///|
/// 多码点遮罩按码点数对应（CJK 亦一比一遮罩）喵。
test "Masked CJK 遮罩" {
  inspect(Masked::of("你好", '•').value(), content="••")
}
