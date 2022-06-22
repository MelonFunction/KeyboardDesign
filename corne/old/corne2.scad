module mount_holes(){                   import("./master.dxf", layer="mount_holes");}
module mount_holes_standoffs(){         import("./master.dxf", layer="mount_holes_standoffs");}
module switch_holes(){                  import("./master.dxf", layer="switch_holes");}
module pcb_footprint(){                 import("./master.dxf", layer="pcb_footprint");}
module pcb_footprint_sharp(){           import("./master.dxf", layer="pcb_footprint_sharp");}
module pcb_footprint_offset_notched(){  import("./master.dxf", layer="pcb_footprint_offset_notched");}
module pcb_footprint_offset(){          import("./master.dxf", layer="pcb_footprint_offset");}
module mcu_hole(){                      import("./master.dxf", layer="mcu_hole_offset");}
module mcu_cover(){                     import("./master.dxf", layer="mcu_cover");}
module screw_holes(){                   import("./master.dxf", layer="screw_holes");}
module screw_head_holes(){              import("./master.dxf", layer="screw_head_holes");}
module thumb_edge(){                    import("./master.dxf", layer="thumb_edge");}
module thumb_cutout(){                  import("./master.dxf", layer="thumb_cutout");}
module bevel_high(){                    import("./master.dxf", layer="bevel_high");}
module bevel_low(){                     import("./master.dxf", layer="bevel_low");}
module bevel_join(){                    import("./master.dxf", layer="bevel_join");}
module thumb_join(){                    import("./master.dxf", layer="thumb_join");}

$fn = 20;

plate_thickness = 3;
top_case_cutout_height = 8;
bottom_case_cutout_height = 8;

pcb_footprint_offset_width = 136.48581;
pcb_footprint_offset_height = 94.45307;

module profile(){
    module bevel(){
        union(){
            rotate_extrude()
                bevel_high();
        }
    }

    union(){
        // top bevel
        translate([0,0,top_case_cutout_height-0.0001])
            bevel();
        // middle
        translate([0,0,-bottom_case_cutout_height])
            linear_extrude(top_case_cutout_height+bottom_case_cutout_height)
            projection(){
                bevel();
            }
        // bottom bevel
        translate([0,0,-bottom_case_cutout_height+0.0001])
        rotate([180,0,0])
            bevel();
    }
};

module body(){
    difference(){
        minkowski(){
            profile();
            linear_extrude(0.0001)
                pcb_footprint_sharp();
        }
        translate([0,0,-500])
        linear_extrude(1000)
            thumb_cutout();
    }
}


module plate(){
    linear_extrude(plate_thickness)
        difference(){
            difference(){
                pcb_footprint_offset_notched();
                switch_holes();
            }
            mcu_hole();
        }
}


module below_plate_cavity(){
    linear_extrude(plate_thickness)
        pcb_footprint_sharp();
}



// plate();
// translate([0,0,-10])
//     below_plate_cavity();

body();