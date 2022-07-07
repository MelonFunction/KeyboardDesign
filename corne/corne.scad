include <cherry.scad>

module pcb(){               import("./master.dxf", layer="pcb");}
module base(){              import("./master.dxf", layer="base");}
module plate(){             import("./master.dxf", layer="plate");}
module plate_holes(){       import("./master.dxf", layer="plate_holes");}
module switch_holes(){      import("./master.dxf", layer="switch_holes");}
module case_holes(){        import("./master.dxf", layer="case_holes");}
module above_plate_void(){  import("./master.dxf", layer="above_plate_void");}
module below_plate_void(){  import("./master.dxf", layer="below_plate_void");}
module mcu_cover(){         import("./master.dxf", layer="mcu_cover");}
module trrs_xy(){           import("./master.dxf", layer="trrs_xy");}
module trrs_xy_hole(){      import("./master.dxf", layer="trrs_xy_hole");}
module trrs_zy(){           import("./master.dxf", layer="trrs_zy");}
module usb_xy(){            import("./master.dxf", layer="usb_xy");}
module usb_zy(){            import("./master.dxf", layer="usb_zy");}

module load(number){import("./master.dxf", layer=str("body",number));}


$fn = 60;

// Main stack parameters
top_wall_height = 11.6 - 5; // How high the lip around the switches is. Measures from the top of the plate
plate_thickness = 4; // Very thick plate
pcb_thickness = 3.47;
base_thickness = 2; // Thickness of the last layer of material
top_of_plate_to_top_of_pcb = 5;
top_of_pcb_to_bottom_of_case = 3.3+1.5+1; // Bottom of the switch to end of contacts/stem + clearance
mcu_cover_thickness = 2;
screw_posts_offset = 2.5;

// Bevel
top_bevel_min_diameter = 6;                          //   ___
top_bevel_height = 5;                                //  /
top_bevel_max_diameter = 14;                          // /
// this flat part is calculated                      // | 
// automatically                                     // | 
bottom_bevel_max_diameter = top_bevel_max_diameter;  // \ 
bottom_bevel_height = 4;                             //  \
bottom_bevel_min_diameter = 9;                       //   ---


// Cutouts
mcu_usb_z = -2-1; // offset from pcb surface
mcu_trrs_z = -2-1; // offset from pcb surface
mcu_usb_height = 12;
mcu_trrs_height = 12;

screw_length = 8;

// Calculated values
pcb_z = base_thickness+top_of_pcb_to_bottom_of_case+plate_thickness-pcb_thickness - top_of_plate_to_top_of_pcb;
height = plate_thickness+top_of_pcb_to_bottom_of_case+base_thickness+top_wall_height;
echo(str("TOTAL BODY HEIGHT: ", height, "mm"));

module pcb_assembly(){
    translate([0,0,pcb_z])
        color("#00880088")
        linear_extrude(pcb_thickness)
        pcb();
}

module plate_assembly(){
    translate([0,0,base_thickness+top_of_pcb_to_bottom_of_case])
        color("#888800")
        linear_extrude(plate_thickness)
            difference(){
                plate();
                union(){
                    switch_holes();
                    // plate_holes();
                }
            }
}

module base_assembly(){
    translate([0,0,-0.01])
        color("#880088")
        linear_extrude(base_thickness)
        base();
}

module mcu_cover_assembly(){
    translate([0,0,plate_thickness+top_of_pcb_to_bottom_of_case+base_thickness+top_wall_height-mcu_cover_thickness+0.00001])
        color("#008888")
        linear_extrude(mcu_cover_thickness)
        mcu_cover();
}

module round(amount, children){
    minkowski(){
        sphere(amount);
        union(){
            children();
        }
    }
}

module round_xy(amount, children){
    minkowski(){
        translate([0,0,-amount/2])
            cylinder(r1=amount,r2=amount, h=amount);
        union(){
            children();
        }
    }
}


module round_zy(amount, children){
    minkowski(){
        rotate([0,90,0])
            cylinder(r1=amount,r2=amount, h=amount);
        union(){
            children();
        }
    }
}

module round_zx(amount, children){
    minkowski(){
        rotate([90,0,0])
            cylinder(r1=amount,r2=amount, h=amount);
        union(){
            children();
        }
    }
}


module body_assembly(){
    module bevel(r1, r2, h, fn=$fn){
        cylinder(r1=r1, r2=r2, h=h, $fn = fn);
    }
    module minkowski_follower(){
        translate([0,0,height-top_bevel_height]) // top
            color("#ff8888")
            bevel(r1=top_bevel_max_diameter, r2=top_bevel_min_diameter, h=top_bevel_height);

        translate([0,0,bottom_bevel_height]) // middle
            color("#88ff88")
            bevel(r1=top_bevel_max_diameter, r2=top_bevel_max_diameter, h=height-(top_bevel_height+bottom_bevel_height));

