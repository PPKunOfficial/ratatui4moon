# 铁律 · 7 条最高优先级契约喵

> 本文件是 `AGENTS.md` 的唯一铁律真相源，任何改动不得破坏。违反任意一条即视为破坏仓库条约喵。

## 铁律（按优先级排序）

1. **依赖方向**：`core` 是依赖树叶子，零依赖、零 I/O，禁止 import 本 module 其他 package；`backend` 只允许依赖 `core`；`widgets` / `layout` 只允许依赖 `core`，**禁止依赖 `backend`**（widget 的输出是 Buffer，不是 ANSI）；黑盒测试包（如 `widgets/test/`）只允许依赖被测 package 与 `backend` 的公开 API 喵。

2. **core 零 I/O**：`core` 禁止终端、文件、网络、进程、时钟等一切 I/O；一切平台接触（raw mode、输入事件、tty）收敛在 `backend`，且真终端后端必须经由 `moonbit-community/tty` 组装，禁止在本库自写平台 C stub 喵。

3. **无 panic**：渲染路径禁止 `abort` / `panic`，越界与退化输入（空区域、超宽文本）一律优雅裁剪；`guard!` 仅限"调用方破坏内部不变量"的程序员错误（如 `Buffer::diff` 尺寸不一致），不得当业务错误通道喵。

4. **黄金快照**：一切渲染行为改动必须以 `inspect` 快照佐证；快照更新只走 `moon test --update`，禁止手改 content 字符串、禁止静默改断言掩盖回归喵。

5. **即时模式**：widget 一律无状态，`render(area, buf)` 即画即走；禁止 retained 组件树、响应式订阅、全量帧缓存——那是 vDOM 路线（mizchi/tui 位）的范式，与本库互斥喵。

6. **ANSI 出口唯一**：一切终端转义序列只能出自 `backend/ansi.mbt`（`csi` / `cursor_to` / `sgr_transition` / `frame_to_ansi`）；上层禁止手拼 `"\u{1b}[..."` 转义字串喵。

7. **扩展性纪律**：可后加的字段一律 `T?` 或带默认值；对外枚举一律 `pub(all)`，消费者 `match` 必须带通配分支以防新增变体；禁止预埋无消费方的机制字段/参数喵。
