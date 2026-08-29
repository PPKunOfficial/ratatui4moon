///|
/// Layout 单元测试：复刻 ratatui-v0.30.2 `layout/layout.rs` 测试清单喵。
///
/// letters 特征矩阵以数据表循环承载（上游 rstest #[case] 逐条对应）；
/// 断言形式与上游一致：以单字母铺满各段后比对整行喵。

///|
/// 上游 letters 辅助：横向切分后按段宽铺字母并比对喵。
fn letters(
  flex : @core.Flex,
  constraints : Array[@core.Constraint],
  width : Int,
  expected : String,
) -> Unit raise {
  let area = @core.Rect::new(0, 0, width, 1)
  let layout = Layout::default()
    .direction(@core.Horizontal)
    .constraints(constraints)
    .flex(flex)
  let chunks = layout.split(area)
  let buffer = @core.Buffer::empty(area)
  let alphabet = "abcdefghijklmnopqrstuvwxyz"
  let chars : Array[Char] = []
  for ch in alphabet.iter() {
    chars.push(ch)
  }
  for i, chunk in chunks {
    let c = chars[i]
    let text = String::repeat(c.to_string(), chunk.width)
    buffer.set_string(chunk.x, chunk.y, text, @core.Style::default())
  }
  let out = StringBuilder()
  for x in 0..<width {
    out.write_string(buffer.get(x, 0).symbol())
  }
  assert_eq(out.to_string(), expected)
}

///|
/// 上游 split_with_spacers docstring 示例一：纵向 Length(5)+Fill(1) 喵。
test "Layout 纵向 Length+Fill" {
  let layout = Layout::default()
    .direction(@core.Vertical)
    .constraints([@core.Length(5), @core.Fill(1)])
  let (areas, spacers) = layout.split_with_spacers(
    @core.Rect::new(2, 2, 10, 10),
  )
  assert_eq(areas[0], @core.Rect::new(2, 2, 10, 5))
  assert_eq(areas[1], @core.Rect::new(2, 7, 10, 5))
  assert_eq(spacers[0], @core.Rect::new(2, 2, 10, 0))
  assert_eq(spacers[1], @core.Rect::new(2, 7, 10, 0))
  assert_eq(spacers[2], @core.Rect::new(2, 12, 10, 0))
}

///|
/// 上游 split_with_spacers docstring 示例二：横向 spacing(1) +
/// Ratio(1,3)+Ratio(2,3) 喵。
test "Layout 横向 Ratio 带间距" {
  let layout = Layout::default()
    .direction(@core.Horizontal)
    .spacing(1)
    .constraints([@core.Ratio(1, 3), @core.Ratio(2, 3)])
  let (areas, spacers) = layout.split_with_spacers(@core.Rect::new(0, 0, 10, 2))
  assert_eq(areas[0], @core.Rect::new(0, 0, 3, 2))
  assert_eq(areas[1], @core.Rect::new(4, 0, 6, 2))
  assert_eq(spacers[0], @core.Rect::new(0, 0, 0, 2))
  assert_eq(spacers[1], @core.Rect::new(3, 0, 1, 2))
  assert_eq(spacers[2], @core.Rect::new(10, 0, 0, 2))
}

///|
/// 上游 vertical_split_by_height：高度守恒且单调喵。
test "Layout 纵向高度守恒" {
  let target = @core.Rect::new(2, 2, 10, 10)
  let chunks = Layout::default()
    .direction(@core.Vertical)
    .constraints([@core.Percentage(10), @core.Max(5), @core.Min(1)])
    .split(target)
  let mut total = 0
  for chunk in chunks {
    total += chunk.height
  }
  inspect(total, content="10")
  for i in 1..<chunks.length() {
    assert_eq(chunks[i - 1].y <= chunks[i].y, true)
  }
}

///|
/// 上游 edge_cases：退化区域的四处特征行为喵。
test "Layout edge cases" {
  let layout = Layout::default()
    .constraints([@core.Percentage(50), @core.Percentage(50), @core.Min(0)])
    .split(@core.Rect::new(0, 0, 1, 1))
  assert_eq(layout[0], @core.Rect::new(0, 0, 1, 1))
  assert_eq(layout[1], @core.Rect::new(0, 1, 1, 0))
  assert_eq(layout[2], @core.Rect::new(0, 1, 1, 0))
  let layout = Layout::default()
    .constraints([@core.Max(1), @core.Percentage(99), @core.Min(0)])
    .split(@core.Rect::new(0, 0, 1, 1))
  assert_eq(layout[0], @core.Rect::new(0, 0, 1, 0))
  assert_eq(layout[1], @core.Rect::new(0, 0, 1, 1))
  assert_eq(layout[2], @core.Rect::new(0, 1, 1, 0))
  let layout = Layout::default()
    .constraints([@core.Min(1), @core.Length(0), @core.Min(1)])
    .direction(@core.Horizontal)
    .split(@core.Rect::new(0, 0, 1, 1))
  assert_eq(layout[0], @core.Rect::new(0, 0, 1, 1))
  assert_eq(layout[1], @core.Rect::new(1, 0, 0, 1))
  assert_eq(layout[2], @core.Rect::new(1, 0, 0, 1))
  let layout = Layout::default()
    .constraints([@core.Length(3), @core.Min(4), @core.Length(1), @core.Min(4)])
    .direction(@core.Horizontal)
    .split(@core.Rect::new(0, 0, 7, 1))
  assert_eq(layout[0], @core.Rect::new(0, 0, 0, 1))
  assert_eq(layout[1], @core.Rect::new(0, 0, 4, 1))
  assert_eq(layout[2], @core.Rect::new(4, 0, 0, 1))
  assert_eq(layout[3], @core.Rect::new(4, 0, 3, 1))
}

///|
/// 上游 length 参数矩阵（33 case）喵。
test "letters length" {
  let cases : Array[(String, Int, Array[@core.Constraint], String)] = [
    ("Legacy", 1, [@core.Length(0)], "a"),
    ("Legacy", 1, [@core.Length(1)], "a"),
    ("Legacy", 1, [@core.Length(2)], "a"),
    ("Legacy", 2, [@core.Length(0)], "aa"),
    ("Legacy", 2, [@core.Length(1)], "aa"),
    ("Legacy", 2, [@core.Length(2)], "aa"),
    ("Legacy", 2, [@core.Length(3)], "aa"),
    ("Legacy", 1, [@core.Length(0), @core.Length(0)], "b"),
    ("Legacy", 1, [@core.Length(0), @core.Length(1)], "b"),
    ("Legacy", 1, [@core.Length(0), @core.Length(2)], "b"),
    ("Legacy", 1, [@core.Length(1), @core.Length(0)], "a"),
    ("Legacy", 1, [@core.Length(1), @core.Length(1)], "a"),
    ("Legacy", 1, [@core.Length(1), @core.Length(2)], "a"),
    ("Legacy", 1, [@core.Length(2), @core.Length(0)], "a"),
    ("Legacy", 1, [@core.Length(2), @core.Length(1)], "a"),
    ("Legacy", 1, [@core.Length(2), @core.Length(2)], "a"),
    ("Legacy", 2, [@core.Length(0), @core.Length(0)], "bb"),
    ("Legacy", 2, [@core.Length(0), @core.Length(1)], "bb"),
    ("Legacy", 2, [@core.Length(0), @core.Length(2)], "bb"),
    ("Legacy", 2, [@core.Length(0), @core.Length(3)], "bb"),
    ("Legacy", 2, [@core.Length(1), @core.Length(0)], "ab"),
    ("Legacy", 2, [@core.Length(1), @core.Length(1)], "ab"),
    ("Legacy", 2, [@core.Length(1), @core.Length(2)], "ab"),
    ("Legacy", 2, [@core.Length(1), @core.Length(3)], "ab"),
    ("Legacy", 2, [@core.Length(2), @core.Length(0)], "aa"),
    ("Legacy", 2, [@core.Length(2), @core.Length(1)], "aa"),
    ("Legacy", 2, [@core.Length(2), @core.Length(2)], "aa"),
    ("Legacy", 2, [@core.Length(2), @core.Length(3)], "aa"),
    ("Legacy", 2, [@core.Length(3), @core.Length(0)], "aa"),
    ("Legacy", 2, [@core.Length(3), @core.Length(1)], "aa"),
    ("Legacy", 2, [@core.Length(3), @core.Length(2)], "aa"),
    ("Legacy", 2, [@core.Length(3), @core.Length(3)], "aa"),
    ("Legacy", 3, [@core.Length(2), @core.Length(2)], "aab"),
  ]
  for case in cases {
    letters(flex_of(case.0), case.2, case.1, case.3)
  }
}

