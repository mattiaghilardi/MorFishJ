//-----------------------------------------------------------------------------------------//
//                                                                                         //
//                                     MorFishJ v0.0.1                                     //
//                                                                                         //
//                             Set of ImageJ macros to measure                             //
//                     morphological traits from side-view fish images.                    //
//                                                                                         //
//                                 Author: Mattia Ghilardi                                 //
//                               mattia.ghilardi91@gmail.com                               //
//                                     July 19th, 2022                                      //
//                                                                                         //
//-----------------------------------------------------------------------------------------//

// Check version
var v = versionCheck();

// "versionCheck": Check version at install time
function versionCheck() {
    requires("1.53e");
    return 1;
}

//-------------------------------- HELPER FUNCTIONS  --------------------------------------//

// "imageCheck": Check that one image is open for single image analysis and none for multiple analysis
function imageCheck(type) { // type: single (s) or multiple (m) analysis
	list = getList("image.titles");
	if (type == "m" && list.length > 0) {
		exit("<html>"
		     + "<center>Close all images before starting <br>"
		     + "a multiple image analysis.</center>");
	} else if (type == "s" && list.length == 0) {
		exit("<html>"
		     + "<center>Open an image before running <br>"
		     + "a single image analysis.</center>");
	} else if (type == "s" && list.length > 1) {
		exit("<html>"
		     + "Multiple images are open");
	}
}

// "imageSize": Get image's width and height and the center's coordinates
var h, w, ymid, xmid;
function imageSize() {
	h = getHeight;
	w = getWidth;
	ymid = h/2;
	xmid = w/2;
}

// "orientation": Get fish orientation
var side;
function orientation() {
	// Orientation
	Dialog.create("Orientation");
	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("Which side is the fish facing?");
	Dialog.setInsets(5, 25, 5);
	Dialog.addChoice("", newArray("left", "right"));
	Dialog.show();
	side = Dialog.getChoice();
}

// "setScale": Set scale
var pw;
function setScale() {
	setTool("Line");
	run("Line Width...", "line=1");
	waitForUser("Set scale", "Trace a line on a reference \nobject of known length.");
	if (selectionType != 5) {
		showMessage("<html>"
			     + "Straight line selection required!");
		waitForUser("Set scale", "Trace a line on a reference \nobject of known length.");
	}
	roiManager("Add");
	Dialog.create("Set scale");
	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("Please enter the known length \nand select the unit of measurement.\nAny unit will be converted to 'cm'.");
	Dialog.setInsets(5, 15, 5);
	Dialog.addNumber("Known length:", 0);
	Dialog.setInsets(5, 15, 5);
	Dialog.addChoice("Unit:", newArray("mm", "cm", "inch"));
	Dialog.show();
	num = Dialog.getNumber();
	unit = Dialog.getChoice();
	num1 = num/10;
	num2 = num*2.54;
	if (unit == "cm") {
		run("Set Scale...", "known=num unit=cm");
	} else if  (unit == "mm") {
		run("Set Scale...", "known=num1 unit=cm");
	} else {
		run("Set Scale...", "known=num2 unit=cm");
	}
	getPixelSize(unit, pw, ph);
	roiManager("Select", 0);
	roiManager("Rename", "px."+unit);
	run("Select None");
}

// "measureAngle": Measure angle in degrees between a line and the horizontal axis.
function measureAngle(x1, y1, x2, y2) {
	dx = x2-x1;
	dy = y1-y2;
	angle = (180.0/PI)*atan(dy/dx);
	return angle;
}

// "rotateImage": Rotate an image based on the angle of a straight line selection.
function rotateImage(x1, y1, x2, y2) {
	angle = measureAngle(x1, y1, x2, y2);
	run("Arbitrarily...", "angle="+angle+" interpolate fill");
}

// "straightenRotate": Adjust the image if the fish is bended or not horizontal
var straighten, rotate;
function straightenRotate() {
	Dialog.create("Image adjustment");
	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("The fish must be straight and horizontal.\nIf this is not the case check the box with the\nrequired action, otherwise press OK.");
	Dialog.setInsets(5, 70, 0);
	Dialog.addCheckbox("Straighten", false);
	Dialog.setInsets(5, 70, 0);
	Dialog.addCheckbox("Rotate", false);
	Dialog.show();
	
	straighten = Dialog.getCheckbox();
	rotate = Dialog.getCheckbox();
	
	if (straighten == 1) {
		setTool("Polyline");
		run("Line Width... ");
		waitForUser("Straighten fish", "Create a segmented line selection following the midline of the fish.\nThe selection must extend from both the snout and caudal fin.\n \nAdjust the selection as needed, then increase the line width\nuntil the whole fish falls within the shaded area.\n \nOnce happy with the selection press OK.");
		if (selectionType != 6) {
			showMessage("<html>"
				     + "Segmented line selection required!");
			waitForUser("Straighten fish", "Create a segmented line selection following the midline of the fish.\nThe selection must extend from both the snout and caudal fin.\n \nAdjust the selection as needed, then increase the line width\nuntil the whole fish falls within the shaded area.\n \nOnce happy with the selection press OK.");
		}
		run("Straighten...");
		straightened = getImageID();
		rename(title);
		selectImage(copy);
		run("Close");
		run("Line Width...", "line=1");
		if (isOpen("Line Width")) {
			selectWindow("Line Width");
			run("Close");
		}
	} 
	else if (straighten == 0 && rotate == 1) {
		setTool("Line");
		waitForUser("Rotate image", "Trace a straight line with the same orientation as the fish. \nThe image will be rotated based on the angle of the line selection.");
		if (selectionType != 5) {
			showMessage("<html>"
				     + "Straight line selection required!");
			waitForUser("Rotate image", "Trace a straight line with the same orientation as the fish. \nThe image will be rotated based on the angle of the line selection.");
		}
		getLine(x1, y1, x2, y2, lineWidth);
		rotateImage(x1, y1, x2, y2);
	}
}

// "roiAddRename": Add selection to ROI and rename
function roiAddRename(name) {
	roiManager("Add");
	nROI = RoiManager.size;
	roiManager("Select", (nROI-1));
	roiManager("Rename", name);
	run("Labels...", "color=white font=12 show use draw bold");
}

