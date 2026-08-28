///|
/// 遮罩文本（上游 `text::Masked`）：保存原文、按遮罩字符呈现，
/// 用于密码/令牌等敏感输入的展示喵。
pub(all) struct Masked {
  inner : String
  mask_char : Char
} derive(Eq)

///|
/// 构造遮罩文本（上游 `Masked::new`）喵。
pub fn Masked::of(content : String, mask_char : Char) -> Masked {
  { inner: content, mask_char }
}

///|
/// 读遮罩字符（上游 `Masked::mask_char`）喵。
pub fn Masked::mask_char(self : Masked) -> Char {
  self.mask_char
}

///|
/// 读遮罩后的呈现文本（上游 `Masked::value`）喵。
pub fn Masked::value(self : Masked) -> String {
  let out = StringBuilder()
  for _ in self.inner {
    out.write_char(self.mask_char)
  }
  out.to_string()
}

///|
/// Debug 语义（上游手写 Debug：刻意呈现**原文**，便于调试）喵。
pub fn Masked::to_debug(self : Masked) -> String {
  self.inner
}

///|
/// Display 语义（上游 `impl Display for Masked`：呈现遮罩文本）喵。
pub fn Masked::to_display(self : Masked, limit? : Int) -> String {
  let value = self.value()
  match limit {
    Some(max) => {
      let out = StringBuilder()
      let mut count = 0
      for ch in value {
        if count >= max {
          break
        }
        out.write_char(ch)
        count += 1
      }
      out.to_string()
    }
    None => value
  }
}

///|
/// 转多行文本（上游 `From<Masked> for Text`）喵。
pub fn Masked::to_text(self : Masked) -> Text {
  Text::raw(self.value())
}
