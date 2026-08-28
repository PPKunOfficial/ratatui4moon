# MoonBit 编码品味 · taste 速成手册喵

> 来源：`mooncakes.io/docs/moonbitlang/core` + `github.com/moonbitlang/core` 源码实地扒取，对照 Nonoka 家族（Nonoka / ratatui4moon）现有写法提炼。学 core 的形，守家族的魂喵。
> 本手册与 Nonoka 仓库同源同规：core 派生章节逐字一致，仓库映射章节各自适配。

---

## 1. 心法一句话

**块式、显式、手写、可快照**—— core 把每个语义单元切成 `///|` 块，顺序无关；类型命名严、注释带可跑示例、错误用 `raise`/`Option` 显式、wire 全手写、测试靠 `inspect` 快照。ratatui4moon 在此之上加七条铁律（见 `@.agents/iron.md`）：依赖方向、core 零 I/O、无 panic、黄金快照、即时模式、ANSI 出口唯一、扩展性纪律喵。

---

## 2. 文件与包的骨架

### 2.1 包即目录

```
core/array/
  moon.pkg        # 依赖声明
  array.mbt       # 主实现
  deprecated.mbt  # 废弃别名集中地，别散落主文件
  array_test.mbt  # 黑盒测试
  array_wbtest.mbt # 白盒测试（可访问 priv）
  array.mbti      # 生成的接口摘要（moon info 产出，git 跟踪）

ratatui4moon/
  core/           # 依赖树叶：Rect / Style / Cell / Buffer / 差分
  backend/        # Backend trait · TestBackend · ANSI 引擎
  widgets/        # 无状态 widget（Block / Paragraph / …）
  widgets/test/   # 黑盒黄金快照包（for "test" 导入）
```

- `builtin` 是隐式可用、无需 import 的基座；`prelude` 自动 open，重导出 `Debug`/`BigInt`/`Ref`/`Lazy`/`test` 断言等。
- 其他包一律 `moonbitlang/core/<pkg>` + `@pkg` 前缀使用；本 module 内跨包同样走别名前缀（`@core.Buffer`、`@backend.TestBackend`）。
- `moon.pkg` 只声明直接依赖，禁止上层反向依赖叶子包（本库版：`core` 是叶子，禁止依赖任何其他包喵）。

### 2.2 块式组织 `///|`

core 的 `AGENTS.md` 原话：*MoonBit code is organized in block style, each block is separated by `///|`, the order of each block is irrelevant. In some refactorings, you can process block by block independently.*

```moonbit
///|
/// Zips two arrays ...          // 块注释：参数/返回/示例三件套
pub fn[A, B, C] zip_with(...) -> Array[C] raise? { ... }

///|
pub impl[T: Eq] Eq for Array[T] with fn equal(self, other) -> Bool { ... }
```

- 每个 `///|` 开一块，块内恰好一个顶层定义（fn/struct/enum/impl/trait/test）。
- 块顺序无关——重构时可按块独立搬运。
- 废弃块统一丢 `deprecated.mbt`，别污染主文件。

---

## 3. 命名与可见性

| 对象 | 风格 | 例 |
|------|------|----|
| 类型/ trait / enum 变体 | `PascalCase` | `HashMap`, `StopReason::ToolUse`, `StreamEvent::Error` |
| 函数/方法/变量/字段 | `snake_case` | `from_array`, `cache_read`, `set_cell` |
| 常量/静态 | `snake_case` | `default_init_capacity`, `ESCAPE` |
| 泛型形参 | 单字母 `A,B,C` 起步；`K,V` 给 Map 专用 | `fn[A,B] List::map` |
| 包名/文件名 | `snake_case` | `hashmap`, `test_backend` |

可见性阶梯：
`priv`（包内） < 无修饰（抽象公开，慎用） < `pub`（公开） < `pub(all)`（字段全公开，统一模型专用） < `pub(open)`（trait 可被外部实现，`Backend` 用它）。

> core 叮嘱：**测试夹具一律 `priv`**，否则 `derive` 会触发 `implicit_impl_as_method`，逼你写无意义的 `pub extend`。ratatui4moon 的 `core` 模型（`Rect` / `Style` / `Cell` / `Buffer`）刻意 `pub(all)`——跨包构造与字段访问是渲染管线的日常喵。

---

## 4. 类型、derive 与 trait 品味

### 4.1 结构体/枚举写法

```moonbit
// 家族实例（Nonoka protocol）：位置参数枚举 + 结构体现成 struct，派生齐全喵
pub(all) enum Msg {
  User(UserContent, Int64?)
  Assistant(AssistantMsg)
} derive(Eq, Debug)

pub(all) struct Usage {
  input : Int
  output : Int
  cost : Cost?
} derive(Eq, Debug)

pub fn Usage::zero() -> Usage { { input: 0, output: 0, cost: None } }
```

