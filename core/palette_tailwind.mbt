// Tailwind CSS 缺省色板（上游 `style/palette/tailwind.rs`）：22 组
// 色板，各 50–950 十一档，附纯黑/纯白喵。
//
// 上游以 `const` 结构体字面量承载；MoonBit 以顶层 `let` 值对位
// （小写蛇形命名），数据由上游源机械搬运喵。

///|
/// Tailwind 色板（上游 `tailwind::Palette`）：50–950 十一档喵。
pub(all) struct TailwindPalette {
  c50 : Color
  c100 : Color
  c200 : Color
  c300 : Color
  c400 : Color
  c500 : Color
  c600 : Color
  c700 : Color
  c800 : Color
  c900 : Color
  c950 : Color
} derive(Eq, Debug)

///|
/// Tailwind Slate 色板（上游 `tailwind::SLATE`）喵。
pub let tailwind_slate : TailwindPalette = {
  c50: Color::from_u32(0xf8fafc),
  c100: Color::from_u32(0xf1f5f9),
  c200: Color::from_u32(0xe2e8f0),
  c300: Color::from_u32(0xcbd5e1),
  c400: Color::from_u32(0x94a3b8),
  c500: Color::from_u32(0x64748b),
  c600: Color::from_u32(0x475569),
  c700: Color::from_u32(0x334155),
  c800: Color::from_u32(0x1e293b),
  c900: Color::from_u32(0x0f172a),
  c950: Color::from_u32(0x020617),
}

///|
/// Tailwind Gray 色板（上游 `tailwind::GRAY`）喵。
pub let tailwind_gray : TailwindPalette = {
  c50: Color::from_u32(0xf9fafb),
  c100: Color::from_u32(0xf3f4f6),
  c200: Color::from_u32(0xe5e7eb),
  c300: Color::from_u32(0xd1d5db),
  c400: Color::from_u32(0x9ca3af),
  c500: Color::from_u32(0x6b7280),
  c600: Color::from_u32(0x4b5563),
  c700: Color::from_u32(0x374151),
  c800: Color::from_u32(0x1f2937),
  c900: Color::from_u32(0x111827),
  c950: Color::from_u32(0x030712),
}

///|
/// Tailwind Zinc 色板（上游 `tailwind::ZINC`）喵。
pub let tailwind_zinc : TailwindPalette = {
  c50: Color::from_u32(0xfafafa),
  c100: Color::from_u32(0xf4f4f5),
  c200: Color::from_u32(0xe4e4e7),
  c300: Color::from_u32(0xd4d4d8),
  c400: Color::from_u32(0xa1a1aa),
  c500: Color::from_u32(0x71717a),
  c600: Color::from_u32(0x52525b),
  c700: Color::from_u32(0x3f3f46),
  c800: Color::from_u32(0x27272a),
  c900: Color::from_u32(0x18181b),
  c950: Color::from_u32(0x09090b),
}

///|
/// Tailwind Neutral 色板（上游 `tailwind::NEUTRAL`）喵。
pub let tailwind_neutral : TailwindPalette = {
  c50: Color::from_u32(0xfafafa),
  c100: Color::from_u32(0xf5f5f5),
  c200: Color::from_u32(0xe5e5e5),
  c300: Color::from_u32(0xd4d4d4),
  c400: Color::from_u32(0xa3a3a3),
  c500: Color::from_u32(0x737373),
  c600: Color::from_u32(0x525252),
  c700: Color::from_u32(0x404040),
  c800: Color::from_u32(0x262626),
  c900: Color::from_u32(0x171717),
  c950: Color::from_u32(0x0a0a0a),
}

///|
/// Tailwind Stone 色板（上游 `tailwind::STONE`）喵。
pub let tailwind_stone : TailwindPalette = {
  c50: Color::from_u32(0xfafaf9),
  c100: Color::from_u32(0xf5f5f4),
  c200: Color::from_u32(0xe7e5e4),
  c300: Color::from_u32(0xd6d3d1),
  c400: Color::from_u32(0xa8a29e),
  c500: Color::from_u32(0x78716c),
  c600: Color::from_u32(0x57534e),
  c700: Color::from_u32(0x44403c),
  c800: Color::from_u32(0x292524),
  c900: Color::from_u32(0x1c1917),
  c950: Color::from_u32(0x0c0a09),
}

