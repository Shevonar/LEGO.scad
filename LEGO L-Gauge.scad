use <LEGO.scad>;

stud_spacing=8;
gap = 0.1;
rail_crossection=[[-0.9,0],[-0.9,3.2],[0,3.2],[0,4],[1.75,5.2],[1.75,9.6],[4.25,9.6],[4.25,5.2],[6,4],[6,3.2],[6.9,3.2],[6.9,0],[5.55,0],[5.55,2],[0.45,2],[0.45,0]];
rail_connector_crossection=[[0,3.2],[0,4],[1.75,7.6],[1.75,9.6],[3-gap,9.6],[3-gap,3.2]];
// for under side
wall_thickness = 1.35;
hole_size = stud_spacing - 2*wall_thickness;

color("grey") translate([-4*stud_spacing,0,0]) straight_track(8);
//color("grey") translate([-200,0,0]) straight_track(16);
//color("grey") translate([-300,0,0]) straight_track(4);

module quarter_circle(radius) {
    segments = segment_count(radius);
    angle = 90 / segments;
    for (i=[0:segments-1]) {
        rotate([0,0,i*angle]) curved_track(radius);
    }
}

quarter_circle(56);

//color("grey") curved_track(24);
//color("grey") curved_track(32);
//color("grey") curved_track(40);
//color("grey") curved_track(56);
//color("grey") curved_track(72);
//color("grey") curved_track(88);
//color("grey") curved_track(104);

// 4D Brix reference
// half straight
*translate([-4*stud_spacing,4*stud_spacing]) color("green") rotate([0,0,90]) translate([-188,-343.09,0]) import("2-04-001-std_v21.stl", center=true, convexity=4);
// R40 curve
*translate([36*stud_spacing,0,0]) translate([-21.8,110.3,0]) rotate([0,0,292.5]) translate([-647.7,-461.4,0]) import("2-04-069-sur_v04.stl", center=true, convexity=4);

module quarter_circle2() {
    segments = 4;
    angle = 90 / segments;
    for (i=[0:segments-1]) {
        rotate([0,0,i*angle]) translate([36*stud_spacing,0,0]) translate([-21.8,110.3,0]) rotate([0,0,292.5]) translate([-647.7,-461.4,0]) import("2-04-069-sur_v04.stl", center=true, convexity=4);
    }
}
quarter_circle2();


module rail_connector() {
    difference() {
        rotate([90,0,0]) linear_extrude(stud_spacing-2*gap) {
            polygon(points=rail_connector_crossection);
        }
        corner_radius=1.75;
        translate([corner_radius-0.01,-(stud_spacing-corner_radius-2*gap+0.01),0]) rotate([0,0,180]) linear_extrude(10) difference() {
            square(corner_radius);
            circle(corner_radius, $fn=24);
        }
    }
}

module sleepers_connector() {
    module brick() {
        translate([4,32]) rotate([0,0,90]) block(
            width=1,
            length=8,
            height=1/3,
            type="block",
            include_wall_splines=false,
            block_bottom_type="closed"
        );
    }
    module connector() {
        linear_extrude(3.2) {
            offset(r=0.2) offset(r=-0.3) difference() {
                union() {
                    polygon(points=[[0,0],[0,20],[1.6,21.6],[1.6,26.4],[0,28],[0,36],[-1.6,37.6],[-1.6,42.4],[0,44],[0,64],[7.8,64],[7.8,0]]);
                    translate([0.2, 24]) circle(2, $fn=24);
                }
                translate([0, 40]) circle(1.95, $fn=24);
                translate([0, 24]) circle(0.8, $fn=24);
            }
        }
    }
    module cut() {
        translate([-2, 20, -0.09]) cube([4.2, 24.2, 3.3]);
    }
    