- 字段多时用 `struct`；变体少且语义靠顺序固定的用**位置参数枚举**。
- 构造统一用 `Type::new` / `Type::zero` / `Rect::new` 这种关联函数，字面量初始化写 `{ field: value }`，能省略就省略（`{ ch, style }`）。
- `derive(Eq, Debug)` 几乎标配；`Compare`/`Hash`/`Show`/`ToJson` 按需。注意 `Show::to_string` 仅标量类型才 promote，集合一律走 `@debug.Debug`（core 已把 `Show` 标记 deprecated）。

### 4.2 `Option` 与 `Result` 的 MoonBit 方言

- `T?` 即 `Option[T]`，`None`/`Some(v)` 直用：`Color?`, `Int64?`, `Json?`。
- 可失败函数签名 `-> T raise Error` 或 `-> T raise?`（多态错误），调用方用 `raise`/`guard`/`guard!`。
- 不要 `panic` 冒充业务错误；渲染路径的越界/退化输入一律优雅裁剪，禁止 `abort` 喵。

### 4.3 trait 晋升纪律（extends.mbt 专属）

core 的 `extends.mbt` 晋升规则是**按 trait 的归属包**决定：

- 归属 `builtin` 的（`Eq`/`Compare`/`Hash`/`Show`/`Default`/`Add` 等）——可 `pub extend` 晋升为 `x.method()`，运算符每型必晋升；`Compare::compare`/`Eq::equal`/`Hash::hash` 全型统一晋升，衍生方法（`op_lt`/`not_equal`/`hash_combine`）保持 deprecated。
- 归属高层包的（`@json.FromJson`/`@debug.Debug`/`ToJson`）——**永不晋升**，一律用自由函数 `Json(x)` / `@json.from_json`。`ToJson` 虽暂在 `builtin`，也按高层处理，为未来迁移不 churn 调用点。

> ratatui4moon 映射：`core`/`widgets` 不晋升高层 trait；`Backend` 是 `pub(open)` trait（归属 `backend` 包），实现方用 `pub impl Backend for X with fn draw(...)` 喵。

---

## 5. 文档注释：塔菲风但技术零模糊

本仓库约定：**.md 与注释统一中文、塔菲风格（俏皮、句尾可带"喵"），但技术表述必须准确**。

core 的块注释模板（照搬即品味）：

```moonbit
///|
/// Sets a key-value pair into the hash map. If the key already exists, updates
/// its value. ...
///
/// Parameters:
///
/// * `map` : The hash map to modify.
///
/// Returns ...
///
/// Example:
///
/// ```mbt check
/// test {
///   let map : @hashmap.HashMap[String, Int] = HashMap([])
///   map.set("key", 42)
///   debug_inspect(map.get("key"), content="Some(42)")
/// }
/// ```
pub fn[K: Hash + Eq, V] HashMap::set(self: HashMap[K,V], key: K, value: V) -> Unit { ... }
```

要点：

- 首句动词开头，讲清副作用/边界（"越界自动裁剪"、"恰好一个终结事件"）。
- `Parameters`/`Returns`/`Example` 三段式，示例必须是 ```mbt check + test { ... }``` 可被 `moon check` 静态检验的。
- 废弃用 `#deprecated("Use from_array instead")` + `#doc(hidden)`，别名用 `#alias` / `#as_free_fn` / `#owned` 标注所有权。

ratatui4moon 版标杆（`backend/ansi.mbt` 的 `sgr_transition`）：

```moonbit
///|
/// 单元格样式切换的 SGR 增量喵。
///
/// `prev` 是上一单元格样式（帧首传 `None`）；样式未变化返回空串，
/// 回到默认样式发射 RESET，进入非默认样式发射"RESET + 逐项设置"。
/// 帧首（`None`）遇到默认样式同样返回空串，保证无样式帧零 SGR 噪音喵。
pub fn sgr_transition(next : Style, prev : Style?) -> String { ... }
```

---

## 6. 错误与分支惯用语

```moonbit
// guard 早退，guard! 断言崩溃（仅内部不变量）
guard json is Json::Object(map) else { raise WireError::NotObject("msg") }
guard! index >= 0 && index < len

// Option 匹配补默认（宽松反序列化）
fn get_str(map: Map[String, Json], key: String, default: String) -> String {
  match map.get(key) { Some(Json::String(s)) => s; _ => default }
}
```

