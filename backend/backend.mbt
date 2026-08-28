///|
/// 终端后端统一契约喵。
///
/// spike 阶段只锁定 `draw`：接收一帧差分单元格并呈现。真实终端后端
/// （接 `moonbit-community/tty`）需要 raw mode / 光标控制 / 尺寸查询与
/// async 输入，届时再扩契约，避免为不存在的消费方预埋机制喵。
pub(open) trait Backend {
  fn draw(Self, Array[(Int, Int, @core.Cell)]) -> Unit
}
