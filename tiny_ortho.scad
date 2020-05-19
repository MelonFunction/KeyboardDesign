// TODO
// internal columns to prevent some plate flex
// cutouts for cables
// pro micro holder
// tenting method

// Switch module constants
switch_dimension = [14, 14];
spacing = 5;
module_dimension = [switch_dimension[0]+spacing, switch_dimension[1]+spacing];
plate_thickness = 1.5;

// Layout constants
columns = 6;
rows = 3;

// Thumb cluster constants
thumb_columns = 3;
thumb_rows = 1;
thumb_columns_offset = 2;
thumb_rot_step = 30;

// Case constants
case_height = 15;

module spacing(){
	square([
		module_dimension[0],
		module_dimension[1]], center=false);
}

module cutout(create_switch_hole=false){
	translate([spacing/2, spacing/2, 0]) square([
				switch_dimension[0],
				switch_dimension[1]], center=false);
}

module shell(get_cutouts=false){
	// Main switch area
	for (x = [0:1:columns-1]){
		for (y = [0:1:rows-1]){
			translate([x*module_dimension[0], y*module_dimension[1], 0]){
				if (get_cutouts == true){
					cutout();
				}else{
					spacing();
				}
			}
		}
	}

	// Thumb cluster
	for (t = [0:1:thumb_columns-1]){
		dy = offset_y(t, thumb_rot_step);
		translate([
			// right side
			module_dimension[0]*(columns+thumb_columns-thumb_columns_offset+1) 
				- module_dimension[0]*((thumb_columns-t)) // offset per switch
				- offset_x(module_dimension[0], dy), // adjust based on rotation
			-module_dimension[1] - dy,
		0]){
			rotate([0,0,-thumb_rot_step*(t)]){
				if (get_cutouts == true){
					cutout();
				}else{
					spacing();
				}
			}
		}
	}
}

module cutouts(create_switch_hole=true){
	shell(true);
}

function offset_y(step, rot) = step>1 ? (sin(rot*(step-1))*module_dimension[0]) : 0;
function offset_x(hyp, y) = sqrt(hyp*hyp + y*y);

	
color("#999"){
	// Case
	linear_extrude(case_height){
		difference(){
			offset(spacing) shell();
			offset(-spacing) offset(spacing) shell();
		}
	}

	// Plate
	translate([0,0,case_height-plate_thickness]){
		linear_extrude(plate_thickness){
			difference(){
				offset(spacing) shell();
				cutouts();
			}
		}
	}

}
// Base
color("#ddd"){
	translate([0,0,-plate_thickness]){
		linear_extrude(plate_thickness){
			difference(){
				offset(spacing) shell();
				// cutouts();
			}
		}
	}
}