// "lineXline": Intersection point between two ROIs representing perpendicular lines
function lineXline(a, b) {
	roiManager("Select", a);
	run("Line to Area");
	roiManager("Add");
	roiManager("Select", b);
	run("Line to Area");
	roiManager("Add");
	c = 1+b;
	d = 2+b;
	roiManager("Select", newArray(c, d));
	roiManager("AND");
	roiManager("Add");
	e = 3+b;
	roiManager("Select", e);
	getSelectionCoordinates(x, y);
	myx = x[2];
	myy = y[2];
	roiManager("Select", newArray(c, d, e));
	roiManager("Delete");
	coord = newArray(myx, myy);
	return coord;
}

// "areaXline": Intersection points between two ROIs, the first an area and the second a straight line
// Modified from: https://forum.image.sc/t/how-to-get-xy-coordinate-of-selection-line-crossing-a-roi/6923/6
function extrema(p) {
	for (i = 1; i < p.length; i++) {
		p[i-1] = abs(p[i]-p[i-1]);
            }
}
function intersection(xx, yy, s, p) {
	for (i = 0; i < 2; i++) {
		if (i > 0) { 
			sign = -1; 
		} else { 
			sign = 1; 
		}
		dx = sign*sqrt(pow(p[i], 2)/(1+pow(s, 2)));
		xx[i] += dx;
		if (s != 1/0) { 
			yy[i] -= s*dx; 
		} else { 
			yy[i] += sign*p[i]; 
		}
	}
}
function areaXline(a, b) {
	roiManager("Select", a);
	run("Create Mask");
	roiManager("Select", b);
	if (selectionType != 5) {
		exit("<html>"
		      + "Straight line selection required!");
	}
	getSelectionCoordinates(x, y);
	slp = -(y[0]-y[1])/(x[0]-x[1]);
	len = sqrt(pow(x[0]-x[1], 2) + pow(y[0]-y[1], 2));
	profile = getProfile();
	extrema(profile);
	profile = Array.findMaxima(profile, 0, 1);
	profile[1] = len-profile[1];
	intersection(x, y, slp, profile);
	point1 = newArray(x[0], y[0]);
	point2 = newArray(x[1], y[1]);
	points = Array.concat(point1, point2);
	close("Mask");
	return points;
}

//---------------  FUNCTIONS FOR SETTING UP OR CONTINUING MULTIPLE ANALYSES  --------------//

var inputDir, outputDir1, outputDir2, fileName, fileExt, filePath, lastImg, logFile, newList, analysisType;

// "continuedAnalysis": load TraitLog file and harvest metadata (analysis: main, head, gut)
function continuedAnalysis(analysis) {

	// Dialog
	help = "https://mattiaghilardi.github.io/MorFishJ_manual/GUI.html#continued-analysis";
	Dialog.create("Load TraitLog file");
	Dialog.addFile("TraitLog", "");
	Dialog.addHelp(help);
	Dialog.show();
	logFile = Dialog.getString();
	
	// Check user entry
	checkLog = File.isFile(logFile);
	
	// If the user have NOT loaded a file - ERROR
	if (checkLog == 0) {
		exit("<html>"
		     + "<Center><b>WARNING!</b><br>"
		     + "No file has been loaded.</Center>");
	}
	
	// If the user have loaded a file harvest metadata
	else {
		
		// First check that it is a TraitLog file and not something else
		logFileName = File.getName(logFile);
		if(logFileName.startsWith("TraitLog_")){
			
			// Harvest metadata and check if anything is missing
			// First initialise all variables as empty
			inputDir = ""; outputDir1 = ""; outputDir2 = ""; fileName = ""; fileExt = ""; analysisType = "";
			harvestMetadata(logFile);
			
			// Check the the type of analysis selected matches that in the metadata
			if (analysis != analysisType) {
				exit("<html>"
				     + "<Center><b>WARNING!</b><br>"
				     + "The selected analysis differ from that<br>"
				     + "registered in the <i>TraitLog</i> file.</Center>");
			}
			
			// Check that the last logged image matches one in the input directory
			fileListIn = getFileList(inputDir);
			newList = "";
			for (i = 0; i < fileListIn.length; i++) {
				if (fileListIn[i].matches(lastImg)) {
					
					// If it matches the last image in the directory - ERROR
					if (i == fileListIn.length-1) {
						exit("<html>"
						     + "<Center><b>WARNING!</b><br>"
						     + "The last logged image in the loaded <i>TraitLog</i> file<br>"
						     + "matches the last image in the input directory.<br>"
						     + "Analysis completed!</Center>");
					} else {
						// Create a new array starting from the next image
						newList = Array.slice(fileListIn, i+1);
						
						// Check that the results file is in the directory
						filePath = outputDir2 + fileName + fileExt;
						if (!File.exists(filePath)) {
							exit("<html>"
							     + "<Center><b>WARNING!</b><br>"
							     + "The results file <i>" + fileName + fileExt + "</i><br>"
							     + "cannot be found in the output directory.</Center>");
						}
					}
				}
			}
			if (newList.length == 0) {
				exit("<html>"
				     + "<Center><b>WARNING!</b><br>"
				     + "The last logged image in the loaded <i>TraitLog</i> file<br>"
				     + "does not match any image in the input directory.</Center>");
			}
		} else {
			exit("<html>"
			     + "<Center><b>WARNING!</b><br>"
			     + "The loaded file is not a <i>TraitLog</i> file.</Center>");
		}
	}
}
	
