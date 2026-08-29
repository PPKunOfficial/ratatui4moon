// 线段 Shape 与 Cohen–Sutherland 裁剪（上游 `canvas/line.rs` +
// line-clipping 0.3.7 crate 的纯 MoonBit 移植）喵。
//
// 裁剪器对位上游锁定的 line-clipping 0.3.7 `cohen_sutherland::clip_line`：
// 区域码 LEFT/RIGHT/BOTTOM/TOP 与求交顺序逐行同构，端点恰在窗口边界
// 视为窗口内喵。

///|
/// 区域码：左/右/下/上（上游 `Region` bitflags）喵。
const CLIP_LEFT : Int = 0b0001

///|
const CLIP_RIGHT : Int = 0b0010

///|
const CLIP_BOTTOM : Int = 0b0100

///|
const CLIP_TOP : Int = 0b1000

///|
/// 点的区域码（上游 `Region::from_point`）：恰在边界上视为窗口内喵。
fn clip_region_code(
  x : Double,
  y : Double,
  x_min : Double,
  x_max : Double,
  y_min : Double,
  y_max : Double,
) -> Int {
  let mut code = 0
  if x < x_min {
    code = code.lor(CLIP_LEFT)
  } else if x > x_max {
    code = code.lor(CLIP_RIGHT)
  }
  if y < y_min {
    code = code.lor(CLIP_BOTTOM)
  } else if y > y_max {
    code = code.lor(CLIP_TOP)
  }
  code
}

///|
/// 求线段与区域码所标识边界的交点（上游 `calculate_intersection`）：
/// 求交次序 LEFT → RIGHT → BOTTOM → TOP 与上游一致喵。
fn clip_intersection(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  code : Int,
  x_min : Double,
  x_max : Double,
  y_min : Double,
  y_max : Double,
) -> (Double, Double) {
  let dx = x2 - x1
  let dy = y2 - y1
  if code.land(CLIP_LEFT) != 0 {
    return (x_min, y1 + (x_min - x1) * dy / dx)
  }
  if code.land(CLIP_RIGHT) != 0 {
    return (x_max, y1 + (x_max - x1) * dy / dx)
  }
  if code.land(CLIP_BOTTOM) != 0 {
    return (x1 + (y_min - y1) * dx / dy, y_min)
  }
  (x1 + (y_max - y1) * dx / dy, y_max)
}

///|
/// Cohen–Sutherland 线段裁剪（上游 `cohen_sutherland::clip_line`）：
/// 完全在外落 None，其余返回裁剪后的端点对喵。
fn clip_line(
  x_min : Double,
  x_max : Double,
  y_min : Double,
  y_max : Double,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
) -> ((Double, Double), (Double, Double))? {
  let mut px1 = x1
  let mut py1 = y1
  let mut px2 = x2
  let mut py2 = y2
  let mut code1 = clip_region_code(px1, py1, x_min, x_max, y_min, y_max)
  let mut code2 = clip_region_code(px2, py2, x_min, x_max, y_min, y_max)
  while true {
    if code1.land(code2) != 0 {
      return None
    } else if code1 != 0 {
      let (nx, ny) = clip_intersection(
        px1, py1, px2, py2, code1, x_min, x_max, y_min, y_max,
      )
      px1 = nx
      py1 = ny
      code1 = clip_region_code(px1, py1, x_min, x_max, y_min, y_max)
    } else if code2 != 0 {
      let (nx, ny) = clip_intersection(
        px2, py2, px1, py1, code2, x_min, x_max, y_min, y_max,
      )
      px2 = nx
      py2 = ny
      code2 = clip_region_code(px2, py2, x_min, x_max, y_min, y_max)
    } else {
      return Some(((px1, py1), (px2, py2)))
    }
  } nobreak {
    None
  }
  // 区域码单调收敛，恒经 return 退出；此分支不可达喵。
}

