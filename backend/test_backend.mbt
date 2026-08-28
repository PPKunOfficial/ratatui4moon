///|
/// 测试后端：记录每帧差分单元格，供黄金 ANSI 快照与离线渲染断言使用喵。
///
/// 这是"确定性测试"的支点：widget 渲染 → Buffer 差分 → TestBackend 录帧
/// → `last_ansi()` 精确字符串断言，全程零真实终端、零 I/O 喵。
pub(all) struct TestBackend {
  frames : Array[Array[(Int, Int, @core.Cell)]]
}

///|
/// 创建空测试后端喵。
pub fn TestBackend::new() -> TestBackend {
  { frames: [] }
}

///|
/// 实现 Backend：原样记录一帧喵。
pub impl Backend for TestBackend with fn draw(
  self : TestBackend,
  content : Array[(Int, Int, @core.Cell)],
) -> Unit {
  self.frames.push(content)
}

///|
/// 已录帧数喵。
pub fn TestBackend::frame_count(self : TestBackend) -> Int {
  self.frames.length()
}

///|
/// 最近一帧的 ANSI 渲染喵；无帧返回空串。
pub fn TestBackend::last_ansi(self : TestBackend) -> String {
  match self.frames.last() {
    Some(frame) => frame_to_ansi(frame)
    None => ""
  }
}
