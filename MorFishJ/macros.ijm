//-----------------------------------------------------------------------------------------//
//                                                                                         //
//                                  MorFishJ v0.3.0.9999                                   //
//                                                                                         //
//                             Set of ImageJ macros to measure                             //
//                          morphological traits from fish images.                         //
//                                                                                         //
//                                 Author: Mattia Ghilardi                                 //
//                               mattia.ghilardi91@gmail.com                               //
//                                  September 23rd, 2025                                   //
//                                                                                         //
//-----------------------------------------------------------------------------------------//

// MorFishJ and ImageJ versions
var MorFishJ_version = "v0.3.0", ImageJ_version = "1.53s";

// Check ImageJ version
var v = versionCheck();

// "versionCheck": Check ImageJ version at install time
function versionCheck() {
    requires(ImageJ_version);
    return 1;
}

//-------------------------------- HELPER FUNCTIONS  --------------------------------------//

function skipImage() { 
  // Provides the option to skip the current image and to add a comment.
  // Returns an array with two elements:
  // 0 - a string with the remark;
  // 1 - logical indicating whether to skip the image (1) or not (0)
  
  help = "https://mattiaghilardi.github.io/MorFishJ_manual/" + MorFishJ_version + "/image_quality.html";
  message = "Write any remark to the current image if needed,\n" +
            "or select 'Skip image' to skip the current image\n" +
            "and move to the next, then click OK.";
  Dialog.create("Set scale");
  Dialog.create("Image quality");
  Dialog.setInsets(0, 0, 0);
  Dialog.addMessage(message);
  //Dialog.addSlider("Quality", 0, 5, 5); // slider to select level of image quality from 0 to 5
  Dialog.addString("Remarks", "", 30);
  Dialog.addCheckbox("Skip image", false);
  Dialog.addHelp(help);
  Dialog.show();
  
  //quality = Dialog.getNumber();
  remark = Dialog.getString();
  skip = Dialog.getCheckbox();
  
  return newArray(remark, skip);
}