///|
/// 上游 max 参数矩阵（33 case）喵。
test "letters max" {
  let cases : Array[(String, Int, Array[@core.Constraint], String)] = [
    ("Legacy", 1, [@core.Max(0)], "a"),
    ("Legacy", 1, [@core.Max(1)], "a"),
    ("Legacy", 1, [@core.Max(2)], "a"),
    ("Legacy", 2, [@core.Max(0)], "aa"),
    ("Legacy", 2, [@core.Max(1)], "aa"),
    ("Legacy", 2, [@core.Max(2)], "aa"),
    ("Legacy", 2, [@core.Max(3)], "aa"),
    ("Legacy", 1, [@core.Max(0), @core.Max(0)], "b"),
    ("Legacy", 1, [@core.Max(0), @core.Max(1)], "b"),
    ("Legacy", 1, [@core.Max(0), @core.Max(2)], "b"),
    ("Legacy", 1, [@core.Max(1), @core.Max(0)], "a"),
    ("Legacy", 1, [@core.Max(1), @core.Max(1)], "a"),
    ("Legacy", 1, [@core.Max(1), @core.Max(2)], "a"),
    ("Legacy", 1, [@core.Max(2), @core.Max(0)], "a"),
    ("Legacy", 1, [@core.Max(2), @core.Max(1)], "a"),
    ("Legacy", 1, [@core.Max(2), @core.Max(2)], "a"),
    ("Legacy", 2, [@core.Max(0), @core.Max(0)], "bb"),
    ("Legacy", 2, [@core.Max(0), @core.Max(1)], "bb"),
    ("Legacy", 2, [@core.Max(0), @core.Max(2)], "bb"),
    ("Legacy", 2, [@core.Max(0), @core.Max(3)], "bb"),
    ("Legacy", 2, [@core.Max(1), @core.Max(0)], "ab"),
    ("Legacy", 2, [@core.Max(1), @core.Max(1)], "ab"),
    ("Legacy", 2, [@core.Max(1), @core.Max(2)], "ab"),
    ("Legacy", 2, [@core.Max(1), @core.Max(3)], "ab"),
    ("Legacy", 2, [@core.Max(2), @core.Max(0)], "aa"),
    ("Legacy", 2, [@core.Max(2), @core.Max(1)], "aa"),
    ("Legacy", 2, [@core.Max(2), @core.Max(2)], "aa"),
    ("Legacy", 2, [@core.Max(2), @core.Max(3)], "aa"),
    ("Legacy", 2, [@core.Max(3), @core.Max(0)], "aa"),
    ("Legacy", 2, [@core.Max(3), @core.Max(1)], "aa"),
    ("Legacy", 2, [@core.Max(3), @core.Max(2)], "aa"),
    ("Legacy", 2, [@core.Max(3), @core.Max(3)], "aa"),
    ("Legacy", 3, [@core.Max(2), @core.Max(2)], "aab"),
  ]
  for case in cases {
    letters(flex_of(case.0), case.2, case.1, case.3)
  }
}

///|
/// 上游 min 参数矩阵（26 case）喵。
test "letters min" {
  let cases : Array[(String, Int, Array[@core.Constraint], String)] = [
    ("Legacy", 1, [@core.Min(0), @core.Min(0)], "b"),
    ("Legacy", 1, [@core.Min(0), @core.Min(1)], "b"),
    ("Legacy", 1, [@core.Min(0), @core.Min(2)], "b"),
    ("Legacy", 1, [@core.Min(1), @core.Min(0)], "a"),
    ("Legacy", 1, [@core.Min(1), @core.Min(1)], "a"),
    ("Legacy", 1, [@core.Min(1), @core.Min(2)], "a"),
    ("Legacy", 1, [@core.Min(2), @core.Min(0)], "a"),
    ("Legacy", 1, [@core.Min(2), @core.Min(1)], "a"),
    ("Legacy", 1, [@core.Min(2), @core.Min(2)], "a"),
    ("Legacy", 2, [@core.Min(0), @core.Min(0)], "bb"),
    ("Legacy", 2, [@core.Min(0), @core.Min(1)], "bb"),
    ("Legacy", 2, [@core.Min(0), @core.Min(2)], "bb"),
    ("Legacy", 2, [@core.Min(0), @core.Min(3)], "bb"),
    ("Legacy", 2, [@core.Min(1), @core.Min(0)], "ab"),
    ("Legacy", 2, [@core.Min(1), @core.Min(1)], "ab"),
    ("Legacy", 2, [@core.Min(1), @core.Min(2)], "ab"),
    ("Legacy", 2, [@core.Min(1), @core.Min(3)], "ab"),
    ("Legacy", 2, [@core.Min(2), @core.Min(0)], "aa"),
    ("Legacy", 2, [@core.Min(2), @core.Min(1)], "aa"),
    ("Legacy", 2, [@core.Min(2), @core.Min(2)], "aa"),
    ("Legacy", 2, [@core.Min(2), @core.Min(3)], "aa"),
    ("Legacy", 2, [@core.Min(3), @core.Min(0)], "aa"),
    ("Legacy", 2, [@core.Min(3), @core.Min(1)], "aa"),
    ("Legacy", 2, [@core.Min(3), @core.Min(2)], "aa"),
    ("Legacy", 2, [@core.Min(3), @core.Min(3)], "aa"),
    ("Legacy", 3, [@core.Min(2), @core.Min(2)], "aab"),
  ]
  for case in cases {
    letters(flex_of(case.0), case.2, case.1, case.3)
  }
}

///|
/// 上游 percentage 参数矩阵（100 case）喵。
test "letters percentage" {
  let cases : Array[(String, Int, Array[@core.Constraint], String)] = [
    ("Legacy", 1, [@core.Percentage(0)], "a"),
    ("Legacy", 1, [@core.Percentage(25)], "a"),
    ("Legacy", 1, [@core.Percentage(50)], "a"),
    ("Legacy", 1, [@core.Percentage(90)], "a"),
    ("Legacy", 1, [@core.Percentage(100)], "a"),
    ("Legacy", 1, [@core.Percentage(200)], "a"),
    ("Legacy", 2, [@core.Percentage(0)], "aa"),
    ("Legacy", 2, [@core.Percentage(10)], "aa"),
    ("Legacy", 2, [@core.Percentage(25)], "aa"),
    ("Legacy", 2, [@core.Percentage(50)], "aa"),
    ("Legacy", 2, [@core.Percentage(66)], "aa"),
    ("Legacy", 2, [@core.Percentage(100)], "aa"),
    ("Legacy", 2, [@core.Percentage(200)], "aa"),
    ("Legacy", 10, [@core.Percentage(0)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Percentage(10)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Percentage(25)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Percentage(50)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Percentage(66)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Percentage(100)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Percentage(200)], "aaaaaaaaaa"),
    ("Legacy", 1, [@core.Percentage(0), @core.Percentage(0)], "b"),
    ("Legacy", 1, [@core.Percentage(0), @core.Percentage(10)], "b"),
    ("Legacy", 1, [@core.Percentage(0), @core.Percentage(50)], "b"),
    ("Legacy", 1, [@core.Percentage(0), @core.Percentage(90)], "b"),
    ("Legacy", 1, [@core.Percentage(0), @core.Percentage(100)], "b"),
    ("Legacy", 1, [@core.Percentage(0), @core.Percentage(200)], "b"),
    ("Legacy", 1, [@core.Percentage(10), @core.Percentage(0)], "b"),
    ("Legacy", 1, [@core.Percentage(10), @core.Percentage(10)], "b"),
    ("Legacy", 1, [@core.Percentage(10), @core.Percentage(50)], "b"),
    ("Legacy", 1, [@core.Percentage(10), @core.Percentage(90)], "b"),
    ("Legacy", 1, [@core.Percentage(10), @core.Percentage(100)], "b"),
    ("Legacy", 1, [@core.Percentage(10), @core.Percentage(200)], "b"),
    ("Legacy", 1, [@core.Percentage(50), @core.Percentage(0)], "a"),
    ("Legacy", 1, [@core.Percentage(50), @core.Percentage(50)], "a"),
    ("Legacy", 1, [@core.Percentage(50), @core.Percentage(100)], "a"),
    ("Legacy", 1, [@core.Percentage(50), @core.Percentage(200)], "a"),
    ("Legacy", 1, [@core.Percentage(90), @core.Percentage(0)], "a"),
    ("Legacy", 1, [@core.Percentage(90), @core.Percentage(50)], "a"),
    ("Legacy", 1, [@core.Percentage(90), @core.Percentage(100)], "a"),
    ("Legacy", 1, [@core.Percentage(90), @core.Percentage(200)], "a"),
    ("Legacy", 1, [@core.Percentage(100), @core.Percentage(0)], "a"),
    ("Legacy", 1, [@core.Percentage(100), @core.Percentage(50)], "a"),
    ("Legacy", 1, [@core.Percentage(100), @core.Percentage(100)], "a"),
    ("Legacy", 1, [@core.Percentage(100), @core.Percentage(200)], "a"),
    ("Legacy", 2, [@core.Percentage(0), @core.Percentage(0)], "bb"),
    ("Legacy", 2, [@core.Percentage(0), @core.Percentage(25)], "bb"),
    ("Legacy", 2, [@core.Percentage(0), @core.Percentage(50)], "bb"),
    ("Legacy", 2, [@core.Percentage(0), @core.Percentage(100)], "bb"),
    ("Legacy", 2, [@core.Percentage(0), @core.Percentage(200)], "bb"),
    ("Legacy", 2, [@core.Percentage(10), @core.Percentage(0)], "bb"),
    ("Legacy", 2, [@core.Percentage(10), @core.Percentage(25)], "bb"),
    ("Legacy", 2, [@core.Percentage(10), @core.Percentage(50)], "bb"),
    ("Legacy", 2, [@core.Percentage(10), @core.Percentage(100)], "bb"),
    ("Legacy", 2, [@core.Percentage(10), @core.Percentage(200)], "bb"),
    ("Legacy", 2, [@core.Percentage(25), @core.Percentage(0)], "ab"),
    ("Legacy", 2, [@core.Percentage(25), @core.Percentage(25)], "ab"),
    ("Legacy", 2, [@core.Percentage(25), @core.Percentage(50)], "ab"),
    ("Legacy", 2, [@core.Percentage(25), @core.Percentage(100)], "ab"),
    ("Legacy", 2, [@core.Percentage(25), @core.Percentage(200)], "ab"),
    ("Legacy", 2, [@core.Percentage(33), @core.Percentage(0)], "ab"),
    ("Legacy", 2, [@core.Percentage(33), @core.Percentage(25)], "ab"),
    ("Legacy", 2, [@core.Percentage(33), @core.Percentage(50)], "ab"),
    ("Legacy", 2, [@core.Percentage(33), @core.Percentage(100)], "ab"),
    ("Legacy", 2, [@core.Percentage(33), @core.Percentage(200)], "ab"),
    ("Legacy", 2, [@core.Percentage(50), @core.Percentage(0)], "ab"),
    ("Legacy", 2, [@core.Percentage(50), @core.Percentage(50)], "ab"),
    ("Legacy", 2, [@core.Percentage(50), @core.Percentage(100)], "ab"),
    ("Legacy", 2, [@core.Percentage(100), @core.Percentage(0)], "aa"),
    ("Legacy", 2, [@core.Percentage(100), @core.Percentage(50)], "aa"),
    ("Legacy", 2, [@core.Percentage(100), @core.Percentage(100)], "aa"),
    ("Legacy", 3, [@core.Percentage(33), @core.Percentage(33)], "abb"),
    ("Legacy", 3, [@core.Percentage(33), @core.Percentage(66)], "abb"),
    ("Legacy", 4, [@core.Percentage(33), @core.Percentage(33)], "abbb"),
    ("Legacy", 4, [@core.Percentage(33), @core.Percentage(66)], "abbb"),
    ("Legacy", 10, [@core.Percentage(0), @core.Percentage(0)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(0), @core.Percentage(25)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(0), @core.Percentage(50)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(0), @core.Percentage(100)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(0), @core.Percentage(200)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(10), @core.Percentage(0)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(10), @core.Percentage(25)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(10), @core.Percentage(50)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(10), @core.Percentage(100)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(10), @core.Percentage(200)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Percentage(25), @core.Percentage(0)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(25), @core.Percentage(25)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(25), @core.Percentage(50)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(25), @core.Percentage(100)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(25), @core.Percentage(200)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(33), @core.Percentage(0)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(33), @core.Percentage(25)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(33), @core.Percentage(50)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(33), @core.Percentage(100)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(33), @core.Percentage(200)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Percentage(50), @core.Percentage(0)], "aaaaabbbbb"),
    ("Legacy", 10, [@core.Percentage(50), @core.Percentage(50)], "aaaaabbbbb"),
    ("Legacy", 10, [@core.Percentage(50), @core.Percentage(100)], "aaaaabbbbb"),
    ("Legacy", 10, [@core.Percentage(100), @core.Percentage(0)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Percentage(100), @core.Percentage(50)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Percentage(100), @core.Percentage(100)], "aaaaaaaaaa"),
  ]
  for case in cases {
    letters(flex_of(case.0), case.2, case.1, case.3)
  }
}

