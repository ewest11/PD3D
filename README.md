PD3D: Package for Detecting Fluorescent Puncta in 3-D
===========

This repository contains the code for the [PD3D], a package for detecting fluorescent puncta in 3D and localizing them to objects in a segmentation image. This code was developed as part of the data analysis pipeline for SABER images, a method for fluorescent in situ hybridization for detecting DNA and RNA molecules in tissues and cells.

It should be noted that a number of parameters must be changed according to your precise application. Consulting the source code will be helpful in deciding how to tailor the code to your needs and with minimal MATLAB knowledge, the code should be easy to apply.

If you use this code, please kindly cite our pre-print article:

SABER enables highly multiplexed and amplified detection of DNA and RNA in cells and tissues
Jocelyn Y. Kishi, Brian J. Beliveau, Sylvain W. Lapan, Emma R. West, Allen Zhu, Hiroshi M. Sasaki, Sinem K. Saka, Yu Wang, Constance L. Cepko, Peng Yin
bioRxiv 401810; doi: https://doi.org/10.1101/401810

Note about operating systems
----------------------------
PD3D is a set of MATLAB functions written using MATLAB version 2018a.


Installing PD3D dependencies
----------------------------------

First, you'll need to download all dependencies, including [MATLAB](https://www.mathworks.com/downloads) (developed on MATLAB 2018a) and OME's [Bio-Format's library](http://www.openmicroscopy.org/bio-formats/) (developed with version 5.9.1). I have included the bfmatlab folder used for this development for convenience but I certainly did not write this myself and it can be downloaded at the link provided.

You will also need to specifically download the [MATLAB Image Processing Toolbox](https://www.mathworks.com/help/images/index.html), which can be done at the time of installation or recursively.

For visualizing the results of puncta segmentation and cell calling, [ImageJ](https://imagej.nih.gov/ij/download.html) and [ITK-SNAP](http://www.itksnap.org/pmwiki/pmwiki.php) can be extremely useful. For 3D renderings of segmented cells, ITK-SNAP is particularly useful. 


    
Running PD3D to Count Puncta Per Cell in a Sample Image
--------------------------------------------------
Let's apply this pipeline to detect puncta in an example SABER image and count the number of transcripts per cell in a corresponding watershed segmentation image. To get started, download this folder and save it somewhere safe. Replace "myfiles" with the path to your saved location and run the following code in the MATLAB command line:

	>> addpath(genpath('./myfiles/PD3D/'))

We'll be analyzing the data in the SampleData subfolder. This folder contains the original CZI file for a section of the mouse retina stained with WGA to mark cell membranes and for Slc4a RNA using SABER. The SABER image has been extracted from this CZI file and saved as "SABER_puncta.tif", which will be the image file that you use for puncta detection. 

Retinal cells were segmented using ACME (Mosaliganti, 2012) based on the WGA membrane stain and the resulting watershed segmentation file is labelled "wat.tif". This image file is a 32-bit TIFF image file with each cell (and other segmented non-cellular objects) being labelled by a different number. This will be used in assigning our detected puncta to cells and for quantifying the number of transcripts per cell.




Detecting Puncta: Choosing an appropriate threshold for puncta detection
---------------------------------------------------------------------------
This code uses a Laplacian of Gaussian (LoG) method for puncta detection, a technique that has been widely applied for feature detection in image analysis for decades. The method uses properties of how the image intensity function changes with image features, for example, that there are sharp changes in intensity values at feature "edges". The code for 3D LoG filtering was inspired by a similar 2D function developed by Marcelo Cicconet at Harvard Medical School's Image and Data Analysis Core (IDAC), and code for calculating a robust threshold was inspired by a similar 2D function in (Raj, 2008).

There are two major parameters in this method: a puncta size parameter, sigma, and a threshold for the LoG-filtered image. Sigma refers to sigma of the Gaussian function that can be used to estimate our diffraction-limited fluorescent molecules after they've been distorted by the point spread function during detection. This parameter will depend on your imaging resolution and is measured in pixels. In general, the smaller your pixel size, the larger your sigma (because a single puncta will span more pixels at finer resolution). For this sample analysis, we can take sigma=1, but a range of values (0.8 - 1.5) would work. Sigma can be empirically determined by fitting a Gaussian distribution to your puncta. 


To determine the appropriate LoG threshold for puncta detection, we will apply the robustThreshold.m function to the SABER image "SABER_puncta.tif". This function iterates through the range of thresholds for the image and outputs graphs that show how the detection of puncta change across the threshold range. A robust thresholding method would result in a range of threshold values for which the number of puncta detected is relatively constant. This function allows graphically-assisted threshold choice guided by this principal.

This function takes two inputs, sigma and a string variable specifying the path to the image file that we wish to analyze.

		>> sigma=1; imfile='./SampleData/InputFiles/SABER_puncta.tif';

To run the robustThreshold function, we specify names for the output paramaters, namely the chosen threshold, a vector indicating the thresholds tested, and the corresponding number of puncta detected at these thresholds.

		>>  [threshold,threshrange,N] = robustThreshold(imfile,sigma);


When this function runs, three sequential graphs will pop up. The first is simply plotting the total number of transcripts detected across the range of possible thresholds. The second plots the first derivative of that, and the third graph plots the second derivative. As each graph pops up, you can click the point at which you'd like to draw the threshold and that element will be saved as the output variable threshold. I find it easiest to choose the threshold from the first or second derivative graph, choosing a point shortly after these graphs plummet to zero. When the first derivative is zero, this corresponds to the threshold range for which the number of puncta detected doesn't change much, which indicates that the thresholding is "robust". 

In our example, I chose a threshold of 0.18 based on the graphs.

This function will write out a TIFF file of the detected puncta as 'detected_puncta.tif' in the ./SampleData/OutputFiles/ directory. This is a tiff stack of the detected puncta and can be opened in ImageJ for visualization and comparison to the original SABER image.

When analyzing a number of images for the same conditions and imaging parameters, the same sigma should be used. The LoG threshold often needs to be recalculated for each image or identical condition since it is internally normalized. 




Detecting Puncta: Applying Puncta Detection 
---------------------------------------------------------------------------
With a chosen threshold, we can now run the main puncta detection function:

		>> [binarycenter,imgLoG,ims]=LoG_3D_LoGthresh(imfile,threshold,sigma);

		>> output=convn(binarycenter,Gauss3D(sigma,2.5),'same');
		>> figure;imshow(imProjection(binarycenter)); 
		>> tiffWrite(output,'./SampleData/OutputFiles/DP.tif')
		
The output file, 'DP.tif' can be opened in ImageJ and merged with the original puncta image to compare the original signal to detected signal. An example of this output already exists in the OutputFiles folder called 'DP_example.tif'. For fast verification, it is nice to just use MATLAB to visualize the original image and detected image side-by-side in a 2-D projection, which can be done using the following execution:

		>> figure;imshow(imProjection(binarycenter)); 
		>> figure;imshow(uint8(maxProjection(ims)))
		
		The first line plots the max-projected binary image with detected puncta centroids and the second plots the max-projected original 8-bit image. If your input image was 16 or 32 bits, you should change the second line accordingly.



		
Quantifying Puncta Per Cell: Combining PD3D with 3-D cell segmentation
---------------------------------------------------------------------------		
In many cases, it is useful to quantify the number of puncta detected in a specific cell. This can be achieved by combining PD3D with cell segmentation images. In the retina, we use a membrane-based method for cell segmentation in 3-D called [ACME](https://wiki.med.harvard.edu/SysBio/Megason/ACME). The output of this segmentation algorithm is a 32-bit MHA watershed segmentation, where each object is labelled by a different number. The MHA file should be saved as a TIFF in the current MATLAB working directory (ImageJ can be easily used to convert between file types).

We will set a threshold for calling cells positive if they contain more than one puncta. Since Slc4a is expressed at low levels and there is extremely low background in the SABER image, this threshold should work well.

	>> clear all
	>> load('sample_ppc_quant.mat')
	>> [binarycenter,wat,watnew,Seg,finalT,posWat] = PunctaPerCell(imfile,watSegmentation,sigma,threshold,ndots,zvox,outputwat_filename);


The resulting positive, whole cells (i.e. the cells containing more than one puncta which do not intersect image boundaries) are output in a new watershed image file to './SampleData/wat.tif'. This can be opened in ImageJ, saved as an MHA file, and visualized in ITK-SNAP in 3D. If you would like to get counts for all segmented objects, including those of non-cellular size and that intersect the boundary, these counts and centroid coordinates can be found in the output table 'Seg'. The outputs are as follows:

	binarycenter = binary image of detected puncta centers
	wat = imported watershed image
	watnew = watershed image resized to the dimensions of the original SABER image
	Seg = table containing watershed label ID's for all segmented objects, volumes, centroid locations, and number of puncta contained within each segmented object
	finalT = Subsampling of Seg table containing only cell-sized objects that do not intersect the image boundary and contain 			more than 'ndots' number of puncta
	

The default function parameters for PunctaPerCell eliminate all cells intersecting boundaries and assume cells are within a size range between volume of 4um^3 to 418um^3. These bounding numbers can be directly edited within in the function, which should be clear from the commented annotation. 


To run this on a number of images with corresponding watershed cell segmentations, you can use the PunctaPerCellBatch.m function. This function takes a CSV file as input, where all input parameters can be specified. You can use the sample table 'FileTable.csv' as a working template and save it in the current directory once you have changed the parameters. Parameters in the file include:

Condition = name of the condition

inSitu = path to the SABER file

WatFile = path to watershed segmentation image file

Sigma = xy sigma of Gaussian for puncta detection 

LoGThreshold = threshold determined by robustThreshold function

ndots = threshold for number of puncta detected to call a cell "positive" 

Zvox = size (um) of voxels in Z-dimension

OutputWat = path to and name of output file for new watershed image with only positive cells

To run the function, copy the following lines:
		
		>> FT='./FileTable.csv';
		>> [finalTArray,BC,Wat,WatBig,SegTable]=PunctaPerCellBatch(FT);

Output variables are arrays with entries corresponding to each row in the input table (i.e. each set of parameters). The outputs are as follows:

finalTArray = Table with entries corresponding to each segmented object. This includes the watershed label ID, object volume, 3D centroid coordinates, and the number of detected puncta within that object. This final table only includes cells that are called positive based on the number of detected puncta in them (i.e. cells with >ndots puncta and that do not intersect the boundary).

SegTable = Table with label IDs, volumes, and 3D centroid coordinates for all elements in watershed image

Wat = Original watershed image

WatBig = Watershed image resized to the image dimensions of the SABER puncta image

PosWat = Watershed image with only whole cells with >ndots puncta

finalTBigArray = Table with label IDs, volumes, 3D centroid coordinates, and number of puncta detected for all whole objects after size filtration.



Quantifying Puncta Intensity 
---------------------------------------------------------------------------	
PD3D can also be used for quantifying the fluorescent intensity of puncta in a SABER image. The function Signal2Backgroundintensity.m uses the LoG-based 3D puncta detection described above to find puncta and calculates the background-subtracted puncta intensity values. 

To apply this function to our sample data, run the following lines:


		>> imfile='./SampleData/InputFiles/SABER_puncta.tif'; threshold=0.18;sigma=1;
		>> [BackgroundIntAvg,SNR,BackgroundIntensity,SignalmBackAvg,Signal,SignalmBackIntensity,binarycenter]= Signal2Backgroundintensity(filename,threshold,sigma);

BackgroundIntAvg = average intensity of background pixels

SNR = average intensity of signal pixels after subtracting BackgroundIntAvg, divided by BackgroundIntAvg

BackgroundIntensity = vector with intensity values for all background pixels

SignalmBackAvg = Average value of signal pixels after background subtraction

Signal = vector with max intensity values of all detected puncta

SignalmBackIntensity = vector with background-subtracted intensity values of all detected puncta
binarycenter = binary image with detected puncta centroids

The function outputs a histogram of background-subtracted signal intensities for all detected puncta in the image. 




Contributing
------------
This code was developed by a novice and any improvements or suggestions are welcome. Please don't hesitate to reach out with questions or suggestions for improving it.


Citations
---------
Arjun Raj, Patrick van den Bogaard, Scott a Rifkin, Alexander van Oudenaarden,
and Sanjay Tyagi. Imaging individual mRNA molecules using
multiple singly labeled probes. Nature methods, 5(10):877–879, 2008.

Kishore R Mosaliganti, Ramil R Noche, Fengzhu Xiong, Ian A Swinburne,
and Sean G Megason. Acme: automated cell morphology extractor for
comprehensive reconstruction of cell membranes. PLoS computational biology,
8(12):e1002780, 2012.


Questions?
------------
Please reach out to [Emma](mailto:emma_west@g.harvard.edu) with any questions about installing and running the scripts. 
