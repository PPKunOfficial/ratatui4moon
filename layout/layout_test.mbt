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
