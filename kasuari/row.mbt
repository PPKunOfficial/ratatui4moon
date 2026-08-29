///|
/// 单纯形行与符号（上游 `Row` / `Symbol`）喵。

///|
/// 符号类别（上游 `SymbolKind` / `SymbolType`）喵。
pub(all) enum SymbolType {
  Invalid
  External
  Slack
  Error
  Dummy
} derive(Eq, Hash, Debug)

///|
/// 单纯形符号（上游 `Symbol`）：id 单调递增喵。
pub(all) struct Symbol {
  id : Int
  typ : SymbolType
} derive(Eq, Hash, Debug)

///|
pub let symbol_invalid : Symbol = { id: 0, typ: Invalid }

///|
pub fn Symbol::is_invalid(self : Symbol) -> Bool {
  self.typ is Invalid
}

///|
pub fn Symbol::is_external(self : Symbol) -> Bool {
  self.typ is External
}

///|
/// 近零判定（上游 `near_zero`，ε = 1e-8）喵。
let near_zero_eps : Double = 0.00000001

///|
pub fn near_zero(value : Double) -> Bool {
  if value < 0.0 {
    -value < near_zero_eps
  } else {
    value < near_zero_eps
  }
}

///|
/// 单纯形表行：Σ 系数×符号 + 常数（上游 `Row`）喵。
pub(all) struct Row {
  cells : Map[Symbol, Double]
  mut constant : Double
}

///|
pub fn Row::make(constant : Double) -> Row {
  { cells: Map([]), constant }
}

///|
/// 克隆行（上游 `row.clone()`）喵。
pub fn Row::clone_row(self : Row) -> Row {
  let copy = Row::make(self.constant)
  for k, v in self.cells {
    copy.cells.set(k, v)
  }
  copy
}

///|
/// 按 id 升序的单元格快照（决定性遍历基）喵。
pub fn Row::sorted_cells(self : Row) -> Array[(Symbol, Double)] {
  let out : Array[(Symbol, Double)] = []
  for k, v in self.cells {
    out.push((k, v))
  }
  out.sort_by(fn(a, b) { a.0.id - b.0.id })
  out
}

///|
/// 写入符号系数：合并同类项，归零即删（上游 `insert_symbol`）喵。
pub fn Row::insert_symbol(self : Row, s : Symbol, coefficient : Double) -> Unit {
  match self.cells.get(s) {
    Some(existing) => {
      let merged = existing + coefficient
      if near_zero(merged) {
        self.cells.remove(s)
      } else {
        self.cells.set(s, merged)
      }
    }
    None => if !near_zero(coefficient) { self.cells.set(s, coefficient) }
  }
}

///|
/// 常数累加（上游 `Row::add`，用于 suggest_value 增量）喵。
pub fn Row::add(self : Row, delta : Double) -> Double {
  self.constant += delta
  self.constant
}

///|
/// 以系数并入另一行（上游 `insert_row`）；返回常数是否变化喵。
pub fn Row::insert_row(self : Row, other : Row, coefficient : Double) -> Bool {
  let constant_diff = other.constant * coefficient
  self.constant += constant_diff
  for pair in other.sorted_cells() {
    self.insert_symbol(pair.0, pair.1 * coefficient)
  }
  constant_diff != 0.0
}

///|
/// 移除符号（上游 `Row::remove`）喵。
pub fn Row::drop_symbol(self : Row, s : Symbol) -> Unit {
  self.cells.remove(s)
}

///|
/// 整行取负（上游 `reverse_sign`）喵。
pub fn Row::reverse_sign(self : Row) -> Unit {
  self.constant = -self.constant
  let keys : Array[Symbol] = []
  for k, _v in self.cells {
    keys.push(k)
  }
  for k in keys {
    match self.cells.get(k) {
      Some(v) => self.cells.set(k, -v)
      None => ()
    }
  }
}

///|
/// 解出符号并主元化（上游 `solve_for_symbol`；符号不在行内属
/// 程序员错误，`guard!` 断言）喵。
pub fn Row::solve_for_symbol(self : Row, s : Symbol) -> Unit {
  let coeff = match self.cells.get(s) {
    Some(c) => {
      self.cells.remove(s)
      (-1.0 : Double) / c
    }
    None => 0.0
  }
  guard! coeff != 0.0
  self.constant *= coeff
  let keys : Array[Symbol] = []
  for k, _v in self.cells {
    keys.push(k)
  }
  for k in keys {
    match self.cells.get(k) {
      Some(v) => self.cells.set(k, v * coeff)
      None => ()
    }
  }
}

///|
/// 双符号主元化（上游 `solve_for_symbols`）喵。
pub fn Row::solve_for_symbols(self : Row, lhs : Symbol, rhs : Symbol) -> Unit {
  self.insert_symbol(lhs, -1.0)
  self.solve_for_symbol(rhs)
}

///|
/// 读符号系数（上游 `coefficient_for`）喵。
pub fn Row::coefficient_for(self : Row, s : Symbol) -> Double {
  match self.cells.get(s) {
    Some(v) => v
    None => 0.0
  }
}

///|
/// 以给定行替换符号（上游 `substitute`）；返回常数是否变化喵。
pub fn Row::substitute(self : Row, s : Symbol, row : Row) -> Bool {
  match self.cells.get(s) {
    Some(coeff) => {
      self.cells.remove(s)
      self.insert_row(row, coeff)
    }
    None => false
  }
}

///|
/// 行是否全由 dummy 符号构成（上游 `all_dummies`）喵。
pub fn row_all_dummies(row : Row) -> Bool {
  for pair in row.sorted_cells() {
    if !(pair.0.typ is Dummy) {
      return false
    }
  }
  true
}