    module rounded_hole(mirrored=false) {
        corner_radius=hole_size/2;
        translate([0, mirrored ? hole_size : 0]) mirror([0, mirrored ? 1 : 0]) 
        translate([0.1,0.1]) linear_extrude(2) difference() {
            square(hole_size-0.1);
            translate([corner_radius, corner_radius]) rotate([0,0,180]) difference() {
                square(corner_radius);
                circle(corner_radius, $fn=24);
            }
        }
    }
    
    mirror([1,0,0]) translate([32,0,0]) rotate([0,0,90]) render(convexity=4) difference() {
        union() {
            intersection() {
                connector();
                cut();
            }
            difference() {
                brick();
                cut();
                // remove stud 1 and 6
                translate([0,1*stud_spacing,3.2]) cube(stud_spacing);
                translate([0,6*stud_spacing,3.2]) cube(stud_spacing);
                
            }
        }
        // under side holes
        translate([wall_thickness, wall_thickness+0*stud_spacing]) cube([hole_size,hole_size,2]);
        translate([wall_thickness, wall_thickness+1*stud_spacing]) {
            translate([hole_size/2,hole_size/2]) cylinder(h=2, d=hole_size, center=false, $fn=24);
            translate([-2.5,0]) cube([hole_size,hole_size,2]);
        }
        translate([wall_thickness, wall_thickness+2*stud_spacing]) rounded_hole(mirrored=true);
        translate([wall_thickness, wall_thickness+3*stud_spacing]) rounded_hole();
        translate([wall_thickness, wall_thickness+4*stud_spacing]) rounded_hole(mirrored=true);
        translate([wall_thickness, wall_thickness+5*stud_spacing])  rounded_hole();
        translate([wall_thickness, wall_thickness+6*stud_spacing]) {
            translate([hole_size/2,hole_size/2]) cylinder(h=2, d=hole_size, center=false, $fn=24);
            #translate([-2.5,0]) cube([hole_size,hole_size,3.21]);
        }
        translate([wall_thickness, wall_thickness+7*stud_spacing]) cube([hole_size,hole_size,2]);
    }
}

module straight_track(length) {
    realLength = length * stud_spacing;
    // straight rails
    translate([2.5*stud_spacing+3, 0])  {
        translate([0,stud_spacing/2,0]) rotate([90,0,180]) linear_extrude(realLength - stud_spacing) {
            polygon(points=rail_crossection);
        }
        translate([-6,stud_spacing/2,0]) rail_connector();
        translate([0,realLength-stud_spacing/2,0]) rotate([0,0,180]) rail_connector();
    }

    translate([-2.5*stud_spacing+3, 0])  {
        translate([0,stud_spacing/2,0]) rotate([90,0,180]) linear_extrude(realLength - stud_spacing) {
            polygon(points=rail_crossection);
        }
        translate([-6,stud_spacing/2,0]) rail_connector();
        translate([0,realLength-stud_spacing/2,0]) rotate([0,0,180]) rail_connector();
    }
    
    // sleepers
    sleepersCount=length / 4 + 1; // including connector pieces
    sleepersDelta=realLength/(sleepersCount-1);
    for (i=[0:sleepersCount-1]) {
        if (i == 0) {
            translate([0,i*sleepersDelta,0]) sleepers_connector();
        } else if (i == sleepersCount -1) {
            translate([0,i*sleepersDelta,0]) rotate([0,0,180]) sleepers_connector();
        } else {
            translate([0,i*sleepersDelta,0]) sleepers();
        }
    }    
}

function arc_length(theta, r) = (theta / 360) * (2 * PI * r);
function segment_count(radius) = let(real_radius = radius * stud_spacing, circumference = 0.5 * PI * real_radius) max(ceil(circumference / 155), 4);

module curved_track(radius, segments=0) {
    real_radius = radius * stud_spacing;
    segments = segments > 0 ? segments : segment_count(radius);
    angle = 90 / segments;