        translate([0,0,bottom_bevel_height]) // bottom
            color("#8888ff")
            rotate([0,180,0])
            bevel(r1=bottom_bevel_max_diameter, r2=bottom_bevel_min_diameter, h=bottom_bevel_height);
    }
    module screw_posts(){
        translate([0,0,base_thickness])
            difference(){
                linear_extrude(top_of_pcb_to_bottom_of_case)
                    offset(screw_posts_offset)
                    plate_holes();
                linear_extrude(top_of_pcb_to_bottom_of_case+1) // todo screw thread for resin printing
                    plate_holes();
            }
    }
    module connector_cutouts(){
        module rounded_hole(width, height, extrude_amount){
            rad = 2;
            linear_extrude(extrude_amount+0.1)
                minkowski(){
                    circle(d=rad);
                    translate([rad/2,rad/2,0])
                        square([width-rad, height-rad]);
                }
        }
        // MCU USB hole                                 v this part makes sure it pokes through the wall
        translate([mcu_usb_x-mcu_usb_width/2, mcu_usb_y+top_bevel_max_diameter*2, pcb_z+pcb_thickness+mcu_usb_z]) 
            rotate([90,0,0])
            rounded_hole(mcu_usb_width, mcu_usb_height, top_bevel_max_diameter*3);
        // MCU trrs hole      v this part makes sure it pokes through the wall
        translate([mcu_trrs_x-top_bevel_max_diameter, mcu_trrs_y-mcu_trrs_width/2, pcb_z+pcb_thickness+mcu_trrs_z]) 
            rotate([90,0,90])
            rounded_hole(mcu_trrs_width, mcu_trrs_height, top_bevel_max_diameter*3);
    }
    
    module body_main(){
        minkowski(){
            linear_extrude(0.0001)
                pcb();
            minkowski_follower();
        }
    }

    module body_area(){
        linear_extrude(height)
            offset(top_bevel_max_diameter)
            pcb();
    }

    module body(){
        color("#008888") // plate profile bevelled outline
            difference(){
                body_main();
                union(){ // chop chop
                    translate([0,0,plate_thickness+base_thickness+top_of_pcb_to_bottom_of_case-1])
                        color("#66000066")
                        linear_extrude(height)
                        above_plate_void();
                    translate([0,0,base_thickness])
                        color("#00660066")
                        linear_extrude(height - (plate_thickness+top_of_pcb_to_bottom_of_case)+base_thickness)
                        below_plate_void();
                    translate([0,0,-1])
                        linear_extrude(screw_length+1)
                        case_holes();
                }
            }
    }

    hole_offset_size = 4;
    module usb_cutout(){
        translate([0,0,-mcu_usb_z+hole_offset_size])
                round_zx(hole_offset_size)
                linear_extrude(mcu_usb_height-hole_offset_size*2)
                offset(-hole_offset_size)
                usb_xy();
    }
    module h(){ // hole
        translate([0,0,-mcu_trrs_z+hole_offset_size])
            round_zy(hole_offset_size)
            linear_extrude(mcu_trrs_height-hole_offset_size*2)
            offset(-hole_offset_size)
            trrs_xy_hole();
    }
    module r(){ // relief area
        translate([-hole_offset_size,0,-mcu_trrs_z+hole_offset_size])
            round_zy(hole_offset_size)
            linear_extrude(mcu_trrs_height-hole_offset_size*2)
            offset(-hole_offset_size)
            trrs_xy();
    }
    module c(){ // chamfer
        translate([(hole_offset_size),0,-20])
            round_xy((hole_offset_size+0.5))
            linear_extrude(40)
            offset(-hole_offset_size+0.5)
            trrs_xy();
    }
    module trrs_cutout(){
        union(){
            h();
            r();
        }
    }


    difference(){
        union(){
            body();
            lip_thickness = 2;
            color("#008888") intersection(){ // trrs lip area
                translate([-2,0,0]) difference(){
                    round_zy(lip_thickness) r();
                    union(){
                        translate([-10,0,0]) r();
                        translate([10,0,0]) r();
                    }
                }
                body_area();
            }
            color("#008888") intersection(){ // usb lip area
                translate([0,28,0]) difference(){
                    round_zx(lip_thickness) usb_cutout();
                    union(){
                        translate([0,-10,0]) usb_cutout();
                        translate([0,10,0]) usb_cutout();
                    }
                }
                body_area();
            }
        }
        union(){
            trrs_cutout();
            usb_cutout();
            translate([0,0,-0.9])
                // color("#66006666")
                linear_extrude(base_thickness+1)
                // offset(1)
                base();
        }
    }
    
    // screw_posts();
}

module keycaps_assembly(){
    color("#333333") 
        translate([0,0, base_thickness+top_of_pcb_to_bottom_of_case+10.5])
        minkowski(){
            linear_extrude(0.001)
                switch_holes();
            cylinder(7.6, 2, 0);
        }
}

module case_screws_assembly(){
    translate([0,0,-1.65])
        minkowski(){
            difference(){
                translate([0,0,(5.7-2.5)/2])
                    sphere((5.7-2.5)/2);
                translate([-(5.7-2.5)/2,-(5.7-2.5)/2,(5.7-2.5)/2])
                    cube((5.7-2.5));
            }

            linear_extrude(0.01)
                case_holes();
        }
}

mode_preview = 1;
mode_print = 2;
mode_base = 3;

preview_mode = 2;
if (preview_mode == mode_preview){
    translate([8.37+14/2, 37.93+14/2, height+11.6-8])
        cherry();

    plate_assembly();
    mcu_cover_assembly();
    base_assembly();
    case_screws_assembly();
    pcb_assembly();
    keycaps_assembly();
    body_assembly();
}else if (preview_mode == mode_print){
    intersection(){
        // translate([100,-50,-10]) cube([200,200,200]);
        union(){
            plate_assembly();
            mcu_cover_assembly();
            body_assembly();
        }
    }
}else if (preview_mode == mode_base) {
    base_assembly();
}