// "setupMultiAnalysis": Set up analysis of multiple images (analysis: main, head, gut)
function setupMultiAnalysis(analysis) {

	// Dialog
	help = "https://mattiaghilardi.github.io/MorFishJ_manual/GUI.html#new-analysis";
	Dialog.create("Select directories and output file's name and format");
	Dialog.addDirectory("Input directory", "");
	Dialog.addDirectory("Output directory ROIs", "");
	Dialog.addDirectory("Output directory results", "");
	Dialog.addString("Results file name", "Traits");
	Dialog.addChoice("Results file extension",  newArray(".csv", ".txt"));
	Dialog.addHelp(help);
	Dialog.show();
	inputDir = Dialog.getString();
	outputDir1 = Dialog.getString();
	outputDir2 = Dialog.getString();
	fileName = Dialog.getString();
	fileExt = Dialog.getChoice();
	
	// Get the date
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	sep = "_";
	month = month+1;
	if (month<10) {
		month = "0" + month;
	}
	if (dayOfMonth<10) {
		dayOfMonth = "0" + dayOfMonth;
		date = dayOfMonth + sep + month + sep + year;
	} else {
		date = d2s(dayOfMonth, 0) + sep + month + sep + year;
	}
	
	// Check user entries
	checkInput = File.isDirectory(inputDir);
	checkOutput1 = File.isDirectory(outputDir1);
	checkOutput2 = File.isDirectory(outputDir2);
			
	// If all directories have been selected create a new TraitLog file in the chosen output directory for results, 
	// BUT CHECK THERE IS NO EXISTING TraitLog FILE IN THIS DIRECTORY
	if ((checkInput && checkOutput1 && checkOutput2) == 1) {
		
		// First check that there is no existing TraitLog file in the directory to avoid overwriting unintentionally
		fileListOut = getFileList(outputDir2);
		if (fileListOut.length != 0) {
			for (i = 0; i < fileListOut.length; i++) {
				if (fileListOut[i].startsWith("TraitLog")) {
					exit("<html>"
					     + "<Center><b>WARNING!</b><br>"
					     + "There is already an existing <i>TraitLog</i> file in the output directory.<br>"
					     + "If you are certain you do not need this file,<br>"
					     + "you can manually delete it before running the analysis.</Center>");
				}
			}
		}
	
		// If we pass the above:
		// 1 - get list of files in the input directory
		newList = getFileList(inputDir);
		
		// 2 - create a new TraitLog file and record relevant metadata
		logFile = outputDir2 + "TraitLog_" + date + ".txt";
		f = File.open(logFile);
		
		print(f, "Input_directory: " + inputDir);
		print(f, "Output_ROIs: " + outputDir1);
		print(f, "Output_results: " + outputDir2);
		print(f, "File_name: " + fileName);
		print(f, "File_extension: " + fileExt);
		print(f, "Analysis: " + analysis);
		print(f, "Date: " + date);
		
		File.close(f);
		
		// 3 - create a new results file with the user selected name and extension
		filePath = outputDir2 + fileName + fileExt;
		res = File.open(filePath);
		names = colnames(analysis);
		print(res, names);
		File.close(res);
	}
	
	// If NOT all directories have been selected - ERROR
	else {
		exit("<html>"
		     + "<Center><b>WARNING!</b><br>"
		     + "Not all directories have been selected</Center>");
	}	
}

function harvestMetadata(path) {
	str = File.openAsString(path);
	lines = split(str, "\n");
	for (i = 0; i < lines.length; i++) {
		// Input directory
		if (lines[i].startsWith("Input_directory: ")) {
			inputDir = lines[i].substring(indexOf(lines[i], ":")+2);
		}
		
		// Output directory for ROIs
		if (lines[i].startsWith("Output_ROIs: ")) {
			outputDir1 = lines[i].substring(indexOf(lines[i], ":")+2);
		}
		
		// Output directory for results
		if (lines[i].startsWith("Output_results: ")) {
			outputDir2 = lines[i].substring(indexOf(lines[i], ":")+2);
		}
		
		// File name
		if (lines[i].startsWith("File_name: ")) {
			fileName = lines[i].substring(indexOf(lines[i], ":")+2);
		}

		// File extension
		if (lines[i].startsWith("File_extension: ")) {
			fileExt = lines[i].substring(indexOf(lines[i], ":")+2);
		}
		
		// Analysis
		if (lines[i].startsWith("Analysis: ")) {
			analysisType = lines[i].substring(indexOf(lines[i], ":")+2);
		}
	}
	
	// Check that all metadata are present
	if (inputDir == "") {
		exit("<html>"
			     + "<Center><b>WARNING!</b><br>"
			     + "Input directory not found in the loaded <i>TraitLog</i> file.</Center>");
	}
	if (outputDir1 == "") {
		exit("<html>"
			     + "<Center><b>WARNING!</b><br>"
			     + "Output directory for ROIs not found in the loaded <i>TraitLog</i> file.</Center>");
	}
	if (outputDir2 == "") {
		exit("<html>"
			     + "<Center><b>WARNING!</b><br>"
			     + "Output directory for results not found in the loaded <i>TraitLog</i> file.</Center>");
	}
	if (fileName == "") {
		exit("<html>"
			     + "<Center><b>WARNING!</b><br>"
			     + "Results file name not found in the loaded <i>TraitLog</i> file.</Center>");
	}
	if (fileExt == "") {
		exit("<html>"
			     + "<Center><b>WARNING!</b><br>"
			     + "Results file extension not found in the loaded <i>TraitLog</i> file.</Center>");
	}
	if (analysisType == "") {
		exit("<html>"
			     + "<Center><b>WARNING!</b><br>"
			     + "Type of analysis not found in the loaded <i>TraitLog</i> file.</Center>");
	}
	
	// Check that there is at least one logged image
	if (lines.length < 8) {
		exit("<html>"
			     + "<Center><b>WARNING!</b><br>"
			     + "There are no logged images in the loaded <i>TraitLog</i> file.</Center>");
	}
	
	// If we pass the above, harvest the last analysed image
	lastImg = lines[lines.length-1];
	
	// Check that this does not correspond to any of the metadata
	if (lastImg.startsWith("Input_directory: ") || lastImg.startsWith("Output_ROIs: ") || lastImg.startsWith("Output_results: ") || lastImg.startsWith("File_name: ") || lastImg.startsWith("File_extension: ") || lastImg.startsWith("Analysis: ") || lastImg.startsWith("Date: ")) {
		exit("<html>"
			     + "<Center><b>WARNING!</b><br>"
			     + "The loaded <i>TraitLog</i> file has been manually modified.<br>
			     + "The last analysed image cannot be found.</Center>");
	}
}

// "colnames": function to set column names in the results file (analysis: main, head, gut)
function colnames(analysis) {
	// Separator: comma for csv and tab for txt
	if (fileExt == ".csv") {
		sep = ",";
	} else {
		sep = "\t";
	}
	if (analysis == "main") {
		str = "Image_id" + sep + "px.cm" + sep + "TL" + sep + "SL" + sep + "MBd" + sep + "Hl" + sep + "Hd" + sep + "Ed" + sep + "Eh" + sep + "Snl" + sep + "POC" + sep + "AO" + sep + "EMd" + sep + "EMa" + sep + "Mo" + sep + "Jl" + sep + "Bs" + sep + "CPd" + sep + "CFd" + sep + "CFs" + sep + "PFs" + sep + "PFl" + sep + "PFi" + sep + "PFb" + sep + "time";
	} else if (analysis == "head") {
		str = "Image_id" + sep + "Ha" + sep + "Sa" + sep + "EMa" + sep + "time";
	} else if (analysis == "gut") {
		str = "Image_id" + sep + "px.cm" + sep + "GL" + sep + "GD" + sep + "GS" + sep + "GD1" + sep + "GD2" + sep + "GD3" + sep + "GD4" + sep + "GD5" + sep + "GD6" + sep + "GD7" + sep + "GD8" + sep + "GD9" + sep + "GD10" + sep + "time";
	}
	return str;
}