    module curved_rail(angle, rail_radius) {
        difference() {
            rotate_extrude(angle=angle, $fn=360) translate([rail_radius,0,0]) {
                polygon(points=rail_crossection);
            }        
            translate([rail_radius-1,-stud_spacing/2,3.2]) cube(stud_spacing);
            rotate([0,0,angle]) translate([rail_radius-1,-stud_spacing/2,3.2]) cube(stud_spacing);
        }
        translate([rail_radius,stud_spacing/2,0]) rail_connector();  
        rotate([0,0,angle]) translate([rail_radius+6,-stud_spacing/2,0]) rotate([0,0,180]) rail_connector();
    }
    
    // outer curved rail
    outer_radius=(radius+2.5)*stud_spacing-3;
    curved_rail(angle, outer_radius);

    // inner curved rail
    inner_radius=(radius-2.5)*stud_spacing-3;
    curved_rail(angle, inner_radius);

    // sleepers
    sleepersCount=ceil(arc_length(angle, real_radius) / 31);
    sleepersAngle=angle/(sleepersCount-1);
    for (i=[0:sleepersCount-1]) {
        if (i == 0) {
            rotate([0,0,i*sleepersAngle]) translate([radius*8,0,0]) sleepers_connector();
        } else if (i == sleepersCount -1) {
            rotate([0,0,i*sleepersAngle]) translate([radius*8,0,0]) rotate([0,0,180]) sleepers_connector();
        } else {
            rotate([0,0,i*sleepersAngle]) translate([radius*8,0,0]) sleepers();
        }
    }
    
//    echo(outer_radius, arc_length(90, outer_radius));
//    echo(inner_radius, arc_length(90, inner_radius));
//    echo(radius, circumference, segments, angle, arc_length(angle, real_radius), sleepersCount);
}

module sleepers() {
    difference() {
        union() {
            block(
                width=2,
                length=4,
                height=1/3,
                type="block",
                include_wall_splines=false,
                block_bottom_type="closed"
            );
            block(
                width=2,
                length=8,
                height=1/3,
                type="tile",
                include_wall_splines=false,
                block_bottom_type="closed"
            );
            translate([3.5*stud_spacing,0,0]) rotate([0,0,90]) block(
                width=2,
                length=1,
                height=1/3,
                type="block",
                include_wall_splines=false,
                block_bottom_type="closed"
            );
            translate([-3.5*stud_spacing,0,0]) rotate([0,0,90]) block(
                width=2,
                length=1,
                height=1/3,
                type="block",
                include_wall_splines=false,
                block_bottom_type="closed"
            );
        }

        // under side holes      
        translate([3*stud_spacing+wall_thickness, hole_size/2-wall_thickness, -0.01]) cube([hole_size,hole_size,2]);
        translate([-2*stud_spacing+wall_thickness, hole_size/2-wall_thickness, -0.01]) cube([4*stud_spacing-2*wall_thickness,hole_size,2]);
        translate([-4*stud_spacing+wall_thickness, hole_size/2-wall_thickness, -0.01]) cube([hole_size,hole_size,2]);
        
        translate([3*stud_spacing+wall_thickness, hole_size/2-wall_thickness-stud_spacing, -0.01]) cube([hole_size,hole_size,2]);
        translate([-2*stud_spacing+wall_thickness, hole_size/2-wall_thickness-stud_spacing, -0.01]) cube([4*stud_spacing-2*wall_thickness,hole_size,2]);
        translate([-4*stud_spacing+wall_thickness, hole_size/2-wall_thickness-stud_spacing, -0.01]) cube([hole_size,hole_size,2]);
        
        translate([-3*stud_spacing+wall_thickness, hole_size/2-wall_thickness-stud_spacing, -0.01]) cube([stud_spacing-2*wall_thickness,2*stud_spacing-2*wall_thickness,2]);
        translate([2*stud_spacing+wall_thickness, hole_size/2-wall_thickness-stud_spacing, -0.01]) cube([stud_spacing-2*wall_thickness,2*stud_spacing-2*wall_thickness,2]);
    }
}