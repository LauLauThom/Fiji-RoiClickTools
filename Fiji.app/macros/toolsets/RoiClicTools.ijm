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
	Dialog.addNumber("Width: ", width);
	Dialog.addNumber("Height: ", height);
	
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
