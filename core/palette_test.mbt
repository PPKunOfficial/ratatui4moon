// 上游 `palette_conversion.rs` 内联测试逐条复刻 + 色板常量锚定
// （material/tailwind 上游无内联测试，按模块文档示例补锚定）喵。

///|
/// 上游 `from_srgb`：三种分量载体的红与 0.5 灰喵。
test "Color::of_srgb 对位上游 From<Srgb<T>>" {
  @debug.assert_eq(Color::of_srgb_u8(255, 0, 0), Rgb(255, 0, 0))
  @debug.assert_eq(Color::of_srgb_u16(65535, 0, 0), Rgb(255, 0, 0))
  @debug.assert_eq(Color::of_srgb_f64(1.0, 0.0, 0.0), Rgb(255, 0, 0))
  @debug.assert_eq(Color::of_srgb_f64(0.5, 0.5, 0.5), Rgb(128, 128, 128))
}

///|
/// 上游 `from_lin_srgb`：线性 sRGB 的红与 0.5 灰喵。
test "Color::of_lin_srgb 对位上游 From<LinSrgb<T>>" {
  @debug.assert_eq(Color::of_lin_srgb_f64(1.0, 0.0, 0.0), Rgb(255, 0, 0))
  @debug.assert_eq(Color::of_lin_srgb_f64(0.5, 0.5, 0.5), Rgb(188, 188, 188))
}

///|
/// 上游 material 模块文档示例：`RED.c500 = Rgb(244, 67, 54)`、
/// `BLUE.c500 = Rgb(33, 150, 243)` 喵。
test "Material 色板锚定" {
  @debug.assert_eq(material_red.c500, Rgb(244, 67, 54))
  @debug.assert_eq(material_blue.c500, Rgb(33, 150, 243))
  // 端点锚定喵。
  @debug.assert_eq(material_red.c50, Rgb(255, 235, 238))
  @debug.assert_eq(material_red.a700, Rgb(213, 0, 0))
  @debug.assert_eq(material_brown.c900, Rgb(62, 39, 35))
  @debug.assert_eq(material_black, Rgb(0, 0, 0))
  @debug.assert_eq(material_white, Rgb(255, 255, 255))
}

///|
/// Material 色板组数锚定：16 组含强调色（14 档）+ 3 组无强调色
/// （10 档）喵。
test "Material 色板结构锚定" {
  // 变体表 19 组齐全：抽检各组 c50（上游 variants 表数据）喵。
  @debug.assert_eq(material_deep_purple.c50, Rgb(237, 231, 246))
  @debug.assert_eq(material_indigo.c50, Rgb(232, 234, 246))
  @debug.assert_eq(material_light_blue.c50, Rgb(225, 245, 254))
  @debug.assert_eq(material_cyan.c50, Rgb(224, 247, 250))
  @debug.assert_eq(material_teal.c50, Rgb(224, 242, 241))
  @debug.assert_eq(material_green.c50, Rgb(232, 245, 233))
  @debug.assert_eq(material_light_green.c50, Rgb(241, 248, 233))
  @debug.assert_eq(material_lime.c50, Rgb(249, 251, 231))
  @debug.assert_eq(material_yellow.c50, Rgb(255, 253, 231))
  @debug.assert_eq(material_amber.c50, Rgb(255, 248, 225))
  @debug.assert_eq(material_orange.c50, Rgb(255, 243, 224))
  @debug.assert_eq(material_deep_orange.c50, Rgb(251, 233, 231))
  @debug.assert_eq(material_gray.c50, Rgb(250, 250, 250))
  @debug.assert_eq(material_blue_gray.c50, Rgb(236, 239, 241))
  @debug.assert_eq(material_pink.c50, Rgb(252, 228, 236))
  @debug.assert_eq(material_purple.c50, Rgb(243, 229, 245))
}

///|
/// Tailwind 色板锚定（上游文档 SLATE 首档与 ROSE 末档）喵。
test "Tailwind 色板锚定" {
  @debug.assert_eq(tailwind_slate.c50, Rgb(248, 250, 252))
  @debug.assert_eq(tailwind_slate.c950, Rgb(2, 6, 23))
  @debug.assert_eq(tailwind_rose.c500, Rgb(244, 63, 94))
  @debug.assert_eq(tailwind_blue.c500, Rgb(59, 130, 246))
  @debug.assert_eq(tailwind_black, Rgb(0, 0, 0))
  @debug.assert_eq(tailwind_white, Rgb(255, 255, 255))
}
