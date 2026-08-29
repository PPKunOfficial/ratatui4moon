// unicode-width 0.2.2 宽度算法（上游 `src/tables.rs` 的纯 MoonBit
// 移植，Unicode 17.0，非 CJK 缺省语义：Ambiguous 记窄）喵。
//
// 核心是 `str_width` 的**自右向左**折叠：`next_info` 状态从右侧
// 流向左侧，使 VS16/文本选择符/强制连接符等"后缀修饰"能够影响
// 其左侧基字符的宽度（emoji 呈现序列、ZWJ 序列、连字组合）喵。

///|
/// Unicode 版本（上游 `UNICODE_VERSION` = 17.0）喵。
pub let unicode_major : Int = 17

///|
/// Unicode 次版本（上游 `UNICODE_VERSION`）喵。
pub let unicode_minor : Int = 0

///|
/// 宽度模式状态（上游 `WidthInfo(u16)` 以位承载）喵。
pub(all) struct WidthInfo {
  bits : Int
} derive(Eq, Debug)

///|
let width_default : Int = 0

///|
let line_feed_bits : Int = 0b0000000000000001

///|
let emoji_modifier_bits : Int = 0b0000000000000010

///|
let regional_indicator_bits : Int = 0b0000000000000011

///|
let several_regional_indicator_bits : Int = 0b0000000000000100

///|
let emoji_presentation_bits : Int = 0b0000000000000101

///|
let zwj_emoji_presentation_bits : Int = 0b0001000000000110

///|
let vs16_zwj_emoji_presentation_bits : Int = 0b1001000000000110

///|
let ligature_transparent_mask : Int = 0b0010_0000_0000_0000

///|
let vs16_bits : Int = 0b1000000000000000

///|
let vs15_bits : Int = 0b0100000000000000

///|
let vs1_2_3_bits : Int = 0b0000001000000000

///|
let zwj_flag_bits : Int = 0b0000_0100_0000_0000

///|
/// 是否 emoji 呈现（最高位）喵。
fn width_is_emoji_presentation(info : WidthInfo) -> Bool {
  info.bits.land(vs16_bits) == vs16_bits
}

///|
/// 是否 ZWJ emoji 呈现喵。
fn width_is_zwj_emoji_presentation(info : WidthInfo) -> Bool {
  info.bits.land(0b1011_0000_0000_0000) == 0b1001_0000_0000_0000
}

///|
/// 是否文本呈现（第 2 高位）喵。
fn width_is_text_presentation(info : WidthInfo) -> Bool {
  info.bits.land(vs15_bits) == vs15_bits
}

///|
/// 是否 VS1–VS3 喵。
fn width_is_vs1_2_3(info : WidthInfo) -> Bool {
  info.bits.land(vs1_2_3_bits) == vs1_2_3_bits
}

///|
/// 是否连字透明喵。
fn width_is_ligature_transparent(info : WidthInfo) -> Bool {
  info.bits.land(0b0000_1000_0000_0000) == 0b0000_1000_0000_0000
}

///|
/// 置 emoji 呈现位（上游 `set_emoji_presentation`）喵。
fn width_set_emoji_presentation(info : WidthInfo) -> WidthInfo {
  if info.bits.land(ligature_transparent_mask) == ligature_transparent_mask ||
    info.bits.land(0b1001_0000_0000_0000) == 0b0001_0000_0000_0000 {
    {
      bits: info.bits
      .lor(vs16_bits)
      .land(complement16(vs15_bits))
      .land(complement16(vs1_2_3_bits)),
    }
  } else {
    { bits: vs16_bits }
  }
}

///|
/// 清 emoji 呈现位（上游 `unset_emoji_presentation`）喵。
fn width_unset_emoji_presentation(info : WidthInfo) -> WidthInfo {
  if info.bits.land(ligature_transparent_mask) == ligature_transparent_mask {
    { bits: info.bits.land(complement16(vs16_bits)) }
  } else {
    { bits: width_default }
  }
}

///|
/// 置文本呈现位（上游 `set_text_presentation`）喵。
fn width_set_text_presentation(info : WidthInfo) -> WidthInfo {
  if info.bits.land(ligature_transparent_mask) == ligature_transparent_mask {
    {
      bits: info.bits
      .lor(vs15_bits)
      .land(complement16(vs16_bits))
      .land(complement16(vs1_2_3_bits)),
    }
  } else {
    { bits: vs15_bits }
  }
}