///|
/// 把 Double 值钳制到 [lo, hi]（上游 `f64::clamp`）喵。
fn clamp_double(v : Double, lo : Double, hi : Double) -> Double {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
/// 线段（上游 `canvas::Line`）：世界坐标两成点 + 颜色喵。
pub(all) struct CanvasLine {
  x1 : Double
  y1 : Double
  x2 : Double
  y2 : Double
  color : @core.Color
} derive(Eq, Debug)

///|
/// 新建线段（上游 `Line::new`）喵。
pub fn CanvasLine::new(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  color : @core.Color,
) -> CanvasLine {
  { x1, y1, x2, y2, color }
}

///|
/// Shape 实现：裁剪到画布边界后走 Bresenham（上游 `impl Shape for Line`）喵。
pub impl Shape for CanvasLine with fn draw(self, painter) {
  let (x_bounds, y_bounds) = painter.bounds()
  match
    clip_line(
      x_bounds.0,
      x_bounds.1,
      y_bounds.0,
      y_bounds.1,
      self.x1,
      self.y1,
      self.x2,
      self.y2,
    ) {
    Some(((wx1, wy1), (wx2, wy2))) =>
      match painter.get_point(wx1, wy1) {
        Some((x1, y1)) =>
          match painter.get_point(wx2, wy2) {
            Some((x2, y2)) => {
              let color = self.color
              canvas_for_each_line_point(x1, y1, x2, y2, (x, y) => {
                painter.paint(x, y, color)
              })
            }
            None => ()
          }
        None => ()
      }
    None => ()
  }
}

///|
/// Bresenham 直线逐点回调（上游 `for_each_line_point`）：横/竖/低/
/// 高四路分派，端点含两端喵。
fn canvas_for_each_line_point(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  f : (Int, Int) -> Unit,
) -> Unit {
  let dx = (x2 - x1).abs()
  let dy = (y2 - y1).abs()
  if dx == 0 {
    for y in y1.min(y2)..<=y1.max(y2) {
      f(x1, y)
    }
  } else if dy == 0 {
    for x in x1.min(x2)..<=x1.max(x2) {
      f(x, y1)
    }
  } else if dy < dx {
    if x1 > x2 {
      line_point_low(x2, y2, x1, y1, f)
    } else {
      line_point_low(x1, y1, x2, y2, f)
    }
  } else if y1 > y2 {
    line_point_high(x2, y2, x1, y1, f)
  } else {
    line_point_high(x1, y1, x2, y2, f)
  }
}

///|
/// 低斜率路径（上游 `for_each_line_point_low`）喵。
fn line_point_low(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  f : (Int, Int) -> Unit,
) -> Unit {
  let dx = x2 - x1
  let dy = (y2 - y1).abs()
  let mut d = 2 * dy - dx
  let mut y = y1
  for x in x1..<=x2 {
    f(x, y)
    if d > 0 {
      y = if y1 > y2 { y - 1 } else { y + 1 }
      d -= 2 * dx
    }
    d += 2 * dy
  }
}

///|
/// 高斜率路径（上游 `for_each_line_point_high`）喵。
fn line_point_high(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  f : (Int, Int) -> Unit,
) -> Unit {
  let dx = (x2 - x1).abs()
  let dy = y2 - y1
  let mut d = 2 * dx - dy
  let mut x = x1
  for y in y1..<=y2 {
    f(x, y)
    if d > 0 {
      x = if x1 > x2 { x - 1 } else { x + 1 }
      d -= 2 * dy
    }
    d += 2 * dx
  }
}

///|
/// 填充线段（上游 `canvas::FilledLine`）：线到 `fill_to_y` 之间的
/// 区域一并涂色，用于面积图喵。
pub(all) struct FilledCanvasLine {
  x1 : Double
  y1 : Double
  x2 : Double
  y2 : Double
  fill_to_y : Double
  color : @core.Color
} derive(Eq, Debug)

///|
/// 新建填充线段（上游 `FilledLine::new`）喵。
pub fn FilledCanvasLine::new(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  fill_to_y : Double,
  color : @core.Color,
) -> FilledCanvasLine {
  { x1, y1, x2, y2, fill_to_y, color }
}

///|
/// Shape 实现：线体逐点向下/上填到 fill 行（上游 `impl Shape for FilledLine`）喵。
pub impl Shape for FilledCanvasLine with fn draw(self, painter) {
  let (x_bounds, y_bounds) = painter.bounds()
  match
    clip_line(
      x_bounds.0,
      x_bounds.1,
      y_bounds.0,
      y_bounds.1,
      self.x1,
      self.y1,
      self.x2,
      self.y2,
    ) {
    Some(((wx1, wy1), (wx2, wy2))) =>
      match painter.get_point(wx1, wy1) {
        Some((x1, y1)) =>
          match painter.get_point(wx2, wy2) {
            Some((x2, y2)) => {
              let y_fill_world = clamp_double(
                self.fill_to_y,
                y_bounds.0,
                y_bounds.1,
              )
              match painter.get_point(wx1, y_fill_world) {
                Some((_, y_fill)) =>
                  canvas_for_each_line_point(x1, y1, x2, y2, (x, y) => {
                    let start = y.min(y_fill)
                    let end = y.max(y_fill)
                    for yy in start..<=end {
                      painter.paint(x, yy, self.color)
                    }
                  })
                None => ()
              }
            }
            None => ()
          }
        None => ()
      }
    None => ()
  }
}
