///|
/// 折行引擎（上游 `widgets::reflow`）：把带样式的字形流按宽度约束
/// 组装为可渲染行。`WordWrapper` 按词边界折行（可保留缩进），
/// `LineTruncator` 截断超宽行并支持水平偏移喵。
///
/// 上游以迭代器泛型承载输入；本库以 `(字形序列, 对齐)` 数组等价
/// 承载（Paragraph 逐帧喂入，语义一致）喵。

///|
/// 行合成器契约（上游 `LineComposer` trait）喵。
pub(open) trait LineComposer {
  fn next_line(Self) -> WrappedLine?
}

///|
/// 合成产出的一行：字形序列 + 实际宽度 + 对齐喵。
pub(all) struct WrappedLine {
  graphemes : Array[@core.StyledGrapheme]
  width : Int
  alignment : @core.Alignment
}

///|
/// 按词边界折行的合成器（上游 `WordWrapper`）喵。
///
/// `trim` 为 true 时裁剪行首/换行处空白（渲染紧凑），为 false 时
/// 保留缩进与行内空白喵。
pub(all) struct WordWrapper {
  input_lines : Array[(Array[@core.StyledGrapheme], @core.Alignment)]
  mut input_pos : Int
  max_line_width : Int
  wrapped_lines : Array[Array[@core.StyledGrapheme]]
  mut wrapped_head : Int
  mut current_alignment : @core.Alignment
  mut current_line : Array[@core.StyledGrapheme]
  trim : Bool
}

///|
/// 构造折行合成器（上游 `WordWrapper::new`）喵。
pub fn WordWrapper::new(
  lines : Array[(Array[@core.StyledGrapheme], @core.Alignment)],
  max_line_width : Int,
  trim : Bool,
) -> WordWrapper {
  {
    input_lines: lines,
    input_pos: 0,
    max_line_width,
    wrapped_lines: [],
    wrapped_head: 0,
    current_alignment: @core.Alignment::Left,
    current_line: [],
    trim,
  }
}

///|
/// 处理一行输入字形流，产出折行后的行序列（包私有，上游
/// `process_input`：词缓冲/空白缓冲/行缓冲三段式）喵。
fn WordWrapper::process_input(
  self : WordWrapper,
  line_symbols : Array[@core.StyledGrapheme],
) -> Unit {
  let pending_line : Array[@core.StyledGrapheme] = []
  let pending_word : Array[@core.StyledGrapheme] = []
  let pending_whitespace : Array[@core.StyledGrapheme] = []
  let mut ws_head = 0
  let mut line_width = 0
  let mut word_width = 0
  let mut whitespace_width = 0
  let mut non_whitespace_previous = false
  for grapheme in line_symbols {
    let is_whitespace = grapheme.is_whitespace()
    let symbol_width = @core.symbol_width(grapheme.symbol)
    // 超过行宽上限的符号直接忽略
    if symbol_width > self.max_line_width {
      continue
    }
    let word_found = non_whitespace_previous && is_whitespace
    // 去掉空白后当前词会溢出（trim 模式行首）
    let trimmed_overflow = pending_line.is_empty() &&
      self.trim &&
      word_width + symbol_width > self.max_line_width
    // 单独的空白会溢出（trim 模式行首）
    let whitespace_overflow = pending_line.is_empty() &&
      self.trim &&
      whitespace_width + symbol_width > self.max_line_width
    // 含空白的整词会溢出（非 trim 模式行首）
    let untrimmed_overflow = pending_line.is_empty() &&
      !self.trim &&
      word_width + whitespace_width + symbol_width > self.max_line_width
    // 把已完成的段落到行缓冲
    if word_found ||
      trimmed_overflow ||
      whitespace_overflow ||
      untrimmed_overflow {
      if !pending_line.is_empty() || !self.trim {
        while ws_head < pending_whitespace.length() {
          pending_line.push(pending_whitespace[ws_head])
          ws_head += 1
        }
        line_width += whitespace_width
      }
      for g in pending_word {
        pending_line.push(g)
      }
      line_width += word_width
      pending_word.clear()
      pending_whitespace.clear()
      ws_head = 0
      whitespace_width = 0
      word_width = 0
    }
    // 行缓冲满 或 词缓冲溢出：结算当前折行
    let line_full = line_width >= self.max_line_width
    let pending_word_overflow = symbol_width > 0 &&
      line_width + whitespace_width + word_width >= self.max_line_width
    if line_full || pending_word_overflow {
      let mut remaining_width = self.max_line_width - line_width
      if remaining_width < 0 {
        remaining_width = 0
      }
      self.wrapped_lines.push(pending_line.iter().collect())
      pending_line.clear()
      line_width = 0
      // 从行尾反向移除能放下的空白
      while ws_head < pending_whitespace.length() {
        let width = @core.symbol_width(pending_whitespace[ws_head].symbol)
        if width > remaining_width {
          break
        }
        whitespace_width -= width
        remaining_width -= width
        ws_head += 1
      }
      // 行尾的首个空白不计入下一行词首
      if is_whitespace && ws_head >= pending_whitespace.length() {
        continue
      }
    }
    // 符号进入词/空白缓冲
    if is_whitespace {
      whitespace_width += symbol_width
      pending_whitespace.push(grapheme)
    } else {
      word_width += symbol_width
      pending_word.push(grapheme)
    }
    non_whitespace_previous = !is_whitespace
  }
  // 收尾：trim 模式下纯空白尾行产出空行
  if pending_line.is_empty() &&
    pending_word.is_empty() &&
    ws_head < pending_whitespace.length() &&
    self.trim {
    self.wrapped_lines.push([])
  }
  if !pending_line.is_empty() || !self.trim {
    while ws_head < pending_whitespace.length() {
      pending_line.push(pending_whitespace[ws_head])
      ws_head += 1
    }
  }
  for g in pending_word {
    pending_line.push(g)
  }
  pending_word.clear()
  if !pending_line.is_empty() {
    self.wrapped_lines.push(pending_line)
  }
  // 每个输入行至少产出一行（空行也算）喵
  if self.wrapped_head >= self.wrapped_lines.length() {
    self.wrapped_lines.push([])
  }
}

