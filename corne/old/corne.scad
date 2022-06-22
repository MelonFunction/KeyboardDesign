module mount_holes(){                   import("./master.dxf", layer="mount_holes");}
module mount_holes_standoffs(){         import("./master.dxf", layer="mount_holes_standoffs");}
module switch_holes(){                  import("./master.dxf", layer="switch_holes");}
module pcb_footprint_sharp(){           import("./master.dxf", layer="pcb_footprint_sharp");}
module pcb_footprint_offset_notched(){  import("./master.dxf", layer="pcb_footprint_offset_notched");}
module pcb_footprint_offset(){          import("./master.dxf", layer="pcb_footprint_offset", $fn=30);}
module mcu_hole(){                      import("./master.dxf", layer="mcu_hole_offset");}
module mcu_cover(){                      import("./master.dxf", layer="mcu_cover");}
module screw_holes(){                   import("./master.dxf", layer="screw_holes");}
module screw_head_holes(){              import("./master.dxf", layer="screw_head_holes");}
module thumb_edge(){                    import("./master.dxf", layer="thumb_edge");}
module thumb_cutout(){                  import("./master.dxf", layer="thumb_cutout");}
module bevel_high(){                    import("./master.dxf", layer="bevel_high");}
module bevel_low(){                     import("./master.dxf", layer="bevel_low");}
module bevel_join(){                    import("./master.dxf", layer="bevel_join");}
module thumb_join(){                    import("./master.dxf", layer="thumb_join");}

weight_thickness = 2; // can actually accommodate more than 2mm bc of spacers
weight_cutout_depth = 1.5;

plate_thickness = 3;
spacer_height = 7;   // metal pin height on sandwich style cases
spacer_support_height = 3;
spacer_support_wall_thickness = 1.5;

bevel_thickness = 8;
small_lip = 3;
big_lip = 10;

notched_lower_amount = 0;

// Manually change above lip height
above_plate_lip_height = 3; 

screw_cap_height = 3;
screw_thread_height = 8;

mcu_x_offset = 133.93;
mcu_y_offset = 84.57;
mcu_usb_center = 9.2; // subtract from mcu_x_offset
mcu_usb_width = 12;
mcu_trs_center = 48.6; // subtract from mcu_y_offset
mcu_trs_width = 12;

thumb_left_x_offset = 67.42299;
thumb_left_y_offset = 12.14371;
thumb_right_x_offset = 134.28646;
thumb_right_y_offset = 22.00477;
thumb_right_angle = 45;

switch_hole_offset = 0.0;

// Use this to test switch hole tolerances
*difference(){
    translate([0,66,0]) cube([19,19,plate_thickness]);
    translate([0,0,-0.01]) 
            linear_extrude(plate_thickness+0.1)
            offset(switch_hole_offset)
            switch_holes();
}

echo("TOTAL HEIGHT MM:", bevel_thickness+spacer_height+plate_thickness);
// translate([0,0,-bevel_thickness/2]) cube([5,5,bevel_thickness+spacer_height+plate_thickness]);

// $fn = 60;
// !union(){
//     difference(){
//         rotate_extrude()
//             bevel_high();
//         translate([0,-10,0]) cube([20,20,20]);
//     }
//     translate([0,0,0]) rotate_extrude()
//         bevel_join();
//     translate([10,0,0]) rotate_extrude()
//         bevel_low();
// }


// testing stuff
*minkowski(){
    $fn = 60;

    union(){
        difference(){
            union(){
                    // top
                    rotate_extrude()
                        bevel_high();
                    // bottom
                    rotate([180,0,0])
                        rotate_extrude()
                        bevel_high();
            }
            translate([0,-50,-50]) 
                cube([100,100,100]);
        }
    }

    difference(){
        cube([100,100,100]);

        union(){
            translate([0,0,150])
                rotate([0,45,0])
                cube([100,100,100]);    
        }
        translate([71-0.3,0,80-0.7])
            rotate([0,0,0])
            cube([100,100,100]);
    }
}

*difference(){
    minkowski(){
        rotate([180,0,0])
            rotate_extrude()
            bevel_high();
        linear_extrude(spacer_height+plate_thickness+above_plate_lip_height+2)
            thumb_cutout();
    }
    translate([0,0,10])
        minkowski(){
            rotate([180,0,0])
                rotate_extrude()
                bevel_high();
            linear_extrude(spacer_height+plate_thickness+above_plate_lip_height+2)
                offset(-10)
                thumb_cutout();
        }
}


module body(){
        module main_body(rot){
            minkowski(){
                difference(){
                    union(){
                        // top
                        rotate_extrude()
                            bevel_high();
                        // bottom
                        rotate([180,0,0])
                            rotate_extrude()
                            bevel_high();
                    }

                    // yeah, gcal freaks out and this seems to fix it
                    rotate([0,0,rot ? 180+60+0.001 : 0])
                    translate([0,-50,-50])
                        cube([100,100,100]);
                }

                difference(){
                    difference(){
                        linear_extrude(spacer_height+plate_thickness+above_plate_lip_height+0.001) 
                            pcb_footprint_sharp();
                        // cut away thumb area
                        *translate([0,0,-1])
                            linear_extrude(spacer_height+plate_thickness+above_plate_lip_height+2)
                            thumb_cutout();
                        
                        // cut away a bit of the main body so that a nice transition can happen
                        minkowski(){
                            cylinder(4, 0,10);

                            translate([0,0,spacer_height+plate_thickness])
                                linear_extrude(spacer_height+plate_thickness+above_plate_lip_height+2)
                                offset(-10)
                                thumb_cutout();
                        }
                    }

                    translate([100,0,-5])
                        rotate([0,0,20])
                        translate([rot ? -200 : 0,-50,0])
                        cube([200,200,200]);
                }
            }
        }

