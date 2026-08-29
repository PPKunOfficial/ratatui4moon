// 缓冲断言辅助（上游 `buffer/assert.rs`）：比较两缓冲的区域与内容，
// 不一致时以类似 assert_eq! 的格式展示差异喵。
//
// 载体折算登记：上游为 `assert_buffer_eq!` 宏（已 deprecated，官方
// 指引改用 `assert_eq!`）；MoonBit 无宏，以 raise 函数对位，测试经
// `try?` 捕获断言失败喵。

///|
/// 断言两缓冲区域与内容相等（上游 `assert_buffer_eq!`）：先比区域、
/// 再以 `diff` 列出逐格差异，末尾兜底全量比较喵。
pub fn Buffer::assert_buffer_eq(
  actual : Buffer,
  expected : Buffer,
) -> Unit raise {
  if actual.area != expected.area {
    fail(
      "buffer areas not equal\nexpected: \{@debug.to_string(expected)}\nactual:   \{@debug.to_string(actual)}",
    )
  }
  let diffs = expected.diff(actual)
  if diffs.length() > 0 {
    let out = StringBuilder()
    for i, entry in diffs {
      let (x, y, cell) = entry
      let expected_cell = expected.get(x, y)
      out.write_string(
        "\{i}: at (\{x}, \{y})\n  expected: \{@debug.to_string(expected_cell)}\n  actual:   \{@debug.to_string(cell)}\n",
      )
    }
    let nice_diff = out.to_string()
    fail(
      "buffer contents not equal\nexpected: \{@debug.to_string(expected)}\nactual:   \{@debug.to_string(actual)}\ndiff:\n\{nice_diff}",
    )
  }
  // 兜底防御：区域与内容一致却仍不等（上游留作未来行为变更哨兵）喵。
  @debug.assert_eq(actual, expected)
}