///|
/// 上游 percentage_start 参数矩阵（27 case）喵。
test "letters percentage_start" {
  let cases : Array[(String, Int, Array[@core.Constraint], String)] = [
    ("Start", 10, [@core.Percentage(0), @core.Percentage(0)], "          "),
    ("Start", 10, [@core.Percentage(0), @core.Percentage(25)], "bbb       "),
    ("Start", 10, [@core.Percentage(0), @core.Percentage(50)], "bbbbb     "),
    ("Start", 10, [@core.Percentage(0), @core.Percentage(100)], "bbbbbbbbbb"),
    ("Start", 10, [@core.Percentage(0), @core.Percentage(200)], "bbbbbbbbbb"),
    ("Start", 10, [@core.Percentage(10), @core.Percentage(0)], "a         "),
    ("Start", 10, [@core.Percentage(10), @core.Percentage(25)], "abbb      "),
    ("Start", 10, [@core.Percentage(10), @core.Percentage(50)], "abbbbb    "),
    ("Start", 10, [@core.Percentage(10), @core.Percentage(100)], "abbbbbbbbb"),
    ("Start", 10, [@core.Percentage(10), @core.Percentage(200)], "abbbbbbbbb"),
    ("Start", 10, [@core.Percentage(25), @core.Percentage(0)], "aaa       "),
    ("Start", 10, [@core.Percentage(25), @core.Percentage(25)], "aaabb     "),
    ("Start", 10, [@core.Percentage(25), @core.Percentage(50)], "aaabbbbb  "),
    ("Start", 10, [@core.Percentage(25), @core.Percentage(100)], "aaabbbbbbb"),
    ("Start", 10, [@core.Percentage(25), @core.Percentage(200)], "aaabbbbbbb"),
    ("Start", 10, [@core.Percentage(33), @core.Percentage(0)], "aaa       "),
    ("Start", 10, [@core.Percentage(33), @core.Percentage(25)], "aaabbb    "),
    ("Start", 10, [@core.Percentage(33), @core.Percentage(50)], "aaabbbbb  "),
    ("Start", 10, [@core.Percentage(33), @core.Percentage(100)], "aaabbbbbbb"),
    ("Start", 10, [@core.Percentage(33), @core.Percentage(200)], "aaabbbbbbb"),
    ("Start", 10, [@core.Percentage(50), @core.Percentage(0)], "aaaaa     "),
    ("Start", 10, [@core.Percentage(50), @core.Percentage(50)], "aaaaabbbbb"),
    ("Start", 10, [@core.Percentage(50), @core.Percentage(100)], "aaaaabbbbb"),
    ("Start", 10, [@core.Percentage(100), @core.Percentage(0)], "aaaaaaaaaa"),
    ("Start", 10, [@core.Percentage(100), @core.Percentage(50)], "aaaaabbbbb"),
    ("Start", 10, [@core.Percentage(100), @core.Percentage(100)], "aaaaabbbbb"),
    ("Start", 10, [@core.Percentage(100), @core.Percentage(200)], "aaaaabbbbb"),
  ]
  for case in cases {
    letters(flex_of(case.0), case.2, case.1, case.3)
  }
}

///|
/// 上游 percentage_spacebetween 参数矩阵（27 case）喵。
test "letters percentage_spacebetween" {
  let cases : Array[(String, Int, Array[@core.Constraint], String)] = [
    (
      "SpaceBetween",
      10,
      [@core.Percentage(0), @core.Percentage(0)],
      "          ",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(0), @core.Percentage(25)],
      "        bb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(0), @core.Percentage(50)],
      "     bbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(0), @core.Percentage(100)],
      "bbbbbbbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(0), @core.Percentage(200)],
      "bbbbbbbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(10), @core.Percentage(0)],
      "a         ",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(10), @core.Percentage(25)],
      "a       bb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(10), @core.Percentage(50)],
      "a    bbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(10), @core.Percentage(100)],
      "abbbbbbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(10), @core.Percentage(200)],
      "abbbbbbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(25), @core.Percentage(0)],
      "aaa       ",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(25), @core.Percentage(25)],
      "aaa     bb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(25), @core.Percentage(50)],
      "aaa  bbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(25), @core.Percentage(100)],
      "aaabbbbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(25), @core.Percentage(200)],
      "aaabbbbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(33), @core.Percentage(0)],
      "aaa       ",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(33), @core.Percentage(25)],
      "aaa     bb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(33), @core.Percentage(50)],
      "aaa  bbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(33), @core.Percentage(100)],
      "aaabbbbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(33), @core.Percentage(200)],
      "aaabbbbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(50), @core.Percentage(0)],
      "aaaaa     ",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(50), @core.Percentage(50)],
      "aaaaabbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(50), @core.Percentage(100)],
      "aaaaabbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(100), @core.Percentage(0)],
      "aaaaaaaaaa",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(100), @core.Percentage(50)],
      "aaaaabbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(100), @core.Percentage(100)],
      "aaaaabbbbb",
    ),
    (
      "SpaceBetween",
      10,
      [@core.Percentage(100), @core.Percentage(200)],
      "aaaaabbbbb",
    ),
  ]
  for case in cases {
    letters(flex_of(case.0), case.2, case.1, case.3)
  }
}