//------------------------------  FUNCTIONS FOR MAIN ANALYSES  ----------------------------//

var title, titleWithExt, time; // same for all analyses

// "mainAnalysis": Main trait analysis
var TL, SL, Bs, CFs, CFd, CPd, PFs, PFl, PFb, PFi, MBd, Hl, Hd, Ed, POC, AO, Snl, Eh, Mo, Jl, EMd, EMa;
function mainAnalysis() {
	
	t0 = getTime;
	
	// Get image ID and name
	original = getImageID;
	titleWithExt = getTitle();
	title = File.nameWithoutExtension;
	
	// Duplicate image, rename, and close original
	run("Duplicate...", " ");
	copy = getImageID;
	rename(title);
	selectImage(original);
	run("Close");
	
	// Open ROI manager
	run("ROI Manager...");
	roiManager("Show All with labels");
	
	// Set colors
	run("Colors...", "foreground=black background=white selection=red");
	
	// Set scale
	setScale();
	
	// Adjust the image if the fish is bended or not horizontal	
	straightenRotate();
	
	// Image size
	imageSize();
	
	// Orientation
	orientation();
	
	
	// REFERENCE LINES //
	
	// Fish outline
	setTool("Polygon");
	waitForUser("Fish outline", "Trace a polygon following the contour of the \nbody excluding dorsal, pelvic, and anal fins.");
	if (selectionType != 2) {
		showMessage("<html>"
			     + "Polygon selection required!");
		waitForUser("Fish outline", "Trace a polygon following the contour of the \nbody excluding dorsal, pelvic, and anal fins.");
	}
	
	run("Interpolate", "interval=1 smooth adjust");
	run("Fit Spline");
	roiManager("Add");
	
	// Line A - narrowest point of the caudal peduncle
	makeLine(xmid, 0, xmid, h);
	roiAddRename("A");
	waitForUser("Reference lines", "Reference line A: \n \nMove the line to the left or right to adjust its position.\n \nLine A is vertical at the narrowest point of the caudal peduncle.");
	getSelectionCoordinates(x, y);
	xA = x;
	yA = y;
	
	setBatchMode(true);
	
	// Intersection points along A
	Aroi = RoiManager.size - 1;
	APoints = areaXline(Aroi-1, Aroi);
	
	// Bs - Body area
	// CFs - caudal fin area
	// cut the selected area at line E
	if (side == "left") {
		makeRectangle(0, 0, xA[0], h);
		roiManager("Add");
		roiManager("Select", newArray(Aroi-1, Aroi+1));
		roiManager("AND");
		roiAddRename("Bs");
		makeRectangle(xA[0], 0, w, h);
		roiManager("Add");
		roiManager("Select", newArray(Aroi-1, Aroi+3));
		roiManager("AND");
		roiAddRename("CFs");
		roiManager("Select", newArray(Aroi-1, Aroi+1, Aroi+3));
		roiManager("Delete");
	} else {
		makeRectangle(xA[0], 0, w, h);
		roiManager("Add");
		roiManager("Select", newArray(Aroi-1, Aroi+1));
		roiManager("AND");
		roiAddRename("Bs");
		makeRectangle(0, 0, xA[0], h);
		roiManager("Add");
		roiManager("Select", newArray(Aroi-1, Aroi+3));
		roiManager("AND");
		roiAddRename("CFs");
		roiManager("Select", newArray(Aroi-1, Aroi+1, Aroi+3));
		roiManager("Delete");
	}		
	
	// Bs
	bodyroi = RoiManager.size - 2;
	roiManager("Select", bodyroi);
	Bs = getValue("Area");
	
	// Bounding box of body area
	yB = getValue("BY")/pw;
	yC = yB + (getValue("Height")/pw);
	if (side == "left") {
		xD = getValue("BX")/pw;
	} else {
		xD = (getValue("BX")/pw) + (getValue("Width")/pw);
	}
	// Line B - highest edge of the body (excluding fins)
	makeLine(0, yB, w, yB);
	roiAddRename("B");
	// Line C - lowest edge of the body (excluding fins)
	makeLine(0, yC, w, yC);
	roiAddRename("C");
	// Line D - tip of the snout
	makeLine(xD, 0, xD, h);		
	roiAddRename("D");
	
	// CFs
	roiManager("Select", bodyroi+1);
	CFs = getValue("Area");
	
	// Bounding box of caudal fin
	if (side == "left") {
		xE = (getValue("BX")/pw) + (getValue("Width")/pw);
	} else {
		xE = getValue("BX")/pw;
	}
	yF = getValue("BY")/pw;
	yG = yF + (getValue("Height")/pw);
	// Line E - tip of caudal fin
	makeLine(xE, 0, xE, h);
	roiAddRename("E");
	// Line F - highest edge of the caudal fin
	if (side == "left") {
		makeLine(xA[0], yF, w, yF);
	} else {
		makeLine(0, yF, xA[0], yF);
	}
	roiAddRename("F");
	// Line G - lowest edge of the caudal fin
	if (side == "left") {
		makeLine(xA[0], yG, w, yG);
	} else {
		makeLine(0, yG, xA[0], yG);
	}
	roiAddRename("G");
	
	setBatchMode(false);
	
	// Line H - end of standard length
	makeLine(xmid, 0, xmid, h);
	roiAddRename("H");
	waitForUser("Reference lines", "Reference line H: \n \nMove the line to the left or right to adjust its position.\n \nLine H is vertical at the point where the rays of the tail start \nin the middle of the tail (this line marks the end of the standard length).\nFor parrotfishes this is drawn a little different,\ni.e. between the last- and second to last- scales lying along the midline.");
	getSelectionCoordinates(x, y);
	xH = x;
	yH = y;
	
	// Line I - edge of the operculum
	makeLine(xmid, 0, xmid, h);
	roiAddRename("I");
	waitForUser("Reference lines", "Reference line I: \n \nMove the line to the left or right to adjust its position.\n \nLine I is vertical touching the posterior margin\nof the operculum (i.e. bone structure that covers the gills).");
	getSelectionCoordinates(x, y);
	xI = x;
	yI = y;
	
	// Lines J and K - perpendicular lines crossing in the eye centroid
	setTool("Ellipse");
	waitForUser("Reference lines", "Reference line J and K: \n \nTrace an ellipse around the eye.\nTwo perpendicular lines intersecting\nin the eye centroid will be drawn.");
	if (selectionType != 3) {
		showMessage("<html>"
			     + "Elliptical selection required!");
		waitForUser("Reference lines", "Reference line J and K: \n \nTrace an ellipse around the eye.\nTwo perpendicular lines intersecting\nin the eye centroid will be drawn.");
	}
	
	setBatchMode(true);
	
	roiManager("Add");
	xEC = getValue("X")/pw;
	yEC = getValue("Y")/pw;
	// Line J and get intersection point at the anterior margin of the orbit
	makeLine(0, yEC, w, yEC);
	roiAddRename("J");
	Jroi = RoiManager.size - 1;
	eyePoints = areaXline(Jroi-1, Jroi);
	if (side == "left") { // Aeye is the intersection point between line J and the anterior margin of the orbit
		if (eyePoints[0] < eyePoints[2]) {
			xAeye = eyePoints[0];
		} else {
			xAeye = eyePoints[2];
		}
	} else if (side == "right") {
		if (eyePoints[0] < eyePoints[2]) {
			xAeye = eyePoints[2];
		} else {
			xAeye = eyePoints[0];
		}
	}
	// Delete ellipse
	roiManager("Select", Jroi-1);
	roiManager("Delete");
	// Line K
	makeLine(xEC, 0, xEC, h);
	roiAddRename("K");
	Kroi = RoiManager.size - 1;
	
	setBatchMode(false);
	
	// Line L - pectoral fin insertion
	run("Point Tool...", "type=Dot color=Red size=[Extra Large]");
	setTool("point");
	waitForUser("Reference lines", "Reference line L: \n \nClick on the pectoral fin insertion point. After the point appears,\nyou can click and drag it if you need to readjust.");
	if (selectionType != 10) {
		showMessage("<html>"
			     + "Point selection required!");
		waitForUser("Reference lines", "Reference line L: \n \nClick on the pectoral fin insertion point. After the point appears,\nyou can click and drag it if you need to readjust.");
	}
	getSelectionCoordinates(x, y);
	xPF = x;
	yPF = y;
	makeLine(xPF[0], 0, xPF[0], h);
	roiAddRename("L");
	Lroi = RoiManager.size - 1;
	
	
	// TRAITS //
	
	setBatchMode(true);
	
	// Intersection point along J
	Jroi = Kroi - 1;
	JPoints = areaXline(bodyroi, Jroi);
	if (side == "left") {
		if (JPoints[0] < JPoints[2]) {
			xAO = JPoints[0];
		} else {
			xAO = JPoints[2];
		}
	} else {
		if (JPoints[0] < JPoints[2]) {
			xAO = JPoints[2];
		} else {
			xAO = JPoints[0];
		}
	}
	
	// Intersection points along K
	KPoints = areaXline(bodyroi, Kroi);
	
	// Intersection points along L
	LPoints = areaXline(bodyroi, Lroi);
	
	// TL - Total length
	makeLine(xD, yC, xE, yC);
	roiAddRename("TL");
	TL = getValue("Length");
	
	// SL - Standard length
	makeLine(xD, yB, xH[0], yB);
	roiAddRename("SL");
	SL = getValue("Length");
	
	// MBd - Maximum body depth
	xMBd = xI[0] + ((xA[0] - xI[0])/2);
	makeLine(xMBd, yB, xMBd, yC);
	roiAddRename("MBd");
	MBd = getValue("Length");
	
	// Hl - Head length
	makeLine(xD, yC, xI[0], yC);
	roiAddRename("Hl");
	Hl = getValue("Length");
	
	// Hd - Head depth
	makeLine(KPoints[0], KPoints[1], KPoints[2], KPoints[3]);
	roiAddRename("Hd");
	Hd = getValue("Length");
	
	// Ed - Eye diameter
	makeLine(eyePoints[0], eyePoints[1], eyePoints[2], eyePoints[3]);
	roiAddRename("Ed");
	Ed = getValue("Length");
	
	// POC - Posterior of orbit centroid
	makeLine(xEC, yEC, xI[0], yEC);
	roiAddRename("POC");
	POC = getValue("Length");
	
	// AO - Anterior of orbit
	makeLine(xAeye, yEC, xAO, yEC);
	roiAddRename("AO");
	AO = getValue("Length");
	
	// Snl - Snout length
	makeLine(xD, yB, xAeye, yB);
	roiAddRename("Snl");
	Snl = getValue("Length");
	
	// Eh - Eye position
	makeLine(xEC, yC, xEC, yEC);
	roiAddRename("Eh");
	Eh = getValue("Length");
	
	// CPd - Narrowest depth of caudal peduncle
	makeLine(APoints[0], APoints[1], APoints[2], APoints[3]);
	roiAddRename("CPd");
	CPd = getValue("Length");
	
	// CFd - Caudal fin depth
	makeLine(xE, yF, xE, yG);
	roiAddRename("CFd");
	CFd = getValue("Length");
	
	// PFb - Body depth at level of pectoral fin insertion
	makeLine(LPoints[0], LPoints[1], LPoints[2], LPoints[3]);
	roiAddRename("PFb");
	PFb = getValue("Length");
	
	// PFi - Pectoral fin position
	makeLine(xPF[0], yPF[0], xPF[0], yC);
	roiAddRename("PFi");
	PFi = getValue("Length");
	
	setBatchMode(false);
	
	// PFs - Pectoral fin surface area
	setTool("polygon");
	waitForUser("Pectoral fin surface area", "Trace a polygon following the contour of the pectoral fin.");
	if (selectionType != 2) {
		showMessage("<html>"
			     + "Polygon selection required!");
		waitForUser("Pectoral fin surface area", "Trace a polygon following the contour of the pectoral fin.");
	}
	run("Interpolate", "interval=1 smooth adjust");
	run("Fit Spline");
	roiAddRename("PFs");
	PFs = getValue("Area");
	run("Select None");
	
	// PFl - Pectoral fin length
	setTool("line");
	waitForUser("Pectoral fin length", "Trace a line on the longest ray of the pectoral fin.");
	if (selectionType != 5) {
		showMessage("<html>"
			     + "Straight line selection required!");
		waitForUser("Pectoral fin length", "Trace a line on the longest ray of the pectoral fin.");
	}
	roiAddRename("PFl");
	PFl = getValue("Length");
	
	// Mo - Oral gape position
	setTool("Point");
	waitForUser("Oral gape position", "Click on the tip of the premaxilla (upper jaw).\nAfter the point appears, you can click and\ndrag it if you need to readjust.");
	if (selectionType != 10) {
		showMessage("<html>"
			     + "Point selection required!");
		waitForUser("Oral gape position", "Click on the tip of the premaxilla (upper jaw).\nAfter the point appears, you can click and\ndrag it if you need to readjust.");
	}
	getSelectionCoordinates(x, y);
	xUJ = x;
	yUJ = y;
	makeLine(xUJ[0], yUJ[0], xUJ[0], yC);
	roiAddRename("Mo");
	Mo = getValue("Length");
	
	// Jl - Maxillary jaw length
	waitForUser("Maxillary jaw length", "Click on the intersection between the maxilla\nand the mandible (i.e. the corner of the mouth).\nAfter the point appears, you can click and\ndrag it if you need to readjust.");
	if (selectionType != 10) {
		showMessage("<html>"
			     + "Point selection required!");
		waitForUser("Maxillary jaw length", "Click on the intersection between the maxilla\nand the mandible (i.e. the corner of the mouth).\nAfter the point appears, you can click and\ndrag it if you need to readjust.");
	}
	getSelectionCoordinates(x, y);
	xJC = x;
	yJC = y;
	makeLine(xJC[0], yJC[0], xUJ[0], yUJ[0]);
	roiAddRename("Jl");
	Jl = getValue("Length");
	
	setBatchMode(true);
	
	// EMd - Orbit centroid to mouth
	makeLine(xEC, yEC, xUJ[0], yUJ[0]);
	roiAddRename("EMd");
	EMd = getValue("Length");
	
	// EMa - Mouth-eye angle
	makeSelection("angle", newArray(xEC, xUJ[0], xEC), newArray(yEC, yUJ[0], yUJ[0]));
	roiAddRename("EMa");
	EMa = getValue("Angle");
	
	t1 = getTime;
	time = (t1-t0)/1000;
	
	setBatchMode(false);
}

