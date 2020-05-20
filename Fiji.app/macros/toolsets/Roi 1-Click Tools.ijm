/* This macro should be placed in the ImageJ>macro>toolsets folder so as to appear in the toolbar >> section
* This Click tool creates predefined ROI centered on the point of the Click, add this ROI to the ROI manager and run a measurement in this ROI. 
* With stacks it goes automatically to the next slice.
* The dimensions of the ROI can be set by right clicking or double clicking on the tool icon  
* The choice of measurements should be set in the Analyse > Set Measurements... prior to the successive Click 
* The best is to set the options "Associate ROI with slices" of the ROI manager (More>Options)  
* The ROI set and measurement table should be manually saved after use.   
*
* This code is under BSD-2 licence.
* Author: Laurent Thomas
*/

//----------------- KEYBOARD SHORTCUTS ------------------//
// Macro defining custom keyboard shortcut (key in square-bracket)
// Several shortcut can co-exist, just add a new macro
// NB : With digit key, use the row key at the top of the keyboard (does not work with keypad)
macro "Custom shortcut [1]" {
	// This example makes a stack and a montage of the currently opened images
	// ADD CUSTOM COMMANDS HERE
	N = nImages();
	run("Images to Stack", "name=Stack title=[] use");
	run("Make Montage...", "columns=&N rows=1 scale=1");
}

  // Numeric keypad shortcuts used to set the default ROI group
  macro "Numeric Pad 0 [n0]" { npad(0); }
  macro "Numeric Pad 1 [n1]" { npad(1); }
  macro "Numeric Pad 2 [n2]" { npad(2); }
  macro "Numeric Pad 3 [n3]" { npad(3); }
  macro "Numeric Pad 4 [n4]" { npad(4); }
  macro "Numeric Pad 5 [n5]" { npad(5); }
  macro "Numeric Pad 6 [n6]" { npad(6); }
  macro "Numeric Pad 7 [n7]" { npad(7); }
  macro "Numeric Pad 8 [n8]" { npad(8); }
  macro "Numeric Pad 9 [n9]" { npad(9); }

  function npad(digit) {
      Roi.setDefaultGroup(digit);
      showStatus("Set default Roi group to: " + digit);
  }

// ----------- Helper functions -----------------//

var addToManager = true;
var runMeasure = true;
var nextSlice = true;
var doExtraCmd = false;
var extraCmd = "run('Duplicate...', 'title=crop');";

function goNextSlice(){
	Stack.getDimensions(stackWidth, stackHeight, channels, slices, frames);
	if ((slices>1) && (nextSlice)) run("Next Slice [>]");
}

/* Add default option to dialog */
function addDefaultOption(){
	
	// Recover previous parameters
	addToManager = call("ij.Prefs.get", "default.addToManager", addToManager);
	runMeasure   = call("ij.Prefs.get", "default.runMeasure", runMeasure);
	nextSlice    = call("ij.Prefs.get", "default.nextSlice", nextSlice);
	doExtraCmd   = call("ij.Prefs.get", "default.doExtraCmd", doExtraCmd);
	extraCmd     = call("ij.Prefs.get", "default.extraCmd", extraCmd);

	Dialog.addCheckbox("Add to Roi Manager", addToManager);
	Dialog.addCheckbox("Run measure", runMeasure );
	Dialog.addCheckbox("Auto-Next slice", nextSlice);
	Dialog.addCheckbox("Run extra custom commands", doExtraCmd);
	Dialog.addString("Custom macro commands", extraCmd, 25);
	
	Dialog.addHelp("https://github.com/LauLauThom/Fiji-RoiClickTools");
	Dialog.addMessage("If you use these tools, please cite:\nThomas, LS; Gehrig, J (2020)\nImageJ/Fiji ROI 1-click tools for rapid manual image annotations and measurements\nmicroPublication Biology - 10.17912/micropub.biology.000215");
}


/* Recover default options from dialog */
function getDefaultOptions(){
	addToManager = Dialog.getCheckbox();
	runMeasure   = Dialog.getCheckbox();
	nextSlice    = Dialog.getCheckbox();
	doExtraCmd   = Dialog.getCheckbox();
	extraCmd     = Dialog.getString(); 
	
	call("ij.Prefs.set", "default.addToManager", addToManager);
	call("ij.Prefs.set", "default.runMeasure", runMeasure);
	call("ij.Prefs.set", "default.nextSlice", nextSlice);
	call("ij.Prefs.set", "default.doExtraCmd", doExtraCmd);
	call("ij.Prefs.set", "default.extraCmd", extraCmd);
}

/* Default actions, in this order: AddToManager, runMeasure, nextSlice, customAction and select None  */
// Issue with stack and extra command crop : if NextSlice then crop, wrong 
function defaultActions(){
	if (addToManager) roiManager("Add");
	if (runMeasure)   run("Measure");
	
	// Get the current image title to be able to select back the initial image after the extraCommand, which might have selected another image
	imageName = getTitle();
	if (doExtraCmd) eval(extraCmd);
	/*
	* MORE CUSTOM COMMANDS (executed upon Click with any of the tool, even if the tick box is not ticked)
	* Examples (remove the //, save the file and relaunch fiji to test it)
	*/
	//run("Duplicate...", " ");
	//run("Invert", "slice");
	
	selectImage(imageName); // select back initial image, before calling next slice
	
	goNextSlice();    // only if nextSlice is True
	//run("Select None"); // Deselect last drawn ROI - commented: if not adding to ROI Manager then ROI not visible at all !

}

