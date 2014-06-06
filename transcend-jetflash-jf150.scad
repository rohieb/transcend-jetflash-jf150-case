use <obiscad/obiscad/attach.scad>
use <obiscad/obiscad/bevel.scad>

// Raw dimensions of the PCB and the USB plug:
// PCB: 14.5mm × < 4mm × < 40mm
// USB: 12mm × 4.5mm × < 15mm

// Raw values + tolerance. Case and lid are designed to hold the PCB and the USB
// plug by friction, change tolerance if neccessary for your workflow.
pcb_dim = [14.5+0.5, 4+1, 40+2];
usb_dim = [12+1, 4.5, 15+1];

// Wall thickness
wall_dim = [2,2,3];

// Total outer dimensions
flashdrive_dim = [
	max(pcb_dim[0],usb_dim[0]),
	max(pcb_dim[1],usb_dim[1]),
	usb_dim[2]+pcb_dim[2]
];

// Model of the raw USB flash drive without case
module flashdrive() {
	cube(pcb_dim);
	translate([(pcb_dim[0]-usb_dim[0])/2, (pcb_dim[1]-usb_dim[1])/2, pcb_dim[2]-0.01])
	 cube(usb_dim);
}

// Case for the PCB
module case() {
	h = pcb_dim[2]+wall_dim[2];
	bo1 = [-wall_dim[0]           , -wall_dim[1]           , h/2-wall_dim[2]];
	bo2 = [-wall_dim[0]           ,  wall_dim[1]+pcb_dim[1], h/2-wall_dim[2]];
	bo3 = [ wall_dim[0]+pcb_dim[0], -wall_dim[1]           , h/2-wall_dim[2]];
	bo4 = [ wall_dim[0]+pcb_dim[0],  wall_dim[1]+pcb_dim[1], h/2-wall_dim[2]];
	bi1 = [0         , 0          , h/2-wall_dim[2]];
	bi2 = [0         , +pcb_dim[1], h/2-wall_dim[2]];
	bi3 = [pcb_dim[0], 0          , h/2-wall_dim[2]];
	bi4 = [pcb_dim[0], +pcb_dim[1], h/2-wall_dim[2]];

	difference() {
		translate(-wall_dim)
			cube(flashdrive_dim+2*wall_dim);
		scale([1,1,1.01])
			difference() {
			flashdrive();
			bevel([bi1,[0,0,1],0], [bo1,[-1,-1,0],0], l=h+1, cr=wall_dim[1]);
			bevel([bi2,[0,0,1],0], [bo2,[-1, 1,0],0], l=h+1, cr=wall_dim[1]);
			bevel([bi3,[0,0,1],0], [bo3,[ 1,-1,0],0], l=h+1, cr=wall_dim[1]);
			bevel([bi4,[0,0,1],0], [bo4,[ 1, 1,0],0], l=h+1, cr=wall_dim[1]);
		}

		translate([-2*wall_dim[0],-2*wall_dim[1], pcb_dim[2]])
			cube(2 * ([1,1,1]+flashdrive_dim+wall_dim));
		bevel([bo1,[0,0,1],0], [bo1,[-1,-1,0],0], l=h+1, cr=2*wall_dim[1]);
		bevel([bo2,[0,0,1],0], [bo2,[-1, 1,0],0], l=h+1, cr=2*wall_dim[1]);
		bevel([bo3,[0,0,1],0], [bo3,[ 1,-1,0],0], l=h+1, cr=2*wall_dim[1]);
		bevel([bo4,[0,0,1],0], [bo4,[ 1, 1,0],0], l=h+1, cr=2*wall_dim[1]);

		// don't question those constants, they are magic.
		translate([pcb_dim[0]-1.2, -wall_dim[1], 6])
			rotate([90,-90,0])
			scale([0.2, 0.2, 1])
			linear_extrude(height=1, center=true)
			import("USB_Icon.dxf", center=true);
	}
}

// Cutouts on inside of lid for easier adjusting after printing
module lid_cutouts() {
	translate([(pcb_dim[0]-usb_dim[0])/2, 0, 0])
		cube([usb_dim[0]/4, 2, usb_dim[2]]);
	translate([(pcb_dim[0]-usb_dim[0]/4)/2, 0, 0])
		cube([usb_dim[0]/4, 2, usb_dim[2]]);
	translate([(pcb_dim[0]-usb_dim[0])/2 + usb_dim[0] - usb_dim[0]/4, 0, 0])
		cube([usb_dim[0]/4, 2, usb_dim[2]]);
}

// Lid for the USB plug
module lid() {
	h = usb_dim[2]+2*wall_dim[2];
	bo1 = [-wall_dim[0]           , -wall_dim[1]           , h/2-wall_dim[2]];
	bo2 = [-wall_dim[0]           ,  wall_dim[1]+pcb_dim[1], h/2-wall_dim[2]];
	bo3 = [ wall_dim[0]+pcb_dim[0], -wall_dim[1]           , h/2-wall_dim[2]];
	bo4 = [ wall_dim[0]+pcb_dim[0],  wall_dim[1]+pcb_dim[1], h/2-wall_dim[2]];

	difference() {
		translate(-[wall_dim[0],wall_dim[1],0])
			cube([flashdrive_dim[0], flashdrive_dim[1], usb_dim[2]-wall_dim[2]]
			+ 2*wall_dim);

		translate([0, 0, -pcb_dim[2]])
			flashdrive();
		translate([0, (pcb_dim[1]-usb_dim[1])/2 - 0.75, 0])
			lid_cutouts();			
		translate([0, (pcb_dim[1]-usb_dim[1])/2 + usb_dim[1] - 1.25, 0])
			lid_cutouts();			

		bevel([bo1,[0,0,1],0], [bo1,[-1,-1,0],0], l=h+1, cr=2*wall_dim[1]);
		bevel([bo2,[0,0,1],0], [bo2,[-1, 1,0],0], l=h+1, cr=2*wall_dim[1]);
		bevel([bo3,[0,0,1],0], [bo3,[ 1,-1,0],0], l=h+1, cr=2*wall_dim[1]);
		bevel([bo4,[0,0,1],0], [bo4,[ 1, 1,0],0], l=h+1, cr=2*wall_dim[1]);
	}
}

// uncomment what you want to build, lid or case
//case();
lid();