// "headAnalysis": Analysis to measure head angles
var Sa, Ha, EMa;
function headAnalysis() {
	
	t0 = getTime;
	
	// Get image ID and name
	original = getImageID;
	titleWithExt = getTitle();
	title = File.nameWithoutExtension;
	
	// Duplicate image, rename, and close original
	run("Duplicate...", " ");
	copy = getImageID;
	rename(title);
	selectImage(original);
	run("Close");
	
	// Open ROI manager
	run("ROI Manager...");
	roiManager("Show All with labels");
	
	// Set colors
	run("Colors...", "foreground=black background=white selection=red");
	
	// Adjust the image if the fish is bended or not horizontal
	straightenRotate();
	
	// Image size
	imageSize();
	
	// Orientation
	orientation();
	
	
	// REFERENCE LINES AND POINTS //
	
	run("Point Tool...", "type=Dot color=Red size=[Extra Large]");
	run("Line Width...", "line=1");
	
	// Point P1
	setTool("Point");
	waitForUser("Reference Point", "Reference point P1: \n \nClick on the tip of the premaxilla (upper jaw). \nAfter the point appears, you can click and \ndrag it if you need to readjust.");
	if (selectionType != 10) {
		showMessage("<html>"
			     + "Point selection required!");
		waitForUser("Reference Point", "Reference point P1: \n \nClick on the tip of the premaxilla (upper jaw). \nAfter the point appears, you can click and \ndrag it if you need to readjust.");
	}
	getSelectionCoordinates(x, y);
	xP1 = x;
	yP1 = y;
	roiAddRename("P1");


	// Lines
	setTool("Ellipse");
	waitForUser("Reference lines", "Trace an ellipse around the eye.");
	if (selectionType != 3) {
		showMessage("<html>"
			     + "Elliptical selection required!");
		waitForUser("Reference lines", "Trace an ellipse around the eye.");
	}
	
	setBatchMode(true);
	
	roiManager("Add");
	xEC = getValue("X");
	yEC = getValue("Y");
	// Line 1
	makeLine(0, yEC, w, yEC);
	roiAddRename("L1");
	L1roi = RoiManager.size - 1;
	eyePointsH = areaXline(L1roi-1, L1roi);
	if (side == "left") { // Aeye is the intersection point between line L1 and the anterior margin of the orbit
		if (eyePointsH[0] < eyePointsH[2]) {
			xAeye = eyePointsH[0];
		} else {
			xAeye = eyePointsH[2];
		}
	} else if (side == "right") {
		if (eyePointsH[0] < eyePointsH[2]) {
			xAeye = eyePointsH[2];
		} else {
			xAeye = eyePointsH[0];
		}
	}
	// Line 2
	makeLine(xEC, 0, xEC, h);
	roiAddRename("L2");
	L2roi = RoiManager.size - 1;
	eyePointsV = areaXline(L1roi-1, L2roi);
	if (eyePointsV[1] < eyePointsV[3]) {// Ueye is the intersection point between line L2 and the upper margin of the orbit
		yUeye = eyePointsV[1];
	} else {
		yUeye = eyePointsV[3];
	}
	// Line 3
	makeLine(xAeye, 0, xAeye, h);
	roiAddRename("L3");
	// Line 4
	makeLine(0, yUeye, w, yUeye);
	roiAddRename("L4");
	// Get intersection point between L3 and L4
	point34 = lineXline(L2roi+1,L2roi+2);
	makePoint(point34[0], point34[1]);
	// Delete ellipse	
	roiManager("Select", L1roi-1);
	roiManager("Delete");
	// Line 5
	xL5 = xP1[0]+((xAeye-xP1[0])/2);
	makeLine(xL5, 0, xL5, h);
	roiAddRename("L5");
		
	setBatchMode(false);	

	
	// TRAITS //
	
	// Ha - Head angle
	setTool("point");
	waitForUser("Head angle", "Click on the intersection of line L5 with the dorsal margin of the snout.\nYou can click and drag the point if you need to readjust.");
	if (selectionType != 10) {
		showMessage("<html>"
			     + "Point selection required!");
		waitForUser("Head angle", "Click on the intersection of line L5 with the dorsal margin of the snout.\nYou can click and drag the point if you need to readjust.");
	}
	getSelectionCoordinates(x, y);
	xL5up = x;
	yL5up = y;
	makeSelection("angle", newArray(point34[0], xL5up[0], xP1[0]), newArray(point34[1], yL5up[0], yP1[0]));
	roiAddRename("Ha");
	Ha = getValue("Angle");
	
	// Correct Ha if it is concave
	angle1 = measureAngle(xP1[0], yP1[0], point34[0], point34[1]);
	angle2 = measureAngle(xL5up[0], yL5up[0], point34[0], point34[1]);
	if (angle2 > angle1){
		Ha = 360-Ha;
	}
	
	// Sa - Snout angle
	waitForUser("Snout angle", "Click on the intersection of line L5 with the ventral margin of the snout.\nYou can click and drag the point if you need to readjust.");
	if (selectionType != 10) {
		showMessage("<html>"
			     + "Point selection required!");
		waitForUser("Snout angle", "Click on the intersection of line L5 with the ventral margin of the snout.\nYou can click and drag the point if you need to readjust.");
	}
	getSelectionCoordinates(x, y);
	xL5low = x;
	yL5low = y;
	makeSelection("angle", newArray(xL5up[0], xP1[0], xL5low[0]), newArray(yL5up[0], yP1[0], yL5low[0]));
	roiAddRename("Sa");
	Sa = getValue("Angle");
	
	// EMa - Eye-Mouth angle
	makeSelection("angle", newArray(xEC, xP1[0], xEC), newArray(yEC, yP1[0], yP1[0]));
	roiAddRename("EMa");
	EMa = getValue("Angle");
	
	t1 = getTime;
	time = (t1-t0)/1000;
}