///|
/// 上游 ratio 参数矩阵（91 case）喵。
test "letters ratio" {
  let cases : Array[(String, Int, Array[@core.Constraint], String)] = [
    ("Legacy", 1, [@core.Ratio(0, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 4)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 2)], "a"),
    ("Legacy", 1, [@core.Ratio(9, 10)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(2, 1)], "a"),
    ("Legacy", 2, [@core.Ratio(0, 1)], "aa"),
    ("Legacy", 2, [@core.Ratio(1, 10)], "aa"),
    ("Legacy", 2, [@core.Ratio(1, 4)], "aa"),
    ("Legacy", 2, [@core.Ratio(1, 2)], "aa"),
    ("Legacy", 2, [@core.Ratio(2, 3)], "aa"),
    ("Legacy", 2, [@core.Ratio(1, 1)], "aa"),
    ("Legacy", 2, [@core.Ratio(2, 1)], "aa"),
    ("Legacy", 1, [@core.Ratio(0, 1), @core.Ratio(0, 1)], "b"),
    ("Legacy", 1, [@core.Ratio(0, 1), @core.Ratio(1, 10)], "b"),
    ("Legacy", 1, [@core.Ratio(0, 1), @core.Ratio(1, 2)], "b"),
    ("Legacy", 1, [@core.Ratio(0, 1), @core.Ratio(9, 10)], "b"),
    ("Legacy", 1, [@core.Ratio(0, 1), @core.Ratio(1, 1)], "b"),
    ("Legacy", 1, [@core.Ratio(0, 1), @core.Ratio(2, 1)], "b"),
    ("Legacy", 1, [@core.Ratio(1, 10), @core.Ratio(0, 1)], "b"),
    ("Legacy", 1, [@core.Ratio(1, 10), @core.Ratio(1, 10)], "b"),
    ("Legacy", 1, [@core.Ratio(1, 10), @core.Ratio(1, 2)], "b"),
    ("Legacy", 1, [@core.Ratio(1, 10), @core.Ratio(9, 10)], "b"),
    ("Legacy", 1, [@core.Ratio(1, 10), @core.Ratio(1, 1)], "b"),
    ("Legacy", 1, [@core.Ratio(1, 10), @core.Ratio(2, 1)], "b"),
    ("Legacy", 1, [@core.Ratio(1, 2), @core.Ratio(0, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 2), @core.Ratio(1, 2)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 2), @core.Ratio(1, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 2), @core.Ratio(2, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(9, 10), @core.Ratio(0, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(9, 10), @core.Ratio(1, 2)], "a"),
    ("Legacy", 1, [@core.Ratio(9, 10), @core.Ratio(1, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(9, 10), @core.Ratio(2, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 1), @core.Ratio(0, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 1), @core.Ratio(1, 2)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 1), @core.Ratio(1, 1)], "a"),
    ("Legacy", 1, [@core.Ratio(1, 1), @core.Ratio(2, 1)], "a"),
    ("Legacy", 2, [@core.Ratio(0, 1), @core.Ratio(0, 1)], "bb"),
    ("Legacy", 2, [@core.Ratio(0, 1), @core.Ratio(1, 4)], "bb"),
    ("Legacy", 2, [@core.Ratio(0, 1), @core.Ratio(1, 2)], "bb"),
    ("Legacy", 2, [@core.Ratio(0, 1), @core.Ratio(1, 1)], "bb"),
    ("Legacy", 2, [@core.Ratio(0, 1), @core.Ratio(2, 1)], "bb"),
    ("Legacy", 2, [@core.Ratio(1, 10), @core.Ratio(0, 1)], "bb"),
    ("Legacy", 2, [@core.Ratio(1, 10), @core.Ratio(1, 4)], "bb"),
    ("Legacy", 2, [@core.Ratio(1, 10), @core.Ratio(1, 2)], "bb"),
    ("Legacy", 2, [@core.Ratio(1, 10), @core.Ratio(1, 1)], "bb"),
    ("Legacy", 2, [@core.Ratio(1, 10), @core.Ratio(2, 1)], "bb"),
    ("Legacy", 2, [@core.Ratio(1, 4), @core.Ratio(0, 1)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 4), @core.Ratio(1, 4)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 4), @core.Ratio(1, 2)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 4), @core.Ratio(1, 1)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 4), @core.Ratio(2, 1)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 3), @core.Ratio(0, 1)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 3), @core.Ratio(1, 4)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 3), @core.Ratio(1, 2)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 3), @core.Ratio(1, 1)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 3), @core.Ratio(2, 1)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 2), @core.Ratio(0, 1)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 2), @core.Ratio(1, 2)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 2), @core.Ratio(1, 1)], "ab"),
    ("Legacy", 2, [@core.Ratio(1, 1), @core.Ratio(0, 1)], "aa"),
    ("Legacy", 2, [@core.Ratio(1, 1), @core.Ratio(1, 2)], "aa"),
    ("Legacy", 2, [@core.Ratio(1, 1), @core.Ratio(1, 1)], "aa"),
    ("Legacy", 3, [@core.Ratio(1, 3), @core.Ratio(1, 3)], "abb"),
    ("Legacy", 3, [@core.Ratio(1, 3), @core.Ratio(2, 3)], "abb"),
    ("Legacy", 10, [@core.Ratio(0, 1), @core.Ratio(0, 1)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(0, 1), @core.Ratio(1, 4)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(0, 1), @core.Ratio(1, 2)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(0, 1), @core.Ratio(1, 1)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(0, 1), @core.Ratio(2, 1)], "bbbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 10), @core.Ratio(0, 1)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 10), @core.Ratio(1, 4)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 10), @core.Ratio(1, 2)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 10), @core.Ratio(1, 1)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 10), @core.Ratio(2, 1)], "abbbbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 4), @core.Ratio(0, 1)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 4), @core.Ratio(1, 4)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 4), @core.Ratio(1, 2)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 4), @core.Ratio(1, 1)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 4), @core.Ratio(2, 1)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 3), @core.Ratio(0, 1)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 3), @core.Ratio(1, 4)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 3), @core.Ratio(1, 2)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 3), @core.Ratio(1, 1)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 3), @core.Ratio(2, 1)], "aaabbbbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 2), @core.Ratio(0, 1)], "aaaaabbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 2), @core.Ratio(1, 2)], "aaaaabbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 2), @core.Ratio(1, 1)], "aaaaabbbbb"),
    ("Legacy", 10, [@core.Ratio(1, 1), @core.Ratio(0, 1)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Ratio(1, 1), @core.Ratio(1, 2)], "aaaaaaaaaa"),
    ("Legacy", 10, [@core.Ratio(1, 1), @core.Ratio(1, 1)], "aaaaaaaaaa"),
  ]
  for case in cases {
    letters(flex_of(case.0), case.2, case.1, case.3)
  }
}

///|
/// 上游 ratio_start 参数矩阵（27 case）喵。
test "letters ratio_start" {
  let cases : Array[(String, Int, Array[@core.Constraint], String)] = [
    ("Start", 10, [@core.Ratio(0, 1), @core.Ratio(0, 1)], "          "),
    ("Start", 10, [@core.Ratio(0, 1), @core.Ratio(1, 4)], "bbb       "),
    ("Start", 10, [@core.Ratio(0, 1), @core.Ratio(1, 2)], "bbbbb     "),
    ("Start", 10, [@core.Ratio(0, 1), @core.Ratio(1, 1)], "bbbbbbbbbb"),
    ("Start", 10, [@core.Ratio(0, 1), @core.Ratio(2, 1)], "bbbbbbbbbb"),
    ("Start", 10, [@core.Ratio(1, 10), @core.Ratio(0, 1)], "a         "),
    ("Start", 10, [@core.Ratio(1, 10), @core.Ratio(1, 4)], "abbb      "),
    ("Start", 10, [@core.Ratio(1, 10), @core.Ratio(1, 2)], "abbbbb    "),
    ("Start", 10, [@core.Ratio(1, 10), @core.Ratio(1, 1)], "abbbbbbbbb"),
    ("Start", 10, [@core.Ratio(1, 10), @core.Ratio(2, 1)], "abbbbbbbbb"),
    ("Start", 10, [@core.Ratio(1, 4), @core.Ratio(0, 1)], "aaa       "),
    ("Start", 10, [@core.Ratio(1, 4), @core.Ratio(1, 4)], "aaabb     "),
    ("Start", 10, [@core.Ratio(1, 4), @core.Ratio(1, 2)], "aaabbbbb  "),
    ("Start", 10, [@core.Ratio(1, 4), @core.Ratio(1, 1)], "aaabbbbbbb"),
    ("Start", 10, [@core.Ratio(1, 4), @core.Ratio(2, 1)], "aaabbbbbbb"),
    ("Start", 10, [@core.Ratio(1, 3), @core.Ratio(0, 1)], "aaa       "),
    ("Start", 10, [@core.Ratio(1, 3), @core.Ratio(1, 4)], "aaabbb    "),
    ("Start", 10, [@core.Ratio(1, 3), @core.Ratio(1, 2)], "aaabbbbb  "),
    ("Start", 10, [@core.Ratio(1, 3), @core.Ratio(1, 1)], "aaabbbbbbb"),
    ("Start", 10, [@core.Ratio(1, 3), @core.Ratio(2, 1)], "aaabbbbbbb"),
    ("Start", 10, [@core.Ratio(1, 2), @core.Ratio(0, 1)], "aaaaa     "),
    ("Start", 10, [@core.Ratio(1, 2), @core.Ratio(1, 2)], "aaaaabbbbb"),
    ("Start", 10, [@core.Ratio(1, 2), @core.Ratio(1, 1)], "aaaaabbbbb"),
    ("Start", 10, [@core.Ratio(1, 1), @core.Ratio(0, 1)], "aaaaaaaaaa"),
    ("Start", 10, [@core.Ratio(1, 1), @core.Ratio(1, 2)], "aaaaabbbbb"),
    ("Start", 10, [@core.Ratio(1, 1), @core.Ratio(1, 1)], "aaaaabbbbb"),
    ("Start", 10, [@core.Ratio(1, 1), @core.Ratio(2, 1)], "aaaaabbbbb"),
  ]
  for case in cases {
    letters(flex_of(case.0), case.2, case.1, case.3)
  }
}

///|
/// 上游 ratio_spacebetween 参数矩阵（27 case）喵。
test "letters ratio_spacebetween" {
  let cases : Array[(String, Int, Array[@core.Constraint], String)] = [
    ("SpaceBetween", 10, [@core.Ratio(0, 1), @core.Ratio(0, 1)], "          "),
    ("SpaceBetween", 10, [@core.Ratio(0, 1), @core.Ratio(1, 4)], "        bb"),
    ("SpaceBetween", 10, [@core.Ratio(0, 1), @core.Ratio(1, 2)], "     bbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(0, 1), @core.Ratio(1, 1)], "bbbbbbbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(0, 1), @core.Ratio(2, 1)], "bbbbbbbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 10), @core.Ratio(0, 1)], "a         "),
    ("SpaceBetween", 10, [@core.Ratio(1, 10), @core.Ratio(1, 4)], "a       bb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 10), @core.Ratio(1, 2)], "a    bbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 10), @core.Ratio(1, 1)], "abbbbbbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 10), @core.Ratio(2, 1)], "abbbbbbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 4), @core.Ratio(0, 1)], "aaa       "),
    ("SpaceBetween", 10, [@core.Ratio(1, 4), @core.Ratio(1, 4)], "aaa     bb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 4), @core.Ratio(1, 2)], "aaa  bbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 4), @core.Ratio(1, 1)], "aaabbbbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 4), @core.Ratio(2, 1)], "aaabbbbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 3), @core.Ratio(0, 1)], "aaa       "),
    ("SpaceBetween", 10, [@core.Ratio(1, 3), @core.Ratio(1, 4)], "aaa     bb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 3), @core.Ratio(1, 2)], "aaa  bbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 3), @core.Ratio(1, 1)], "aaabbbbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 3), @core.Ratio(2, 1)], "aaabbbbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 2), @core.Ratio(0, 1)], "aaaaa     "),
    ("SpaceBetween", 10, [@core.Ratio(1, 2), @core.Ratio(1, 2)], "aaaaabbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 2), @core.Ratio(1, 1)], "aaaaabbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 1), @core.Ratio(0, 1)], "aaaaaaaaaa"),
    ("SpaceBetween", 10, [@core.Ratio(1, 1), @core.Ratio(1, 2)], "aaaaabbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 1), @core.Ratio(1, 1)], "aaaaabbbbb"),
    ("SpaceBetween", 10, [@core.Ratio(1, 1), @core.Ratio(2, 1)], "aaaaabbbbb"),
  ]
  for case in cases {
    letters(flex_of(case.0), case.2, case.1, case.3)
  }
}

