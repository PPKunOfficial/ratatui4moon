///|
/// 符号显示宽度（v0.1 近似区间法，v0.2 迁 `unicode/` 全量表）喵。
///
/// 语义对位上游 `unicode-width`：控制字符与零宽符号宽 0、CJK/全角
/// 宽 2、其余宽 1；字符串宽度为逐码点宽度之和（零宽修饰符不加分）。
/// emoji 专属 VS16 序列（如 `⌨️`）暂按基础码点计宽，与全量表一同
/// 迁移（相应上游用例已在测试文件登记"待复刻"）喵。
pub fn symbol_width(symbol : String) -> Int {
  let mut total = 0
  for ch in symbol {
    total += char_display_width(ch)
  }
  total
}

///|
/// 单码点显示宽度喵。
pub fn char_display_width(ch : Char) -> Int {
  let cp = ch.to_int()
  if cp < 0x20 || (cp >= 0x7F && cp < 0xA0) {
    return 0
  }
  if is_zero_width(cp) {
    return 0
  }
  if is_wide(cp) {
    return 2
  }
  1
}

///|
/// 零宽区间：组合记号、变体选择符、ZW 系列等（宽 0）喵。
fn is_zero_width(cp : Int) -> Bool {
  (cp >= 0x0300 && cp <= 0x036F) || // 组合附加符号
  (cp >= 0x0483 && cp <= 0x0489) || // 叙利亚/阿拉伯组合记号
  (cp >= 0x0591 && cp <= 0x05BD) || // 希伯来组合记号
  (cp >= 0x0610 && cp <= 0x061A) || // 阿拉伯组合记号
  (cp >= 0x064B && cp <= 0x065F) ||
  cp == 0x0670 ||
  (cp >= 0x06D6 && cp <= 0x06DC) ||
  (cp >= 0x0730 && cp <= 0x074A) ||
  (cp >= 0x07A6 && cp <= 0x07B0) ||
  (cp >= 0x0900 && cp <= 0x0902) || // 天城文组合记号等
  cp == 0x093A ||
  cp == 0x093C ||
  (cp >= 0x0E31 && cp <= 0x0E3A && cp != 0x0E32 && cp != 0x0E33) || // 泰文
  (cp >= 0x0EB1 && cp <= 0x0EBC) ||
  (cp >= 0x1AB0 && cp <= 0x1AFF) || // 组合记号扩展
  (cp >= 0x1DC0 && cp <= 0x1DFF) ||
  (cp >= 0x20D0 && cp <= 0x20FF) || // 符号组合记号
  (cp >= 0xFE00 && cp <= 0xFE0F) || // 变体选择符 VS1–VS16
  (cp >= 0xFE20 && cp <= 0xFE2F) || // 组合半标记
  (cp >= 0x200B && cp <= 0x200F) || // ZWSP/ZWNJ/ZWJ/LRM/RLM
  (cp >= 0x2060 && cp <= 0x2064) || // 词连接符等
  cp == 0xFEFF // BOM / 零宽不换行空格
}

///|
/// 宽字符区间：CJK/全角/谚文/Emoji（宽 2）喵。
fn is_wide(cp : Int) -> Bool {
  (cp >= 0x1100 && cp <= 0x115F) || // 谚文字母扩展
  (cp >= 0x2E80 && cp <= 0x303E) || // CJK 部首/康熙/注音/象形
  (cp >= 0x3041 && cp <= 0x33FF) || // 平假名/片假名/注音/兼容
  (cp >= 0x3400 && cp <= 0x4DBF) || // CJK 扩展 A
  (cp >= 0x4E00 && cp <= 0x9FFF) || // CJK 统一表意
  (cp >= 0xA000 && cp <= 0xA4CF) || // 彝文
  (cp >= 0xA960 && cp <= 0xA97F) || // 谚文字母扩展 A
  (cp >= 0xAC00 && cp <= 0xD7A3) || // 谚文音节
  (cp >= 0xF900 && cp <= 0xFAFF) || // CJK 兼容表意
  (cp >= 0xFE10 && cp <= 0xFE19) || // 竖排形式
  (cp >= 0xFE30 && cp <= 0xFE6F) || // CJK 兼容形式/小写变体
  (cp >= 0xFF00 && cp <= 0xFF60) || // 全角 ASCII/标点
  (cp >= 0xFFE0 && cp <= 0xFFE6) || // 全角符号
  (cp >= 0x1F300 && cp <= 0x1F64F) || // Emoji 符号与表情
  (cp >= 0x1F680 && cp <= 0x1F6FF) || // 交通与地图
  (cp >= 0x1F900 && cp <= 0x1F9FF) || // 补充符号与象形
  (cp >= 0x1FA70 && cp <= 0x1FAFF) || // 扩展 A
  (cp >= 0x20000 && cp <= 0x2FFFD) || // CJK 扩展 B–F
  (cp >= 0x30000 && cp <= 0x3FFFD) // CJK 扩展 G–H
}