// "gutAnalysis": Analysis to measure intestinal traits
var GL, GD, GS, GD1, GD2, GD3, GD4, GD5, GD6, GD7, GD8, GD9, GD10;
function gutAnalysis() {
	
	t0 = getTime;
	
	// Get image ID and name
	original = getImageID;
	titleWithExt = getTitle();
	title = File.nameWithoutExtension;
		
	// Duplicate image, rename, and close original
	run("Duplicate...", " ");
	copy = getImageID();
	rename(title);
	selectImage(original);
	run("Close");
	
	// Open ROI manager
	run("ROI Manager...");
	roiManager("Show All with labels");
	
	// Set colors
	run("Colors...", "foreground=black background=white selection=red");
	
	// Set scale
	setScale();
	
	// Intestinal length
	setTool("Polyline");
	waitForUser("Intestinal length", "Trace a segmented line from the pyloric outlet to the anus\n(or from the oesophagus to the anus in stomachless fishes )\nfollowing the midline of the intestine.");
	if (selectionType != 6) {
		showMessage("<html>"
		     + "Segmented line selection required!");
		waitForUser("Intestinal length", "Trace a segmented line from the pyloric outlet to the anus\n(or from the oesophagus to the anus in stomachless fishes )\nfollowing the midline of the intestine.");
	}
	run("Interpolate", "interval=1 smooth adjust");
	run("Fit Spline");
	roiAddRename("GL");
	GL = getValue("Length");
	
	// Intestinal diameter
	// Add 10 points at equal distance
	getSelectionCoordinates(x, y);
	xp = newArray(11);
	yp = newArray(11);
	for (i = 0; i < xp.length; i++) {
		xp[i] = x[i*x.length/11];
		yp[i] = y[i*x.length/11];
	}
	xp = Array.slice(xp, 1); // remove first point
	yp = Array.slice(yp, 1);
	makeSelection("Point", xp, yp);
	run("Point Tool...", "type=Dot color=Red size=[Extra Large]");
	roiAddRename("Points");
	run("Select None");
	
	// 10 diameters
	setTool("Line");
	waitForUser("Intestinal diameter", "At the level of the 1st point, moving from the \noesophagus to the anus, trace a straight line \nperpendicular to the midline of the intestine \nand joining the two margins.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "At the level of the 1st point, moving from the \noesophagus to the anus, trace a straight line \nperpendicular to the midline of the intestine \nand joining the two margins.");
	}
	roiAddRename("GD1");
	GD1 = getValue("Length");
	waitForUser("Intestinal diameter", "Now do the same at the 2nd point.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "Now do the same at the 2nd point.");
	}
	roiAddRename("GD2");
	GD2 = getValue("Length");
	waitForUser("Intestinal diameter", "Now do the same at the 3rd point.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "Now do the same at the 3rd point.");
	}
	roiAddRename("GD3");
	GD3 = getValue("Length");
	waitForUser("Intestinal diameter", "Now do the same at the 4th point.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "Now do the same at the 4th point.");
	}
	roiAddRename("GD4");
	GD4 = getValue("Length");
	waitForUser("Intestinal diameter", "Now do the same at the 5th point.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "Now do the same at the 5th point.");
	}
	roiAddRename("GD5");
	GD5 = getValue("Length");
	waitForUser("Intestinal diameter", "Now do the same at the 6th point.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "Now do the same at the 6th point.");
	}
	roiAddRename("GD6");
	GD6 = getValue("Length");
	waitForUser("Intestinal diameter", "Now do the same at the 7th point.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "Now do the same at the 7th point.");
	}
	roiAddRename("GD7");
	GD7 = getValue("Length");
	waitForUser("Intestinal diameter", "Now do the same at the 8th point.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "Now do the same at the 8th point.");
	}
	roiAddRename("GD8");
	GD8 = getValue("Length");
	waitForUser("Intestinal diameter", "Now do the same at the 9th point.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "Now do the same at the 9th point.");
	}
	roiAddRename("GD9");
	GD9 = getValue("Length");
	waitForUser("Intestinal diameter", "Now do the same at the 10th point.");
	if (selectionType != 5) {
		showMessage("<html>"
		     + "Straight line selection required!");
		waitForUser("Intestinal diameter", "Now do the same at the 10th point.");
	}
	roiAddRename("GD10");
	GD10 = getValue("Length");
	
	// Mean intestinal diameter
	GD = (GD1+GD2+GD3+GD4+GD5+GD6+GD7+GD8+GD9+GD10)/10;
	
	// Intestinal surface area
	GS = 2*PI*(GD/2)*GL;
	
	t1 = getTime;
	time = (t1-t0)/1000;
}

