///|
/// 项：变量 × 系数（上游 `Term`）喵。

///|
pub(all) struct Term {
  variable : Variable
  coefficient : Double
} derive(Eq, Debug)

///|
/// 以变量与系数构造项（上游 `Term::new`）喵。
pub fn Term::new(variable : Variable, coefficient : Double) -> Term {
  { variable, coefficient }
}

///|
/// 以变量构造系数为 1 的项（上游 `Term::from_variable`）喵。
pub fn Term::of_variable(variable : Variable) -> Term {
  { variable, coefficient: 1.0 }
}

///|
/// 项数乘：系数相乘喵。
pub fn term_mul(term : Term, k : Double) -> Term {
  { variable: term.variable, coefficient: term.coefficient * k }
}

///|
/// 项数除喵。
pub fn term_div(term : Term, k : Double) -> Term {
  { variable: term.variable, coefficient: term.coefficient / k }
}

///|
/// 项取负喵。
pub fn term_neg(term : Term) -> Term {
  { variable: term.variable, coefficient: -term.coefficient }
}
