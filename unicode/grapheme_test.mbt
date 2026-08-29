// 图形簇与宽度交叉验证：用例取自上游 ratatui `renders_emoji`/
// `diff_clears_trailing_cell_for_wide_grapheme` 与 unicode
// README/上游测试语义（🇷🇸🇮🇴 双旗、组合记号等）喵。

///|
/// 宽度：单 emoji、ZWJ 序列、VS16 序列均为 2 列；CJK 2 列；
/// 组合记号零宽；换行特判 1 列（上游 str_width 的 LINE_FEED 分支）喵。
test "宽度：emoji/CJK/组合/换行" {
  inspect(str_width("🤷"), content="2")
  inspect(str_width("🐻‍❄️"), content="2")
  inspect(str_width("👁️‍🗨️"), content="2")
  inspect(str_width("⌨️"), content="2")
  inspect(str_width("⚠️"), content="2")
  inspect(str_width("中"), content="2")
  inspect(str_width("a中b"), content="4")
  inspect(str_width("e\u{0301}"), content="1")
  inspect(str_width("ab\n"), content="3")
  inspect(str_width("🇷🇸"), content="2")
  inspect(str_width("👨‍👩‍👧‍👦"), content="2")
  inspect(str_width("#️⃣"), content="2")
}

///|
/// 切分：各 emoji 序列成单簇；双旗两簇；组合记号归并基字符喵。
test "图形簇：emoji/旗帜/组合记号" {
  inspect(graphemes("🤷").length(), content="1")
  inspect(graphemes("🐻‍❄️").length(), content="1")
  inspect(graphemes("👁️‍🗨️").length(), content="1")
  inspect(graphemes("⌨️").length(), content="1")
  inspect(graphemes("🇷🇸🇮🇴").length(), content="2")
  inspect(graphemes("a\u{0301}b").length(), content="2")
  inspect(graphemes("ab").length(), content="2")
  inspect(graphemes("中").length(), content="1")
  inspect(graphemes("👨‍👩‍👧‍👦").length(), content="1")
  // 空串无簇喵。
  inspect(graphemes("").length(), content="0")
}

///|
/// 类别抽查：Extended_Pictographic/ZWJ/RIS/Extend/InCB 喵。
test "类别抽查" {
  inspect(
    grapheme_category(0x1F43B) is GC_Extended_Pictographic,
    content="true",
  )
  inspect(grapheme_category(0x200D) is GC_ZWJ, content="true")
  inspect(grapheme_category(0x2744) is GC_Extended_Pictographic, content="true")
  inspect(grapheme_category(0xFE0F) is GC_Extend, content="true")
  inspect(grapheme_category(0x1F1F7) is GC_Regional_Indicator, content="true")
  inspect(grapheme_category(0x0301) is GC_Extend, content="true")
  inspect(grapheme_category(0x0915) is GC_InCB_Consonant, content="true")
  inspect(grapheme_category(0x61) is GC_Any, content="true")
  inspect(grapheme_category(0x0A) is GC_LF, content="true")
}
