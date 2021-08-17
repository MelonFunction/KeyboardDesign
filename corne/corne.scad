module mount_holes(){                   import("./master.dxf", layer="mount_holes");}
module mount_holes_standoffs(){         import("./master.dxf", layer="mount_holes_standoffs");}
module switch_holes(){                  import("./master.dxf", layer="switch_holes");}
module pcb_footprint(){                 import("./master.dxf", layer="pcb_footprint");}
module pcb_footprint_sharp(){           import("./master.dxf", layer="pcb_footprint_sharp");}
module pcb_footprint_offset_notched(){  import("./master.dxf", layer="pcb_footprint_offset_notched");}
module pcb_footprint_offset(){          import("./master.dxf", layer="pcb_footprint_offset");}
module mcu_hole(){                      import("./master.dxf", layer="mcu_hole_offset");}
module screw_holes(){                   import("./master.dxf", layer="screw_holes");}
module screw_head_holes(){              import("./master.dxf", layer="screw_head_holes");}

weight_thickness = 2; // can actually accommodate more than 2mm bc of spacers
weight_cutout_depth = 1;

plate_thickness = 3;
spacer_height = 7;   // metal pin height on sandwich style cases
spacer_support_height = 3;
spacer_support_wall_thickness = 1.83;

bevel_thickness = 8;
small_lip = 3;
big_lip = 10;

notched_lower_amount = 0;

// Manually change above lip height
above_plate_lip_height = 4; 

screw_cap_height = 3;
screw_thread_height = 8;

mcu_x_offset = 133.93;
mcu_y_offset = 84.57;
mcu_usb_center = 9.2; // subtract from mcu_x_offset
mcu_usb_width = 12;
mcu_trs_center = 48.6; // subtract from mcu_y_offset
mcu_trs_width = 12;

echo("TOTAL HEIGHT MM:", bevel_thickness+spacer_height+plate_thickness);
// translate([0,0,-bevel_thickness/2]) cube([5,5,bevel_thickness+spacer_height+plate_thickness]);

module body(){
    minkowski(){
        union(){
            cylinder(bevel_thickness/2, big_lip, small_lip);
            translate([0,0,-bevel_thickness/2]) cylinder(bevel_thickness/2, small_lip, big_lip);
        }

        linear_extrude(spacer_height+plate_thickness+above_plate_lip_height+0.001) 
            pcb_footprint_sharp();
    }
}

module pro_micro(){
    translate([mcu_x_offset-18, mcu_y_offset-33.3, spacer_height])
        cube([18, 33.3, 2]);
    translate([mcu_x_offset-18+9-4, mcu_y_offset-10+2, spacer_height-2])
        cube([8, 10, 2]);
}
// #pro_micro();

module cutout_weight(){
    translate([0,0,-bevel_thickness/2+plate_thickness - weight_cutout_depth])
        linear_extrude(weight_thickness)
        // Solo mode here to export the weight plate
        difference(){
            offset(-1)
                pcb_footprint_offset();
        
            offset(1)
                spacers2D();
        }
}

module cutouts(){
        module cable_cutout(width, height, extrude_amount=big_lip){
            linear_extrude(extrude_amount+0.1)
                minkowski(){
                    circle(d=2);
                    translate([1,1,0]) square([width-1, height-1]);
                }
        }