///|
/// 清文本呈现位（上游 `unset_text_presentation`）喵。
fn width_unset_text_presentation(info : WidthInfo) -> WidthInfo {
  if info.bits.land(ligature_transparent_mask) == ligature_transparent_mask {
    { bits: info.bits.land(complement16(vs15_bits)) }
  } else {
    { bits: width_default }
  }
}

///|
/// 置 VS1–VS3 位（上游 `set_vs1_2_3`）喵。
fn width_set_vs1_2_3(info : WidthInfo) -> WidthInfo {
  if info.bits.land(ligature_transparent_mask) == ligature_transparent_mask {
    {
      bits: info.bits
      .lor(vs1_2_3_bits)
      .land(complement16(vs16_bits))
      .land(complement16(vs15_bits)),
    }
  } else {
    { bits: vs1_2_3_bits }
  }
}

///|
/// 清 VS1–VS3 位（上游 `unset_vs1_2_3`）喵。
fn width_unset_vs1_2_3(info : WidthInfo) -> WidthInfo {
  if info.bits.land(ligature_transparent_mask) == ligature_transparent_mask {
    { bits: info.bits.land(complement16(vs1_2_3_bits)) }
  } else {
    { bits: width_default }
  }
}

///|
/// 16 位按位取反（WidthInfo 掩码用，上游 `!WidthInfo::X` 喵）。
fn complement16(bits : Int) -> Int {
  Int::lxor(0xFFFF, bits)
}

///|
/// 三层查找表查宽度（上游 `lookup_width`）：宽度 3（U+17D8 老傣文
/// 双引号）与特殊 WidthInfo 在命中后按码点细分喵。
pub fn lookup_width(cp : Int) -> (Int, WidthInfo) {
  let t1_offset = width_root[cp >> 13]
  let t2_offset = width_middle[t1_offset][(cp >> 7).land(0x3F)]
  let packed_widths = width_leaves[t2_offset][(cp >> 2).land(0x1F)]
  let width = (packed_widths >> (2 * cp.land(0b11))).land(0b11)
  if width < 3 {
    (width, { bits: width_default })
  } else {
    // 2 位位图放不下的特殊码点（上游 lookup_width 的 match 全量）：
    // 宽度与 WidthInfo 逐条对位喵。
    if cp == 0x0A {
      return (1, { bits: line_feed_bits })
    }
    if cp == 0x5DC {
      return (1, { bits: 0b0011100000000000 })
    }
    if cp >= 0x622 && cp <= 0x882 {
      return (1, { bits: 0b0011000011111111 })
    }
    if cp >= 0x1780 && cp <= 0x17AF {
      return (1, { bits: 0b0011110000000111 })
    }
    if cp == 0x17D8 {
      return (3, { bits: width_default })
    }
    if cp == 0x1A10 {
      return (1, { bits: 0b0011100000000001 })
    }
    if cp >= 0x2D31 && cp <= 0x2D6F {
      return (1, { bits: 0b0011100000000011 })
    }
    if cp >= 0xA4FC && cp <= 0xA4FD {
      return (1, { bits: 0b0011110000000101 })
    }
    if cp == 0xFE01 {
      return (0, { bits: vs1_2_3_bits })
    }
    if cp == 0xFE0E {
      return (0, { bits: vs15_bits })
    }
    if cp == 0xFE0F {
      return (0, { bits: vs16_bits })
    }
    if cp == 0x10C03 {
      return (1, { bits: 0b0011100000000110 })
    }
    if cp == 0x16D67 {
      return (1, { bits: 0b0000000000100000 })
    }
    if cp == 0x16D68 {
      return (1, { bits: 0b0000000000100001 })
    }
    if cp >= 0x1F1E6 && cp <= 0x1F1FF {
      return (1, { bits: regional_indicator_bits })
    }
    if cp >= 0x1F3FB && cp <= 0x1F3FF {
      return (2, { bits: emoji_modifier_bits })
    }
    (2, { bits: emoji_presentation_bits })
  }
}

///|
/// 单码点宽度（上游 `single_char_width`）：控制字符落 None 喵。
pub fn single_char_width(cp : Int) -> Int? {
  if cp < 0x7F {
    if cp >= 0x20 {
      Some(1)
    } else {
      None
    }
  } else if cp >= 0xA0 {
    Some(lookup_width(cp).0)
  } else {
    None
  }
}

