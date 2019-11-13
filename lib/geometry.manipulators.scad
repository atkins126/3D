/* Functions for manipulating points (2D/3D) and lists of points.
*/

use <helpers.math.scad>
use <helpers.lists.scad>
use <geometry.scad>
use <curves.scad>

// Translates 2D/3D point or points by a specified offset.
// Offsetting a 2D point in 3 dimensions creates a 3D point.
// Offsetting a 3D point in 2 dimensions creates a 2D point.

function g_translate(offset, points) = 
  ! is_vector(points)
    ? [for (pt = points) g_translate(offset, pt)]
    : let (pt = points)
      is_undef(offset.z) ? [pt.x + offset.x, pt.y + offset.y] 
                         : [pt.x + offset.x, pt.y + offset.y, make_3D(pt).z + offset.z];
  
// echo(g_translate([1,1,1], [1,1])); // [2,2,1]
// echo(g_translate([1,1], [[1,1], [1,1,1]]));    // [2,2], [2,2]
// echo(g_translate([1,1,1], [[1,1], [1,1,1]]));  // [2,2,1], [2,2,2]
  
// Scales 2D/3D point or points relatively to an `origin`.
  
function g_scale(factor, origin = [0,0,0], points) = 
  ! is_vector(points)
    ? [for (pt = points) g_scale(factor, origin, pt)]
    : let (pt = points)
      (pt - origin) * factor + origin;
    
// echo(g_scale(2, [0,0,0], [1,1])); // [2,2]
// echo(g_scale(2, [1,1,0], [[1,1], [2,2,2]])); // [1,1], [3,3,4]

// Mirrors x => -x. Supports 2D and 3D points.

function g_mirrorX(points) = 
  [for (pt = points) 
     is_undef(pt.z) ? [-pt.x, pt.y] : [-pt.x, pt.y, pt.z]];

// Mirrors y => -y. Supports 2D and 3D points.

function g_mirrorY(points) = 
  [for (pt = points) 
     is_undef(pt.z) ? [pt.x, -pt.y] : [pt.x, -pt.y, pt.z]];

// Mirrors z => -z. Supports 3D points.

function g_mirrorZ(points) = 
  [for (pt = points) [pt.x, pt.y, -pt.z]];

// Rotates 2D/3D point or points around `origin` by `alpha` degrees along rotation axis `v`.

function g_rotate(angle, origin = [0, 0, 0], v = [0, 0, 1], points) = 
  ! is_vector(points)
    ? [for (pt = points) g_rotate(angle, origin, v, pt)]
    : let (pt = points,
            u = normalize(v),
            m = g_translate(-1 * origin, [pt]),
            c = cos(angle),
            s = sin(angle),
            R = [[c + u.x * u.x * (1 - c),         u.x * u.y * (1 - c) - u.z * s,  u.x * u.z * (1 - c) + u.y * s],
                [u.y * u.x * (1 - c) + u.z * s,   c + u.y * u.y * (1 - c),        u.y * u.z * (1 - c) + u.x * s],
                [u.z * u.x * (1 - c) + u.y * s,   u.z * u.y * (1 - c) + u.x * s,  c + u.z * u.z * (1 - c)]])
        g_translate(origin, R * m[0]);

//  echo(g_rotate(90, points = [1, 1, 1])); // [-1, 1, 1]
//  echo(g_rotate(90, [1, 0, 0], [0, 0, 1], [1, 1, 1])); // [0, 0, 1]

// Wraps 2D/3D point or points around the cylinder with radius r and axis [0, y, -r]. 

function g_wrap_around_cylinder(r, points) = 
  ! is_vector(points)
  ? [for (pt = points) g_wrap_around_cylinder(r, pt)]
  : let (pt = make_3D(points),
         alpha = 360 / (2 * PI * r) * pt.x)
    [(r + pt.z) * sin(alpha), pt.y, -r + (r+pt.z) * cos(alpha)];

// Linear shear points perpendicular to Z axis. `begin1/end1` segment is sheared to `begin2/end2` segment.
  
function g_zshear(begin1, end1, begin2, end2, points) = 
  ! is_vector(points)
  ? [for (pt = points) g_zshear(begin1, end1, begin2, end2, pt)]
  : let (dz1 = end1.z - begin1.z,
         dz2 = end2.z - begin2.z,
         pt = make_3D(points),
         t = (pt.z - begin1.z) / dz1,
         pt1 = interpolate(t, begin1, end1),
         pt2 = interpolate(t, begin2, end2))
    [pt2.x + (pt.x - pt1.x), pt2.y + (pt.y - pt1.y), pt.z];

// Twist mesh along a curve.

function g_twist(curve, angle, points) =
  ! is_vector(points)
  ? [for (pt = points) g_twist(curve, angle, pt)]
  : let (pt = points,
         full_len = curve_len(curve),
         find = curve_find_closest_point(curve, pt),
         pt_len = curve_partial_len(curve, find[1], find[0]))
    g_rotate(angle * pt_len/full_len, find[0], curve[find[1]+1] - curve[find[1]], pt);

// echo(g_twist([[0,0,0], [0,0,1]], 90, [[1,1,0], [1,1,1]])); // [1,1,0], [-1,1,0]