- `raise` 用于可恢复的结构性错误；`abort("...")` 仅用于"空列表取头"这种程序员错误，且要配 `#internal(unsafe, "...")` + `#doc(hidden)`。
- 字符串插值一律 `"\{expr}"`，别拼 `+`。
- **本库对应纪律**：渲染路径没有 raise 通道——越界裁剪（`Buffer::set_cell` 静默忽略）、退化区域整体跳过（`Block::render` <2×2 return）；`guard!` 仅限内部不变量（`Buffer::diff` 的尺寸断言）喵。

---

## 7. 集合与迭代：for/continue/break/nobreak 三件套

core 最标志性的味道是**显式状态机的 `for` 循环**，替代递归：

```moonbit
// 带 nobreak 的"正常结束 vs 提前 break"区分
pub impl[T: Eq] Eq for Array[T] with fn equal(self, other) {
  guard self.length() == other.length() else { return false }
  for i in 0..<self.length() {
    guard self.unsafe_get(i) == other.unsafe_get(i) else { break false }
  } nobreak { true }
}

// 迭代器消费：for v in self / for i, v in self
pub fn[T] Array::each(self: Array[T], f: (T) -> Unit raise?) -> Unit raise? {
  for v in self { f(v) }
}
```

- 优先用 `for v in collection` / `for i in 0..<len` / `for i, v in self`，别手写 `while` + 索引。
- 需要携带多状态就 `for a = init1, b = init2 { ... continue new_a, new_b }`，终态用 `break value`，无 break 走 `nobreak { default }`。
- `#locals(f)` 标注闭包捕获局部性的函数（`map`/`filter`/`each` 等），让编译器优化逃逸。
- 本库实例：`frame_to_ansi` 的光标状态机（`cursor_valid` + 相邻性判断）、`Buffer::set_string` 的 `for ch in text` 列推进喵。

---

## 8. 转义与序列化：全手写，零魔法

本库 v0.1 没有 JSON/wire 层；领域内的对应纪律是 **ANSI 全手写、出口唯一**：

- 一切转义出自 `backend/ansi.mbt`：`csi(params, code)` 构造、`cursor_to` 定位、`sgr_transition` 样式增量、`frame_to_ansi` 整帧发射；
- 上层（widgets / 未来 layout）禁止手拼 `"\u{1b}[..."` 字面量——见铁律 6；
- 转义行为以黄金快照锁定（`widgets/test/golden_test.mbt`），改协议先改快照再改实现，`moon test --update` 收尾喵。

> 未来若引入序列化（布局/主题/会话持久化），按 core 品味全手写：辅助 `put_str`/`get_str` 消灭重复，缺字段补默认、未知字段忽略，序列化永不失败、反序列化仅对结构性问题 `raise`；禁止引入 serde 式魔法宏。需要实例回读 Nonoka `protocol/wire.mbt` 喵。

---

## 9. 测试：快照优先，断言兜底

core 的测试哲学：**`inspect`/`debug_inspect` 快照 > `assert_eq`**，循环内才用断言。

```moonbit
test "of" {
  let m = from_array([(1, 2), (3, 4)])
  @debug.debug_inspect(m.get(1), content="Some(2)")  // 快照字符串精确匹配
}

test "set" {
  let m: HashMap[MyString, Int] = new_hashmap(8)
  m.set("a", 1); m.set("b", 1)
  inspect(m.length(), content="7")  // 基础值也用 inspect
}
```

工具链：

```bash
moon test                 # 全绿方可提交
moon test --update        # 行为变更后批量更新快照（别手改快照字符串）
moon test -p nonoka/ratatui4moon/widgets  # 单包回归
moon check                # lint
moon fmt                  # 格式化（提交前必跑）
moon info                 # 更新 .mbti 接口摘要，diff .mbti 可见公开 API 是否意外变更
```

- 黑盒测试放 `*_test.mbt`，白盒放 `*_wbtest.mbt`；需要隔离时建 `<pkg>/test/` 独立测试包，只依赖公开 API（本库：`widgets/test/` 黄金快照包）。
- **本库的快照主战场**：`widget 渲染 → Buffer::diff → TestBackend → last_ansi` 精确 ANSI 串断言，零真实终端、零 I/O、完全确定性。
- 无 `Show` 的类型（`Color?` 等统一模型）走 Debug 通道 `@debug.debug_inspect`，或提取标量断言（如 `Color::fg_code()`），不许给模型补 `Show` 凑合喵。

---

## 10. 工具链与属性速查