// --------------- CLICK-TOOLS ---------//

// -------------- Point  --------------- //
//Not provided already available in built-in imageJ


// -------------- Line  --------------- //

// Initalize variables (global such that the option macro can change it)
var lineLength  = 50;
var lineAngle  = 45; // trigo orientation
 
macro "Line Click Tool - Cf00Lff11" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(xcenter, ycenter, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){  // 16 : left Click or 48 = 16 + 32 Left-Click + in a ROI
		x1 = xcenter - cos(PI/180 * lineAngle) * lineLength/2;
		y1 = ycenter + sin(PI/180 * lineAngle) * lineLength/2;
		
		x2 = xcenter + cos(PI/180 * lineAngle) * lineLength/2;
		y2 = ycenter - sin(PI/180 * lineAngle) * lineLength/2;

		makeLine(x1, y1, x2, y2);
		
		defaultActions();
	}
}	


macro "Line Click Tool Options" { 
	Dialog.create("Line Click tool options");

	// recover previously typed values
	lineLength = call("ij.Prefs.get", "line.length", 200); // default 200
	lineAngle  = call("ij.Prefs.get", "line.angle", 0);  // default 0
	
	Dialog.addNumber("Length (pixels): ", lineLength);
	Dialog.addNumber("Angle (degrees, counter-clockwise): ", lineAngle);
	addDefaultOption();
	Dialog.show();
	
	lineLength  = Dialog.getNumber();
	lineAngle   = Dialog.getNumber();
	getDefaultOptions(); //Update the global variables addToManager, runMeasure, nextSlice 

	// Save entered value
	call("ij.Prefs.set", "line.length", lineLength);
	call("ij.Prefs.set", "line.angle", lineAngle);
}


// -------------------- Circle ---------------- //
var radius = 20; 

macro "Circle Click Tool - Cf00O11cc" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(x, y, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){ 					  // 16 : left Click or 48 = 16 + 32 Left-Click + in a ROI
		makeOval(x-radius, y-radius, 2*radius, 2*radius); // Draw the circle of given radius using the points from ROI manager as center
		
		defaultActions();
	}
}	

macro "Circle Click Tool Options" { 
   Dialog.create("Circle Click tool options")
   
   // recover previously typed values
   radius = call("ij.Prefs.get", "circle.radius", 200); // default 200
   
   Dialog.addNumber("Radius (pixels)", radius);
   addDefaultOption();
   Dialog.show();
   
   radius = Dialog.getNumber();
   getDefaultOptions(); //Update the global variables addToManager, runMeasure, nextSlice 
   
   // Save typed value
   	call("ij.Prefs.set", "circle.radius", radius);

  } 
  

/*
// Commented, rotated rectangle replace it

// ------------------ Rectangle ------------------------- //

// Initalize variables (global such that the option macro can change it)
var rectWidth  = 10;
var rectHeight = 10;

macro "Rectangle Click Tool - Cf00R11cc" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(xcenter, ycenter, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){  // 16 : left Click or 48 = 16 + 32 Left-Click + in a ROI
		xcorner = xcenter - rectWidth/2;
		ycorner = ycenter - rectHeight/2;
		
		makeRectangle(xcorner, ycorner, rectWidth, rectHeight); // Create a rectangular Roi centered on the point clicked
		
		defaultActions();
		
		   // Deselect last drawn ROI
	}
}	


macro "Rectangle Click Tool Options" { 
	Dialog.create("Rectangle Click tool options");
	Dialog.addNumber("Width: ", rectWidth);
	Dialog.addNumber("Height: ", rectHeight);
	
	addDefaultOption();

	Dialog.show();
	
	rectWidth  = Dialog.getNumber();
	rectHeight = Dialog.getNumber();
	
	getDefaultOptions();
	

}
*/


// -------------- Rotated Rectangle --------------- //

// Initalize variables (global such that the option macro can change it)
var rotRectWidth  = 40;
var rotRectHeight = 20;
var rotRectAngle  = 0; // trigo orientation
 
macro "Rotated Rectangle Click Tool - Cf00R11cc" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(xcenter, ycenter, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){  // 16 : left Click or 48 = 16 + 32 Left-Click + in a ROI
		x1 = xcenter - cos(PI/180 * rotRectAngle) * rotRectWidth/2;
		y1 = ycenter + sin(PI/180 * rotRectAngle) * rotRectWidth/2;
		
		x2 = xcenter + cos(PI/180 * rotRectAngle) * rotRectWidth/2;
		y2 = ycenter - sin(PI/180 * rotRectAngle) * rotRectWidth/2;

		makeRotatedRectangle(x1, y1, x2, y2, rotRectHeight);
		
		defaultActions();
	}
}	


