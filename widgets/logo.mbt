// Ratatui 徽标组件（上游 `ratatui-widgets/src/logo.rs`）：两行文本
// 绘出的 Ratatui 徽标，Tiny（2x15）/ Small（2x27）两档喵。

///|
/// 徽标尺寸（上游 `logo::Size`，对外名 `RatatuiLogoSize`）喵。
pub(all) enum RatatuiLogoSize {
  /// Tiny（缺省，2x15）喵。
  Tiny
  /// Small（2x27）喵。
  Small
} derive(Eq, Debug)

///|
/// 缺省尺寸（上游 `Size::default` = `Tiny`）喵。
pub fn RatatuiLogoSize::default() -> RatatuiLogoSize {
  Tiny
}

///|
/// 徽标字样（上游 `Size::as_str`，包私有）喵。
fn RatatuiLogoSize::as_logo_str(self : RatatuiLogoSize) -> String {
  match self {
    Tiny => RatatuiLogoSize::tiny_str()
    Small => RatatuiLogoSize::small_str()
  }
}

///|
/// 徽标组件（上游 `RatatuiLogo`）喵。
pub(all) struct RatatuiLogo {
  size : RatatuiLogoSize
} derive(Eq, Debug)

///|
/// 以尺寸创建徽标（上游 `RatatuiLogo::new`）喵。
pub fn RatatuiLogo::new(size : RatatuiLogoSize) -> RatatuiLogo {
  { size, }
}

///|
/// 设徽标尺寸（上游 `RatatuiLogo::size`）喵。
pub fn RatatuiLogo::size(
  _self : RatatuiLogo,
  size : RatatuiLogoSize,
) -> RatatuiLogo {
  { size, }
}

///|
/// 缺省徽标（上游 `RatatuiLogo::default` = Tiny）喵。
pub fn RatatuiLogo::default() -> RatatuiLogo {
  { size: Tiny }
}

///|
/// Tiny 徽标（上游 `RatatuiLogo::tiny`）喵。
pub fn RatatuiLogo::tiny() -> RatatuiLogo {
  { size: Tiny }
}

///|
/// Small 徽标（上游 `RatatuiLogo::small`）喵。
pub fn RatatuiLogo::small() -> RatatuiLogo {
  { size: Small }
}

///|
/// Widget 实现（上游 `impl Widget for RatatuiLogo`）：以原始文本
/// 渲染喵。
pub impl @core.Widget for RatatuiLogo with fn render(
  self : RatatuiLogo,
  area : @core.Rect,
  buf : @core.Buffer,
) -> Unit {
  @core.Text::raw(self.size.as_logo_str()).render(area, buf)
}