///|
/// 是否 Emoji 呈现序列的起始基字符（上游 `starts_emoji_presentation_seq`）喵。
fn starts_emoji_presentation_seq(cp : Int) -> Bool {
  let top_bits = cp >> 10
  let idx_of_leaf : Int = match top_bits {
    0x0 => 0
    0x8 => 1
    0x9 => 2
    0xA => 3
    0xC => 4
    0x7C => 5
    0x7D => 6
    _ => return false
  }
  let idx_within_leaf = (cp >> 3).land(0x7F)
  let leaf_byte = emoji_presentation_leaves[idx_of_leaf][idx_within_leaf]
  (leaf_byte >> cp.land(7)).land(1) == 1
}

///|
/// 是否非表意的文本呈现序列起始（上游
/// `starts_non_ideographic_text_presentation_seq`）喵。
fn starts_non_ideographic_text_presentation_seq(cp : Int) -> Bool {
  let top_bits = cp >> 8
  let leaf : Array[(Int, Int)] = match top_bits {
    0x23 => text_presentation_leaf_0
    0x25 => text_presentation_leaf_1
    0x26 => text_presentation_leaf_2
    0x27 => text_presentation_leaf_3
    0x2B => text_presentation_leaf_4
    0x1F0 => text_presentation_leaf_5
    0x1F3 => text_presentation_leaf_6
    0x1F4 => text_presentation_leaf_7
    0x1F5 => text_presentation_leaf_8
    0x1F6 => text_presentation_leaf_9
    _ => return false
  }
  range_pair_contains(leaf, cp.land(0xFF))
}

///|
/// 是否 Emoji_Modifier_Base（上游 `is_emoji_modifier_base`）喵。
fn is_emoji_modifier_base(cp : Int) -> Bool {
  let top_bits = cp >> 8
  let leaf : Array[(Int, Int)] = match top_bits {
    0x26 => emoji_modifier_leaf_0
    0x27 => emoji_modifier_leaf_1
    0x1F3 => emoji_modifier_leaf_2
    0x1F4 => emoji_modifier_leaf_3
    0x1F5 => emoji_modifier_leaf_4
    0x1F6 => emoji_modifier_leaf_5
    0x1F9 => emoji_modifier_leaf_6
    0x1FA => emoji_modifier_leaf_7
    _ => return false
  }
  range_pair_contains(leaf, cp.land(0xFF))
}

///|
/// 区间对二分查找（上游 `binary_search_by` 的等价承载）喵。
fn range_pair_contains(leaf : Array[(Int, Int)], value : Int) -> Bool {
  let mut lo = 0
  let mut hi = leaf.length()
  while lo < hi {
    let mid = (lo + hi) / 2
    let (l, h) = leaf[mid]
    if value < l {
      hi = mid
    } else if value > h {
      lo = mid + 1
    } else {
      return true
    }
  }
  false
}

///|
/// 是否连字透明字符（上游 `is_ligature_transparent`）喵。
fn is_ligature_transparent(cp : Int) -> Bool {
  cp == 0x34F ||
  (cp >= 0x17B4 && cp <= 0x17B5) ||
  (cp >= 0x180B && cp <= 0x180D) ||
  cp == 0x180F ||
  cp == 0x200D ||
  (cp >= 0xFE00 && cp <= 0xFE0F) ||
  (cp >= 0xE0100 && cp <= 0xE01EF)
}

///|
/// 是否零宽且 Joining_Type=Transparent（上游 `is_transparent_zero_width`）：
/// 查宽度为 0 且不在非透明零宽区间表中喵。
fn is_transparent_zero_width(cp : Int) -> Bool {
  let (w, _) = lookup_width(cp)
  if w != 0 {
    false
  } else {
    // 二分：cp 落入任一 (lo, hi) 区间即"非透明"喵。
    let mut lo = 0
    let mut hi = non_transparent_zero_widths.length()
    let mut contained = false
    while lo < hi {
      let mid = (lo + hi) / 2
      let (l, h) = non_transparent_zero_widths[mid]
      if cp < l {
        hi = mid
      } else if cp > h {
        lo = mid + 1
      } else {
        contained = true
        break
      }
    }
    !contained
  }
}

///|
/// 字符串宽度（上游 `UnicodeWidthStr::width` → `str_width`）：自右
/// 向左折叠状态喵。
pub fn str_width(s : String) -> Int {
  let chars : Array[Char] = []
  for ch in s {
    chars.push(ch)
  }
  let mut sum = 0
  let mut next_info : WidthInfo = { bits: width_default }
  for i in 0..<chars.length() {
    let ch = chars[chars.length() - 1 - i]
    let (add, info) = width_in_str(ch.to_int(), next_info)
    sum += add
    next_info = info
  }
  sum
}