// "checkImage": Check that one image is open for single image analysis and none for multiple analysis
function checkImage(type) { // type: single (s) or multiple (m) analysis
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

// "duplicateImage": Duplicate image and get name with and without extension
var titleWithExt = "", title = "", copy = "";
function duplicateImage() {
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
}

// "getImageSize": Get image's width and height and the center's coordinates
var h = 0, w = 0, ymid = 0, xmid = 0;
function getImageSize() {
  h = getHeight;
  w = getWidth;
  ymid = h / 2;
  xmid = w / 2;
}

// "getOrientation": Get fish orientation
var side = "left";
function getOrientation() {
  message = "Which side is the fish facing?";
  Dialog.create("Orientation");
  Dialog.setInsets(0, 0, 0);
  Dialog.addMessage(message);
  Dialog.setInsets(5, 25, 5);
  Dialog.addChoice("", newArray("left", "right"));
  Dialog.show();
  side = Dialog.getChoice();
}

// "setScale": Set scale
var pw = "";
function setScale() {
  do {
    run("Select None");
    setTool("Line");
    run("Line Width...", "line=1");
    message = "Trace a line on a reference\n" +
              "object of known length.";
    waitForUser("Set scale", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  
  roiManager("Add");
  help = "https://mattiaghilardi.github.io/MorFishJ_manual/" + MorFishJ_version + "/set_scale.html#gut-traits-scale";
  message = "Please enter the known length\n" +
            "and select the unit of measurement.\n" +
            "Any unit will be converted to 'cm'.";
  Dialog.create("Set scale");
  Dialog.setInsets(0, 0, 0);
  Dialog.addMessage(message);
  Dialog.setInsets(5, 15, 5);
  Dialog.addNumber("Known length:", 0);
  Dialog.setInsets(5, 15, 5);
  Dialog.addChoice("Unit:", newArray("mm", "cm", "inch"));
  Dialog.addHelp(help);
  Dialog.show();
  num = Dialog.getNumber();
  unit = Dialog.getChoice();
  if (unit == "mm") {
    num = num / 10;
  } else if  (unit == "inch") {
    num = num * 2.54;
  }
  run("Set Scale...", "known=num unit=cm");
  getPixelSize(unit, pw, ph);
  roiManager("Select", 0);
  roiManager("Rename", "px." + unit);
  run("Select None");
}

// "getScale": Get scale for the image if available
var pxcm = "NA";
function getScale() {
  help = "https://mattiaghilardi.github.io/MorFishJ_manual/" + MorFishJ_version + "/set_scale.html#main-traits-scale";
  message = "Please select the appropriate option to add\n" +
            "a scale to the image. If none is available\n" +
            "click OK and continue without scale.";
  Dialog.create("Image scale");
  Dialog.setInsets(0, 0, 0);
  Dialog.addMessage(message);
  Dialog.setInsets(5, 50, 0);
  Dialog.addCheckbox("Reference object", false);
  Dialog.setInsets(5, 50, 0);
  Dialog.addCheckbox("Known fish length", false);
  Dialog.addHelp(help);
  Dialog.show();

  refObj = Dialog.getCheckbox();
  fishLength = Dialog.getCheckbox();
  
  if (refObj == 1) {
    getRefScale();
  } 
  else if (refObj == 0 && fishLength == 1) {
    getFishLength();
  }
  //else if (refObj == 0 && fishLength == 0) {
  //	pxcm = "NA";
  //}
}

// "getRefScale": Get scale from reference object
function getRefScale() {
  do {
    run("Select None");
    setTool("Line");
    run("Line Width...", "line=1");
    message = "Trace a line on a reference\n" +
              "object of known length.";
    waitForUser("Reference scale", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  
  roiManager("Add");
  px = getValue("Length");
  help = "https://mattiaghilardi.github.io/MorFishJ_manual/" + MorFishJ_version + "/set_scale.html#scale-through-reference-object";
  message = "Please enter the known length\n" +
            "and select the unit of measurement.";
  Dialog.create("Reference scale");
  Dialog.setInsets(0, 0, 0);
  Dialog.addMessage(message);
  Dialog.setInsets(5, 15, 5);
  Dialog.addNumber("Known length:", 0);
  Dialog.setInsets(5, 15, 5);
  Dialog.addChoice("Unit:", newArray("mm", "cm", "inch"));
  Dialog.addHelp(help);
  Dialog.show();
  num = Dialog.getNumber();
  unit = Dialog.getChoice();
  if (unit == "mm") {
    num = num / 10;
  } else if  (unit == "inch") {
    num = num * 2.54;
  }
  unit = "cm";
  pxcm = px / num;
  roiManager("Select", 0);
  roiManager("Rename", "px." + unit);
  run("Select None");
}

// "getFishLength": Get known fish length (standard or total)
var length = "NA", lengthType = "NA";
function getFishLength() {
  help = "https://mattiaghilardi.github.io/MorFishJ_manual/" + MorFishJ_version + "/set_scale.html#scale-through-fish-length";
  message = "Please enter the known length of the\n" +
            "fish, select the unit of measurement\n" +
            "and the type of length measured.";
  Dialog.create("Known fish length");
  Dialog.setInsets(0, 0, 0);
  Dialog.addMessage(message);
  Dialog.setInsets(5, 40, 5);
  Dialog.addNumber("Fish length:", 0);
  Dialog.setInsets(5, 40, 5);
  Dialog.addChoice("Unit:", newArray("mm", "cm", "inch"));
  Dialog.setInsets(5, 40, 5);
  Dialog.addChoice("Length type:", newArray("standard", "total"));
  Dialog.addHelp(help);
  Dialog.show();
  length = Dialog.getNumber();
  unit = Dialog.getChoice();
  lengthType = Dialog.getChoice();
  if (unit == "mm") {
    length = length / 10;
  } else if  (unit == "inch") {
    length = length * 2.54;
  }
}

// "measureAngle": Measure angle in degrees between a line and the horizontal axis.
// This function differ from the built in function as it is not sensitive to the direction in which the line is drawn (left to right or right to left).
function measureAngle(x1, y1, x2, y2) {
  dx = x2 - x1;
  dy = y1 - y2;
  angle = (180.0 / PI) * atan(dy / dx);
  return angle;
}

//// "rotateImage": Rotate an image based on the angle of a straight line selection.
//function rotateImage(x1, y1, x2, y2) {
//	angle = measureAngle(x1, y1, x2, y2);
//	run("Rotate... ", "angle=" + angle + " interpolation=Bilinear fill");
//	return angle;
//}

// "straightenRotate": Adjust the image if the fish is bended or not horizontal
var straighten = 0, rotate = 0;
//var rotationAngle = 0; // to report the angle of rotation
function straightenRotate() {
  help = "https://mattiaghilardi.github.io/MorFishJ_manual/" + MorFishJ_version + "/straighten_rotate.html";
  message = "The fish must be straight and horizontal.\n" +
            "If this is the case click OK, if not,\n" +
            "check the box with the required action.";
  Dialog.create("Image adjustment");
  Dialog.setInsets(0, 0, 0);
  Dialog.addMessage(message);
  Dialog.setInsets(5, 70, 0);
  Dialog.addCheckbox("Straighten", false);
  Dialog.setInsets(5, 70, 0);
  Dialog.addCheckbox("Rotate", false);
  Dialog.addHelp(help);
  Dialog.show();
  
  straighten = Dialog.getCheckbox();
  rotate = Dialog.getCheckbox();
  
  if (straighten == 1) {
    do {
      run("Select None");
      setTool("Polyline");
      run("Line Width... ");
      message = "Create a segmented line selection following the midline of the fish.\n" +
                "The selection must extend from both the snout and caudal fin.\n" +
                " \n" +
                "Adjust the selection as needed, then, using the 'Line Width' window,\n" +
                "increase the line width until the whole fish falls within the shaded area.\n" +
                " \n" +
                "Once happy with the selection click OK.";
      waitForUser("Straighten fish", message);
      if (selectionType != 6) {
        showMessage("<html>"
                  + "Segmented line selection required!");
      }
    } while (selectionType != 6);
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
    do {
      run("Select None");
      setTool("Line");
      message = "Trace a straight line with the same orientation as the fish.\n" +
                "The image will be rotated based on the angle of the line selection.";
      waitForUser("Rotate image", message);
      if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
      }
    } while (selectionType != 5);
    
///////////////////////////////////////////////////////////////////////////////////////////////////////
// ALTERNATIVE: insted of tracing a line open the rotate dialog and then extract angle once finished?
// 	run("Rotate... ");
// 	rotationAngle = getValue("rotation.angle");
///////////////////////////////////////////////////////////////////////////////////////////////////////

    getLine(x1, y1, x2, y2, lineWidth);
    rotationAngle = measureAngle(x1, y1, x2, y2);
    nROI = RoiManager.size;
    allROIs = newArray(nROI);
    for (i = 0; i < allROIs.length; i++){
      allROIs[i] = i;
    }
    roiManager("Select", allROIs);
    RoiManager.rotate(rotationAngle, getWidth / 2, getHeight / 2);
    run("Rotate... ", "angle=" + rotationAngle + " interpolation=Bilinear fill"); // possibility to add enlarge to avoid cropping but existing ROIs would be translated
  }
}

// "roiAddRename": Add selection to ROI Manager with custom name
function roiAddRename(name) {
  roiManager("Add");
  nROI = RoiManager.size;
  roiManager("Select", (nROI - 1));
  roiManager("Rename", name);
  run("Labels...", "color=white font=12 show use draw bold");
}

// "lineXline": Intersection point between two lines
function lineXline(a, b) { // a and b are strings, the names of two ROIs representing lines
  RoiManager.selectByName(a);
  run("Line to Area");
  roiAddRename("a1");
  RoiManager.selectByName(b);
  run("Line to Area");
  roiAddRename("b1");
  a1 = RoiManager.getIndex("a1");
  b1 = RoiManager.getIndex("b1");
  roiManager("Select", newArray(a1, b1));
  roiManager("AND");
  roiAddRename("c");
  RoiManager.selectByName("c");
  getSelectionCoordinates(x, y);
  x = x[0];
  y = y[0];
  c = RoiManager.getIndex("c");
  roiManager("Select", newArray(a1, b1, c));
  roiManager("Delete");
  coord = newArray(x, y);
  return coord;
}

// "areaXline": Intersection points between two ROIs, the first an area and the second a straight line
// Modified from: https://forum.image.sc/t/how-to-get-xy-coordinate-of-selection-line-crossing-a-roi/6923/6

function extrema(p) {
  for (i = 1; i < p.length; i++) {
    p[i-1] = abs(p[i] - p[i-1]);
  }
}
function intersection(xx, yy, s, p) {
  for (i = 0; i < 2; i++) {
    if (i > 0) { 
      sign = -1; 
    } else { 
      sign = 1; 
    }
    dx = sign * sqrt(pow(p[i], 2) / (1 + pow(s, 2)));
    xx[i] += dx;
    if (s != 1/0) { 
      yy[i] -= s * dx; 
    } else { 
      yy[i] += sign * p[i]; 
    }
  }
}
function areaXline(a, b) { // a and b are strings, the names of two ROIs
  RoiManager.selectByName(a);
  run("Create Mask");
  RoiManager.selectByName(b);
  if (selectionType != 5) {
    exit("<html>"
       + "Straight line selection required!");
  }
  getSelectionCoordinates(x, y);
  slp = -(y[0] - y[1]) / (x[0] - x[1]);
  len = sqrt(pow(x[0] - x[1], 2) + pow(y[0] - y[1], 2));
  profile = getProfile();
  extrema(profile);
  profile = Array.findMaxima(profile, 0, 1);
  for (i = 0; i < 2; i++) {
    profile[i] = profile[i] + 1;
  }
  profile[1] = len - profile[1];
  intersection(x, y, slp, profile);
  point1 = newArray(round(x[0]), round(y[0]));
  point2 = newArray(round(x[1]), round(y[1]));
  points = Array.concat(point1, point2);
  close("Mask");
  return points;
}

//---------------  FUNCTIONS FOR SETTING UP OR CONTINUING MULTIPLE ANALYSES  --------------//

var inputDir = "", outputDir1 = "", outputDir2 = "";
var fileName = "", fileExt = "", filePath "";
var analysisType = "";
var lastImg = "";
var logFile = "";
var newList = "";

// "continuedAnalysis": load TraitLog file and harvest metadata (analysis: main, head, gut)
function continuedAnalysis(analysis) {

  // Dialog
  help = "https://mattiaghilardi.github.io/MorFishJ_manual/" + MorFishJ_version + "/GUI.html#continued-analysis";
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
      //inputDir = ""; outputDir1 = ""; outputDir2 = ""; fileName = ""; fileExt = ""; analysisType = "";
      harvestMetadata(logFile);
      
      // Check that the type of analysis selected matches that in the metadata
      if (analysis != analysisType) {
        exit("<html>"
           + "<Center><b>WARNING!</b><br>"
           + "The selected analysis differ from that<br>"
           + "registered in the <i>TraitLog</i> file.</Center>");
      }
      
      // Check that the last logged image matches one in the input directory
      fileListIn = getFileList(inputDir);
      //newList = "";
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
  help = "https://mattiaghilardi.github.io/MorFishJ_manual/" + MorFishJ_version + "/GUI.html#new-analysis";
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
  month = month + 1;
  if (month < 10) {
    month = "0" + month;
  }
  if (dayOfMonth < 10) {
    dayOfMonth = "0" + dayOfMonth;
  } else {
    dayOfMonth = d2s(dayOfMonth, 0);
  }
  date = dayOfMonth + sep + month + sep + year;
  
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
      inputDir = lines[i].substring(indexOf(lines[i], ":") + 2);
    }
    
    // Output directory for ROIs
    if (lines[i].startsWith("Output_ROIs: ")) {
      outputDir1 = lines[i].substring(indexOf(lines[i], ":") + 2);
    }
    
    // Output directory for results
    if (lines[i].startsWith("Output_results: ")) {
      outputDir2 = lines[i].substring(indexOf(lines[i], ":") + 2);
    }
    
    // File name
    if (lines[i].startsWith("File_name: ")) {
      fileName = lines[i].substring(indexOf(lines[i], ":") + 2);
    }

    // File extension
    if (lines[i].startsWith("File_extension: ")) {
      fileExt = lines[i].substring(indexOf(lines[i], ":") + 2);
    }
    
    // Analysis
    if (lines[i].startsWith("Analysis: ")) {
      analysisType = lines[i].substring(indexOf(lines[i], ":") + 2);
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
  lastImg = lines[lines.length - 1];
  
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
    str = newArray("Image_id", "px.cm", "TL", "SL", "MBd", "Hl", "Hd", "Ed", "Eh", "Snl", "POC", "AO", "EMd", "EMa", "Mo", "Jl", "Bs", "CPd", "CFd", "CFs", "PFs", "PFl", "PFi", "PFb", "remark", "time");
  } else if (analysis == "head") {
    str = newArray("Image_id", "Ha", "Sa", "EMa", "remark", "time");
  } else if (analysis == "gut") {
    str = newArray("Image_id", "px.cm", "GL", "GD", "GS", "GD1", "GD2", "GD3", "GD4", "GD5", "GD6", "GD7", "GD8", "GD9", "GD10", "remark", "time");
  }
  str = String.join(str, sep);
  return str;
}

//------------------------------  FUNCTIONS FOR MAIN ANALYSES  ----------------------------//

var title = "", titleWithExt = "", time = ""; // same for all analyses

// "mainAnalysis": Main trait analysis
var TL = "", SL = "";
var Bs = "";
var CFs = "", CFd = "", CPd = "";
var PFs = "", PFl = "", PFb = "", PFi = "";
var MBd = "";
var Hl = "", Hd = "";
var Ed = "", POC = "", AO = "", Snl = "", Eh = "", Mo = "", Jl = "", EMd = "", EMa = "";
function mainAnalysis() {
  
  t0 = getTime;
  
  // Set scale
  getScale();
  
  // Adjust the image if the fish is bended or not horizontal	
  straightenRotate();
  
  // Image size
  getImageSize();
  
  // Orientation
  getOrientation();
  
  
  // REFERENCE LINES //
  
  // Fish outline
  do {
    run("Select None");
    setTool("Polygon");
    message = "Trace a polygon following the contour of the body including\n" +
            "the caudal fin, but excluding dorsal, pelvic, and anal fins.\n" +
            " \n" +
            "If the pectoral fin extends outside the body, follow the\n" +
            "imaginary contour of the body under the fin.";
    waitForUser("Fish outline", message);
    if (selectionType != 2) {
      showMessage("<html>"
                + "Polygon selection required!");
    }
  } while (selectionType != 2);
  run("Interpolate", "interval=1 smooth adjust");
  run("Fit Spline");
  roiAddRename("outline");
  outlineroi = RoiManager.size - 1;
  
  // Line A - narrowest point of the caudal peduncle
  makeLine(xmid, 0, xmid, h);
  roiAddRename("A");
  message = "Reference line A: \n" +
            " \n" +
            "Move the line to the left or right to adjust its position.\n" +
            " \n" +
            "Line A is vertical at the narrowest point of the caudal peduncle.";
  waitForUser("Reference lines", message);
  getSelectionCoordinates(x, y);
  xA = x;
  yA = y;
  
  setBatchMode(true);
  
  // Intersection points along A
  //Aroi = RoiManager.size - 1;
  APoints = areaXline("outline", "A");
  
  // Bs - Body area
  // CFs - caudal fin area
  // cut the selected area at line E
  if (side == "left") {
    makeRectangle(0, 0, xA[0], h);
    roiManager("Add");
    rect1roi = RoiManager.size - 1;
    roiManager("Select", newArray(outlineroi, rect1roi));
    roiManager("AND");
    roiAddRename("Bs");
    makeRectangle(xA[0], 0, w, h);
    roiManager("Add");
    rect2roi = RoiManager.size - 1;
    roiManager("Select", newArray(outlineroi, rect2roi));
    roiManager("AND");
    roiAddRename("CFs");
    roiManager("Select", newArray(rect1roi, rect2roi));
    roiManager("Delete");
  } else {
    makeRectangle(xA[0], 0, w, h);
    roiManager("Add");
    rect1roi = RoiManager.size - 1;
    roiManager("Select", newArray(outlineroi, rect1roi));
    roiManager("AND");
    roiAddRename("Bs");
    makeRectangle(0, 0, xA[0], h);
    roiManager("Add");
    rect2roi = RoiManager.size - 1;
    roiManager("Select", newArray(outlineroi, rect2roi));
    roiManager("AND");
    roiAddRename("CFs");
    roiManager("Select", newArray(rect1roi, rect2roi));
    roiManager("Delete");
  }		
  
  // Bs
  //bodyroi = RoiManager.size - 2;
  RoiManager.selectByName("Bs");
  Bs = getValue("Area");
  
  // Bounding box of body area
  yB = getValue("BY");
  yC = yB + getValue("Height");
  if (side == "left") {
    xD = getValue("BX");
  } else {
    xD = getValue("BX") + getValue("Width");
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
  RoiManager.selectByName("CFs");
  CFs = getValue("Area");
  
  // Bounding box of caudal fin
  if (side == "left") {
    xE = getValue("BX") + getValue("Width");
  } else {
    xE = getValue("BX");
  }
  yF = getValue("BY");
  yG = yF + getValue("Height");
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
  message = "Reference line H: \n" +
            " \n" +
            "Move the line to the left or right to adjust its position.\n" +
            " \n" +
            "Line H is vertical at the point where the rays of the tail start in the\n" +
            "middle of the tail (this line marks the end of the standard length).\n" +
            " \n" +
            "For parrotfishes this is drawn a little different,\n" +
            "i.e. between the last- and second to last- scales lying along the midline.";
  waitForUser("Reference lines", message);
  getSelectionCoordinates(x, y);
  xH = x;
  yH = y;
  
  // Line I - edge of the operculum
  makeLine(xmid, 0, xmid, h);
  roiAddRename("I");
  message = "Reference line I: \n" +
            " \n" +
            "Move the line to the left or right to adjust its position.\n" +
            " \n" +
            "Line I is vertical touching the posterior margin of the\n" +
            "operculum (i.e. bone structure that covers the gills).";
  waitForUser("Reference lines", message);
  getSelectionCoordinates(x, y);
  xI = x;
  yI = y;
  
  // Lines J and K - perpendicular lines crossing in the eye centroid
  do {
    run("Select None");
    setTool("Ellipse");
    message = "Reference line J and K: \n" +
              " \n" +
              "Trace an ellipse around the eye.\n" +
              "Two perpendicular lines intersecting\n" +
              "in the eye centroid will be drawn.";
    waitForUser("Reference lines", message);
    if (selectionType != 3) {
      showMessage("<html>"
                + "Elliptical selection required!");
    }
  } while (selectionType != 3);
  
  setBatchMode(true);
  
  roiAddRename("eye");
  xEC = getValue("X");
  yEC = getValue("Y");
  // Line J and get intersection point at the anterior margin of the orbit
  makeLine(0, yEC, w, yEC);
  roiAddRename("J");
  //Jroi = RoiManager.size - 1;
  eyePoints = areaXline("eye", "J");
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
  //roiManager("Select", Jroi - 1);
  //roiManager("Delete");
  // Line K
  makeLine(xEC, 0, xEC, h);
  roiAddRename("K");
  //Kroi = RoiManager.size - 1;
  
  setBatchMode(false);
  
  // Line L - pectoral fin insertion
  do {
    run("Point Tool...", "type=Dot color=Red size=[Extra Large]");
    run("Select None");
    setTool("point");
    message = "Reference line L: \n" +
              " \n" +
              "Click on the pectoral fin insertion point.\n" +
              "After the point appears, you can click and drag\n" +
              "it if you need to readjust its position.";
    waitForUser("Reference lines", message);
    if (selectionType != 10) {
      showMessage("<html>"
                + "Point selection required!");
    }
  } while (selectionType != 10);
  getSelectionCoordinates(x, y);
  xPF = x[0];
  yPF = y[0];
  makeLine(xPF, 0, xPF, h);
  roiAddRename("L");
  //Lroi = RoiManager.size - 1;
  
  
  // TRAITS //
  
  setBatchMode(true);
  
  // Intersection point along J
  //Jroi = Kroi - 1;
  JPoints = areaXline("Bs", "J");
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
  KPoints = areaXline("Bs", "K");
  
  // Intersection points along L
  LPoints = areaXline("Bs", "L");
  
  // TL - Total length
  makeLine(xD, yC, xE, yC);
  roiAddRename("TL");
  TL = getValue("Length");
  
  // SL - Standard length
  makeLine(xD, yB, xH[0], yB);
  roiAddRename("SL");
  SL = getValue("Length");
  
  // pxcm if known fish length
  if (length != "NA") {
    if (lengthType == "standard") {
      pxcm = SL / length;
    } else if (lengthType == "total") {
      pxcm = TL / length;
    }
  }

  // MBd - Maximum body depth
  xMBd = xI[0] + ((xA[0] - xI[0]) / 2);
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
  // Exception for fish with very anterior eyes, or positioned on top of head (e.g. Periophtalmus spp. and many other blennies)
  // Set AO = 0 if the anterior of the eye is outside the body outline
  if ((side == "left" && xAeye < xAO) || (side == "right" && xAeye > xAO)) {
    AO = 0;
  } else {
    makeLine(xAeye, yEC, xAO, yEC);
    roiAddRename("AO");
    AO = getValue("Length");
  }

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
  makeLine(xPF, yPF, xPF, yC);
  roiAddRename("PFi");
  PFi = getValue("Length");
  
  setBatchMode(false);
  
  // PFs - Pectoral fin surface area
  do {
    run("Select None");
    setTool("polygon");
    message = "Trace a polygon following the contour of the pectoral fin.";
    waitForUser("Pectoral fin surface area", message);
    if (selectionType != 2) {
      showMessage("<html>"
                + "Polygon selection required!");
    }
  } while (selectionType != 2);
  run("Interpolate", "interval=1 smooth adjust");
  run("Fit Spline");
  roiAddRename("PFs");
  PFs = getValue("Area");
  run("Select None"); //to avoid issues with next step
  
  // PFl - Pectoral fin length
  do {
    run("Select None");
    setTool("line");
    message = "Trace a line on the longest ray of the pectoral fin.";
    waitForUser("Pectoral fin length", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("PFl");
  PFl = getValue("Length");
  
  // Mo - Oral gape position
  do {
    run("Select None");
    setTool("Point");
    message = "Click on the tip of the premaxilla (upper jaw).\n" +
              "After the point appears, you can click and\n" +
              "drag it if you need to readjust its position.";
    waitForUser("Oral gape position", message);
    if (selectionType != 10) {
      showMessage("<html>"
                + "Point selection required!");
    }
  } while (selectionType != 10);
  getSelectionCoordinates(x, y);
  xUJ = x[0];
  yUJ = y[0];
  makeLine(xUJ, yUJ, xUJ, yC);
  roiAddRename("Mo");
  Mo = getValue("Length");
  
  // Jl - Maxillary jaw length
  do {
    run("Select None");
    setTool("Point");
    message = "Click on the intersection between the maxilla\n" +
              "and the mandible (i.e. the corner of the mouth).\n" +
              "After the point appears, you can click and\n" +
              "drag it if you need to readjust its position.";
    waitForUser("Maxillary jaw length", message);
    if (selectionType != 10) {
      showMessage("<html>"
                + "Point selection required!");
    }
  } while (selectionType != 10);
  getSelectionCoordinates(x, y);
  xJC = x[0];
  yJC = y[0];
  makeLine(xJC, yJC, xUJ, yUJ);
  roiAddRename("Jl");
  Jl = getValue("Length");
  
  setBatchMode(true);
  
  // EMd - Orbit centroid to mouth
  makeLine(xEC, yEC, xUJ, yUJ);
  roiAddRename("EMd");
  EMd = getValue("Length");
  
  // EMa - Mouth-eye angle
  makeSelection("angle", newArray(xEC, xUJ, xEC), newArray(yEC, yUJ, yUJ));
  roiAddRename("EMa");
  EMa = getValue("Angle");
  
  t1 = getTime;
  time = (t1 - t0) / 1000;
  
  setBatchMode(false);
}

// "headAnalysis": Analysis to measure head angles
var Sa = "", Ha = "", EMa = "";
function headAnalysis() {
  
  t0 = getTime;
  
  // Adjust the image if the fish is bended or not horizontal
  straightenRotate();
  
  // Image size
  getImageSize();
  
  // Orientation
  getOrientation();
  
  
  // REFERENCE LINES AND POINTS //
  
  run("Point Tool...", "type=Dot color=Red size=[Extra Large]");
  run("Line Width...", "line=1");
  
  // Point P1
  do {
    run("Select None");
    setTool("Point");
    message = "Reference point P1:\n" +
              " \n" +
              "\nClick on the tip of the premaxilla (upper jaw).\n" +
              "After the point appears, you can click and\n" +
              "drag it if you need to readjust its position.";
    waitForUser("Reference Point", message);
    if (selectionType != 10) {
      showMessage("<html>"
                + "Point selection required!");
    }
  } while (selectionType != 10);
  getSelectionCoordinates(x, y);
  xP1 = x[0];
  yP1 = y[0];
  roiAddRename("P1");


  // Lines
  do {
    run("Select None");
    setTool("Ellipse");
    message = "Trace an ellipse around the eye.";
    waitForUser("Reference lines", message);
    if (selectionType != 3) {
      showMessage("<html>"
                + "Elliptical selection required!");
    }
  } while (selectionType != 3);
  
  setBatchMode(true);
  
  roiAddRename("eye");
  xEC = getValue("X");
  yEC = getValue("Y");
  // Line 1
  makeLine(0, yEC, w, yEC);
  roiAddRename("L1");
  //L1roi = RoiManager.size - 1;
  eyePointsH = areaXline("eye", "L1");
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
  //L2roi = RoiManager.size - 1;
  eyePointsV = areaXline("eye", "L2");
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
  point34 = lineXline("L3", "L4");
  makePoint(point34[0], point34[1]);
  // Delete ellipse	
  //roiManager("Select", L1roi - 1);
  //roiManager("Delete");
  // Line 5
  xL5 = xP1 + ((xAeye - xP1) / 2);
  makeLine(xL5, 0, xL5, h);
  roiAddRename("L5");
    
  setBatchMode(false);	

  
  // TRAITS //
  
  // Ha - Head angle
  do {
    run("Select None");
    setTool("Point");
    message = "Click on the intersection of line L5 with the dorsal margin of the snout.\n" +
              "You can click and drag the point if you need to readjust its position.";
    waitForUser("Head angle", message);
    if (selectionType != 10) {
      showMessage("<html>"
                + "Point selection required!");
    }
  } while (selectionType != 10);
  getSelectionCoordinates(x, y);
  xL5up = x[0];
  yL5up = y[0];
  makeSelection("angle", newArray(point34[0], xL5up, xP1), newArray(point34[1], yL5up, yP1));
  roiAddRename("Ha");
  Ha = getValue("Angle");
  
  // Correct Ha if it is concave
  angle1 = measureAngle(xP1, yP1, point34[0], point34[1]);
  angle2 = measureAngle(xL5up, yL5up, point34[0], point34[1]);
  if (angle2 > angle1){
    Ha = 360 - Ha;
  }
  
  // Sa - Snout angle
  do {
    run("Select None");
    setTool("Point");
    message = "Click on the intersection of line L5 with the ventral margin of the snout.\n" +
              "You can click and drag the point if you need to readjust its position.";
    waitForUser("Snout angle", message);
    if (selectionType != 10) {
      showMessage("<html>"
                + "Point selection required!");
    }
  } while (selectionType != 10);
  getSelectionCoordinates(x, y);
  xL5low = x[0];
  yL5low = y[0];
  makeSelection("angle", newArray(xL5up, xP1, xL5low), newArray(yL5up, yP1, yL5low));
  roiAddRename("Sa");
  Sa = getValue("Angle");
  
  // EMa - Eye-Mouth angle
  makeSelection("angle", newArray(xEC, xP1, xEC), newArray(yEC, yP1, yP1));
  roiAddRename("EMa");
  EMa = getValue("Angle");
  
  t1 = getTime;
  time = (t1 - t0) / 1000;
}

// "gutAnalysis": Analysis to measure intestinal traits
var GL = "", GD = "", GS = "";
var GD1 = "", GD2 = "", GD3 = "", GD4 = "", GD5 = "", GD6 = "", GD7 = "", GD8 = "", GD9 = "", GD10 = "";
function gutAnalysis() {
  
  t0 = getTime;
  
  // Set scale
  setScale();
  
  // Intestinal length
  do {
    run("Select None");
    setTool("Polyline");
    message = "Trace a segmented line from the pyloric outlet to the anus\n" +
              "(or from the oesophagus to the anus in stomachless fishes)\n" +
              "following the midline of the intestine.";
    waitForUser("Intestinal length", message);
    if (selectionType != 6) {
      showMessage("<html>"
                + "Segmented line selection required!");
    }
  } while (selectionType != 6);
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
    xp[i] = x[i * x.length / 11];
    yp[i] = y[i * x.length / 11];
  }
  xp = Array.slice(xp, 1); // remove first point
  yp = Array.slice(yp, 1);
  makeSelection("Point", xp, yp);
  run("Point Tool...", "type=Dot color=Red size=[Extra Large]");
  roiAddRename("Points");
  run("Select None");
  
  // 10 diameters
  do {
    run("Select None");
    setTool("Line");
    message = "At the level of the 1st point, moving from the \n" +
              "oesophagus to the anus, trace a straight line \n" +
              "perpendicular to the midline of the intestine \n" +
              "and joining the two margins.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD1");
  GD1 = getValue("Length");
  do {
    run("Select None");
    setTool("Line");
    message = "Now do the same at the 2nd point.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD2");
  GD2 = getValue("Length");
  do {
    run("Select None");
    setTool("Line");
    message = "Now do the same at the 3rd point.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD3");
  GD3 = getValue("Length");
  do {
    run("Select None");
    setTool("Line");
    message = "Now do the same at the 4th point.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD4");
  GD4 = getValue("Length");
  do {
    run("Select None");
    setTool("Line");
    message = "Now do the same at the 5th point.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD5");
  GD5 = getValue("Length");
  do {
    run("Select None");
    setTool("Line");
    message = "Now do the same at the 6th point.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD6");
  GD6 = getValue("Length");
  do {
    run("Select None");
    setTool("Line");
    message = "Now do the same at the 7th point.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD7");
  GD7 = getValue("Length");
  do {
    run("Select None");
    setTool("Line");
    message = "Now do the same at the 8th point.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD8");
  GD8 = getValue("Length");
  do {
    run("Select None");
    setTool("Line");
    message = "Now do the same at the 9th point.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD9");
  GD9 = getValue("Length");
  do {
    run("Select None");
    setTool("Line");
    message = "Now do the same at the 10th point.";
    waitForUser("Intestinal diameter", message);
    if (selectionType != 5) {
      showMessage("<html>"
                + "Straight line selection required!");
    }
  } while (selectionType != 5);
  roiAddRename("GD10");
  GD10 = getValue("Length");
  
  // Mean intestinal diameter
  GD = (GD1 + GD2 + GD3 + GD4 + GD5 + GD6 + GD7 + GD8 + GD9 + GD10) / 10;
  
  // Intestinal surface area
  GS = 2 * PI * (GD / 2) * GL;
  
  t1 = getTime;
  time = (t1 - t0) / 1000;
}

//-----------------------------  FUNCTIONS FOR SAVING RESULTS  ----------------------------//

// "setMainTable": Fill in the main analysis results table
function setMainTable(i) {
  Table.set("image_id", i, title);
  Table.set("px.cm", i, pxcm);
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
  Table.set("px.cm", i, 1 / pw);
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
    str = newArray(title, pxcm, TL, SL, MBd, Hl, Hd, Ed, Eh, Snl, POC, AO, EMd, EMa, Mo, Jl, Bs, CPd, CFd, CFs, PFs, PFl, PFi, PFb, remark, time);
  } else if (analysis == "head") {
    str = newArray(title, Ha, Sa, EMa, remark, time);
  } else if (analysis == "gut") {
    str = newArray(title, 1 / pw, GL, GD, GS, GD1, GD2, GD3, GD4, GD5, GD6, GD7, GD8, GD9, GD10, remark, time);
  }
  str = String.join(str, sep);
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
  checkImage("s");
  
  // Duplicate image
  duplicateImage();
  
  // Open ROI manager
  run("ROI Manager...");
  roiManager("Show All with labels");
  
  // Set colors
  run("Colors...", "foreground=black background=white selection=red");
  
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
  checkImage("m");
  
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
    
    // Duplicate image
    duplicateImage();
    
    // Option to skip image
    do {
      imageQuality = skipImage();
      remark = imageQuality[0];
      skip = imageQuality[1];
      skip2 = -1;
      if (skip == 1)
        skip2 = getBoolean("Are you sure you want to skip this image?");
    } while (skip2 == 0);
    
    if (skip == 0) {
      
      // Open ROI manager
      run("ROI Manager...");
      roiManager("Show All with labels");
      
      // Set colors
      run("Colors...", "foreground=black background=white selection=red");
      
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
    }
    
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


