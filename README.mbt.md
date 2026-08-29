# ratatui4moon

MoonBit 的 ratatui 式终端 UI 框架：**cell 网格双缓冲 + 即时模式 widget + 黄金 ANSI 快照测试**喵。

## 生态位

| 库 | 定位 |
|---|---|
| `moonbit-community/tty` | 低层终端原语（crossterm 位）：raw mode / 尺寸 / 输入事件 |
| `mizchi/tui` | vDOM + 响应式路线（Ink 位） |
| **ratatui4moon** | **immediate-mode 框架层（ratatui 位）**：Buffer/布局/widget |

不引入 Bun、不走 FFI，全程纯 MoonBit，native 后端静态编译单二进制喵。

## 架构

```
widgets/   无状态 widget：render(area, buf) 即画即走
   │
core/      Rect / Style / Cell / Buffer + 帧差分（纯函数，零 I/O，依赖树叶）
   │
backend/   Backend trait · TestBackend（录帧）· ANSI 发射引擎
```

## 测试哲学

黄金快照：`widget 渲染 → Buffer::diff → TestBackend → last_ansi`，
对精确 ANSI 字符串做 `inspect!` 断言。零真实终端、零网络、完全确定性；
行为规格采用"上游单测复刻 TDD"：先把 ratatui（pinned `ratatui-v0.30.2`）
的对应内联测试逐条搬进来，再照上游语义写实现跑到全绿（详见
docs/design.md ADR-6/ADR-7）喵。

```bash
moon test            # 全绿
moon test --update   # 行为变更后批量更新快照（禁止手改）
```

## 状态

v0.1：`core` / `backend` / `widgets` 三包绿；Rect/Style/Cell/Buffer/Span/Line、
Block（边框/线型/标题/内边距）、Paragraph（折行/截断/滚动/对齐）、List、Tabs、
Gauge/LineGauge（unicode 半格进度条）、Sparkline（九级波形图）、Scrollbar
（四方位滚动条）、Clear/Fill（清空与填充基元）、BarChart（双方向分组
柱状图）的单元测试与集成黄金用例逐条复刻自 ratatui-v0.30.2 并 TDD
转绿；symbols line/block/bar/shade/scrollbar 符号表全量入库；黄金快照管线
已立。
设计全文见 [docs/design.md](docs/design.md)，对位进度见
[docs/parity.md](docs/parity.md)，仓库条约见 [AGENTS.md](AGENTS.md)。
