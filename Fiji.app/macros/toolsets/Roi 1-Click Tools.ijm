/* This macro should be placed in the ImageJ>macro>toolsets folder so as to appear in the toolbar >> section
* This click tool creates predefined ROI centered on the point of the clic, add this ROI to the ROI manager and run a measurement in this ROI. 
* With stacks it goes automatically to the next slice.
* The dimensions of the ROI can be set by right clicking or double clicking on the tool icon  
* The choice of measurements should be set in the Analyse > Set Measurements... prior to the successive click 
* The best is to set the options "Associate ROI with slices" of the ROI manager (More>Options)  
* The ROI set and measurement table should be manually saved after use.   
*/

// Macro defining custom keyboard shortcut (key in square-bracket)
// Several shortcut can co-exist, just add a new macro
// NB : With digit key, use the row key at the top of the keyboard (does not work with keypad)
macro "Custom shortuct [1]" {
	// ADD CUSTOM COMMANDS HERE
	run("Images to Stack", "name=Stack title=[] use");
	run("Make Montage...", "columns=5 rows=1 scale=1");
}


var addToManager = true;
var runMeasure = true;
var nextSlice = true;
var doExtraCmd = false;
var extraCmd = "//Enter some macro command";

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
	
	Dialog.addHelp("https://github.com/LauLauThom/RoiClicTool");
	Dialog.addMessage("If you use these tools, please cite:\nLaurent Thomas - (2019, December 16)\nImageJ/Fiji 1-click ROI Tools (Version 1)\nZenodo: http://doi.org/10.5281/zenodo.3577888");
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
	* MORE CUSTOM COMMANDS (executed upon click with any of the tool, even if the tick box is not ticked)
	* Examples (remove the //, save the file and relaunch fiji to test it)
	*/
	//run("Duplicate...", " ");
	//run("Invert", "slice");
	
	selectImage(imageName); // select back initial image, before calling next slice
	
	goNextSlice();    // only if nextSlice is True
	//run("Select None"); // Deselect last drawn ROI - commented: if not adding to ROI Manager then ROI not visible at all !

}


// -------------- Point  --------------- //
//Not provided already available in built-in imageJ


// -------------- Line  --------------- //

// Initalize variables (global such that the option macro can change it)
var lineLength  = 50;
var lineAngle  = 45; // trigo orientation
 
macro "Line clic Tool - Cf00Lff11" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(xcenter, ycenter, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){  // 16 : left click or 48 = 16 + 32 Left-click + in a ROI
		x1 = xcenter - cos(PI/180 * lineAngle) * lineLength/2;
		y1 = ycenter + sin(PI/180 * lineAngle) * lineLength/2;
		
		x2 = xcenter + cos(PI/180 * lineAngle) * lineLength/2;
		y2 = ycenter - sin(PI/180 * lineAngle) * lineLength/2;

		makeLine(x1, y1, x2, y2);
		
		defaultActions();
	}
}	


macro "Line clic Tool Options" { 
	Dialog.create("Line clic tool options");
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

macro "Circle clic Tool - Cf00O11cc" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(x, y, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){ 					  // 16 : left click or 48 = 16 + 32 Left-click + in a ROI
		makeOval(x-radius, y-radius, 2*radius, 2*radius); // Draw the circle of given radius using the points from ROI manager as center
		
		defaultActions();
	}
}	

macro "Circle clic Tool Options" { 
   Dialog.create("Circle clic tool options")
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

macro "Rectangle clic Tool - Cf00R11cc" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(xcenter, ycenter, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){  // 16 : left click or 48 = 16 + 32 Left-click + in a ROI
		xcorner = xcenter - rectWidth/2;
		ycorner = ycenter - rectHeight/2;
		
		makeRectangle(xcorner, ycorner, rectWidth, rectHeight); // Create a rectangular Roi centered on the point clicked
		
		defaultActions();
		
		   // Deselect last drawn ROI
	}
}	


macro "Rectangle clic Tool Options" { 
	Dialog.create("Rectangle clic tool options");
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
 
macro "Rotated Rectangle clic Tool - Cf00R11cc" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(xcenter, ycenter, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){  // 16 : left click or 48 = 16 + 32 Left-click + in a ROI
		x1 = xcenter - cos(PI/180 * rotRectAngle) * rotRectWidth/2;
		y1 = ycenter + sin(PI/180 * rotRectAngle) * rotRectWidth/2;
		
		x2 = xcenter + cos(PI/180 * rotRectAngle) * rotRectWidth/2;
		y2 = ycenter - sin(PI/180 * rotRectAngle) * rotRectWidth/2;

		makeRotatedRectangle(x1, y1, x2, y2, rotRectHeight);
		
		defaultActions();
	}
}	


macro "Rotated Rectangle clic Tool Options" { 
	Dialog.create("Rotated Rectangle clic tool options");
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
 
macro "Ellipse clic Tool - Cf00O11fa" {
	roiManager("Associate", "true"); // associate ROI with slice
	roiManager("Show All with labels");	
	
	getCursorLoc(xcenter, ycenter, z, flags); 
	//print("Sample: "+x+" "+y); 

	if ((flags==16)|(flags == 48)){  // 16 : left click or 48 = 16 + 32 Left-click + in a ROI
		x1 = xcenter - cos(PI/180 * ellipseAngle) * ellipseWidth/2;
		y1 = ycenter + sin(PI/180 * ellipseAngle) * ellipseWidth/2;
		
		x2 = xcenter + cos(PI/180 * ellipseAngle) * ellipseWidth/2;
		y2 = ycenter - sin(PI/180 * ellipseAngle) * ellipseWidth/2;

		makeEllipse(x1, y1, x2, y2, ellipseHeight/ellipseWidth);
		
		defaultActions();
	}
}	


macro "Ellipse clic Tool Options" { 
	Dialog.create("Ellipse clic tool options");
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