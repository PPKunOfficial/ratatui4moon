// Ratatui 徽标字样（上游 `logo.rs` 的 `Size::tiny/small` 机械搬运）：
// 含尾部换行，与上游 indoc 常量逐字一致喵。

///|
/// Tiny 徽标（2x15）喵。
pub fn RatatuiLogoSize::tiny_str() -> String {
  "▛▚▗▀▖▜▘▞▚▝▛▐ ▌▌\n" +
  "▛▚▐▀▌▐ ▛▜ ▌▝▄▘▌\n"
}

///|
/// Small 徽标（2x27）喵。
pub fn RatatuiLogoSize::small_str() -> String {
  "█▀▀▄ ▄▀▀▄▝▜▛▘▄▀▀▄▝▜▛▘█  █ █\n" +
  "█▀▀▄ █▀▀█ ▐▌ █▀▀█ ▐▌ ▀▄▄▀ █\n"
}
