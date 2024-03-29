PD3D: Package for Detecting Fluorescent Puncta in 3-D
===========

This repository contains the code for the [PD3D], a package that enables detection of fluorescent puncta in 3-D and assignment of these puncta to objects in a watershed segementation image. This code is intended for detecting and locating fluorescent puncta in 3-D image stacks and was developed as part of the data analysis pipeline for SABER images. Many aspects of the analysis are tailorable to your particular imaging conditions and analysis needs and with very basic MATLAB knowledge, the code should be easily applied. 


If you use this code, please kindly cite our pre-print article:

CITATION!!!


Note about operating systems
----------------------------
PD3D is a set of MATLAB functions written using MATLAB version 2018a.




Installing PD3D dependencies
----------------------------------

First, you'll need to download all dependencies, including [MATLAB](https://www.mathworks.com/downloads) (developed on MATLAB 2018a) and OME's [Bio-Format's library](http://www.openmicroscopy.org/bio-formats/) (developed with version 5.9.1). 

You will also need to specifically download the [MATLAB Image Processing Toolbox](https://www.mathworks.com/help/images/index.html), which can be done at the time of installation or recursively.

For visualizing the results of puncta segmentation and cell calling, ImageJ (CITE) and ITK-SNAP can be extremely useful. For 3D renderings of segmented cells, ITK-SNAP is particularly useful. 


    
Running PD3D to Count Puncta Per Cell in a Sample Image
--------------------------------------------------
Let's apply this pipeline to detect puncta in an example SABER image and count the number of transcripts per cell in a corresponding watershed segmentation image. To get started, download this folder and save it somewhere safe. Replace "myfiles" with the path to your saved location and run the following code in the MATLAB command line:

	>> addpath(genpath('./myfiles/PD3D/'))

We'll be analyzing the data in the SampleData subfolder. This folder contains the original CZI file for a section of the mouse retina stained with WGA to mark cell membranes and for Slc4a RNA using SABER. The SABER image has been extracted from this CZI file and saved as "SABER_puncta.tif", which will be the image file that you use for puncta detection. 

Retinal cells were segmented using ACME (CITE) based on the WGA membrane stain and the resulting watershed segmentation file is labelled "wat.tif". This image file is a 32-bit TIFF image file with each cell (and other segmented non-cellular object) being labelled by a different number. This will be used in assigning our detected puncta to cells and for quantifying the number of transcripts per cell.




Detecting Puncta: Choosing an appropriate threshold for puncta detection
---------------------------------------------------------------------------
This code uses a Laplacian of Gaussian (LoG) method for puncta detection, a technique that has been widely applied for feature detection in image analysis for decades *CITE. The method uses properties of how the image intensity function changes as with image features, for example, that there are sharp changes in intensity values at feature "edges". 

There are two major parameters in this method: a puncta size parameter, sigma, and a threshold for the LoG-filtered image. Sigma refers to sigma of the Gaussian function that can be used to estimate our diffraction-limited fluorescent molecules after they've been distorted by the point spread function during detection. This parameter will depend on your imaging resolution and is measured in pixels. In general, the smaller your pixel size, the larger your sigma (because a single puncta will span more pixels at finer resolution). For this sample analysis, we can take sigma=1, but a range of values (0.8 - 1.5) would work. Sigma can be empirically determined by fitting a Gaussian distribution to your puncta. 


To determine the appropriate LoG threshold for puncta detection, we will apply the robustThreshold.m function to the SABER image "SABER_puncta.tif". This function iterates through the range of thresholds for the image and outputs graphs that show how the detection of puncta change across the threshold range. A robust thresholding method would result in a range of threshold values for which the number of puncta detected is relatively constant. This function allows graphically-assisted threshold choice guided by this principal.

This function takes two inputs, sigma and a string variable specifying the path to the image file that we wish to analyze.

		>> sigma=1; imfile='./SampleData/InputFiles/SABER_puncta.tif';

To run the robustThreshold function, we specify names for the output paramaters, namely the chosen threshold, a vector indicating the thresholds tested, and the corresponding number of puncta detected at these thresholds.

		>>  [threshold,threshs,threshrange,N] = robustThreshold(imfile,sigma)


When this function runs, three sequential graphs will pop up. The first is simply plotting the total number of transcripts detected across the range of possible thresholds. The second plots the first derivative of that, and the third graph plots the second derivative. As each graph pops up, you can click the point at which you'd like to draw the threshold and that element will be saved as the output variable threshold. I find it easiest to choose the threshold from the first or second derivative graph, choosing a point shortly after these graphs plummet to zero. When the first derivative is zero, this corresponds to the threshold range for which the number of puncta detected doesn't change much, which indicates that the thresholding is "robust". 

In our example, I chose a threshold of 0.18 based on the graphs.

This function will write out a TIFF file of the detected puncta as 'detected_puncta.tif' in the ./SampleData/OutputFiles/ directory. This is a tiff stack of the detected puncta and can be opened in ImageJ for visualization and comparison to the original SABER image.

When analyzing a number of images for the same conditions and imaging parameters, the same sigma and LoG threshold can be used. However, these paramaters might vary across fluorescent channels and targets.




Detecting Puncta: Applying Puncta Detection 
---------------------------------------------------------------------------
With a chosen threshold, we can now run the main puncta detection function:

		>> [binarycenter,imgLoG,ims]=LoG_3D_LoGthresh(imfile,threshold,sigma);

		>> output=convn(binarycenter,Gauss3D(sigma,2.5),'same');
		>> figure;imshow(imProjection(binarycenter)); tiffWrite(output,'./SampleData/OutputFiles/DP.tif')
		
The output file, 'DP.tif' can be opened in ImageJ and merged with the original puncta image to compare the original signal to detected signal. For fast verification, it is nice to just use MATLAB to visualize the original image and detected image side-by-side in a 2-D projection, which can be done using the following execution:

		>> figure;imshow(imProjection(binarycenter)); tiffWrite(output,'./SampleData/OutputFiles/DP.tif')





		
Quantifying Puncta Per Cell: Combining PD3D with 3-D cell segmentation
---------------------------------------------------------------------------		
In many cases, it is useful to quantify the number of puncta detected in a specific cell. This can be achieved by combining PD3D with cell segmentation. In the retina, we use a membrane-based method for cell segmentation in 3-D called [ACME](https://wiki.med.harvard.edu/SysBio/Megason/ACME). The output of this segmentation algorithm is a 32-bit MHA watershed segmentation, where each object is labelled by a different number. The MHA file should be saved as a TIFF in the current MATLAB working directory (ImageJ can be easily used to convert between file types).

We will set a threshold for calling cells positive if they contain more than one puncta. Since Slc4a is expressed at low levels and there is extremely low background in the SABER image, this threshold should work well.

	>> clear all
	>> load('sample_ppc_quant.mat')
	>> zvox=0.8;
	>> [binarycenter,wat,watnew,Seg,finalT,posWat] = PunctaPerCell(imfile,watSegmentation,sigma,threshold,ndots,zvox,outputwat_filename);


The resulting positive, whole cells (i.e. the cells containing more than one puncta which do not intersect image boundaries) are output in a new watershed image file to './SampleData/wat.tif'. This can be opened in ImageJ, saved as an MHA file, and visualized in ITK-SNAP in 3D. If you would like to get counts for all segmented objects, including those of non-cellular size and that intersect the boundary, these counts and centroid coordinates can be found in the output table 'Seg'. The outputs are as follows:

	binarycenter = binary image of detected puncta centers
	wat = imported watershed image
	watnew = watershed image resized to the dimensions of the original SABER image
	Seg = table containing watershed label ID's for all segmented objects, volumes, centroid locations, and number of puncta contained within each segmented object
	finalT = Subsampling of Seg table containing only cell-sized objects that do not intersect the image boundary and contain 			more than 'ndots' number of puncta
	

The default function parameters for PunctaPerCell eliminate all cells intersecting boundaries and assume cells are within a size range between volume of 4um^3 to 418um^3. These bounding numbers can be directly edited within in the function, which should be clear from the commented annotation. 


To run this on a number of images with corresponding watershed cell segmentations, you can use the PunctaPerCellBatch.m function. This function takes a CSV file as input, where all input parameters can be specified. You can use the sample table 'FileTable.csv' as a working template and save it in the current directory once you have 


		>> FT='./FileTable.csv';
		>> [finalTArray,BC,Wat,WatBig,SegTable]=PunctaPerCellBatch(FT);





Quantifying Puncta Intensity
---------------------------------------------------------------------------	
PD3D can also be used for quantifying the fluorescent intensity of puncta in a SABER image. 

Signal2Backgroundintensity.m


[BackgroundIntAvg,SNR,BackgroundIntensity,SignalmBackAvg,Signal]= Signal2Backgroundintensity(filename,threshold,sigma);










Contributing
------------

We welcome commits from researchers who wish to improve our software. Please follow the [git flow](http://nvie.com/posts/a-successful-git-branching-model/) branching model. Make all changes to a topic branch off the branch `dev`. Merge the topic branch into `dev` first (preferably using `--no-ff`) and ensure everything works. Code will _only_ merged into `master` for release builds. Hotfixes should be developed and tested in a separate branch off `master`, and a new release should be generated immediately after the hotfix is merged.

Questions?
------------
Please reach out to [Brian](mailto:Brian.Beliveau@wyss.harvard.edu) with any questions about installing and running the scripts. 