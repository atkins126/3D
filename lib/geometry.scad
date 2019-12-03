/* Functions that implement calculations on points (2D/3D) and lists of points.
*/

use <helpers.lists.scad>
use <helpers.math.scad>
use <helpers.objects.scad>

// Calculates distance between two points.

function distance(pt1, pt2) =
  length(pt2 - pt1);
  
// Linear interpolation between two points.

function interpolate(t, pt1, pt2) = 
  (1 - t) * pt1 + t * pt2;

// Sets Z coordinate to 0 if it is not defined.

function make_3D(points) = 
  ! is_vector(points)
    ? [for (pt = points) make_3D(pt)]
    : is_undef(points.z) ? concat(points, 0) : points;
  
// echo(make_3D([1,1]));
// echo(make_3D([[1,1], [2,2,2]]));
    
// Removes Z coordinate.

function make_2D(points) = 
  ! is_vector(points)
    ? [for (pt = points) make_2D(pt)]
    : slice(points, [0:1]);
  
// Point on the unit circle on XY plane corresponding to `angle` (in degrees).
  
function point_on_unit_circle(angle) = [cos(angle), sin(angle)];

// Finds closest point on a segment.

function find_closest_point(from, to, pt) = 
  let(v = make_3D(to) - make_3D(from),
      u = make_3D(from) - make_3D(pt),
      vu = v*u,
      vv = v*v,
      t = -vu/vv)
  t >= 0 && t <= 1 
    ? interpolate(t, from, to)
    : let (dF = distance(pt, from),
           dT = distance(pt, to))
      dF < dT ? from : to;

// Bounding box.

function bb_create(p1, p2, p3, p4) = 
  // parameters: left, top, right, bottom
  //         or: [left bottom x, left bottom y], [right top x, right top y], undef, undef
  //         or: bb object, undef, undef, undef
  is_undef(p2)
    ? p1
    : is_undef(p3) && is_undef(p4)
        ? [p1.x, p2.y, p2.x, p1.y]
        : [p1, p2, p3, p4];

function bb_left(bb, __left) = __getset(bb, 0, __left);
function bb_top(bb, __top) = __getset(bb, 1, __top);
function bb_right(bb, __right) = __getset(bb, 2, __right);
function bb_bottom(bb, __bottom) = __getset(bb, 3, __bottom);

function bb_width(bb) = bb_right(bb) - bb_left(bb);

function bb_height(bb) = bb_top(bb) - bb_bottom(bb);

function bb_move_to(bb, left, top, right, bottom) =
  let(dx = is_undef(left) 
             ? is_undef(right)
                 ? undef
                 : right - bb_right(bb)
             : left - bb_left(bb),
      dy = is_undef(bottom)
             ? is_undef(top)
                 ? undef
                 : top - bb_top(bb)
             : bottom - bb_bottom(bb))
  bb_create(is_undef(dx) ? bb_left(bb) : bb_left(bb) + dx, 
            is_undef(dy) ? bb_top(bb) : bb_top(bb) + dy, 
            is_undef(dx) ? bb_right(bb) : bb_right(bb) + dx,
            is_undef(dy) ? bb_bottom(bb) : bb_bottom(bb) + dy);