///|
/// Tailwind Red 色板（上游 `tailwind::RED`）喵。
pub let tailwind_red : TailwindPalette = {
  c50: Color::from_u32(0xfef2f2),
  c100: Color::from_u32(0xfee2e2),
  c200: Color::from_u32(0xfecaca),
  c300: Color::from_u32(0xfca5a5),
  c400: Color::from_u32(0xf87171),
  c500: Color::from_u32(0xef4444),
  c600: Color::from_u32(0xdc2626),
  c700: Color::from_u32(0xb91c1c),
  c800: Color::from_u32(0x991b1b),
  c900: Color::from_u32(0x7f1d1d),
  c950: Color::from_u32(0x450a0a),
}

///|
/// Tailwind Orange 色板（上游 `tailwind::ORANGE`）喵。
pub let tailwind_orange : TailwindPalette = {
  c50: Color::from_u32(0xfff7ed),
  c100: Color::from_u32(0xffedd5),
  c200: Color::from_u32(0xfed7aa),
  c300: Color::from_u32(0xfdba74),
  c400: Color::from_u32(0xfb923c),
  c500: Color::from_u32(0xf97316),
  c600: Color::from_u32(0xea580c),
  c700: Color::from_u32(0xc2410c),
  c800: Color::from_u32(0x9a3412),
  c900: Color::from_u32(0x7c2d12),
  c950: Color::from_u32(0x431407),
}

///|
/// Tailwind Amber 色板（上游 `tailwind::AMBER`）喵。
pub let tailwind_amber : TailwindPalette = {
  c50: Color::from_u32(0xfffbeb),
  c100: Color::from_u32(0xfef3c7),
  c200: Color::from_u32(0xfde68a),
  c300: Color::from_u32(0xfcd34d),
  c400: Color::from_u32(0xfbbf24),
  c500: Color::from_u32(0xf59e0b),
  c600: Color::from_u32(0xd97706),
  c700: Color::from_u32(0xb45309),
  c800: Color::from_u32(0x92400e),
  c900: Color::from_u32(0x78350f),
  c950: Color::from_u32(0x451a03),
}

///|
/// Tailwind Yellow 色板（上游 `tailwind::YELLOW`）喵。
pub let tailwind_yellow : TailwindPalette = {
  c50: Color::from_u32(0xfefce8),
  c100: Color::from_u32(0xfef9c3),
  c200: Color::from_u32(0xfef08a),
  c300: Color::from_u32(0xfde047),
  c400: Color::from_u32(0xfacc15),
  c500: Color::from_u32(0xeab308),
  c600: Color::from_u32(0xca8a04),
  c700: Color::from_u32(0xa16207),
  c800: Color::from_u32(0x854d0e),
  c900: Color::from_u32(0x713f12),
  c950: Color::from_u32(0x422006),
}

///|
/// Tailwind Lime 色板（上游 `tailwind::LIME`）喵。
pub let tailwind_lime : TailwindPalette = {
  c50: Color::from_u32(0xf7fee7),
  c100: Color::from_u32(0xecfccb),
  c200: Color::from_u32(0xd9f99d),
  c300: Color::from_u32(0xbef264),
  c400: Color::from_u32(0xa3e635),
  c500: Color::from_u32(0x84cc16),
  c600: Color::from_u32(0x65a30d),
  c700: Color::from_u32(0x4d7c0f),
  c800: Color::from_u32(0x3f6212),
  c900: Color::from_u32(0x365314),
  c950: Color::from_u32(0x1a2e05),
}

///|
/// Tailwind Green 色板（上游 `tailwind::GREEN`）喵。
pub let tailwind_green : TailwindPalette = {
  c50: Color::from_u32(0xf0fdf4),
  c100: Color::from_u32(0xdcfce7),
  c200: Color::from_u32(0xbbf7d0),
  c300: Color::from_u32(0x86efac),
  c400: Color::from_u32(0x4ade80),
  c500: Color::from_u32(0x22c55e),
  c600: Color::from_u32(0x16a34a),
  c700: Color::from_u32(0x15803d),
  c800: Color::from_u32(0x166534),
  c900: Color::from_u32(0x14532d),
  c950: Color::from_u32(0x052e16),
}