///|
/// Flex 变体名解析（上游 `Flex::from_str` 对位；letters 数据表用）喵。
fn flex_of(name : String) -> @core.Flex {
  match name {
    "Legacy" => @core.Legacy
    "Start" => @core.Start
    "Center" => @core.Center
    "End" => @core.End
    "SpaceBetween" => @core.SpaceBetween
    "SpaceAround" => @core.SpaceAround
    "SpaceEvenly" => @core.SpaceEvenly
    _ => @core.Legacy
  }
}

///|
/// 上游 check_ranges：横切后比对各段 (left, right) 序列喵。
fn check_ranges(
  width : Int,
  constraints : Array[@core.Constraint],
  flex : @core.Flex,
  spacing : Int?,
  expected : String,
) -> Unit raise {
  let layout = Layout::horizontal(constraints).flex(flex)
  let layout = match spacing {
    Some(s) => layout.spacing(s)
    None => layout
  }
  let chunks = layout.split(@core.Rect::new(0, 0, width, 1))
  let parts : Array[String] = []
  for chunk in chunks {
    parts.push("(\{chunk.left()},\{chunk.right()})")
  }
  assert_eq(parts.join(","), normalize_expected(expected))
}

///|
/// 上游 check_widths：六种非遗留 flex 下各段宽度一致喵。
fn check_widths(
  width : Int,
  constraints : Array[@core.Constraint],
  expected : String,
) -> Unit raise {
  let flexes = [
    @core.Start,
    @core.End,
    @core.Center,
    @core.SpaceAround,
    @core.SpaceEvenly,
    @core.SpaceBetween,
  ]
  for flex in flexes {
    let chunks = Layout::horizontal(constraints)
      .flex(flex)
      .split(@core.Rect::new(0, 0, width, 1))
    let parts : Array[String] = []
    for chunk in chunks {
      parts.push(chunk.width.to_string())
    }
    assert_eq(parts.join(","), normalize_expected(expected))
  }
}

///|
/// 上游 check_pairs：比对各段 (x, width) 序列喵。
fn check_pairs(
  width : Int,
  constraints : Array[@core.Constraint],
  flex : @core.Flex,
  spacing : Int?,
  expected : String,
) -> Unit raise {
  let layout = Layout::horizontal(constraints).flex(flex)
  let layout = match spacing {
    Some(s) => layout.spacing(s)
    None => layout
  }
  let chunks = layout.split(@core.Rect::new(0, 0, width, 1))
  let parts : Array[String] = []
  for chunk in chunks {
    parts.push("(\{chunk.x},\{chunk.width})")
  }
  assert_eq(parts.join(","), normalize_expected(expected))
}

///|
/// 上游 check_spacers：spacer 数 = 段数 + 1 且 (x, width) 匹配喵。
fn check_spacers(
  width : Int,
  constraints : Array[@core.Constraint],
  flex : @core.Flex,
  spacing : Int?,
  expected : String,
) -> Unit raise {
  let layout = Layout::horizontal(constraints).flex(flex)
  let layout = match spacing {
    Some(s) => layout.spacing(s)
    None => layout
  }
  let (_, spacers) = layout.split_with_spacers(@core.Rect::new(0, 0, width, 1))
  inspect(spacers.length(), content="\{constraints.length() + 1}")
  let parts : Array[String] = []
  for spacer in spacers {
    parts.push("(\{spacer.x},\{spacer.width})")
  }
  assert_eq(parts.join(","), normalize_expected(expected))
}

///|
/// 期望串规范化：去掉空格与 vec![] 外括号喵。
fn normalize_expected(expected : String) -> String {
  let s = expected.replace_all(old=" ", new="")
  let s = s.replace_all(old="[", new="")
  let s = s.replace_all(old="]", new="")
  s
}

///|
/// 上游 constraint_length 参数矩阵（12 case）喵。
test "layout constraint_length" {
  let cases : Array[(Array[@core.Constraint], String)] = [
    ([@core.Length(25), @core.Min(100)], "[(0,0),(0,100)]"),
    ([@core.Length(25), @core.Min(0)], "[(0,25),(25,100)]"),
    ([@core.Length(25), @core.Max(0)], "[(0,100),(100,100)]"),
    ([@core.Length(25), @core.Max(100)], "[(0,25),(25,100)]"),
    ([@core.Length(25), @core.Percentage(25)], "[(0,25),(25,100)]"),
    ([@core.Percentage(25), @core.Length(25)], "[(0,75),(75,100)]"),
    ([@core.Length(25), @core.Ratio(1, 4)], "[(0,25),(25,100)]"),
    ([@core.Ratio(1, 4), @core.Length(25)], "[(0,75),(75,100)]"),
    ([@core.Length(25), @core.Length(25)], "[(0,25),(25,100)]"),
    (
      [@core.Length(25), @core.Length(25), @core.Length(25)],
      "[(0,25),(25,50),(50,100)]",
    ),
    (
      [@core.Length(15), @core.Length(35), @core.Length(25)],
      "[(0,15),(15,50),(50,100)]",
    ),
    (
      [@core.Length(25), @core.Length(25), @core.Length(25)],
      "[(0,25),(25,50),(50,100)]",
    ),
  ]
  for case in cases {
    check_ranges(100, case.0, flex_of("Legacy"), None, case.1)
  }
}

///|
/// 上游 table_length 参数矩阵（2 case）喵。
test "layout table_length" {
  let cases : Array[(Int, Array[@core.Constraint], String)] = [
    (7, [@core.Length(4), @core.Length(4)], "(0,3),(4,7)"),
    (4, [@core.Length(4), @core.Length(4)], "(0,2),(3,4)"),
  ]
  for case in cases {
    check_ranges(case.0, case.1, flex_of("Start"), Some(1), case.2)
  }
}

///|
/// 上游 length_is_higher_priority 参数矩阵（16 case）喵。
test "layout length_is_higher_priority" {
  let cases : Array[(Array[@core.Constraint], String)] = [
    (
      [@core.Min(25), @core.Length(25), @core.Max(25)],
      "[(0,50),(50,75),(75,100)]",
    ),
    (
      [@core.Max(25), @core.Length(25), @core.Min(25)],
      "[(0,25),(25,50),(50,100)]",
    ),
    (
      [@core.Length(33), @core.Length(33), @core.Length(33)],
      "[(0,33),(33,66),(66,100)]",
    ),
    (
      [@core.Length(25), @core.Length(25), @core.Length(25)],
      "[(0,25),(25,50),(50,100)]",
    ),
    (
      [@core.Percentage(25), @core.Length(25), @core.Ratio(1, 4)],
      "[(0,25),(25,50),(50,100)]",
    ),
    (
      [@core.Length(25), @core.Ratio(1, 4), @core.Percentage(25)],
      "[(0,25),(25,75),(75,100)]",
    ),
    (
      [@core.Ratio(1, 4), @core.Length(25), @core.Percentage(25)],
      "[(0,50),(50,75),(75,100)]",
    ),
    (
      [@core.Ratio(1, 4), @core.Percentage(25), @core.Length(25)],
      "[(0,50),(50,75),(75,100)]",
    ),
    (
      [@core.Length(100), @core.Length(1), @core.Min(20)],
      "[(0,80),(80,80),(80,100)]",
    ),
    (
      [@core.Min(20), @core.Length(1), @core.Length(100)],
      "[(0,20),(20,21),(21,100)]",
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,55),(55,100)]",
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(2)],
      "[(0,30),(30,40),(40,100)]",
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(4)],
      "[(0,18),(18,28),(28,100)]",
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(5)],
      "[(0,15),(15,25),(25,100)]",
    ),
    (
      [@core.Length(25), @core.Length(25), @core.Length(25)],
      "[(0,25),(25,50),(50,100)]",
    ),
    (
      [@core.Length(25), @core.Length(25), @core.Length(25)],
      "[(0,25),(25,50),(50,100)]",
    ),
  ]
  for case in cases {
    check_ranges(100, case.0, flex_of("Legacy"), None, case.1)
  }
}

///|
/// 上游 length_is_higher_priority_in_flex 参数矩阵（15 case）喵。
test "layout length_is_higher_priority_in_flex" {
  let cases : Array[(Array[@core.Constraint], String)] = [
    ([@core.Min(25), @core.Length(25), @core.Max(25)], "[50,25,25]"),
    ([@core.Max(25), @core.Length(25), @core.Min(25)], "[25,25,50]"),
    ([@core.Length(33), @core.Length(33), @core.Length(33)], "[33,33,33]"),
    ([@core.Length(25), @core.Length(25), @core.Length(25)], "[25,25,25]"),
    ([@core.Percentage(25), @core.Length(25), @core.Ratio(1, 4)], "[25,25,25]"),
    ([@core.Length(25), @core.Ratio(1, 4), @core.Percentage(25)], "[25,25,25]"),
    ([@core.Ratio(1, 4), @core.Length(25), @core.Percentage(25)], "[25,25,25]"),
    ([@core.Ratio(1, 4), @core.Percentage(25), @core.Length(25)], "[25,25,25]"),
    ([@core.Length(100), @core.Length(1), @core.Min(20)], "[79,1,20]"),
    ([@core.Min(20), @core.Length(1), @core.Length(100)], "[20,1,79]"),
    ([@core.Fill(1), @core.Length(10), @core.Fill(1)], "[45,10,45]"),
    ([@core.Fill(1), @core.Length(10), @core.Fill(2)], "[30,10,60]"),
    ([@core.Fill(1), @core.Length(10), @core.Fill(4)], "[18,10,72]"),
    ([@core.Fill(1), @core.Length(10), @core.Fill(5)], "[15,10,75]"),
    ([@core.Length(25), @core.Length(25), @core.Length(25)], "[25,25,25]"),
  ]
  for case in cases {
    check_widths(100, case.0, case.1)
  }
}

