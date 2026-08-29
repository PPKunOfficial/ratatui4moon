// ratatui4moon：MoonBit 的 ratatui 式即时模式 TUI 框架。
// cell 网格双缓冲 + 增量 ANSI + 黄金快照测试；纯 MoonBit，零 FFI、零 Bun。
name = "nonoka/ratatui4moon"

version = "0.1.0"

readme = "README.mbt.md"

repository = ""

license = "MIT OR Apache-2.0"

keywords = [ "tui", "terminal", "ratatui", "moonbit" ]

preferred_target = "native"

description = "MoonBit 的 ratatui 式终端 UI 框架：cell buffer 双缓冲、即时模式 widget、黄金 ANSI 快照测试"

import {
  "moonbit-community/tty@0.3.0",
  "moonbitlang/async@0.20.0",
}
