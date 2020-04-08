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
	Dialog.addNumber("Length (pixels): ", lineLength);
	Dialog.addNumber("Angle (degrees, counter-clockwise): ", lineAngle);
	
	addDefaultOption();
	
	Dialog.show();
	
	lineLength  = Dialog.getNumber();
	lineAngle   = Dialog.getNumber();
	
	getDefaultOptions(); //Update the global variables addToManager, runMeasure, nextSlice 
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
   Dialog.addNumber("Radius (pixels)", radius);

   addDefaultOption();

   Dialog.show();
   
   radius = Dialog.getNumber();
   getDefaultOptions(); //Update the global variables addToManager, runMeasure, nextSlice 
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
	Dialog.addNumber("Width (pixels): ", rotRectWidth);
	Dialog.addNumber("Height (pixels): ", rotRectHeight);
	Dialog.addNumber("Angle (degrees, counter-clockwise): ", rotRectAngle);
	
	addDefaultOption();

	Dialog.show();
	
	rotRectWidth  = Dialog.getNumber();
	rotRectHeight = Dialog.getNumber();
	rotRectAngle  = Dialog.getNumber();
	
	getDefaultOptions(); //Update the global variables addToManager, runMeasure, nextSlice 
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
	Dialog.addNumber("Width (pixels): ", ellipseWidth);
	Dialog.addNumber("Height (pixels): ", ellipseHeight);
	Dialog.addNumber("Angle (degrees, counter-clockwise): ", ellipseAngle);

	addDefaultOption();

	Dialog.show();
	
	ellipseWidth  = Dialog.getNumber();
	ellipseHeight = Dialog.getNumber();
	ellipseAngle  = Dialog.getNumber();
	
	getDefaultOptions(); //Update the global variables addToManager, runMeasure, nextSlice 

}