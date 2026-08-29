// 色彩空间转换（上游 `style/palette_conversion.rs`）：把 `palette`
// crate 的 Srgb/LinSrgb 色语义移植为 Color 构造函数喵。
//
// 登记差异：MoonBit 无 `palette` crate，上游的 `From<Srgb<T>>`/
// `From<LinSrgb<T>>` 泛型转换以按分量类型的具名构造函数对位；
// 传递函数与舍入语义逐条对齐上游测试（0.5 → 128 / 线性 0.5 → 188）。

///|
/// 从 0–255 分量构造真彩色（上游 `From<Srgb<u8>>`）喵。
pub fn Color::of_srgb_u8(r : Int, g : Int, b : Int) -> Color {
  Rgb(clamp_u8(r), clamp_u8(g), clamp_u8(b))
}

///|
/// 从 0–65535 分量构造真彩色（上游 `From<Srgb<u16>>`）：分量按
/// 257 折算到 0–255 喵。
pub fn Color::of_srgb_u16(r : Int, g : Int, b : Int) -> Color {
  Rgb(clamp_u8(r / 257), clamp_u8(g / 257), clamp_u8(b / 257))
}

///|
/// 从 0.0–1.0 分量构造真彩色（上游 `From<Srgb<f32>>`）：四舍五入
/// 到 0–255，0.5 → 128 喵。
pub fn Color::of_srgb_f64(r : Double, g : Double, b : Double) -> Color {
  Rgb(scale_component(r), scale_component(g), scale_component(b))
}

///|
/// 从线性 sRGB 0.0–1.0 分量构造真彩色（上游 `From<LinSrgb<T>>`）：
/// 先做线性 → sRGB 传递函数，再缩放到 0–255，线性 0.5 → 188 喵。
pub fn Color::of_lin_srgb_f64(r : Double, g : Double, b : Double) -> Color {
  Rgb(
    scale_component(linear_to_srgb(r)),
    scale_component(linear_to_srgb(g)),
    scale_component(linear_to_srgb(b)),
  )
}

///|
/// 钳制到 0–255 喵。
fn clamp_u8(v : Int) -> Int {
  if v < 0 {
    0
  } else if v > 255 {
    255
  } else {
    v
  }
}

///|
/// 0.0–1.0 分量缩放到 0–255（半值四舍五入并钳制）喵。
fn scale_component(v : Double) -> Int {
  clamp_u8((v * 255.0).round().to_int())
}

///|
/// 线性 → sRGB 传递函数（IEC 61966-2-1）喵。
fn linear_to_srgb(v : Double) -> Double {
  if v <= 0.0031308 {
    v * 12.92
  } else {
    1.055 * @math.pow(v, 1.0 / 2.4) - 0.055
  }
}
