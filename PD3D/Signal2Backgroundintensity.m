function [BackgroundIntAvg,SNR,BackgroundIntensity,SignalmBackAvg,Signal,SignalmBackIntensity,binarycenter]= Signal2Backgroundintensity(filename,threshold,sigma);
%% This function quantifies the background-subtracted intensity of detected puncta


%% Detect puncta
 [binarycenter,imgLoG,ims]=LoG_3D_LoGthresh(filename,threshold,sigma);


%% Find intensity values of puncta centroids
% Take background pixels as >15 pixels away from any puncta centroid
SignalMask=imdilate(binarycenter,strel('sphere',15));
BackgroundMask=-1*(SignalMask)+1;
%% Calculate background
Background=double(BackgroundMask).*im2double(ims);

BackgroundIntensity=Background(Background>0);

BackgroundIntAvg=sum(BackgroundIntensity(:))/size(BackgroundIntensity,1);
%% Calculate signal intensities
% Take region around the detected puncta centroid (i.e. region spanned by
% PSF) and take the max value. This should generally correspond to the
% center of the puncta. 
BC=imdilate(binarycenter,strel('sphere',1)); % change 1 to another value for higher res imaging
 
% Find max pixel value within each connected component (i.e. puncta)
cc = bwconncomp(BC,4);

for i=1:size(cc.PixelIdxList,2)
ind = cc.PixelIdxList{:,i};
signal(i)=max(ims(ind));
end

Signal=im2double(signal);
%% Subtract background intensities
SignalmBackIntensity=im2double(signal)-BackgroundIntAvg;

SignalmBackAvg=sum(SignalmBackIntensity)/size(SignalmBackIntensity,2);

SNR=mean(SignalmBackAvg)/BackgroundIntAvg;
%% Plot histogram of intensity values
figure;histogram(SignalmBackIntensity)
title 'Histogram of Background-Subtracted Signal Intensities'
xlabel 'Background-Subtracted Intensity Value'
ylabel 'Number of Detected Puncta'
end
