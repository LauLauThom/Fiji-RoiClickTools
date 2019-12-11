/* This macro should be placed in the ImageJ>macro>toolsets folder so as to appear in the toolbar >> section
* This click tool creates a circular ROI of defined radius center on the point of the clic, add this circular ROI to the ROI manager and run a measurement in this ROI. 
* With stacks it goes automatically to the next slice.
* The radius of the circular ROI can be set by right clicking or double clicking on the tool icon  
* The choice of measurements should be set in the Analyse > Set Measurements... prior to the successive click 
* The best is to set the options "Associate ROI with slices" of the ROI manager (More>Options)  
* The ROI set and measurement table should be manually saved after use.   
*/

var addToManager = true;
var runMeasure = true;
var nextSlice = true;

function goNextSlice(){
	Stack.getDimensions(stackWidth, stackHeight, channels, slices, frames);
	if ((slices>1) && (nextSlice)) run("Next Slice [>]");
}


// -------------- Point  --------------- //
//Not provided already available in built-in imageJ


// -------------- Line  --------------- //

// Initalize variables (global such that the option macro can change it)
var lineLength  = 20;
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
		
		if (addToManager) roiManager("Add");
		if (runMeasure) run("Measure");
		goNextSlice();         // only if nextSlice is True
		
		run("Select None");   // Deselect last drawn ROI
	}
}	


macro "Line clic Tool Options" { 
	Dialog.create("Line clic tool options");
	Dialog.addNumber("Length: ", lineLength);
	Dialog.addNumber("Angle (counter-clockwise): ", lineAngle);

	
	Dialog.addCheckbox("Add to Roi Manager", addToManager);
	Dialog.addCheckbox("Run measure", runMeasure );
	Dialog.addCheckbox("Auto-Next slice", nextSlice);
	Dialog.show();
	
	lineLength  = Dialog.getNumber();
	lineAngle   = Dialog.getNumber();
	
	addToManager = Dialog.getCheckbox();
	runMeasure   = Dialog.getCheckbox();
	nextSlice    = Dialog.getCheckbox();
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
		
		if (addToManager) roiManager("Add");
		if (runMeasure) run("Measure");		      // Measure the values of interest in the drawn ROI
		goNextSlice(); // only if nextSlice is True
		
		run("Select None"); // Deselect last drawn ROI
	}
}	

macro "Circle clic Tool Options" { 
   Dialog.create("Circle clic tool options")
   Dialog.addNumber("Radius", radius);
   Dialog.addCheckbox("Add to Roi Manager", addToManager);
   Dialog.addCheckbox("Run measure", runMeasure );
   Dialog.addCheckbox("Auto-Next slice", nextSlice);
   
   Dialog.show();
   
   radius       = Dialog.getNumber();
   addToManager = Dialog.getCheckbox();
   runMeasure   = Dialog.getCheckbox();
   nextSlice    = Dialog.getCheckbox();   
  } 
  


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
		xcorner = xcenter - width/2;
		ycorner = ycenter - height/2;
		
		makeRectangle(xcorner, ycorner, rectWidth, rectHeight); // Create a rectangular Roi centered on the point clicked
		
		if (addToManager) roiManager("Add");
		if (runMeasure) run("Measure");
		goNextSlice();         // only if nextSlice is True
		
		run("Select None");   // Deselect last drawn ROI
	}
}	


macro "Rectangle clic Tool Options" { 
	Dialog.create("Rectangle clic tool options");
	Dialog.addNumber("Width: ", rectWidth);
	Dialog.addNumber("Height: ", rectHeight);
	
	Dialog.addCheckbox("Add to Roi Manager", addToManager);
	Dialog.addCheckbox("Run measure", runMeasure );
	Dialog.addCheckbox("Auto-Next slice", nextSlice);
	Dialog.show();
	
	rectWidth  = Dialog.getNumber();
	rectHeight = Dialog.getNumber();
	
	addToManager = Dialog.getCheckbox();
	runMeasure   = Dialog.getCheckbox();
	nextSlice    = Dialog.getCheckbox();
}


// -------------- Rotated Rectangle --------------- //

// Initalize variables (global such that the option macro can change it)
var rotRectWidth  = 10;
var rotRectHeight = 10;
var rotRectAngle  = 45; // trigo orientation
 
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
		
		if (addToManager) roiManager("Add");
		if (runMeasure) run("Measure");
		goNextSlice();         // only if nextSlice is True
		
		run("Select None");   // Deselect last drawn ROI
	}
}	


macro "Rotated Rectangle clic Tool Options" { 
	Dialog.create("Rotated Rectangle clic tool options");
	Dialog.addNumber("Width: ", rotRectWidth);
	Dialog.addNumber("Height: ", rotRectHeight);
	Dialog.addNumber("Angle (counter-clockwise): ", rotRectAngle);

	
	Dialog.addCheckbox("Add to Roi Manager", addToManager);
	Dialog.addCheckbox("Run measure", runMeasure );
	Dialog.addCheckbox("Auto-Next slice", nextSlice);
	Dialog.show();
	
	rotRectWidth  = Dialog.getNumber();
	rotRectHeight = Dialog.getNumber();
	rotRectAngle  = Dialog.getNumber();
	
	addToManager = Dialog.getCheckbox();
	runMeasure   = Dialog.getCheckbox();
	nextSlice    = Dialog.getCheckbox();
}



// -------------- Ellipse  --------------- //

// Initalize variables (global such that the option macro can change it)
var ellipseWidth  = 20;
var ellipseHeight = 10;
var ellipseAngle  = 45; // trigo orientation
 
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
		
		if (addToManager) roiManager("Add");
		if (runMeasure) run("Measure");
		goNextSlice();         // only if nextSlice is True
		
		run("Select None");   // Deselect last drawn ROI
	}
}	


macro "Ellipse clic Tool Options" { 
	Dialog.create("Ellipse clic tool options");
	Dialog.addNumber("Width: ", ellipseWidth);
	Dialog.addNumber("Height: ", ellipseHeight);
	Dialog.addNumber("Angle (counter-clockwise): ", ellipseAngle);

	
	Dialog.addCheckbox("Add to Roi Manager", addToManager);
	Dialog.addCheckbox("Run measure", runMeasure );
	Dialog.addCheckbox("Auto-Next slice", nextSlice);
	Dialog.show();
	
	ellipseWidth  = Dialog.getNumber();
	ellipseHeight = Dialog.getNumber();
	ellipseAngle  = Dialog.getNumber();
	
	addToManager = Dialog.getCheckbox();
	runMeasure   = Dialog.getCheckbox();
	nextSlice    = Dialog.getCheckbox();
}