    difference(){
        union(){
                // left
                main_body(false);
                // right
                main_body(true);
        }

        // // Thumb cluster bevel cutout
        // #translate([66.66+4.6, 13.61, 10+spacer_height+plate_thickness-1]) // for wide cylinder
        *translate([66.66+4.6, 13.61, spacer_height+plate_thickness+3])  // for square
            rotate([90, 0, 36])
            translate([-4.6,0,-3]) // no idea what this was
            linear_extrude(100)
            // hull(){
            //     translate([50, 0, 0]) circle(d=10);
            //     circle(d=10);
            // }
            square([60,10]);

        *translate([0,0,spacer_height+plate_thickness*2])
                    linear_extrude(spacer_height+plate_thickness)
                    thumb_cutout();
    }
    
    

    *minkowski(){
        union(){
            // top
            // cylinder(bevel_thickness/4, big_lip, small_lip);
            // bottom
            
            translate([0,0,-bevel_thickness/2]) cylinder(bevel_thickness/2, small_lip, big_lip);
        }
        intersection(){
            translate([66.66, -70, -25])
                cube([100,100,50]);
            linear_extrude(spacer_height+plate_thickness+above_plate_lip_height+0.001) 
                pcb_footprint_sharp();
        }
    }

    // Thumb cluster bevel
    minkowski(){
        union(){
            // top
            rotate_extrude()
                bevel_low();
            // cylinder(bevel_thickness/4, big_lip, small_lip);
            // bottom
            rotate([180,0,0])
                    rotate_extrude()
                    bevel_high();
            // translate([0,0,-bevel_thickness/2]) cylinder(bevel_thickness/2, small_lip, big_lip);
        }
        linear_extrude(spacer_height+plate_thickness+above_plate_lip_height+0.001)
            thumb_edge();
    }

    // // Thumb cluster bevel smoothing/ramps
    //     translate([thumb_left_x_offset+14,thumb_left_y_offset+1.4, spacer_height+plate_thickness*2-2.5])
    //         rotate([90, 0, -90])
    //         rotate([-10,0,0])
    //         linear_extrude(15)
    //         bevel_high();
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
        // Solo mode here to export the weight plate (ctrl+f projection, slice)
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
        translate([0,0,-bevel_thickness/2+spacer_height+plate_thickness-0.01]) 
            linear_extrude(plate_thickness+0.1)
            offset(switch_hole_offset)
            switch_holes();
        // MCU plate hole
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
            cable_cutout(mcu_usb_width+1, spacer_height+plate_thickness*2-1-1, big_lip*2);
        // MCU TRS hole
        translate([mcu_x_offset, mcu_y_offset-mcu_trs_center-mcu_trs_width/2+0.01, 0.5]) 
            rotate([90,0,90])
            cable_cutout(mcu_usb_width-1, spacer_height+plate_thickness);

        // translate([thumb_left_x_offset-0.3, thumb_left_y_offset-1.63-5, spacer_height+plate_thickness*2+4])
        //     rotate([0,18.525,0])
        //     cube([7.865,10,30]);
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

    // integrate the oled cover
    // it should probably have its own thickness value but using plate_thickness
    // since it's 3mm seems fine
    translate([0,0,bevel_thickness+plate_thickness*2]) 
        linear_extrude(plate_thickness)
        mcu_cover();

}

module block(){
    translate([-20,-15,spacer_height-1.01]) cube([200, 120, 100]);
}

module preview(){
    difference(){
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
preview_mode = true;
// if (preview_mode == true){
//     $fn = 30;

//     if (should_mirror == true) {
//         translate([-150,0,0]) preview();
//         translate([150,0,0]) mirror([1,0,0]) preview();
//     } else {
//         difference(){
//             preview();
//             translate([90,-200,-50]) cube([400, 400, 100]);
//         }
//     }
// } else {
//     $fn = 10;

//     difference(){
//         union(){
//             // Bottom left
//             translate([-150,0,0]) color("#999999") translate([0,0,bevel_thickness/2]) union(){
//                 difference(){
//                     main();
//                     block();
//                 }
                
//                 standoffs();
//             }

//             // Bottom right
//             translate([150,0,0]) mirror([1,0,0]) color("#999999") translate([0,0,bevel_thickness/2]) union(){
//                 difference(){
//                     main();
//                     block();
//                 }
                
//                 standoffs();
//             }

//             // Top left
//             // No idea why it's off by 1
//             translate([-150,0,0]) color("#444444") translate([130,0,-spacer_height+1]) rotate([0,0,180]) intersection(){
//                 main();
//                 block();
//             }

//             // Top right
//             translate([150,0,0]) mirror([1,0,0]) color("#444444") translate([130,0,-spacer_height+1]) rotate([0,0,180]) intersection(){
//                 main();
//                 block();
//             }
//         }
//     }
// }

pcb_footprint_offset();