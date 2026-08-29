///|
/// strength_test.mbt：复刻上游 `strength.rs` 单测喵。

///|
test "Strength new 裁剪" {
  let cases : Array[(Double, Double)] = [
    (-1.0, 0.0),
    (0.0, 0.0),
    (1.0, 1.0),
    (1000.0, 1000.0),
    (1000000.0, 1000000.0),
    (1001001000.0, 1001001000.0),
    (1001001001.0, 1001001000.0), // 超限裁剪到 REQUIRED
  ]
  for c in cases {
    let (input, expected) = c
    let s = Strength::of_value(input)
    let diff = if s.value() > expected {
      s.value() - expected
    } else {
      expected - s.value()
    }
    @debug.assert_eq(diff < 0.001, true)
  }
}

///|
test "Strength create" {
  // 复刻上游 create 的 rstest cases
  let s = Strength::create(0.0, 0.0, 0.0, 1.0)
  @debug.assert_eq(s == Strength::zero(), true)
  let s = Strength::create(0.0, 0.0, 1.0, 1.0)
  @debug.assert_eq(s == Strength::weak(), true)
  let s = Strength::create(0.0, 1.0, 0.0, 1.0)
  @debug.assert_eq(s == Strength::medium(), true)
  let s = Strength::create(1.0, 0.0, 0.0, 1.0)
  @debug.assert_eq(s == Strength::strong(), true)
  // clip cases：weak_clip 1000*2 -> medium
  let s = Strength::create(0.0, 0.0, 1000.0, 2.0)
  @debug.assert_eq(s == Strength::medium(), true)
  let s = Strength::create(0.0, 1000.0, 0.0, 2.0)
  @debug.assert_eq(s == Strength::strong(), true)
  // max
  let s = Strength::create(1000.0, 1000.0, 1000.0, 1.0)
  @debug.assert_eq(s == Strength::required(), true)
}

///|
test "Strength add sub mul" {
  let weak = Strength::weak()
  let medium = Strength::medium()
  let strong = Strength::strong()
  let req = Strength::required()
  let zero = Strength::zero()
  // add
  @debug.assert_eq(zero.add(zero) == zero, true)
  @debug.assert_eq(weak.add(weak).value(), 2.0)
  @debug.assert_eq(strong.add(req) == req, true) // saturate
  // sub
  @debug.assert_eq(weak.sub(weak) == zero, true)
  @debug.assert_eq(medium.sub(weak).value(), 999.0)
  // mul
  @debug.assert_eq(weak.mul_float(2.0).value(), 2.0)
  @debug.assert_eq(medium.mul_float(0.5).value(), 500.0)
  @debug.assert_eq(weak.mul_float(-1.0) == zero, true) // negative clips to zero
}