///|
/// 单字符在字符串语境下的宽度贡献与状态迁移（上游 `width_in_str`）喵。
pub fn width_in_str(cp : Int, next_info_in : WidthInfo) -> (Int, WidthInfo) {
  let mut next_info = next_info_in
  // 右侧已处于 emoji 呈现态：本字符若能开启呈现序列，则吃掉呈现
  // 宽度（基字符承担 2 列，VS16/ZWJ 落 0）喵。
  if width_is_emoji_presentation(next_info) {
    if starts_emoji_presentation_seq(cp) {
      let width = if width_is_zwj_emoji_presentation(next_info) { 0 } else { 2 }
      return (width, { bits: emoji_presentation_bits })
    } else {
      next_info = width_unset_emoji_presentation(next_info)
    }
  }
  if cp <= 0xA0 {
    if cp == 0x0A {
      return (1, { bits: line_feed_bits })
    }
    if cp == 0x0D && next_info == { bits: line_feed_bits } {
      return (0, { bits: width_default })
    }
    return (1, { bits: width_default })
  }
  // 快速路径：状态非默认时先处理变体选择符/连字/组合特例喵。
  if next_info.bits != width_default {
    if cp == 0xFE0F {
      return (0, width_set_emoji_presentation(next_info))
    }
    if cp == 0xFE01 {
      return (0, width_set_vs1_2_3(next_info))
    }
    if cp == 0xFE0E {
      return (0, width_set_text_presentation(next_info))
    }
    if width_is_text_presentation(next_info) {
      if starts_non_ideographic_text_presentation_seq(cp) {
        return (1, { bits: width_default })
      } else {
        next_info = width_unset_text_presentation(next_info)
      }
    } else if width_is_vs1_2_3(next_info) {
      if cp == 0x2018 || cp == 0x2019 || cp == 0x201C || cp == 0x201D {
        return (2, { bits: width_default })
      } else {
        next_info = width_unset_vs1_2_3(next_info)
      }
    }
    if width_is_ligature_transparent(next_info) {
      if cp == 0x200D {
        return (0, { bits: next_info.bits.lor(zwj_flag_bits) })
      } else if is_ligature_transparent(cp) {
        return (0, next_info)
      }
    }
    // 组合连字特例（阿拉伯 Lam-Alef、希伯来 Alef-Lamed、高棉 coeng、
    // 布吉文、提非纳文、老傈僳文、突厥如尼、emoji 修饰符、区域指示
    // 符、ZWJ emoji、标签序列、Kirat Rai 元音等）喵。
    let bits = next_info.bits
    let (matched, add, out) : (Bool, Int, WidthInfo) = if bits ==
      0b0011000011111111 &&
      (
        cp == 0x644 ||
        (cp >= 0x6B5 && cp <= 0x6B8) ||
        cp == 0x76A ||
        cp == 0x8A6 ||
        cp == 0x8C7
      ) {
      (true, 0, { bits: width_default })
    } else if bits == 0b0011000011111111 && is_transparent_zero_width(cp) {
      (true, 0, { bits: 0b0011000011111111 })
    } else if bits == 0b0011110000000000 && cp == 0x5D0 {
      (true, 0, { bits: width_default })
    } else if bits == 0b0011110000000111 && cp == 0x17D2 {
      (true, -1, { bits: width_default })
    } else if bits == 0b0011110000000001 && cp == 0x1A17 {
      (true, 0, { bits: 0b0011110000000010 })
    } else if bits == 0b0011110000000010 && cp == 0x1A15 {
      (true, 0, { bits: width_default })
    } else if (bits == 0b0011100000000011 || bits == 0b0011110000000011) &&
      cp == 0x2D7F {
      (true, 1, { bits: 0b0011110000000100 })
    } else if bits == 0b0011110000000011 &&
      ((cp >= 0x2D31 && cp <= 0x2D65) || cp == 0x2D6F) {
      (true, 0, { bits: width_default })
    } else if bits == 0b0011110000000100 &&
      ((cp >= 0x2D31 && cp <= 0x2D65) || cp == 0x2D6F) {
      (true, -1, { bits: width_default })
    } else if bits == 0b0011110000000101 && cp >= 0xA4F8 && cp <= 0xA4FB {
      (true, 0, { bits: width_default })
    } else if bits == 0b0011110000000110 && cp == 0x10C32 {
      (true, 0, { bits: width_default })
    } else if bits == emoji_modifier_bits && is_emoji_modifier_base(cp) {
      (true, 0, { bits: emoji_presentation_bits })
    } else if (
        bits == regional_indicator_bits ||
        bits == several_regional_indicator_bits
      ) &&
      cp >= 0x1F1E6 &&
      cp <= 0x1F1FF {
      (true, 1, { bits: several_regional_indicator_bits })
    } else if (
        bits == emoji_presentation_bits ||
        bits == several_regional_indicator_bits ||
        bits == 0b0000000000001010 ||
        bits == 0b0000000000001011 ||
        bits == emoji_modifier_bits
      ) &&
      cp == 0x200D {
      (true, 0, { bits: zwj_emoji_presentation_bits })
    } else if bits == zwj_emoji_presentation_bits && cp == 0x20E3 {
      (true, 0, { bits: 0b0001000000000111 })
    } else if bits == vs16_zwj_emoji_presentation_bits &&
      starts_emoji_presentation_seq(cp) {
      (true, 0, { bits: emoji_presentation_bits })
    } else if bits == 0b1001000000000111 &&
      ((cp >= 0x30 && cp <= 0x39) || cp == 0x23 || cp == 0x2A) {
      (true, 0, { bits: emoji_presentation_bits })
    } else if bits == zwj_emoji_presentation_bits &&
      cp >= 0x1F1E6 &&
      cp <= 0x1F1FF {
      (true, 1, { bits: 0b0000000000001001 })
    } else if (bits == 0b0000000000001001 || bits == 0b0000000000001011) &&
      cp >= 0x1F1E6 &&
      cp <= 0x1F1FF {
      (true, -1, { bits: 0b0000000000001010 })
    } else if bits == 0b0000000000001010 && cp >= 0x1F1E6 && cp <= 0x1F1FF {
      (true, 3, { bits: 0b0000000000001011 })
    } else if bits == zwj_emoji_presentation_bits &&
      cp >= 0x1F3FB &&
      cp <= 0x1F3FF {
      (true, 0, { bits: emoji_modifier_bits })
    } else if bits == zwj_emoji_presentation_bits && cp == 0xE007F {
      (true, 0, { bits: 0b0000000000010000 })
    } else if (bits >= 0b0000000000010000 && bits <= 0b0000000000010101) &&
      cp >= 0xE0061 &&
      cp <= 0xE007A {
      // TAG_END→A1→…→A6 逐级推进（上游六臂的等价承载）喵。
      (true, 0, { bits: bits + 1 })
    } else if (bits >= 0b0000000000010000 && bits <= 0b0000000000010100) &&
      cp >= 0xE0030 &&
      cp <= 0xE0039 {
      (true, 0, { bits: 0b0000000000010001 })
    } else if (
        bits == 0b0000000000010011 ||
        bits == 0b0000000000010100 ||
        bits == 0b0000000000010101 ||
        bits == 0b0000000000010110 ||
        bits == 0b0000000000010010
      ) &&
      cp == 0x1F3F4 {
      (true, 0, { bits: emoji_presentation_bits })
    } else if bits == zwj_emoji_presentation_bits {
      let (w, info) = lookup_width(cp)
      if info.bits == emoji_presentation_bits {
        (true, 0, { bits: emoji_presentation_bits })
      } else {
        (false, w, info)
      }
    } else if bits == 0b0000000000100000 && cp == 0x16D63 {
      (true, 0, { bits: width_default })
    } else if bits == 0b0000000000100000 && cp == 0x16D67 {
      (true, 0, { bits: 0b0000000000100001 })
    } else if bits == 0b0000000000100000 && cp == 0x16D68 {
      (true, 1, { bits: 0b0000000000100000 })
    } else if bits == 0b0000000000100000 && cp == 0x16D69 {
      (true, 0, { bits: width_default })
    } else if bits == 0b0000000000100001 && cp == 0x16D63 {
      (true, 0, { bits: width_default })
    } else {
      (false, 0, next_info)
    }
    if matched {
      return (add, out)
    }
    if bits == 0b0000000000100000 || bits == 0b0000000000100001 {
      // Kirat Rai 已穷尽特例，落常规查找喵。
      let (w, info) = lookup_width(cp)
      return (w, info)
    }
  }
  let (w, info) = lookup_width(cp)
  (w, info)
}
