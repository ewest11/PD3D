
function [finalTArray,finalTBigArray,BC,Wat,WatBig,SegTable,PosWat]=PunctaPerCellBatch(FT)
%% This function takes in a table of images and paramaters and calculates puncta per cell
%FT = './FileTable.csv'
        % This is a string specifying a CSV file with file and parameter
        % information. Parameters include a string to specifiy the name of
        % the condition, string to specify the in situ image, string to
        % specify the watershed segmentation file, sigma (for Gaussian
        % puncta estimation), LoG Threshold, threshold for number of
        % puncta, and string name for an output file of the final
        % segmentation for positive cells only.
     

%% Add paths for image files, functions, and bfmatlab library
addpath(genpath('./'))


%% Upload CSV file with variables
%FT='./FileTable.csv'
FileTable=readtable(FT,'Delimiter',',')


%% Take in input paramaters from the CSV file

Imfile=FileTable.inSitu; % Input TIFF filename for SABER image
Sigma = FileTable.Sigma; % Estimated sigma (XY) of puncta. This varies with image resolution and should be empirically measured.

Ndots=FileTable.ndots; % Threshold for calling a cell positive for transcript of interest
Threshold=FileTable.LoGThreshold; % Threshold for LoG filter (range = [0:1]). robustThreshold.m can be used to rigorously define a threhsold. 
Zvox=FileTable.Zvox; % Distance (um) between z-stacks in SABER image
WatSegs=FileTable.WatFile; % Input TIFF filenames for watershed segmentation
WatFinals=FileTable.OutputWat; % Output TIFF filenames for positive cell watershed

%%  Compute punta detected per cell for all input images (rows) in FT

for i=1:size(FileTable,1)

    imfile=Imfile{i}
    watSegmentation=WatSegs{i};
    sigma=Sigma(i);
    threshold=Threshold(i);
    outputwat=WatFinals{i};
    ndots=Ndots(i);
    zvox=Zvox(i);

%Calculate puncta per cell 

[binarycenter,wat, watnew,Seg,finalT,finalT1, posWat]= PunctaPerCell(imfile,watSegmentation,sigma,threshold,ndots,zvox,outputwat);
finalTArray{i}=finalT;
finalTBigArray{i}=finalT1;
BC{i}=binarycenter;
Wat{i}=wat;
WatBig{i}=watnew;
SegTable{i}=Seg;
PosWat{i}=posWat;
figure;imshow(imProjection(binarycenter))

end