///|
/// 上游 fixed_with_50_width 参数矩阵（2 case）喵。
test "layout fixed_with_50_width" {
  let cases : Array[(Array[@core.Constraint], String)] = [
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(2)],
      "[(0,13),(13,23),(23,50)]",
    ),
    (
      [@core.Length(10), @core.Fill(2), @core.Fill(1)],
      "[(0,10),(10,37),(37,50)]",
    ),
  ]
  for case in cases {
    check_ranges(50, case.0, flex_of("Legacy"), None, case.1)
  }
}

///|
/// 上游 fill 参数矩阵（32 case）喵。
test "layout fill" {
  let cases : Array[(Array[@core.Constraint], String)] = [
    (
      [@core.Fill(1), @core.Fill(2), @core.Fill(1), @core.Fill(1)],
      "[(0,20),(20,60),(60,80),(80,100)]",
    ),
    (
      [@core.Fill(1), @core.Fill(2), @core.Fill(3), @core.Fill(4)],
      "[(0,10),(10,30),(30,60),(60,100)]",
    ),
    (
      [@core.Fill(4), @core.Fill(3), @core.Fill(2), @core.Fill(1)],
      "[(0,40),(40,70),(70,90),(90,100)]",
    ),
    (
      [@core.Fill(1), @core.Fill(3), @core.Fill(2), @core.Fill(4)],
      "[(0,10),(10,40),(40,60),(60,100)]",
    ),
    (
      [
        @core.Fill(1),
        @core.Fill(3),
        @core.Length(50),
        @core.Fill(2),
        @core.Fill(4),
      ],
      "[(0,5),(5,20),(20,70),(70,80),(80,100)]",
    ),
    (
      [
        @core.Fill(1),
        @core.Fill(3),
        @core.Percentage(50),
        @core.Fill(2),
        @core.Fill(4),
      ],
      "[(0,5),(5,20),(20,70),(70,80),(80,100)]",
    ),
    (
      [
        @core.Fill(1),
        @core.Fill(3),
        @core.Min(50),
        @core.Fill(2),
        @core.Fill(4),
      ],
      "[(0,5),(5,20),(20,70),(70,80),(80,100)]",
    ),
    (
      [
        @core.Fill(1),
        @core.Fill(3),
        @core.Max(50),
        @core.Fill(2),
        @core.Fill(4),
      ],
      "[(0,5),(5,20),(20,70),(70,80),(80,100)]",
    ),
    ([@core.Fill(0), @core.Fill(1), @core.Fill(0)], "[(0,0),(0,100),(100,100)]"),
    (
      [@core.Fill(0), @core.Length(1), @core.Fill(0)],
      "[(0,50),(50,51),(51,100)]",
    ),
    (
      [@core.Fill(0), @core.Percentage(1), @core.Fill(0)],
      "[(0,50),(50,51),(51,100)]",
    ),
    ([@core.Fill(0), @core.Min(1), @core.Fill(0)], "[(0,50),(50,51),(51,100)]"),
    ([@core.Fill(0), @core.Max(1), @core.Fill(0)], "[(0,50),(50,51),(51,100)]"),
    (
      [@core.Fill(0), @core.Fill(2), @core.Fill(0), @core.Fill(1)],
      "[(0,0),(0,67),(67,67),(67,100)]",
    ),
    (
      [@core.Fill(0), @core.Fill(2), @core.Percentage(20)],
      "[(0,0),(0,80),(80,100)]",
    ),
    (
      [@core.Fill(0), @core.Fill(0), @core.Percentage(20)],
      "[(0,40),(40,80),(80,100)]",
    ),
    ([@core.Fill(0), @core.Ratio(1, 5)], "[(0,80),(80,100)]"),
    ([@core.Fill(0), @core.Fill(65535)], "[(0,0),(0,100)]"),
    ([@core.Fill(65535), @core.Fill(0)], "[(0,100),(100,100)]"),
    ([@core.Fill(0), @core.Percentage(20)], "[(0,80),(80,100)]"),
    ([@core.Fill(1), @core.Percentage(20)], "[(0,80),(80,100)]"),
    ([@core.Fill(65535), @core.Percentage(20)], "[(0,80),(80,100)]"),
    (
      [@core.Fill(65535), @core.Fill(0), @core.Percentage(20)],
      "[(0,80),(80,80),(80,100)]",
    ),
    ([@core.Fill(0), @core.Length(20)], "[(0,80),(80,100)]"),
    ([@core.Fill(0), @core.Min(20)], "[(0,80),(80,100)]"),
    ([@core.Fill(0), @core.Max(20)], "[(0,80),(80,100)]"),
    (
      [
        @core.Fill(1),
        @core.Fill(1),
        @core.Fill(1),
        @core.Min(30),
        @core.Length(50),
      ],
      "[(0,7),(7,13),(13,20),(20,50),(50,100)]",
    ),
    (
      [
        @core.Fill(1),
        @core.Fill(1),
        @core.Fill(1),
        @core.Length(50),
        @core.Length(50),
      ],
      "[(0,0),(0,0),(0,0),(0,50),(50,100)]",
    ),
    (
      [
        @core.Fill(1),
        @core.Fill(1),
        @core.Fill(1),
        @core.Length(75),
        @core.Length(50),
      ],
      "[(0,0),(0,0),(0,0),(0,75),(75,100)]",
    ),
    (
      [
        @core.Fill(1),
        @core.Fill(1),
        @core.Fill(1),
        @core.Min(50),
        @core.Max(50),
      ],
      "[(0,0),(0,0),(0,0),(0,50),(50,100)]",
    ),
    (
      [@core.Fill(1), @core.Fill(1), @core.Fill(1), @core.Ratio(1, 1)],
      "[(0,0),(0,0),(0,0),(0,100)]",
    ),
    (
      [@core.Fill(1), @core.Fill(1), @core.Fill(1), @core.Percentage(100)],
      "[(0,0),(0,0),(0,0),(0,100)]",
    ),
  ]
  for case in cases {
    check_ranges(100, case.0, flex_of("Legacy"), None, case.1)
  }
}

///|
/// 上游 percentage_parameterized 参数矩阵（2 case）喵。
test "layout percentage_parameterized" {
  let cases : Array[(Array[@core.Constraint], String)] = [
    ([@core.Min(0), @core.Percentage(20)], "[(0,80),(80,100)]"),
    ([@core.Max(0), @core.Percentage(20)], "[(0,0),(0,100)]"),
  ]
  for case in cases {
    check_ranges(100, case.0, flex_of("Legacy"), None, case.1)
  }
}

///|
/// 上游 min_max 参数矩阵（6 case）喵。
test "layout min_max" {
  let cases : Array[(Array[@core.Constraint], String)] = [
    ([@core.Max(100), @core.Min(0)], "[(0,100),(100,100)]"),
    ([@core.Min(0), @core.Max(100)], "[(0,0),(0,100)]"),
    ([@core.Length(65535), @core.Min(10)], "[(0,90),(90,100)]"),
    ([@core.Min(10), @core.Length(65535)], "[(0,10),(10,100)]"),
    ([@core.Length(0), @core.Max(10)], "[(0,90),(90,100)]"),
    ([@core.Max(10), @core.Length(0)], "[(0,10),(10,100)]"),
  ]
  for case in cases {
    check_ranges(100, case.0, flex_of("Legacy"), None, case.1)
  }
}