///|
/// 取下一条折行（上游 `LineComposer for WordWrapper`）喵。
pub impl LineComposer for WordWrapper with fn next_line(self : WordWrapper) -> WrappedLine? {
  if self.max_line_width == 0 {
    return None
  }
  while true {
    // 先弹出已缓存的折行
    if self.wrapped_head < self.wrapped_lines.length() {
      let line = self.wrapped_lines[self.wrapped_head]
      self.wrapped_head += 1
      let mut line_width = 0
      for grapheme in line {
        line_width += @core.symbol_width(grapheme.symbol)
      }
      self.current_line = line
      return Some(
        WrappedLine::of(self.current_line, line_width, self.current_alignment),
      )
    }
    // 否则处理下一条输入行
    if self.input_pos >= self.input_lines.length() {
      return None
    }
    let (line_symbols, line_alignment) = self.input_lines[self.input_pos]
    self.input_pos += 1
    self.current_alignment = line_alignment
    self.process_input(line_symbols)
  }
  abort("unreachable")
}

///|
/// 截断式合成器（上游 `LineTruncator`）：超宽部分直接截掉，
/// 支持从行首跳过 `horizontal_offset` 列喵。
pub(all) struct LineTruncator {
  input_lines : Array[(Array[@core.StyledGrapheme], @core.Alignment)]
  mut input_pos : Int
  max_line_width : Int
  mut current_line : Array[@core.StyledGrapheme]
  mut horizontal_offset : Int
}

///|
/// 构造截断合成器（上游 `LineTruncator::new`）喵。
pub fn LineTruncator::new(
  lines : Array[(Array[@core.StyledGrapheme], @core.Alignment)],
  max_line_width : Int,
) -> LineTruncator {
  {
    input_lines: lines,
    input_pos: 0,
    max_line_width,
    current_line: [],
    horizontal_offset: 0,
  }
}

///|
/// 设水平偏移（左对齐行跳过前 N 列，上游 `set_horizontal_offset`）喵。
pub fn LineTruncator::set_horizontal_offset(
  self : LineTruncator,
  horizontal_offset : Int,
) -> Unit {
  self.horizontal_offset = horizontal_offset
}

///|
/// 取下一条截断行（上游 `LineComposer for LineTruncator`）喵。
pub impl LineComposer for LineTruncator with fn next_line(self : LineTruncator) -> WrappedLine? {
  if self.max_line_width == 0 {
    return None
  }
  if self.input_pos >= self.input_lines.length() {
    return None
  }
  let (symbols, alignment) = self.input_lines[self.input_pos]
  self.input_pos += 1
  let current_line : Array[@core.StyledGrapheme] = []
  let mut current_line_width = 0
  let mut horizontal_offset = self.horizontal_offset
  for grapheme in symbols {
    let width = @core.symbol_width(grapheme.symbol)
    // 超过总宽上限的符号忽略
    if width > self.max_line_width {
      continue
    }
    if current_line_width + width > self.max_line_width {
      break
    }
    let symbol = if horizontal_offset == 0 || alignment != @core.Alignment::Left {
      grapheme.symbol
    } else {
      let w = @core.symbol_width(grapheme.symbol)
      if w > horizontal_offset {
        let trimmed = trim_offset(grapheme.symbol, horizontal_offset)
        horizontal_offset = 0
        trimmed
      } else {
        horizontal_offset -= w
        ""
      }
    }
    current_line_width += @core.symbol_width(symbol)
    current_line.push(@core.StyledGrapheme::of(symbol, grapheme.style))
  }
  self.current_line = current_line
  Some(WrappedLine::of(self.current_line, current_line_width, alignment))
}

///|
/// WrappedLine 构造（包私有）喵。
fn WrappedLine::of(
  graphemes : Array[@core.StyledGrapheme],
  width : Int,
  alignment : @core.Alignment,
) -> WrappedLine {
  { graphemes, width, alignment }
}

///|
/// 从字符串头部按整字形裁掉不超过 offset 宽度的前缀
/// （上游 `trim_offset`，包私有）喵。
fn trim_offset(src : String, offset : Int) -> String {
  let mut remaining = offset
  let out = StringBuilder()
  let mut trimming = true
  for ch in src {
    if trimming {
      let width = @core.char_display_width(ch)
      if width <= remaining {
        remaining -= width
        continue
      }
      trimming = false
    }
    out.write_char(ch)
  }
  out.to_string()
}
