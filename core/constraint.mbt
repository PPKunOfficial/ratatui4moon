///|
/// 布局约束（上游 `layout::Constraint`）喵。
///
/// 描述布局切分时某一段的目标尺寸语义：`Min`/`Max` 是下/上界，
/// `Length`/`Percentage`/`Ratio` 是定值/比例目标，`Fill` 按权重
/// 分摊剩余空间。数值域以 Int 承装（上游 u16/u32；u32::MAX 级
/// 极端用例按 Int 域折算）喵。
pub(all) enum Constraint {
  Min(Int)
  Max(Int)
  Length(Int)
  Percentage(Int)
  Ratio(Int, Int)
  Fill(Int)
} derive(Eq, Debug)

///|
/// 缺省约束为 100%（上游 `Constraint::default`）喵。
pub fn Constraint::default() -> Constraint {
  Percentage(100)
}

///|
/// Display 语义（上游 strum Display：`Percentage(50)`/`Ratio(1, 2)`）喵。
pub fn Constraint::to_display(self : Constraint) -> String {
  match self {
    Min(v) => "Min(\{v})"
    Max(v) => "Max(\{v})"
    Length(v) => "Length(\{v})"
    Percentage(v) => "Percentage(\{v})"
    Ratio(n, d) => "Ratio(\{n}, \{d})"
    Fill(v) => "Fill(\{v})"
  }
}

///|
/// 把约束应用到给定长度上（上游 `Constraint::apply`）喵。
///
/// `Percentage`/`Ratio` 按上游使用 f32 算术（含舍入行为）；
/// `Ratio` 以分母取 `max(1)` 规避除零：`0/0 → 0`、`x/0 → 全长`；
/// 结果永不越过 `length`（`Min` 除外——它是下界，允许放宽）喵。
pub fn Constraint::apply(self : Constraint, length : Int) -> Int {
  match self {
    Percentage(p) => {
      let ratio = Float::from_int(p) / 100.0
      let scaled = (ratio * Float::from_int(length)).min(
        Float::from_int(length),
      )
      scaled.to_int()
    }
    Ratio(n, d) => {
      let denominator = if d > 1 { d } else { 1 }
      let ratio = Float::from_int(n) / Float::from_int(denominator)
      let scaled = (ratio * Float::from_int(length)).min(
        Float::from_int(length),
      )
      scaled.to_int()
    }
    Length(l) => if length < l { length } else { l }
    Fill(l) => if length < l { length } else { l }
    Max(m) => if length < m { length } else { m }
    Min(m) => if length > m { length } else { m }
  }
}

///|
/// 长度序列转约束序列（上游 `Constraint::from_lengths`）喵。
pub fn Constraint::from_lengths(lengths : Array[Int]) -> Array[Constraint] {
  let out : Array[Constraint] = []
  for l in lengths {
    out.push(Length(l))
  }
  out
}

///|
/// 比率序列转约束序列（上游 `Constraint::from_ratios`）喵。
pub fn Constraint::from_ratios(ratios : Array[(Int, Int)]) -> Array[Constraint] {
  let out : Array[Constraint] = []
  for ratio in ratios {
    out.push(Ratio(ratio.0, ratio.1))
  }
  out
}

///|
/// 百分比序列转约束序列（上游 `Constraint::from_percentages`）喵。
pub fn Constraint::from_percentages(
  percentages : Array[Int],
) -> Array[Constraint] {
  let out : Array[Constraint] = []
  for p in percentages {
    out.push(Percentage(p))
  }
  out
}

///|
/// 上界序列转约束序列（上游 `Constraint::from_maxes`）喵。
pub fn Constraint::from_maxes(maxes : Array[Int]) -> Array[Constraint] {
  let out : Array[Constraint] = []
  for m in maxes {
    out.push(Max(m))
  }
  out
}

///|
/// 下界序列转约束序列（上游 `Constraint::from_mins`）喵。
pub fn Constraint::from_mins(mins : Array[Int]) -> Array[Constraint] {
  let out : Array[Constraint] = []
  for m in mins {
    out.push(Min(m))
  }
  out
}

///|
/// 权重序列转约束序列（上游 `Constraint::from_fills`）喵。
pub fn Constraint::from_fills(fills : Array[Int]) -> Array[Constraint] {
  let out : Array[Constraint] = []
  for f in fills {
    out.push(Fill(f))
  }
  out
}