| 属性/指令 | 用途 | 例 |
|-----------|------|----|
| `#alias("_[_]")` | 运算符别名 | `HashMap::at` 别名 `_[_]` |
| `#owned(value)` | 移动语义提示 | `HashMap::set` 的 `value` |
| `#locals(f)` | 闭包不逃逸优化 | `Array::map`, `List::filter` |
| `#inline` | 内联 | `need_escape_scalar` |
| `#deprecated("Use X")` | 废弃引导 | `List::from_array` |
| `#doc(hidden)` | 接口隐藏但仍可用 | `unsafe_head` |
| `#internal(unsafe, "...")` | 标记不安全内部 API | `unsafe_nth` |
| `#cfg(target="native")` | 条件编译 | `need_escape` 的 v128 加速 |
| `#coverage.skip` | 覆盖率跳过 | 测试桩 `MyString` 的 Hash |
| `#callsite(autofill(...))` | 调用点注入 | `json_inspect` |
| `///\|` | 块分隔 | 每定义一块 |
| `moon fmt` | 唯一格式化器 | 提交前必跑（会把 `inspect!` 规范为 `inspect`） |
| `moon info` | 生成 `.mbti` | 提交前必跑，检查 diff |
| `moon check` | lint | 提交前必跑 |

---

## 11. ratatui4moon 对 core 的继承与加严

在 core 品味之上，本库加了 7 条铁律（见 `.agents/iron.md`，此节只列映射喵）：

1. **依赖方向**：`core` 叶子化；`widgets` 不碰 ANSI；测试包只依赖公开 API。
2. **core 零 I/O**：平台接触全在 `backend`，真终端后端经 `moonbit-community/tty` 组装。
3. **无 panic**：越界裁剪、退化跳过；`guard!` 仅内部不变量。
4. **黄金快照**：渲染行为的唯一佐证形式。
5. **即时模式**：widget 无状态，`render(area, buf)` 即画即走。
6. **ANSI 出口唯一**：转义只出自 `backend/ansi.mbt`。
7. **扩展性纪律**：`T?` 字段、`pub(all)` 枚举、match 通配、无预埋机制。

落到代码的家族味道：

- 统一 `derive(Eq, Debug)`，不用 `Show` 做调试（core 已 deprecated）。
- 现算不存冗余字段——别制造第二个真相源（如 `Style::is_default` 由字段推导，不存布尔副本）。
- `Buffer` 行主序一维存储，索引公式 `(y - area.y) * width + (x - area.x)` 集中在 `set_cell`/`get`，别在调用方重算。
- 差分只带增量（变更单元格列表），不带全量快照；全量在 Buffer 端，消费在 backend 端喵。

---

## 12. 反模式清单（看到就改喵）

- ❌ 一个文件塞多职责（把 ANSI 发射塞进 widgets）
- ❌ widget / 上层手拼 ANSI 转义字串（该走 `backend/ansi.mbt`）
- ❌ `abort`/`panic` 出现在渲染路径（该优雅裁剪；`guard!` 仅限不变量）
- ❌ widget 持 retained 状态、订阅响应式、缓存全量帧
- ❌ 手改快照 content 字符串掩盖回归（该 `moon test --update` 接管）
- ❌ `match` 枚举不写通配分支（未来加变体就炸）
- ❌ 测试里用 `assert_eq` 测单值快照（该 `inspect`，让 `moon test --update` 接管）
- ❌ `core` 里 import 本 module 其他包或触碰 I/O
- ❌ `moon fmt` / `moon info` / `moon check` / `moon test` 未全绿就提交
- ❌ 为未来预埋无消费方的机制字段/参数（等真有消费方再加喵）

---

## 13. 速查：新建一个包的最小品味

```bash
mkdir -p layout
cat > layout/moon.pkg <<'EOF'
import {
  "nonoka/ratatui4moon/core",
}

pkgtype(kind: "library")

supported_targets = "+native"
EOF

cat > layout/solver.mbt <<'EOF'
///|
/// 线性布局求解器喵。
pub(all) struct LinearSolver {
  direction : Direction
} derive(Eq, Debug)
EOF

moon fmt && moon info && moon check && moon test -p nonoka/ratatui4moon/layout
```

---

## 14. 参考

- mooncakes core 文档：`https://mooncakes.io/docs/moonbitlang/core`（builtin → prelude → collections → json/… 分层图）
- core 源码：`https://github.com/moonbitlang/core`（`AGENTS.md` 的 `extend` 晋升规则、`CONTRIBUTING.md` 的命名/格式化/测试指南）
- 本仓库条约：`AGENTS.md`、`.agents/iron.md`、`docs/design.md`、`core/*.mbt`、`backend/ansi.mbt`
- 家族同源手册：Nonoka 仓库 `.agents/taste.md`（wire/协议域实例）

> 记住喵：先 `moon fmt && moon info` 看 `.mbti` diff，再 `moon test --update` 定快照，最后 `moon check && moon test` 全绿——这就是 core 教给你的"先定形，再定行"喵。