macro "Rotated Rectangle Click Tool Options" { 
	Dialog.create("Rotated Rectangle Click tool options");
	
	// Recover saved parameters
	rotRectWidth  = call("ij.Prefs.get", "rect.width", 200);  // default 200
    rotRectHeight = call("ij.Prefs.get", "rect.height", 100); // default 100
	rotRectAngle  = call("ij.Prefs.get", "rect.angle", 0);    // default 0
	
	Dialog.addNumber("Width (pixels): ", rotRectWidth);
	Dialog.addNumber("Height (pixels): ", rotRectHeight);
	Dialog.addNumber("Angle (degrees, counter-clockwise): ", rotRectAngle);
	addDefaultOption();
	Dialog.show();
	
	rotRectWidth  = Dialog.getNumber();
	rotRectHeight = Dialog.getNumber();
	rotRectAngle  = Dialog.getNumber();
	getDefaultOptions(); //Update the global variables addToManager, runMeasure, nextSlice 
	
	// Save entered variables
	call("ij.Prefs.set", "rect.width", rotRectWidth);
	call("ij.Prefs.set", "rect.height", rotRectHeight);
	call("ij.Prefs.set", "rect.angle", rotRectAngle);
}



// -------------- Ellipse  --------------- //

// Initalize variables (global such that the option macro can change it)
var ellipseWidth  = 50;
var ellipseHeight = 20;
var ellipseAngle  = 0; // trigo orientation
 
macro "Ellipse Click Tool - Cf00O11fa" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(xcenter, ycenter, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){  // 16 : left Click or 48 = 16 + 32 Left-Click + in a ROI
		x1 = xcenter - cos(PI/180 * ellipseAngle) * ellipseWidth/2;
		y1 = ycenter + sin(PI/180 * ellipseAngle) * ellipseWidth/2;
		
		x2 = xcenter + cos(PI/180 * ellipseAngle) * ellipseWidth/2;
		y2 = ycenter - sin(PI/180 * ellipseAngle) * ellipseWidth/2;

		makeEllipse(x1, y1, x2, y2, ellipseHeight/ellipseWidth);
		
		defaultActions();
	}
}	


macro "Ellipse Click Tool Options" { 
	Dialog.create("Ellipse Click tool options");
	
	// Recover saved values
	ellipseWidth  = call("ij.Prefs.get", "ellipse.width", 200);  // default 200
    ellipseHeight = call("ij.Prefs.get", "ellipse.height", 100); // default 100
	ellipseAngle  = call("ij.Prefs.get", "ellipse.angle", 0);    // default 0
	
	Dialog.addNumber("Width (pixels): ", ellipseWidth);
	Dialog.addNumber("Height (pixels): ", ellipseHeight);
	Dialog.addNumber("Angle (degrees, counter-clockwise): ", ellipseAngle);
	addDefaultOption();
	Dialog.show();
	
	ellipseWidth  = Dialog.getNumber();
	ellipseHeight = Dialog.getNumber();
	ellipseAngle  = Dialog.getNumber();
	getDefaultOptions(); //Update the global variables addToManager, runMeasure, nextSlice 
	
	// Save entered values
	call("ij.Prefs.set", "ellipse.width", ellipseWidth);
	call("ij.Prefs.set", "ellipse.height", ellipseHeight);
	call("ij.Prefs.set", "ellipse.angle", ellipseAngle);
}


// ----------------- Custom Line Tool ---------- //
var xoffset = newArray(50,50);
var yoffset = newArray(100,100);
var isLine;


macro "Update custom ROI Action Tool - C00cO11cc" {
	// this macro "save" the current Roi upon click on the toolbar icon
	
	isLine = is("line");
	
	// Compute center of line or polygon as center of bounding-box
	Roi.getBounds(x, y, width, height);
	xcenter = x+width/2;
	ycenter = y+height/2;
	
	// Get roi coordinates and compute coordinates compared to bbox-center
	Roi.getCoordinates(xpoints, ypoints);
	size = Roi.size()
	xoffset = newArray(size);
	yoffset = newArray(size);
	for (i=0; i<size; i++){
		xoffset[i] = xpoints[i] - xcenter;
		yoffset[i] = ypoints[i] - ycenter;
	}
}


macro "Custom ROI Tool - Cf00Lff11" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(xcenter, ycenter, z, flags); 
	
	size = xoffset.length;
	xpoints = newArray(size); // contains the new ROI points
	ypoints = newArray(size); 
	
	if ((flags==16)|(flags == 48)){  // 16 : left Click or 48 = 16 + 32 Left-Click + in a ROI
		for (i=0; i<size; i++){
			xpoints[i] = xcenter + xoffset[i]; // x-coordinates
			ypoints[i] = ycenter + yoffset[i]; // y-coordinates
		}
		
		if (isLine) makeSelection("polyline", xpoints, ypoints);
		else makeSelection("polygon", xpoints, ypoints);
		
		roiManager("Add");
	}
}