///|
/// 约束强度（上游 `Strength`）喵。
///
/// 强度是实数，越大越优先满足；REQUIRED 为不可违约束喵。

///|
pub(all) struct Strength {
  val : Double
} derive(Eq, Debug)

///|
/// 强度为 REQUIRED 的约束不可违，否则求解失败喵。
pub fn Strength::required() -> Strength {
  { val: 1001001000.0 }
}

///|
pub fn Strength::strong() -> Strength {
  { val: 1000000.0 }
}

///|
pub fn Strength::medium() -> Strength {
  { val: 1000.0 }
}

///|
pub fn Strength::weak() -> Strength {
  { val: 1.0 }
}

///|
pub fn Strength::zero() -> Strength {
  { val: 0.0 }
}

///|
/// 以数值构造强度，裁剪到 [0, REQUIRED] 区间（上游 `Strength::new`）喵。
pub fn Strength::of_value(v : Double) -> Strength {
  Strength::clip(v)
}

///|
/// 以 STRONG/MEDIUM/WEAK 三层权重组合构造强度（上游 `Strength::create`）喵。
pub fn Strength::create(
  strong : Double,
  medium : Double,
  weak : Double,
  multiplier : Double,
) -> Strength {
  let strong_part = (strong * multiplier).max(0.0).min(1000.0) * 1000000.0
  let medium_part = (medium * multiplier).max(0.0).min(1000.0) * 1000.0
  let weak_part = (weak * multiplier).max(0.0).min(1000.0)
  Strength::clip(strong_part + medium_part + weak_part)
}

///|
/// 强度裁剪到合法区间（上游 `strength::clip`）喵。
pub fn Strength::clip(s : Double) -> Strength {
  let hi = s.min(1001001000.0)
  if hi < 0.0 {
    { val: 0.0 }
  } else {
    { val: hi }
  }
}

///|
pub fn Strength::value(self : Strength) -> Double {
  self.val
}

///|
pub fn Strength::add(self : Strength, other : Strength) -> Strength {
  Strength::clip(self.val + other.val)
}

///|
pub fn Strength::sub(self : Strength, other : Strength) -> Strength {
  Strength::clip(self.val - other.val)
}

///|
pub fn Strength::mul_float(self : Strength, rhs : Double) -> Strength {
  Strength::clip(self.val * rhs)
}

///|
pub fn Strength::div_float(self : Strength, rhs : Double) -> Strength {
  Strength::clip(self.val / rhs)
}

///|
/// 强度比较：按 val 实数序喵。
pub fn Strength::compare(self : Strength, other : Strength) -> Int {
  if self.val < other.val {
    -1
  } else if self.val > other.val {
    1
  } else {
    0
  }
}

///|
pub fn Strength::lt(self : Strength, other : Strength) -> Bool {
  self.val < other.val
}

///|
pub fn Strength::le(self : Strength, other : Strength) -> Bool {
  self.val <= other.val
}

///|
pub fn Strength::gt(self : Strength, other : Strength) -> Bool {
  self.val > other.val
}

///|
pub fn Strength::ge(self : Strength, other : Strength) -> Bool {
  self.val >= other.val
}

///|
pub fn Strength::equal(self : Strength, other : Strength) -> Bool {
  self.val == other.val
}
