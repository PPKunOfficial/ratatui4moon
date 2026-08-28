///|
/// 折行引擎单元测试：复刻 ratatui-v0.30.2 `widgets/reflow.rs`
/// 测试清单喵（run_composer 等价移植）。

///|
/// 合成器选择（上游 Composer 枚举）喵。
priv enum Composer {
  WordWrap(Bool)
  Truncate
}

///|
/// 上游 run_composer：按合成器产出 (行文本, 宽度, 对齐) 三元组喵。
fn run_composer(
  which : Composer,
  text : @core.Text,
  area_width : Int,
) -> (Array[String], Array[Int], Array[@core.Alignment]) raise {
  let styled_lines : Array[(Array[@core.StyledGrapheme], @core.Alignment)] = []
  for line in text.lines {
    let alignment = match line.alignment {
      Some(a) => a
      None => @core.Alignment::Left
    }
    styled_lines.push(
      (line.styled_graphemes(@core.Style::default()), alignment),
    )
  }
  let lines : Array[String] = []
  let widths : Array[Int] = []
  let alignments : Array[@core.Alignment] = []
  match which {
    WordWrap(trim) =>
      collect_lines(
        WordWrapper::new(styled_lines, area_width, trim),
        area_width,
        lines,
        widths,
        alignments,
      )
    Truncate =>
      collect_lines(
        LineTruncator::new(styled_lines, area_width),
        area_width,
        lines,
        widths,
        alignments,
      )
  }
  (lines, widths, alignments)
}

///|
/// 逐行消费合成器输出（包私有测试辅助）喵。
fn[T : LineComposer] collect_lines(
  composer : T,
  area_width : Int,
  lines : Array[String],
  widths : Array[Int],
  alignments : Array[@core.Alignment],
) -> Unit raise {
  while true {
    match composer.next_line() {
      Some(wrapped) => {
        let text = StringBuilder()
        for grapheme in wrapped.graphemes {
          text.write_string(grapheme.symbol)
        }
        inspect(
          wrapped.width <= area_width,
          content=(
            #|true
          ),
        )
        lines.push(text.to_string())
        widths.push(wrapped.width)
        alignments.push(wrapped.alignment)
      }
      None => break
    }
  }
}

///|
/// 上游 line_composer_one_line：单行在任意宽度下原样通过喵。
test "合成器单行" {
  let width = 40
  for i in 1..<width {
    let text = String::make(i, 'a')
    let (word_wrapper, _, _) = run_composer(
      WordWrap(true),
      @core.Text::raw(text),
      width,
    )
    let (line_truncator, _, _) = run_composer(
      Truncate,
      @core.Text::raw(text),
      width,
    )
    @debug.assert_eq(word_wrapper, [text])
    @debug.assert_eq(line_truncator, [text])
  }
}

///|
/// 上游 line_composer_short_lines：短行不被改动喵。
test "合成器短行" {
  let width = 20
  let text = "abcdefg\nhijklmno\npabcdefg\nhijklmn\nopabcdefghijk\nlmnopabcd\n\n\nefghijklmno"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  let wrapped = [
    "abcdefg", "hijklmno", "pabcdefg", "hijklmn", "opabcdefghijk", "lmnopabcd", "",
    "", "efghijklmno",
  ]
  @debug.assert_eq(word_wrapper, wrapped)
  @debug.assert_eq(line_truncator, wrapped)
}

///|
/// 上游 line_composer_long_word：无法断词时按宽度硬折喵。
test "合成器超长单词" {
  let width = 20
  let text = "abcdefghijklmnopabcdefghijklmnopabcdefghijklmnopabcdefghijklmno"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  let wrapped = [
    "abcdefghijklmnopabcd", "efghijklmnopabcdefgh", "ijklmnopabcdefghijkl", "mno",
  ]
  @debug.assert_eq(word_wrapper, wrapped)
  @debug.assert_eq(line_truncator, ["abcdefghijklmnopabcd"])
}