        union(){
            // Above plate
            translate([0,0,-bevel_thickness/2+plate_thickness*2+spacer_height+0.01])
                linear_extrude(above_plate_lip_height+bevel_thickness-plate_thickness+0.02)
                    pcb_footprint_offset_notched();
            // Below plate
            translate([0,0,-bevel_thickness/2+plate_thickness])
                linear_extrude(spacer_height)
                pcb_footprint_offset();
            // Metal weight pocket
            cutout_weight();
            // Switch holes
            translate([0,0,-bevel_thickness/2+spacer_height+plate_thickness-0.01]) linear_extrude(plate_thickness+0.1) switch_holes();
            // MCU plute hole
            translate([0,0,-bevel_thickness/2+spacer_height+plate_thickness-0.01]) linear_extrude(plate_thickness+0.1) mcu_hole();
            // Screws
            union(){
                // Cap
                translate([0,0,-bevel_thickness/2-0.1]) linear_extrude(bevel_thickness/2+screw_cap_height+0.1) screw_head_holes();
                translate([0,0,-bevel_thickness/2+bevel_thickness/2+screw_cap_height-0.01]) linear_extrude(screw_thread_height) screw_holes();
            }
            // MCU USB hole
            translate([mcu_x_offset-mcu_usb_center-mcu_usb_width/2-1, big_lip+mcu_y_offset+big_lip+0.01, 1-0.4]) 
                rotate([90,0,0])
                cable_cutout(mcu_usb_width+1, spacer_height+plate_thickness*2-1, big_lip*2);
            
            // MCU TRS hole
            translate([mcu_x_offset, mcu_y_offset-mcu_trs_center-mcu_trs_width/2+0.01, 0.5]) 
                rotate([90,0,90])
                cable_cutout(mcu_usb_width-1, spacer_height+plate_thickness);
        }

}

module spacers2D(){
    offset(r=spacer_support_wall_thickness)
        mount_holes_standoffs();
}

module standoffs(){
    union(){
        // Standoff/alignment pins
        translate([0,0,-bevel_thickness/2+plate_thickness])
            linear_extrude(spacer_height)
            mount_holes_standoffs();
        
        // Spacers (PCB sits on this)
        translate([0,0,-bevel_thickness/2+plate_thickness]) 
            linear_extrude(spacer_support_height)
            spacers2D();
    }

}

module main(){
    difference(){
        body();
        cutouts();
    }
}

module block(){
    translate([-20,-15,spacer_height-1.01]) cube([200, 120, 100]);
}

module preview(){
    color("#555555") difference(){
        union(){
            main();
            standoffs();
        }

        // Cut away front section to check thicknesses etc
        // translate([-200,-70,-50]) cube([400, 100, 100]);

        // Cut away top section
        // translate([-200,-50,spacer_height+plate_thickness+0.9]) cube([400, 200, 100]);
    }

    // Caps
    color("#333333") translate([0,0, spacer_height+plate_thickness-1+7.83]) minkowski(){
        linear_extrude(0.001)
            switch_holes();

        cylinder(7.6, 2, 0);
    }
}

should_mirror = false;
preview_mode = false;
if (preview_mode == true){
    $fn = 20;

    if (should_mirror == true) {
        translate([-150,0,0]) preview();
        translate([150,0,0]) mirror([1,0,0]) preview();
    } else {
        preview();
    }
} else {
    $fn = 80;

    difference(){
        union(){
            // Bottom left
            translate([-150,0,0]) color("#999999") translate([0,0,bevel_thickness/2]) union(){
                difference(){
                    main();
                    block();
                }
                
                standoffs();
            }

            // Bottom right
            translate([150,0,0]) mirror([1,0,0]) color("#999999") translate([0,0,bevel_thickness/2]) union(){
                difference(){
                    main();
                    block();
                }
                
                standoffs();
            }

            // Top left
            // No idea why it's off by 1
            translate([-150,0,0]) color("#444444") translate([130,0,-spacer_height+1]) rotate([0,0,180]) intersection(){
                main();
                block();
            }

            // Top right
            translate([150,0,0]) mirror([1,0,0]) color("#444444") translate([130,0,-spacer_height+1]) rotate([0,0,180]) intersection(){
                main();
                block();
            }
        }

        // translate([90,-200,-50]) cube([400, 400, 100]);
    }
}


// For exporting, replace the '*' with a '!' to solo them
*color("#999999") translate([0,0,bevel_thickness/2]) union(){
    difference(){
        main();
        block();
    }
    
    standoffs();
}

*color("#444444") translate([0,0,-spacer_height+1]) intersection(){
    main();
    block();
}