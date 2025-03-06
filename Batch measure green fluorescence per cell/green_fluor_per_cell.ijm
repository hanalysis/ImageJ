// Set empty variables to default values
path = "path";
lower_limit = 0;
upper_limit = 10000;
roi_min = 200;

// Get file path to directory, save list of files, save array of titles
dir = getDirectory("Choose a directory ");
list = getFileList(dir);
titles = newArray(list.length);

// Create dialog box for user to input desired threshold limits
Dialog.create("Threshold");
Dialog.addNumber("Lower limit", lower_limit);
Dialog.addNumber("Upper limit", upper_limit);
Dialog.show();

// Save threshold limits input by the user		
lower_limit = Dialog.getNumber();
upper_limit = Dialog.getNumber();;

// Create dialog box for user to input desired minimum size of particle
Dialog.create("ROI minimum");
Dialog.addNumber("Minimum pixels for ROI", roi_min);
Dialog.show();

// Save ROI limits input by the user		
roi_min = Dialog.getNumber();

// Get name for results
resultsname = "Results";

Dialog.create("Results");
Dialog.addString("Save your results as", resultsname);
Dialog.show();
resultsname = Dialog.getString();

// Loop over each image in the folder 
run("Clear Results");
setBatchMode(true);

// Set number of iterations for label 
num=0

for(i = 0; i<list.length; i++)  { 
	path = dir+list[i];
	open(path);	
	title = getTitle();
	
	// Set threshold 
	run("Split Channels");

		// Select C2 (green)
		selectImage("C2-" + title);
	
	setAutoThreshold("Default dark");
	//run("Threshold...");
	setThreshold(lower_limit, upper_limit, "raw");
	run("Threshold...");
	run("Close");

	// Create mask to measure per cell
	run("Create Mask");
	run("Analyze Particles...", "size=" + roi_min + "-Infinity pixel exclude include add");
	roiManager("Deselect");
	
	selectImage("C2-" + title);
	roiManager("Measure");

	// Add labels to results table 
	
	for(j = num; j<nResults; j++)  { 
	setResult("Sample", j, title);
	updateResults();
	}

	// Saving 0 for when there's no detectable fluorescence
	if (nResults == num) {
	setResult("Mean", nResults, 0);
	setResult("Area", nResults -1 , 0);
	setResult("Min", nResults - 1, 0);
	setResult("Max", nResults - 1, 0);
	setResult("MinThr", nResults - 1, lower_limit);
	setResult("MaxThr", nResults - 1, upper_limit);
	setResult("Sample", nResults - 1, title);
	updateResults(); 
	};

	n=roiManager("count");
	
	if (n > 0) {
		roiManager("Delete");
		};
	
	num = nResults;
	
	}

	// Save results
	saveAs("Results", dir + "/" + resultsname + ".csv");
