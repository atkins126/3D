include <../../lib/helpers.math.scad>
use <../../lib/helpers.lists.scad>
use <../../lib/curves.scad>
use <../../lib/mesh.solids.scad>

dbottom = 0.4;
dtop = 2;
height = 13;
extra = 1;
delta = 0.1;
sizes = [[20, 15]];

$fn = 50;
$fa = 2;

module oval_2D (straight, radius) {
  polygon(
    concat(
      make_segment_arc([-straight/2,0], radius, 90, 270),
      make_segment_arc([straight/2, 0], radius, -90, 90))
  );
}

module oval_outline (straight, radius, offset) {
  difference () {
    offset(delta=offset)
    oval_2D (straight, radius);

    oval_2D (straight, radius);
  }
}

module oval (straight, radius) {
  steps = floor((dtop - dbottom) / delta);
  hd = height/steps;

  translate([0, 0, height])
  rotate(180, [1, 0, 0])
  union () {
    for (i = [0:1:steps-1]) {
      translate([0, 0, i*hd])
      linear_extrude(hd)
      oval_outline(straight, radius, dbottom + i * (dtop - dbottom) / (steps - 1));
    }
    
    translate([0, 0, -extra])
    linear_extrude(extra)
    oval_outline(straight, radius, dbottom);  
  }
 
 /* 
  t = straight/3;
  linear_extrude(2)
  union () {
    for (i = [-1:2:1], j = [-1:2:1]) 
      polygon([
        [i*-5*t/4 - 1, j*(radius + inf)], 
        [i*-5*t/4 + 1, j*(radius + inf)],
        [i*t/4 + 1, - j*(radius + inf)],
        [i*t/4 - 1, - j*(radius + inf)]
      ]);
  }
  */
}

for (xy = sizes) {
  oval(sizes[0].x - sizes[0].y, sizes[0].y/2);
}