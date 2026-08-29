// 图形簇细分（上游 unicode-segmentation 1.13.3 `grapheme.rs` 的
// 纯 MoonBit 移植）：UAX #29 扩展图形簇边界（GB1–GB999）喵。
//
// 载体折算登记：
// - 上游 `GraphemeCursor` 支持 chunk 化供给（PreContext/PrevChunk）；
//   本库调用方始终整串在手（`Span::styled_graphemes`/
//   `Buffer::set_stringn`），故以等价的顺序扫描承载：逐相邻字符对
//   查 `check_pair`，三种需前文的状态（InCB 辅音、区域指示符、
//   ZWJ emoji）直接回看，语义与 `next_boundary` 链一致喵；
// - 上游 `grapheme_cat_lookup` 快表仅加速，查找等价于对
//   `grapheme_cat_table` 全表二分，故不搬运喵。

///|
/// 图形簇类别（上游 `GraphemeCat`，以 Int 常量承载）喵。
pub(all) enum GraphemeCat {
  GC_Any
  GC_CR
  GC_Control
  GC_Extend
  GC_Extended_Pictographic
  GC_InCB_Consonant
  GC_L
  GC_LF
  GC_LV
  GC_LVT
  GC_Prepend
  GC_Regional_Indicator
  GC_SpacingMark
  GC_T
  GC_V
  GC_ZWJ
} derive(Eq, Debug)

///|
/// ASCII 快路径 + 区间表二分（上游 `GraphemeCursor::grapheme_category`
/// 与 `bsearch_range_value_table`；快表省略，全表二分语义等价）喵。
pub fn grapheme_category(cp : Int) -> GraphemeCat {
  if cp <= 0x7E {
    // ASCII 特判优化（上游注释：对含标点/空格的文本普遍提速）喵。
    if cp >= 0x20 {
      return GC_Any
    }
    if cp == 0x0A {
      return GC_LF
    }
    if cp == 0x0D {
      return GC_CR
    }
    return GC_Control
  }
  let mut lo = 0
  let mut hi = grapheme_cat_table.length()
  while lo < hi {
    let mid = (lo + hi) / 2
    let (l, h, cat) = grapheme_cat_table[mid]
    if cp < l {
      hi = mid
    } else if cp > h {
      lo = mid + 1
    } else {
      return cat
    }
  }
  GC_Any
}

///|
/// 是否 InCB=Linker（上游 `is_incb_linker`）喵。
pub fn is_incb_linker(cp : Int) -> Bool {
  for v in incb_linkers {
    if v == cp {
      return true
    }
  }
  false
}

///|
/// 是否 InCB=Extend（上游 `derived_property::InCB_Extend`）喵。
pub fn incb_extend(cp : Int) -> Bool {
  range_contains(incb_extend_table, cp)
}

///|
/// 区间表二分（上游 `bsearch_range_table`）喵。
fn range_contains(table : Array[(Int, Int)], cp : Int) -> Bool {
  let mut lo = 0
  let mut hi = table.length()
  while lo < hi {
    let mid = (lo + hi) / 2
    let (l, h) = table[mid]
    if cp < l {
      hi = mid
    } else if cp > h {
      lo = mid + 1
    } else {
      return true
    }
  }
  false
}

///|
/// 相邻类别对的边界判定（上游 `check_pair`，GB3–GB999 逐条同构）喵。
fn check_pair(before : GraphemeCat, after : GraphemeCat) -> GraphemePairResult {
  match (before, after) {
    (GC_CR, GC_LF) => NotBreak // GB3
    (GC_CR, _) | (GC_Control, _) | (GC_LF, _) => Break // GB4
    (_, GC_Control) | (_, GC_CR) | (_, GC_LF) => Break // GB5
    (GC_L, GC_L) | (GC_L, GC_V) | (GC_L, GC_LV) | (GC_L, GC_LVT) => NotBreak // GB6
    (GC_LV, GC_V) | (GC_LV, GC_T) | (GC_V, GC_V) | (GC_V, GC_T) => NotBreak // GB7
    (GC_LVT, GC_T) | (GC_T, GC_T) => NotBreak // GB8
    (_, GC_Extend) | (_, GC_ZWJ) => NotBreak // GB9
    (_, GC_SpacingMark) => Extended // GB9a
    (GC_Prepend, _) => Extended // GB9b
    (_, GC_InCB_Consonant) => InCbConsonant // GB9c
    (GC_ZWJ, GC_Extended_Pictographic) => Emoji // GB11
    (GC_Regional_Indicator, GC_Regional_Indicator) => Regional // GB12/GB13
    (_, _) => Break // GB999
  }
}

