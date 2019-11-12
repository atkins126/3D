use <../lib/geometry.scad>
use <../lib/curves.scad>
use <../lib/mesh.scad>
use <../lib/mesh.solids.scad>

height = 70;
radius = 20;
step = 7;
ring_height = height - 2*step;
numsides = 5;
xwidth = 1;
ywidth = 1;
zwidth = 1;
twist = 720;

$fn = 50;

module rings (twist) {
  for (i = [0:step:ring_height]) {
    mesh_polyhedron(
      rotate_mesh(
        translate(
          make_polyhedron_mesh(radius * (height - i)/height, numsides, ywidth, zwidth),
          [0, 0, i]),
      twist * i/height)
    );
  }
}

module tent (twist) {
  b = translate(make_segment_line([0,0,0], [0,0,height]), [-xwidth/2, -ywidth/2, 0]);
  b1 = concat(b, 
                translate(b, [xwidth, 0, 0]),
                translate(b, [0, ywidth, 0]),
                translate(b, [xwidth, ywidth, 0]));
  for (pt = [0:1:numsides-1]) {
    v = point_on_unit_circle(360/numsides*pt) * (radius - xwidth/2);
    c = zshear_mesh(b1, [0, 0, height], [0, 0, 0], [0, 0, height], [v.x, v.y, 0]);
    mesh_polyhedron(twist_mesh(c, [[0,0,0], [0,0,height]], twist));
  }
}

//rings(twist);
tent(twist);
tent(-twist);