///|
/// 上游 flex_constraint 参数矩阵（59 case）喵。
test "layout flex_constraint" {
  let cases : Array[(Array[@core.Constraint], String, String)] = [
    ([@core.Length(50)], "[(0,100)]", "Legacy"),
    ([@core.Length(50)], "[(0,50)]", "Start"),
    ([@core.Length(50)], "[(50,100)]", "End"),
    ([@core.Length(50)], "[(25,75)]", "Center"),
    ([@core.Ratio(1, 2)], "[(0,100)]", "Legacy"),
    ([@core.Ratio(1, 2)], "[(0,50)]", "Start"),
    ([@core.Ratio(1, 2)], "[(50,100)]", "End"),
    ([@core.Ratio(1, 2)], "[(25,75)]", "Center"),
    ([@core.Percentage(50)], "[(0,100)]", "Legacy"),
    ([@core.Percentage(50)], "[(0,50)]", "Start"),
    ([@core.Percentage(50)], "[(50,100)]", "End"),
    ([@core.Percentage(50)], "[(25,75)]", "Center"),
    ([@core.Min(50)], "[(0,100)]", "Legacy"),
    ([@core.Min(50)], "[(0,100)]", "Start"),
    ([@core.Min(50)], "[(0,100)]", "End"),
    ([@core.Min(50)], "[(0,100)]", "Center"),
    ([@core.Max(50)], "[(0,100)]", "Legacy"),
    ([@core.Max(50)], "[(0,50)]", "Start"),
    ([@core.Max(50)], "[(50,100)]", "End"),
    ([@core.Max(50)], "[(25,75)]", "Center"),
    ([@core.Min(1)], "[(0,100)]", "SpaceBetween"),
    ([@core.Max(20)], "[(0,100)]", "SpaceBetween"),
    ([@core.Length(20)], "[(0,100)]", "SpaceBetween"),
    ([@core.Length(25), @core.Length(25)], "[(0,25),(25,100)]", "Legacy"),
    ([@core.Length(25), @core.Length(25)], "[(0,25),(25,50)]", "Start"),
    ([@core.Length(25), @core.Length(25)], "[(25,50),(50,75)]", "Center"),
    ([@core.Length(25), @core.Length(25)], "[(50,75),(75,100)]", "End"),
    ([@core.Length(25), @core.Length(25)], "[(0,25),(75,100)]", "SpaceBetween"),
    ([@core.Length(25), @core.Length(25)], "[(17,42),(58,83)]", "SpaceEvenly"),
    ([@core.Length(25), @core.Length(25)], "[(13,38),(63,88)]", "SpaceAround"),
    (
      [@core.Percentage(25), @core.Percentage(25)],
      "[(0,25),(25,100)]",
      "Legacy",
    ),
    ([@core.Percentage(25), @core.Percentage(25)], "[(0,25),(25,50)]", "Start"),
    (
      [@core.Percentage(25), @core.Percentage(25)],
      "[(25,50),(50,75)]",
      "Center",
    ),
    ([@core.Percentage(25), @core.Percentage(25)], "[(50,75),(75,100)]", "End"),
    (
      [@core.Percentage(25), @core.Percentage(25)],
      "[(0,25),(75,100)]",
      "SpaceBetween",
    ),
    (
      [@core.Percentage(25), @core.Percentage(25)],
      "[(17,42),(58,83)]",
      "SpaceEvenly",
    ),
    (
      [@core.Percentage(25), @core.Percentage(25)],
      "[(13,38),(63,88)]",
      "SpaceAround",
    ),
    ([@core.Min(25), @core.Min(25)], "[(0,25),(25,100)]", "Legacy"),
    ([@core.Min(25), @core.Min(25)], "[(0,50),(50,100)]", "Start"),
    ([@core.Min(25), @core.Min(25)], "[(0,50),(50,100)]", "Center"),
    ([@core.Min(25), @core.Min(25)], "[(0,50),(50,100)]", "End"),
    ([@core.Min(25), @core.Min(25)], "[(0,50),(50,100)]", "SpaceBetween"),
    ([@core.Min(25), @core.Min(25)], "[(0,50),(50,100)]", "SpaceEvenly"),
    ([@core.Min(25), @core.Min(25)], "[(0,50),(50,100)]", "SpaceAround"),
    ([@core.Max(25), @core.Max(25)], "[(0,25),(25,100)]", "Legacy"),
    ([@core.Max(25), @core.Max(25)], "[(0,25),(25,50)]", "Start"),
    ([@core.Max(25), @core.Max(25)], "[(25,50),(50,75)]", "Center"),
    ([@core.Max(25), @core.Max(25)], "[(50,75),(75,100)]", "End"),
    ([@core.Max(25), @core.Max(25)], "[(0,25),(75,100)]", "SpaceBetween"),
    ([@core.Max(25), @core.Max(25)], "[(17,42),(58,83)]", "SpaceEvenly"),
    ([@core.Max(25), @core.Max(25)], "[(13,38),(63,88)]", "SpaceAround"),
    (
      [@core.Length(25), @core.Length(25), @core.Length(25)],
      "[(0,25),(38,63),(75,100)]",
      "SpaceBetween",
    ),
    ([@core.Length(50)], "[(0,100)]", "Legacy"),
    ([@core.Length(50)], "[(0,50)]", "Start"),
    ([@core.Length(50)], "[(50,100)]", "End"),
    ([@core.Length(50)], "[(25,75)]", "Center"),
    ([@core.Length(50)], "[(0,100)]", "SpaceBetween"),
    ([@core.Length(50)], "[(25,75)]", "SpaceEvenly"),
    ([@core.Length(50)], "[(25,75)]", "SpaceAround"),
  ]
  for case in cases {
    check_ranges(100, case.0, flex_of(case.2), None, case.1)
  }
}

///|
/// 上游 flex_overlap 参数矩阵（8 case）喵。
test "layout flex_overlap" {
  let cases : Array[(Array[@core.Constraint], String, String, Int)] = [
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(20,20),(40,20)]",
      "Start",
      0,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(19,20),(38,20)]",
      "Start",
      -1,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(21,20),(40,20),(59,20)]",
      "Center",
      -1,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(42,20),(61,20),(80,20)]",
      "End",
      -1,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(19,20),(38,62)]",
      "Legacy",
      -1,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(40,20),(80,20)]",
      "SpaceBetween",
      -1,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(10,20),(40,20),(70,20)]",
      "SpaceEvenly",
      -1,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(7,20),(40,20),(73,20)]",
      "SpaceAround",
      -1,
    ),
  ]
  for case in cases {
    check_pairs(100, case.0, flex_of(case.2), Some(case.3), case.1)
  }
}

///|
/// 上游 flex_spacing 参数矩阵（8 case）喵。
test "layout flex_spacing" {
  let cases : Array[(Array[@core.Constraint], String, String, Int)] = [
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(20,20),(40,20)]",
      "Start",
      0,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(22,20),(44,20)]",
      "Start",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(18,20),(40,20),(62,20)]",
      "Center",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(36,20),(58,20),(80,20)]",
      "End",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(22,20),(44,56)]",
      "Legacy",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(40,20),(80,20)]",
      "SpaceBetween",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(10,20),(40,20),(70,20)]",
      "SpaceEvenly",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(7,20),(40,20),(73,20)]",
      "SpaceAround",
      2,
    ),
  ]
  for case in cases {
    check_pairs(100, case.0, flex_of(case.2), Some(case.3), case.1)
  }
}

///|
/// 上游 constraint_specification_tests_for_priority 参数矩阵（17 case）喵。
test "layout constraint_specification_tests_for_priority" {
  let cases : Array[(Array[@core.Constraint], String)] = [
    ([@core.Length(25), @core.Length(25)], "[(0,25),(25,75)]"),
    ([@core.Length(25), @core.Percentage(25)], "[(0,25),(25,75)]"),
    ([@core.Percentage(25), @core.Length(25)], "[(0,75),(75,25)]"),
    ([@core.Min(25), @core.Percentage(25)], "[(0,75),(75,25)]"),
    ([@core.Percentage(25), @core.Min(25)], "[(0,25),(25,75)]"),
    ([@core.Min(25), @core.Percentage(100)], "[(0,25),(25,75)]"),
    ([@core.Percentage(100), @core.Min(25)], "[(0,75),(75,25)]"),
    ([@core.Max(75), @core.Percentage(75)], "[(0,25),(25,75)]"),
    ([@core.Percentage(75), @core.Max(75)], "[(0,75),(75,25)]"),
    ([@core.Max(25), @core.Percentage(25)], "[(0,25),(25,75)]"),
    ([@core.Percentage(25), @core.Max(25)], "[(0,75),(75,25)]"),
    ([@core.Length(25), @core.Ratio(1, 4)], "[(0,25),(25,75)]"),
    ([@core.Ratio(1, 4), @core.Length(25)], "[(0,75),(75,25)]"),
    ([@core.Percentage(25), @core.Ratio(1, 4)], "[(0,25),(25,75)]"),
    ([@core.Ratio(1, 4), @core.Percentage(25)], "[(0,75),(75,25)]"),
    ([@core.Ratio(1, 4), @core.Fill(25)], "[(0,25),(25,75)]"),
    ([@core.Fill(25), @core.Ratio(1, 4)], "[(0,75),(75,25)]"),
  ]
  for case in cases {
    check_pairs(100, case.0, flex_of("Legacy"), None, case.1)
  }
}

///|
/// 上游 constraint_specification_tests_for_priority_with_spacing 参数矩阵（7 case）喵。
test "layout constraint_specification_tests_for_priority_with_spacing" {
  let cases : Array[(Array[@core.Constraint], String, String, Int)] = [
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(20,20),(40,20)]",
      "Start",
      0,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(18,20),(40,20),(62,20)]",
      "Center",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(36,20),(58,20),(80,20)]",
      "End",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(22,20),(44,56)]",
      "Legacy",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(0,20),(22,20),(44,56)]",
      "Legacy",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(10,20),(40,20),(70,20)]",
      "SpaceEvenly",
      2,
    ),
    (
      [@core.Length(20), @core.Length(20), @core.Length(20)],
      "[(7,20),(40,20),(73,20)]",
      "SpaceAround",
      2,
    ),
  ]
  for case in cases {
    check_pairs(100, case.0, flex_of(case.2), Some(case.3), case.1)
  }
}

///|
/// 上游 fill_vs_flex 参数矩阵（11 case）喵。
test "layout fill_vs_flex" {
  let cases : Array[(Array[@core.Constraint], String, String)] = [
    (
      [@core.Length(10), @core.Fill(1), @core.Length(10)],
      "[(0,10),(10,80),(90,10)]",
      "Legacy",
    ),
    ([@core.Length(10), @core.Length(10)], "[(0,10),(90,10)]", "SpaceBetween"),
    (
      [
        @core.Fill(1),
        @core.Length(10),
        @core.Fill(1),
        @core.Length(10),
        @core.Fill(1),
      ],
      "[(0,27),(27,10),(37,26),(63,10),(73,27)]",
      "Legacy",
    ),
    ([@core.Length(10), @core.Length(10)], "[(27,10),(63,10)]", "SpaceEvenly"),
    (
      [@core.Length(10), @core.Length(10), @core.Fill(1)],
      "[(0,10),(10,10),(20,80)]",
      "Legacy",
    ),
    ([@core.Length(10), @core.Length(10)], "[(0,10),(10,10)]", "Start"),
    (
      [@core.Fill(1), @core.Length(10), @core.Length(10)],
      "[(0,80),(80,10),(90,10)]",
      "Legacy",
    ),
    ([@core.Length(10), @core.Length(10)], "[(80,10),(90,10)]", "End"),
    (
      [@core.Fill(1), @core.Length(10), @core.Length(10), @core.Fill(1)],
      "[(0,40),(40,10),(50,10),(60,40)]",
      "Legacy",
    ),
    ([@core.Length(10), @core.Length(10)], "[(40,10),(50,10)]", "Center"),
    ([@core.Length(10), @core.Length(10)], "[(20,10),(70,10)]", "SpaceAround"),
  ]
  for case in cases {
    check_pairs(100, case.0, flex_of(case.2), None, case.1)
  }
}