///|
/// Tailwind Emerald 色板（上游 `tailwind::EMERALD`）喵。
pub let tailwind_emerald : TailwindPalette = {
  c50: Color::from_u32(0xecfdf5),
  c100: Color::from_u32(0xd1fae5),
  c200: Color::from_u32(0xa7f3d0),
  c300: Color::from_u32(0x6ee7b7),
  c400: Color::from_u32(0x34d399),
  c500: Color::from_u32(0x10b981),
  c600: Color::from_u32(0x059669),
  c700: Color::from_u32(0x047857),
  c800: Color::from_u32(0x065f46),
  c900: Color::from_u32(0x064e3b),
  c950: Color::from_u32(0x022c22),
}

///|
/// Tailwind Teal 色板（上游 `tailwind::TEAL`）喵。
pub let tailwind_teal : TailwindPalette = {
  c50: Color::from_u32(0xf0fdfa),
  c100: Color::from_u32(0xccfbf1),
  c200: Color::from_u32(0x99f6e4),
  c300: Color::from_u32(0x5eead4),
  c400: Color::from_u32(0x2dd4bf),
  c500: Color::from_u32(0x14b8a6),
  c600: Color::from_u32(0x0d9488),
  c700: Color::from_u32(0x0f766e),
  c800: Color::from_u32(0x115e59),
  c900: Color::from_u32(0x134e4a),
  c950: Color::from_u32(0x042f2e),
}

///|
/// Tailwind Cyan 色板（上游 `tailwind::CYAN`）喵。
pub let tailwind_cyan : TailwindPalette = {
  c50: Color::from_u32(0xecfeff),
  c100: Color::from_u32(0xcffafe),
  c200: Color::from_u32(0xa5f3fc),
  c300: Color::from_u32(0x67e8f9),
  c400: Color::from_u32(0x22d3ee),
  c500: Color::from_u32(0x06b6d4),
  c600: Color::from_u32(0x0891b2),
  c700: Color::from_u32(0x0e7490),
  c800: Color::from_u32(0x155e75),
  c900: Color::from_u32(0x164e63),
  c950: Color::from_u32(0x083344),
}

///|
/// Tailwind Sky 色板（上游 `tailwind::SKY`）喵。
pub let tailwind_sky : TailwindPalette = {
  c50: Color::from_u32(0xf0f9ff),
  c100: Color::from_u32(0xe0f2fe),
  c200: Color::from_u32(0xbae6fd),
  c300: Color::from_u32(0x7dd3fc),
  c400: Color::from_u32(0x38bdf8),
  c500: Color::from_u32(0x0ea5e9),
  c600: Color::from_u32(0x0284c7),
  c700: Color::from_u32(0x0369a1),
  c800: Color::from_u32(0x075985),
  c900: Color::from_u32(0x0c4a6e),
  c950: Color::from_u32(0x082f49),
}

///|
/// Tailwind Blue 色板（上游 `tailwind::BLUE`）喵。
pub let tailwind_blue : TailwindPalette = {
  c50: Color::from_u32(0xeff6ff),
  c100: Color::from_u32(0xdbeafe),
  c200: Color::from_u32(0xbfdbfe),
  c300: Color::from_u32(0x93c5fd),
  c400: Color::from_u32(0x60a5fa),
  c500: Color::from_u32(0x3b82f6),
  c600: Color::from_u32(0x2563eb),
  c700: Color::from_u32(0x1d4ed8),
  c800: Color::from_u32(0x1e40af),
  c900: Color::from_u32(0x1e3a8a),
  c950: Color::from_u32(0x172554),
}

///|
/// Tailwind Indigo 色板（上游 `tailwind::INDIGO`）喵。
pub let tailwind_indigo : TailwindPalette = {
  c50: Color::from_u32(0xeef2ff),
  c100: Color::from_u32(0xe0e7ff),
  c200: Color::from_u32(0xc7d2fe),
  c300: Color::from_u32(0xa5b4fc),
  c400: Color::from_u32(0x818cf8),
  c500: Color::from_u32(0x6366f1),
  c600: Color::from_u32(0x4f46e5),
  c700: Color::from_u32(0x4338ca),
  c800: Color::from_u32(0x3730a3),
  c900: Color::from_u32(0x312e81),
  c950: Color::from_u32(0x1e1b4b),
}