///|
/// 上游 line_composer_long_sentence：多空格与单空格折行一致喵。
test "合成器长句" {
  let width = 20
  let text = "abcd efghij klmnopabcd efgh ijklmnopabcdefg hijkl mnopab c d e f g h i j k l m n o"
  let text_multi_space = "abcd efghij    klmnopabcd efgh     ijklmnopabcdefg hijkl mnopab c d e f g h i j k l m n o"
  let (word_wrapper_single_space, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (word_wrapper_multi_space, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text_multi_space),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  let word_wrapped = [
    "abcd efghij", "klmnopabcd efgh", "ijklmnopabcdefg", "hijkl mnopab c d e f",
    "g h i j k l m n o",
  ]
  @debug.assert_eq(word_wrapper_single_space, word_wrapped)
  @debug.assert_eq(word_wrapper_multi_space, word_wrapped)
  @debug.assert_eq(line_truncator, ["abcd efghij klmnopab"])
}

///|
/// 上游 line_composer_zero_width：宽度 0 不产出行喵。
test "合成器零宽" {
  let width = 0
  let text = "abcd efghij klmnopabcd efgh ijklmnopabcdefg hijkl mnopab "
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, [])
  @debug.assert_eq(line_truncator, [])
}

///|
/// 上游 line_composer_max_line_width_of_1：宽度 1 按非空白字形逐行喵。
test "合成器宽度 1" {
  let width = 1
  let text = "abcd efghij klmnopabcd efgh ijklmnopabcdefg hijkl mnopab "
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  let expected : Array[String] = []
  for ch in text {
    if ch.to_int() != 0x20 {
      expected.push(ch.to_string())
    }
  }
  @debug.assert_eq(word_wrapper, expected)
  @debug.assert_eq(line_truncator, ["a"])
}

///|
/// 上游 line_composer_max_line_width_of_1_double_width_characters：
/// 双宽字符放不下被忽略喵。
test "合成器宽度 1 双宽字符" {
  let width = 1
  let text = "コンピュータ上で文字を扱う場合、典型的には文字\naaa\naによる通信を行う場合にその両端点では、"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, ["", "a", "a", "a", "a"])
  @debug.assert_eq(line_truncator, ["", "a", "a"])
}

///|
/// 上游 line_composer_word_wrapper_mixed_length：长短词混合喵。
test "折行长短词混合" {
  let width = 20
  let text = "abcd efghij klmnopabcdefghijklmnopabcdefghijkl mnopab cdefghi j klmno"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, [
    "abcd efghij", "klmnopabcdefghijklmn", "opabcdefghijkl", "mnopab cdefghi j",
    "klmno",
  ])
}

///|
/// 上游 line_composer_double_width_chars：CJK 按双宽折行喵。
test "折行双宽字符" {
  let width = 20
  let text = "コンピュータ上で文字を扱う場合、典型的には文字による通信を行う場合にその両端点では、"
  let (word_wrapper, word_wrapper_width, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(line_truncator, ["コンピュータ上で文字"])
  @debug.assert_eq(word_wrapper, [
    "コンピュータ上で文字", "を扱う場合、典型的に", "は文字による通信を行",
    "う場合にその両端点で", "は、",
  ])
  @debug.assert_eq(word_wrapper_width, [20, 20, 20, 20, 4])
}

///|
/// 上游 line_composer_leading_whitespace_removal：行尾空白裁剪喵。
test "折行行尾空白移除" {
  let width = 20
  let text = "AAAAAAAAAAAAAAAAAAAA    AAA"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, ["AAAAAAAAAAAAAAAAAAAA", "AAA"])
  @debug.assert_eq(line_truncator, ["AAAAAAAAAAAAAAAAAAAA"])
}

///|
/// 上游 line_composer_lots_of_spaces：纯空白输入 trim 后为空行喵。
test "折行大量空白" {
  let width = 20
  let text = "                                                                     "
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, [""])
  @debug.assert_eq(line_truncator, ["                    "])
}

///|
/// 上游 line_composer_char_plus_lots_of_spaces：字母后跟大量空白喵。
test "折行字符加大量空白" {
  let width = 20
  let text = "a                                                                     "
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, ["a", ""])
  @debug.assert_eq(line_truncator, ["a                   "])
}

///|
/// 上游 line_composer_word_wrapper_double_width_chars_mixed_with_spaces喵。
test "折行双宽字符混空白" {
  let width = 20
  let text = "コンピュ ータ上で文字を扱う場合、 典型的には文 字による 通信を行 う場合にその両端点では、"
  let (word_wrapper, word_wrapper_width, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, [
    "コンピュ", "ータ上で文字を扱う場", "合、 典型的には文",
    "字による 通信を行", "う場合にその両端点で", "は、",
  ])
  @debug.assert_eq(word_wrapper_width, [8, 20, 17, 17, 20, 4])
}

