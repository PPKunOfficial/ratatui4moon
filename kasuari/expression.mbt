///|
/// 线性表达式：Σ 系数×变量 + 常数（上游 `Expression`）喵。

///|
pub(all) struct Expression {
  terms : Array[Term]
  constant : Double
} derive(Eq, Debug)

///|
/// 以项序列与常数构造表达式（上游 `Expression::new`）喵。
pub fn Expression::new(terms : Array[Term], constant : Double) -> Expression {
  { terms, constant }
}

///|
/// 常数表达式（上游 `Expression::from_constant`）喵。
pub fn Expression::of_constant(v : Double) -> Expression {
  { terms: [], constant: v }
}

///|
/// 单项表达式（上游 `Expression::from_term`）喵。
pub fn Expression::of_term(term : Term) -> Expression {
  { terms: [term], constant: 0.0 }
}

///|
/// 单变量表达式 x（上游 `From<Variable>`）喵。
pub fn Expression::of_variable(v : Variable) -> Expression {
  Expression::of_term(Term::of_variable(v))
}

///|
/// 多项表达式（上游 `Expression::from_terms`）喵。
pub fn Expression::of_terms(terms : Array[Term]) -> Expression {
  { terms, constant: 0.0 }
}

///|
/// 表达式加法：a + b 喵。
pub fn expr_add(a : Expression, b : Expression) -> Expression {
  let terms : Array[Term] = []
  for t in a.terms {
    terms.push(t)
  }
  for t in b.terms {
    terms.push(t)
  }
  { terms, constant: a.constant + b.constant }
}

///|
/// 表达式减法：a − b 喵。
pub fn expr_sub(a : Expression, b : Expression) -> Expression {
  let terms : Array[Term] = []
  for t in a.terms {
    terms.push(t)
  }
  for t in b.terms {
    terms.push({ variable: t.variable, coefficient: -t.coefficient })
  }
  { terms, constant: a.constant - b.constant }
}

///|
/// 表达式与常数求和：a + c 喵。
pub fn expr_add_const(a : Expression, c : Double) -> Expression {
  { terms: a.terms, constant: a.constant + c }
}

///|
/// 表达式与常数求差：a − c 喵。
pub fn expr_sub_const(a : Expression, c : Double) -> Expression {
  { terms: a.terms, constant: a.constant - c }
}

///|
/// 表达式数乘：a × k 喵。
pub fn expr_mul(a : Expression, k : Double) -> Expression {
  {
    terms: a.terms.map(fn(t) {
      { variable: t.variable, coefficient: t.coefficient * k }
    }),
    constant: a.constant * k,
  }
}

///|
/// 表达式数除：a / k 喵。
pub fn expr_div(a : Expression, k : Double) -> Expression {
  expr_mul(a, 1.0 / k)
}

///|
/// 整体取负（上游 `Expression::negate`）喵。
pub fn Expression::negate(self : Expression) -> Expression {
  {
    terms: self.terms.map(fn(t) {
      { variable: t.variable, coefficient: -t.coefficient }
    }),
    constant: -self.constant,
  }
}

///|
/// 表达式等价：项序列与常数全等喵。
pub fn expression_equal(a : Expression, b : Expression) -> Bool {
  a == b
}