//-----------------------------  FUNCTIONS FOR SAVING RESULTS  ----------------------------//

// "setMainTable": Fill in the main analysis results table
function setMainTable(i) {
	Table.set("image_id", i, title);
	Table.set("px.cm", i, 1/pw);
	Table.set("TL", i, TL);
	Table.set("SL", i, SL);
	Table.set("MBd", i, MBd);
	Table.set("Hl", i, Hl);
	Table.set("Hd", i, Hd);
	Table.set("Ed", i, Ed);
	Table.set("Eh", i, Eh);
	Table.set("Snl", i, Snl);
	Table.set("POC", i, POC);
	Table.set("AO", i, AO);
	Table.set("EMd", i, EMd);
	Table.set("EMa", i, EMa);
	Table.set("Mo", i, Mo);
	Table.set("Jl", i, Jl);
	Table.set("Bs", i, Bs);
	Table.set("CPd", i, CPd);
	Table.set("CFd", i, CFd);
	Table.set("CFs", i, CFs);
	Table.set("PFs", i, PFs);
	Table.set("PFl", i, PFl);
	Table.set("PFi", i, PFi);
	Table.set("PFb", i, PFb);
	Table.set("time", i, time);
}

// "setHeadTable": Fill in the head analysis results table
function setHeadTable(i) {
	Table.set("image_id", i, title);
	Table.set("Ha", i, Ha);
	Table.set("Sa", i, Sa);
	Table.set("EMa", i, EMa);
	Table.set("time", i, time);
}