///|
/// Tailwind Violet 色板（上游 `tailwind::VIOLET`）喵。
pub let tailwind_violet : TailwindPalette = {
  c50: Color::from_u32(0xf5f3ff),
  c100: Color::from_u32(0xede9fe),
  c200: Color::from_u32(0xddd6fe),
  c300: Color::from_u32(0xc4b5fd),
  c400: Color::from_u32(0xa78bfa),
  c500: Color::from_u32(0x8b5cf6),
  c600: Color::from_u32(0x7c3aed),
  c700: Color::from_u32(0x6d28d9),
  c800: Color::from_u32(0x5b21b6),
  c900: Color::from_u32(0x4c1d95),
  c950: Color::from_u32(0x2e1065),
}

///|
/// Tailwind Purple 色板（上游 `tailwind::PURPLE`）喵。
pub let tailwind_purple : TailwindPalette = {
  c50: Color::from_u32(0xfaf5ff),
  c100: Color::from_u32(0xf3e8ff),
  c200: Color::from_u32(0xe9d5ff),
  c300: Color::from_u32(0xd8b4fe),
  c400: Color::from_u32(0xc084fc),
  c500: Color::from_u32(0xa855f7),
  c600: Color::from_u32(0x9333ea),
  c700: Color::from_u32(0x7e22ce),
  c800: Color::from_u32(0x6b21a8),
  c900: Color::from_u32(0x581c87),
  c950: Color::from_u32(0x3b0764),
}

///|
/// Tailwind Fuchsia 色板（上游 `tailwind::FUCHSIA`）喵。
pub let tailwind_fuchsia : TailwindPalette = {
  c50: Color::from_u32(0xfdf4ff),
  c100: Color::from_u32(0xfae8ff),
  c200: Color::from_u32(0xf5d0fe),
  c300: Color::from_u32(0xf0abfc),
  c400: Color::from_u32(0xe879f9),
  c500: Color::from_u32(0xd946ef),
  c600: Color::from_u32(0xc026d3),
  c700: Color::from_u32(0xa21caf),
  c800: Color::from_u32(0x86198f),
  c900: Color::from_u32(0x701a75),
  c950: Color::from_u32(0x4a044e),
}

///|
/// Tailwind Pink 色板（上游 `tailwind::PINK`）喵。
pub let tailwind_pink : TailwindPalette = {
  c50: Color::from_u32(0xfdf2f8),
  c100: Color::from_u32(0xfce7f3),
  c200: Color::from_u32(0xfbcfe8),
  c300: Color::from_u32(0xf9a8d4),
  c400: Color::from_u32(0xf472b6),
  c500: Color::from_u32(0xec4899),
  c600: Color::from_u32(0xdb2777),
  c700: Color::from_u32(0xbe185d),
  c800: Color::from_u32(0x9d174d),
  c900: Color::from_u32(0x831843),
  c950: Color::from_u32(0x500724),
}

///|
/// Tailwind Rose 色板（上游 `tailwind::ROSE`）喵。
pub let tailwind_rose : TailwindPalette = {
  c50: Color::from_u32(0xfff1f2),
  c100: Color::from_u32(0xffe4e6),
  c200: Color::from_u32(0xfecdd3),
  c300: Color::from_u32(0xfda4af),
  c400: Color::from_u32(0xfb7185),
  c500: Color::from_u32(0xf43f5e),
  c600: Color::from_u32(0xe11d48),
  c700: Color::from_u32(0xbe123c),
  c800: Color::from_u32(0x9f1239),
  c900: Color::from_u32(0x881337),
  c950: Color::from_u32(0x4c0519),
}

///|
/// 纯黑（上游 `tailwind::BLACK`）喵。
pub let tailwind_black : Color = Color::from_u32(0x000000)

///|
/// 纯白（上游 `tailwind::WHITE`）喵。
pub let tailwind_white : Color = Color::from_u32(0xFFFFFF)
