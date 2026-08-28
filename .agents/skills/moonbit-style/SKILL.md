---
name: moonbit-style
description: MoonBit 语言编码规范与工具链技能。在本仓库写或修改任何 .mbt / moon.pkg / moon.mod 文件时必须使用：块式 ///| 组织、显式错误处理（优雅裁剪 + guard! 仅限不变量）、derive(Eq, Debug)、inspect 黄金快照测试、moon fmt/info/check/test 提交前工作流。确保代码与本仓库（Nonoka 家族）品味一致。
metadata:
  author: ppkun
  version: "1.0.0"
---

# MoonBit 编码规范（ratatui4moon）

写 MoonBit 代码前先读 `AGENTS.md` 与 `.agents/iron.md`（七条铁律），完整品味手册见 `.agents/taste.md`。本 skill 是日常工作速查喵。

## 组织与命名

- **块式**：每个顶层定义（fn/struct/enum/impl/trait/test）前加 `///|` 分块，块顺序无关；一块一个定义。
- 命名：类型/trait/变体 `PascalCase`；函数/方法/字段/常量 `snake_case`；泛型形参单字母 `A,B,C`。
- 可见性阶梯：`priv` < 无修饰 < `pub` < `pub(all)`（统一模型/数据结构字段全开）< `pub(open)`（可被外部实现的 trait，如 `Backend`）。
- 构造走关联函数（`Rect::new` / `Style::of` / `Cell::empty`），字面量 `{ field: value }` 能省则省（`{ ch, style }`）。

## 错误与边界

- 渲染路径**禁止 panic/abort**：越界静默裁剪（`Buffer::set_cell`）、退化区域整体跳过（`Block::render`）。
- `guard!` 只用于内部不变量（程序员错误），业务分支用 `if`/`match`/`guard ... else`。
- 字符串插值用 `"\{expr}"`，不拼 `+`。

## 测试（黄金快照铁律）

- 快照优先：`inspect(x, content="...")` > `assert_eq`；无 `Show` 的类型用 `@debug.debug_inspect` 或提取标量断言，禁止给模型补 `Show`。
- 渲染链路：`widget → Buffer::diff → TestBackend → last_ansi`，对精确 ANSI 串断言；快照更新只走 `moon test --update`，禁止手改 content。
- 黑盒测试 `*_test.mbt`；跨包隔离建 `<pkg>/test/` 独立包（`for "test"` 导入）。

## 提交前工作流（全部通过才算完成）

```bash
moon fmt      # 格式化（会把 inspect! 规范为 inspect）
moon info     # 生成/更新 .mbti（入库跟踪，diff 可见 API 变化）
moon check    # lint 零警告
moon test     # 全绿
```

## 依赖方向速记

`core`（叶子，零 I/O）← `backend`（ANSI 出口唯一）← `widgets`（只碰 Buffer）← `widgets/test`（黑盒快照）。改任何一层前先确认不违反 `.agents/iron.md` 喵。