///|
/// 上游 line_composer_word_wrapper_nbsp：NBSP 视为词内字符喵。
test "折行 NBSP" {
  let width = 20
  let text = "AAAAAAAAAAAAAAA AAAA\u{00a0}AAA"
  let (word_wrapper, word_wrapper_widths, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, ["AAAAAAAAAAAAAAA", "AAAA\u{00a0}AAA"])
  @debug.assert_eq(word_wrapper_widths, [15, 8])
  let text_space = text.replace_all(old="\u{00a0}", new=" ")
  let (word_wrapper_space, word_wrapper_widths_space, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(text_space),
    width,
  )
  @debug.assert_eq(word_wrapper_space, ["AAAAAAAAAAAAAAA AAAA", "AAA"])
  @debug.assert_eq(word_wrapper_widths_space, [20, 3])
}

///|
/// 上游 line_composer_word_wrapper_preserve_indentation：非 trim 保留缩进喵。
test "折行保留缩进" {
  let width = 20
  let text = "AAAAAAAAAAAAAAAAAAAA    AAA"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(false),
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, ["AAAAAAAAAAAAAAAAAAAA", "   AAA"])
}

///|
/// 上游 line_composer_word_wrapper_preserve_indentation_with_wrap喵。
test "折行保留缩进换行" {
  let width = 10
  let text = "AAA AAA AAAAA AA AAAAAA\n B\n  C\n   D"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(false),
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, [
    "AAA AAA", "AAAAA AA", "AAAAAA", " B", "  C", "   D",
  ])
}

///|
/// 上游 line_composer_word_wrapper_preserve_indentation_lots_of_whitespace 喵。
test "折行保留缩进大量空白" {
  let width = 10
  let text = "               4 Indent\n                 must wrap!"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(false),
    @core.Text::raw(text),
    width,
  )
  @debug.assert_eq(word_wrapper, [
    "          ", "    4", "Indent", "          ", "      must", "wrap!",
  ])
}

///|
/// 上游 line_composer_zero_width_at_end：行尾零宽字符不产生空行喵。
test "折行行尾零宽字符" {
  let width = 3
  let line = "foo\u{200B}"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(line),
    width,
  )
  let (line_truncator, _, _) = run_composer(
    Truncate,
    @core.Text::raw(line),
    width,
  )
  @debug.assert_eq(word_wrapper, ["foo"])
  @debug.assert_eq(line_truncator, ["foo\u{200B}"])
}

///|
/// 上游 line_composer_preserves_line_alignment：行对齐穿透折行喵。
test "折行保留行对齐" {
  let width = 20
  let text = @core.Text::of_lines([
    @core.Line::raw("Something that is left aligned.").left_aligned(),
    @core.Line::raw("This is right aligned and half short.").right_aligned(),
    @core.Line::raw("This should sit in the center.").centered(),
  ])
  let (_, _, wrapped_alignments) = run_composer(WordWrap(true), text, width)
  let text = @core.Text::of_lines([
    @core.Line::raw("Something that is left aligned.").left_aligned(),
    @core.Line::raw("This is right aligned and half short.").right_aligned(),
    @core.Line::raw("This should sit in the center.").centered(),
  ])
  let (_, _, truncated_alignments) = run_composer(Truncate, text, width)
  @debug.assert_eq(wrapped_alignments, [
    @core.Alignment::Left,
    @core.Alignment::Left,
    @core.Alignment::Right,
    @core.Alignment::Right,
    @core.Alignment::Right,
    @core.Alignment::Center,
    @core.Alignment::Center,
  ])
  @debug.assert_eq(truncated_alignments, [
    @core.Alignment::Left,
    @core.Alignment::Right,
    @core.Alignment::Center,
  ])
}

///|
/// 上游 line_composer_zero_width_white_space：行中零宽空白断词喵。
test "折行零宽空白" {
  let width = 3
  let line = "foo\u{200b}bar"
  let (word_wrapper, _, _) = run_composer(
    WordWrap(true),
    @core.Text::raw(line),
    width,
  )
  @debug.assert_eq(word_wrapper, ["foo", "bar"])
}
