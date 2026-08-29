// 上游 braille.rs / pixel.rs / half_block.rs 无内联测试；此处补结构
// 锚定用例（长度 + 位映射抽检），保证表内容与上游逐项一致不漂移喵。
// 生成文件已由脚本对照上游逐字符校验，抽检为防回归的额外保险喵。

///|
/// 盲文表长度与位映射语义抽检：pattern 行主序位 k → 盲文点位
/// （k0=左上 dot1、k1=右上 dot4、k2=dot2、k3=dot5、k4=dot3、k5=dot6、
/// k6=dot7、k7=dot8）喵。
test "BRAILLE 表结构与位映射抽检" {
  inspect(braille_table.length(), content="256")
  // 单点位：pattern 1 = 左上 → U+2801
  inspect(braille_table[1], content="⠁")
  // pattern 2 = 右上 → U+2808（dot4）
  inspect(braille_table[2], content="⠈")
  // pattern 4 = 左中 → U+2802（dot2）
  inspect(braille_table[4], content="⠂")
  // pattern 8 = 右中 → U+2810（dot5）
  inspect(braille_table[8], content="⠐")
  // pattern 16 = 左下 → U+2804（dot3）
  inspect(braille_table[16], content="⠄")
  // pattern 32 = 右下 → U+2820（dot6）
  inspect(braille_table[32], content="⠠")
  // pattern 64 = 左底 → U+2840（dot7）
  inspect(braille_table[64], content="⡀")
  // pattern 128 = 右底 → U+2880（dot8）
  inspect(braille_table[128], content="⢀")
  // 满格 → U+28FF
  inspect(braille_table[255], content="⣿")
}

///|
/// 象限表：行主序 2x2 位图，单点位与满格抽检喵。
test "QUADRANTS 表结构与位映射抽检" {
  inspect(quadrants.length(), content="16")
  inspect(quadrants[0], content=" ")
  inspect(quadrants[1], content="▘")
  inspect(quadrants[2], content="▝")
  inspect(quadrants[3], content="▀")
  inspect(quadrants[15], content="█")
}

///|
/// 六分表结构与端点抽检（2x3 伪像素，64 项）喵。
test "SEXTANTS 表结构与端点抽检" {
  inspect(sextants.length(), content="64")
  inspect(sextants[0], content=" ")
  inspect(sextants[1], content="🬀")
  inspect(sextants[63], content="█")
}

///|
/// 八分表结构与端点抽检（2x4 伪像素，256 项）喵。
test "OCTANTS 表结构与端点抽检" {
  inspect(octants.length(), content="256")
  inspect(octants[0], content=" ")
  inspect(octants[255], content="█")
}

///|
/// 半块三常量锚定（上游 `half_block::{UPPER,LOWER,FULL}`）喵。
test "半块常量锚定" {
  inspect(HALF_BLOCK_UPPER, content="▀")
  inspect(HALF_BLOCK_LOWER, content="▄")
  inspect(HALF_BLOCK_FULL, content="█")
}

///|
/// 圆点标记字符锚定（上游 `symbols::DOT`）喵。
test "DOT 常量锚定" {
  inspect(DOT, content="•")
}