///|
/// 配对判定结果（上游 `PairResult`）喵。
priv enum GraphemePairResult {
  NotBreak
  Break
  Extended
  InCbConsonant
  Regional
  Emoji
}

///|
/// GB9c 回看（上游 `handle_incb_consonant`）：s[k] 为 InCB 辅音时，
/// 其前为 Linker⁺ Extend* 且再前为 InCB 辅音则不断喵。
fn handle_incb_consonant(chars : Array[Char], k : Int) -> Bool {
  // 回看区间 s[0..k]，从 k-1 往前喵。
  let mut linker_count = 0
  let mut i = k - 1
  while i >= 0 {
    let cp = chars[i].to_int()
    if is_incb_linker(cp) {
      linker_count += 1
    } else if incb_extend(cp) {
      // 忽略 Extend，继续喵。
    } else {
      return !(linker_count > 0 && grapheme_category(cp) == GC_InCB_Consonant)
    }
    i -= 1
  }
  // 到串首仍未遇辅音 → 断喵。
  true
}

///|
/// GB12/13 回看（上游 `handle_regional`）：k 前连续 RIS 个数为偶则断喵。
fn handle_regional(chars : Array[Char], k : Int) -> Bool {
  let mut ris_count = 0
  let mut i = k - 1
  while i >= 0 {
    if grapheme_category(chars[i].to_int()) != GC_Regional_Indicator {
      return ris_count % 2 == 0
    }
    ris_count += 1
    i -= 1
  }
  ris_count % 2 == 0
}

///|
/// GB11 回看（上游 `handle_emoji`）：Extend* ZWJ × Extended_Pictographic，
/// 即 ZWJ 前为 Extend* 且再前为 Extended_Pictographic 则不断喵。
fn handle_emoji(chars : Array[Char], k : Int) -> Bool {
  // s[k-1] 必须是 ZWJ（check_pair 已保证 before 为 ZWJ）喵。
  let mut seen_zwj = false
  let mut i = k - 1
  while i >= 0 {
    let cat = grapheme_category(chars[i].to_int())
    if !seen_zwj {
      if cat != GC_ZWJ {
        return true
      }
      seen_zwj = true
    } else {
      match cat {
        GC_Extend => ()
        GC_Extended_Pictographic => return false
        _ => return true
      }
    }
    i -= 1
  }
  true
}

///|
/// 把字符串切成扩展图形簇（上游 `UnicodeSegmentation::graphemes(s, true)`
/// 的等价顺序承载）：返回各簇的码点下标区间 [start, end) 喵。
pub fn grapheme_ranges(s : String) -> Array[(Int, Int)] {
  let chars : Array[Char] = []
  for ch in s {
    chars.push(ch)
  }
  let n = chars.length()
  let ranges : Array[(Int, Int)] = []
  if n == 0 {
    return ranges
  }
  let mut start = 0
  let mut j = 1
  while j < n {
    let before = grapheme_category(chars[j - 1].to_int())
    let after = grapheme_category(chars[j].to_int())
    let is_break : Bool = match check_pair(before, after) {
      NotBreak => false
      Break => true
      // graphemes(true) 为扩展簇：GB9a/GB9b 不断喵。
      Extended => false
      InCbConsonant => handle_incb_consonant(chars, j)
      Regional => handle_regional(chars, j)
      Emoji => handle_emoji(chars, j)
    }
    if is_break {
      ranges.push((start, j))
      start = j
    }
    j += 1
  }
  ranges.push((start, n))
  ranges
}

///|
/// 把字符串切成扩展图形簇子串（上游 `.graphemes(true)` 迭代的
/// 字符串形态承载）喵。
pub fn graphemes(s : String) -> Array[String] {
  let chars : Array[Char] = []
  for ch in s {
    chars.push(ch)
  }
  let out : Array[String] = []
  for range in grapheme_ranges(s) {
    let (a, b) = range
    let builder = StringBuilder()
    for i in a..<b {
      builder.write_char(chars[i])
    }
    out.push(builder.to_string())
  }
  out
}
