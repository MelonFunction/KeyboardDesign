

width = 5;
difference(){
    cube([14+width*2,14+width*2,3]);
    translate([width, width, 0]) cube([14,14,3]);
}