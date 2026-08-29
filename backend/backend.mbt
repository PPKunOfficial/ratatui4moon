///|
/// 终端清除区域（上游 `backend::ClearType`）：作用于可见显示区的
/// 字符单元格，不移动/隐藏/复位光标喵。
pub(all) enum ClearType {
  /// 清空可见显示区全部单元格喵。
  All
  /// 从光标位置（含）清到显示区末尾喵。
  AfterCursor
  /// 从显示区开头清到光标位置（含）喵。
  BeforeCursor
  /// 清空光标所在行喵。
  CurrentLine
  /// 从光标位置（含）清到当前行末尾喵。
  UntilNewLine
} derive(Eq, Debug)

///|
/// 变体名（上游 strum `Display`）喵。
pub fn ClearType::name(self : ClearType) -> String {
  match self {
    All => "All"
    AfterCursor => "AfterCursor"
    BeforeCursor => "BeforeCursor"
    CurrentLine => "CurrentLine"
    UntilNewLine => "UntilNewLine"
  }
}

///|
/// 变体名解析（上游 strum `EnumString`）喵。
pub fn ClearType::from_str(s : String) -> ClearType? {
  match s {
    "All" => Some(All)
    "AfterCursor" => Some(AfterCursor)
    "BeforeCursor" => Some(BeforeCursor)
    "CurrentLine" => Some(CurrentLine)
    "UntilNewLine" => Some(UntilNewLine)
    _ => None
  }
}

///|
/// 窗口尺寸（上游 `backend::WindowSize`）：字符行列 + 像素尺寸
/// （像素字段部分终端返回 0,0）喵。
pub(all) struct WindowSize {
  columns_rows : @core.Size
  pixels : @core.Size
} derive(Eq, Debug)

///|
/// 终端后端统一契约（上游 `backend::Backend`）：绘制内容、光标
/// 控制与终端清除喵。
///
/// 契约扩容登记：spike 阶段只锁定 `draw`；终端会话层（Terminal）
/// 落位后按上游 v0.30.2 完整契约扩容。上游 `type Error` 关联类型
/// 以 `raise Error`（Failure）承载；上游 `Result::Err` 落 `fail`，
/// 默认无操作方法以默认实现承载。滚动区域（`scroll_region_up/down`）
/// 上游为 scrolling-regions feature 门控，不进缺省契约，暂不复刻。
pub(open) trait Backend {
  /// 绘制一批差分单元格（上游 `Backend::draw`）喵。
  fn draw(Self, Array[(Int, Int, @core.Cell)]) -> Unit raise

  /// 在当前光标处插入 n 个换行（上游 `Backend::append_lines`，
  /// 缺省无操作）喵。
  fn append_lines(Self, Int) -> Unit raise

  /// 隐藏光标（上游 `Backend::hide_cursor`）喵。
  fn hide_cursor(Self) -> Unit raise

  /// 显示光标（上游 `Backend::show_cursor`）喵。
  fn show_cursor(Self) -> Unit raise

  /// 查询光标位置（上游 `Backend::get_cursor_position`）喵。
  fn get_cursor_position(Self) -> @core.Position raise

  /// 设置光标位置（上游 `Backend::set_cursor_position`）喵。
  fn set_cursor_position(Self, @core.Position) -> Unit raise

  /// 清空可见显示区（上游 `Backend::clear`）喵。
  fn clear(Self) -> Unit raise

  /// 按区域清除（上游 `Backend::clear_region`）喵。
  fn clear_region(Self, ClearType) -> Unit raise

  /// 查询字符行列尺寸（上游 `Backend::size`）喵。
  fn size(Self) -> @core.Size raise

  /// 查询窗口尺寸含像素（上游 `Backend::window_size`）喵。
  fn window_size(Self) -> WindowSize raise

  /// 冲刷缓冲输出（上游 `Backend::flush`，缺省无操作）喵。
  fn flush(Self) -> Unit raise
}