// "setGutTable": Fill in the gut analysis results table
function setGutTable(i) {
	Table.set("image_id", i, title);
	Table.set("px.cm", i, 1/pw);
	Table.set("GL", i, GL);
	Table.set("GD", i, GD);
	Table.set("GS", i, GS);
	Table.set("GD1", i, GD1);
	Table.set("GD2", i, GD2);
	Table.set("GD3", i, GD3);
	Table.set("GD4", i, GD4);
	Table.set("GD5", i, GD5);
	Table.set("GD6", i, GD6);
	Table.set("GD7", i, GD7);
	Table.set("GD8", i, GD8);
	Table.set("GD9", i, GD9);
	Table.set("GD10", i, GD10);
	Table.set("time", i, time);
}

// "saveResults": append results to the csv or txt file (analysis: main, head, gut)
function saveResults(analysis) {
	if (fileExt == ".csv") {
		sep = ",";
	} else {
		sep = "\t";
	}
	if (analysis == "main") {
		str = title + sep + 1/pw + sep + TL + sep + SL + sep + MBd + sep + Hl + sep + Hd + sep + Ed + sep + Eh + sep + Snl + sep + POC + sep + AO + sep + EMd + sep + EMa + sep + Mo + sep + Jl + sep + Bs + sep + CPd + sep + CFd + sep + CFs + sep + PFs + sep + PFl + sep + PFi + sep + PFb + sep + time;
	} else if (analysis == "head") {
		str = title + sep + Ha + sep + Sa + sep + EMa + sep + time;
	} else if (analysis == "gut") {
		str = title + sep + 1/pw + sep + GL + sep + GD + sep + GS + sep + GD1 + sep + GD2 + sep + GD3 + sep + GD4 + sep + GD5 + sep + GD6 + sep + GD7 + sep + GD8 + sep + GD9 + sep + GD10 + sep + time;
	}
	File.append(str, filePath);
}

// "saveAdjustedImages": save rotated and straightened images as jpg files
function saveAdjustedImages() {
	if (straighten == 1) {
		saveAs("Jpeg", outputDir1 + title + "_straightened");
	} else if (straighten == 0 && rotate == 1) {
		saveAs("Jpeg", outputDir1 + title + "_rotated");
	}
}

//---------------------------  FUNCTIONS FOR COMPLETE ANALYSIS  ---------------------------//

// "singleAnalysis": run analysis on single image (analysis: main, head, gut)
function singleAnalysis(analysis) {

	// Check image
	imageCheck("s");
	
	// Analysis
	if (analysis == "main") {
		mainAnalysis();
	} else if (analysis == "head") {
		headAnalysis();
	} else if (analysis == "gut") {
		gutAnalysis();
	}
	
	// Results
	Table.create("Traits");
	if (analysis == "main") {
		setMainTable(0);
	} else if (analysis == "head") {
		setHeadTable(0);
	} else if (analysis == "gut") {
		setGutTable(0);
	}
}

// "multiAnalysis": run analysis on multiple images (analysis: main, head, gut; type: new, continued)
function multiAnalysis(analysis, type) {
	
	// Check image
	imageCheck("m");
	
	// Setup
	if (type == "new") {
		setupMultiAnalysis(analysis);
	} else {
		continuedAnalysis(analysis);
	}
		
	// Loop over selected images
	for (i = 0; i < newList.length; i++) {
		
		// Open image
		open(inputDir + newList[i]);

		// Analysis
		if (analysis == "main") {
			mainAnalysis();
		} else if (analysis == "head") {
			headAnalysis();
		} else if (analysis == "gut") {
			gutAnalysis();
		}
		
		// OUTPUT //
		
		// Save ROIs
		roiManager("Deselect");
		if (analysis == "main") {
			roiset = "_RoiSet_Main.zip";
		} else if (analysis == "head") {
			roiset = "_RoiSet_Head.zip";
		} else if (analysis == "gut") {
			roiset = "_RoiSet_Gut.zip";
		}
		roiManager("Save", outputDir1 + title + roiset);
		selectWindow("ROI Manager");
		run("Close");
		
		// Save image if rotated or straightened
		saveAdjustedImages();
		
		// Save results
		saveResults(analysis);
		
		// Add image title to TraitLog file
		File.append(titleWithExt, logFile);
		
		// Close image
		close();
	}
exit;
}

//----------------------------------------  MACROS  ---------------------------------------//

// Main Traits - single image
macro "Main Traits" {
	singleAnalysis("main");
}

// Main Traits - multiple images, new analysis
macro "Main Traits Multi" {
	multiAnalysis("main", "new");
}

// Main Traits - multiple images, continued analysis
macro "Main Traits Cont" {
	multiAnalysis("main", "continued");
}

// Head Angles - single image
macro "Head Angles" {
	singleAnalysis("head");	
}

// Head Angles - multiple images, new analysis
macro "Head Angles Multi" {
	multiAnalysis("head", "new");
}

// Head Angles - multiple images, continued analysis
macro "Head Angles Cont" {
	multiAnalysis("head", "continued");
}

// Gut Traits - single image
macro "Gut Traits" {
	singleAnalysis("gut");
}

// Gut Traits - multiple images, new analysis
macro "Gut Traits Multi" {
	multiAnalysis("gut", "new");
}

// Gut Traits - multiple images, continued analysis
macro "Gut Traits Cont" {
	multiAnalysis("gut", "continued");
}


