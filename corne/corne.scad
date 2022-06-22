include <cherry.scad>

module pcb(){               import("./master.dxf", layer="pcb", $fn=30);}
module holes(){             import("./master.dxf", layer="holes", $fn=30);}
module plate(){             import("./master.dxf", layer="plate", $fn=30);}
module switch_holes(){      import("./master.dxf", layer="switch_holes", $fn=30);}
module above_plate_void(){  import("./master.dxf", layer="above_plate_void", $fn=30);}
module mcu_cover(){         import("./master.dxf", layer="mcu_cover", $fn=30);}

// Main stack parameters
top_wall_height = 11.6-5; // How high the lip around the switches is. Measures from the top of the plate
plate_thickness = 4; // Very thick plate
top_of_plate_to_top_of_pcb = 5; // The void between the plate and pcb
top_of_pcb_to_bottom_of_case = 3.3+0.6; // Bottom of the switch to end of contacts/stem + clearance
base_thickness = 1.2; // Thickness of the last layer of material
mcu_cover_thickness = 1.2;

// Bevel
top_bevel_diameter = 3;         //   ___
bevel_height = 5; //  /
bottom_bevel_diameter = 8;     // /
// this flat part is calculated // | 
// automatically                // | 
//                              // \ 


module pcb_assembly(){
    translate([0,0,top_of_pcb_to_bottom_of_case-top_of_plate_to_top_of_pcb + top_of_pcb_to_bottom_of_case])
        color("#008800")
        linear_extrude(base_thickness)
        pcb();
}

module plate_assembly(){
    translate([0,0,base_thickness+top_of_pcb_to_bottom_of_case])
        color("#888800")
        linear_extrude(plate_thickness)
            difference(){
                plate();
                switch_holes();
            }
}

module base_assembly(){
    color("#880088")
        linear_extrude(base_thickness)
        pcb();
}

module mcu_cover_assembly(){
    translate([0,0,plate_thickness+top_of_pcb_to_bottom_of_case+base_thickness+top_wall_height-mcu_cover_thickness])
        color("#008888")
        linear_extrude(mcu_cover_thickness)
        mcu_cover();
}

$fn = 20;

module body_assembly(){
    height = plate_thickness+top_of_pcb_to_bottom_of_case+base_thickness+top_wall_height-bevel_height;

    module bevel(){
        cylinder(r1=bottom_bevel_diameter, r2=top_bevel_diameter, h=bevel_height);
    }
    module minkowski_follower(){
        translate([0,0,height])
            color("red")
            bevel();

        translate([0,0,bevel_height])
            rotate([0,180,0])
            color("red")
            bevel();

        translate([0,0,bevel_height])
            color("green")
            cylinder(r=bottom_bevel_diameter, h=height-bevel_height);
    }

    color("#008888")
        difference(){
            minkowski(){
                linear_extrude(0.0001)
                    pcb();
                minkowski_follower();
            }
            translate([0,0,-1])
                linear_extrude(height+bevel_height+2)
                above_plate_void();
        }
}

translate([8.37+14/2,37.93+14/2,11.3+plate_thickness+top_of_pcb_to_bottom_of_case])
    cherry();


plate_assembly();
pcb_assembly();
base_assembly();
body_assembly();
mcu_cover_assembly();