///|
/// 上游 fill_spacing 参数矩阵（28 case）喵。
test "layout fill_spacing" {
  let cases : Array[(Array[@core.Constraint], String, String, Int)] = [
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "Legacy", 0),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "SpaceEvenly", 0),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "SpaceBetween", 0),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "SpaceAround", 0),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "Start", 0),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "Center", 0),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "End", 0),
    ([@core.Fill(1), @core.Fill(1)], "[(0,45),(55,45)]", "Legacy", 10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,45),(55,45)]", "Start", 10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,45),(55,45)]", "Center", 10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,45),(55,45)]", "End", 10),
    ([@core.Fill(1), @core.Fill(1)], "[(10,35),(55,35)]", "SpaceEvenly", 10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,45),(55,45)]", "SpaceBetween", 10),
    ([@core.Fill(1), @core.Fill(1)], "[(10,30),(60,30)]", "SpaceAround", 10),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "Legacy",
      0,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "SpaceEvenly",
      0,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "SpaceBetween",
      0,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "SpaceAround",
      0,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "Start",
      0,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "Center",
      0,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "End",
      0,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,35),(45,10),(65,35)]",
      "Legacy",
      10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,35),(45,10),(65,35)]",
      "Start",
      10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,35),(45,10),(65,35)]",
      "Center",
      10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,35),(45,10),(65,35)]",
      "End",
      10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(10,25),(45,10),(65,25)]",
      "SpaceEvenly",
      10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,35),(45,10),(65,35)]",
      "SpaceBetween",
      10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(10,15),(45,10),(75,15)]",
      "SpaceAround",
      10,
    ),
  ]
  for case in cases {
    check_pairs(100, case.0, flex_of(case.2), Some(case.3), case.1)
  }
}

///|
/// 上游 fill_overlap 参数矩阵（28 case）喵。
test "layout fill_overlap" {
  let cases : Array[(Array[@core.Constraint], String, String, Int)] = [
    ([@core.Fill(1), @core.Fill(1)], "[(0,55),(45,55)]", "Legacy", -10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "SpaceAround", -10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,55),(45,55)]", "SpaceBetween", -10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,55),(45,55)]", "Start", -10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,55),(45,55)]", "Center", -10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,55),(45,55)]", "End", -10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "SpaceEvenly", -10),
    ([@core.Fill(1), @core.Fill(1)], "[(0,51),(50,50)]", "Legacy", -1),
    ([@core.Fill(1), @core.Fill(1)], "[(0,51),(50,50)]", "Start", -1),
    ([@core.Fill(1), @core.Fill(1)], "[(0,51),(50,50)]", "Center", -1),
    ([@core.Fill(1), @core.Fill(1)], "[(0,51),(50,50)]", "End", -1),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "SpaceAround", -1),
    ([@core.Fill(1), @core.Fill(1)], "[(0,51),(50,50)]", "SpaceBetween", -1),
    ([@core.Fill(1), @core.Fill(1)], "[(0,50),(50,50)]", "SpaceEvenly", -1),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,55),(45,10),(45,55)]",
      "Legacy",
      -10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "SpaceAround",
      -10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,55),(45,10),(45,55)]",
      "SpaceBetween",
      -10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,55),(45,10),(45,55)]",
      "Start",
      -10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,55),(45,10),(45,55)]",
      "Center",
      -10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,55),(45,10),(45,55)]",
      "End",
      -10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "SpaceEvenly",
      -10,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,46),(45,10),(54,46)]",
      "Legacy",
      -1,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,46),(45,10),(54,46)]",
      "Start",
      -1,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,46),(45,10),(54,46)]",
      "Center",
      -1,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,46),(45,10),(54,46)]",
      "End",
      -1,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "SpaceAround",
      -1,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,46),(45,10),(54,46)]",
      "SpaceBetween",
      -1,
    ),
    (
      [@core.Fill(1), @core.Length(10), @core.Fill(1)],
      "[(0,45),(45,10),(55,45)]",
      "SpaceEvenly",
      -1,
    ),
  ]
  for case in cases {
    check_pairs(100, case.0, flex_of(case.2), Some(case.3), case.1)
  }
}

///|
/// 上游 flex_spacing_lower_priority_than_user_spacing 参数矩阵（1 case）喵。
test "layout flex_spacing_lower_priority_than_user_spacing" {
  let cases : Array[(Array[@core.Constraint], String, String, Int)] = [
    ([@core.Length(10), @core.Length(10)], "[(0,10),(90,10)]", "Center", 80),
  ]
  for case in cases {
    check_pairs(100, case.0, flex_of(case.2), Some(case.3), case.1)
  }
}

///|
/// 上游 split_with_spacers_no_spacing 参数矩阵（7 case）喵。
test "layout split_with_spacers_no_spacing" {
  let cases : Array[(Array[@core.Constraint], String, String)] = [
    ([@core.Length(10), @core.Length(10)], "[(0,0),(10,0),(100,0)]", "Legacy"),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(10,80),(100,0)]",
      "SpaceBetween",
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,27),(37,26),(73,27)]",
      "SpaceEvenly",
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,20),(30,40),(80,20)]",
      "SpaceAround",
    ),
    ([@core.Length(10), @core.Length(10)], "[(0,0),(10,0),(20,80)]", "Start"),
    ([@core.Length(10), @core.Length(10)], "[(0,40),(50,0),(60,40)]", "Center"),
    ([@core.Length(10), @core.Length(10)], "[(0,80),(90,0),(100,0)]", "End"),
  ]
  for case in cases {
    check_spacers(100, case.0, flex_of(case.2), None, case.1)
  }
}

///|
/// 上游 split_with_spacers_and_spacing 参数矩阵（7 case）喵。
test "layout split_with_spacers_and_spacing" {
  let cases : Array[(Array[@core.Constraint], String, String, Int)] = [
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(10,5),(100,0)]",
      "Legacy",
      5,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(10,80),(100,0)]",
      "SpaceBetween",
      5,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,27),(37,26),(73,27)]",
      "SpaceEvenly",
      5,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,20),(30,40),(80,20)]",
      "SpaceAround",
      5,
    ),
    ([@core.Length(10), @core.Length(10)], "[(0,0),(10,5),(25,75)]", "Start", 5),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,38),(48,5),(63,37)]",
      "Center",
      5,
    ),
    ([@core.Length(10), @core.Length(10)], "[(0,75),(85,5),(100,0)]", "End", 5),
  ]
  for case in cases {
    check_spacers(100, case.0, flex_of(case.2), Some(case.3), case.1)
  }
}

///|
/// 上游 split_with_spacers_and_overlap 参数矩阵（7 case）喵。
test "layout split_with_spacers_and_overlap" {
  let cases : Array[(Array[@core.Constraint], String, String, Int)] = [
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(10,0),(100,0)]",
      "Legacy",
      -1,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(10,80),(100,0)]",
      "SpaceBetween",
      -1,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,27),(37,26),(73,27)]",
      "SpaceEvenly",
      -1,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,20),(30,40),(80,20)]",
      "SpaceAround",
      -1,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(10,0),(19,81)]",
      "Start",
      -1,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,41),(51,0),(60,40)]",
      "Center",
      -1,
    ),
    ([@core.Length(10), @core.Length(10)], "[(0,81),(91,0),(100,0)]", "End", -1),
  ]
  for case in cases {
    check_spacers(100, case.0, flex_of(case.2), Some(case.3), case.1)
  }
}

///|
/// 上游 split_with_spacers_and_too_much_spacing 参数矩阵（7 case）喵。
test "layout split_with_spacers_and_too_much_spacing" {
  let cases : Array[(Array[@core.Constraint], String, String, Int)] = [
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(0,100),(100,0)]",
      "Legacy",
      200,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(0,100),(100,0)]",
      "SpaceBetween",
      200,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,33),(33,34),(67,33)]",
      "SpaceEvenly",
      200,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,25),(25,50),(75,25)]",
      "SpaceAround",
      200,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(0,100),(100,0)]",
      "Start",
      200,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(0,100),(100,0)]",
      "Center",
      200,
    ),
    (
      [@core.Length(10), @core.Length(10)],
      "[(0,0),(0,100),(100,0)]",
      "End",
      200,
    ),
  ]
  for case in cases {
    check_spacers(100, case.0, flex_of(case.2), Some(case.3), case.1)
  }
}

///|
/// 上游 legacy_vs_default 参数矩阵（6 case）喵。
test "layout legacy_vs_default" {
  let cases : Array[(Array[@core.Constraint], String, String)] = [
    ([@core.Min(10), @core.Length(10)], "[(0,90),(90,10)]", "Legacy"),
    ([@core.Min(10), @core.Length(10)], "[(0,90),(90,10)]", "Start"),
    ([@core.Min(10), @core.Percentage(100)], "[(0,10),(10,90)]", "Legacy"),
    ([@core.Min(10), @core.Percentage(100)], "[(0,10),(10,90)]", "Start"),
    ([@core.Percentage(50), @core.Percentage(50)], "[(0,50),(50,50)]", "Legacy"),
    ([@core.Percentage(50), @core.Percentage(50)], "[(0,50),(50,50)]", "Start"),
  ]
  for case in cases {
    check_pairs(100, case.0, flex_of(case.2), None, case.1)
  }
}
