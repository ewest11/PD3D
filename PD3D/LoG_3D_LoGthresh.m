
function [binarycenter,rmLoG,ims]=LoG_3D_LoGthresh(imfile,threshold,sigma)
% This function takes an input 3D image stack, threshold, and sigma and outputs 
% puncta centroids, a LoG-filtered image, and the original image stack.

%% Import in situ file - ims is an 8-bit or 16-bit image stack 
I3D=bfopen(imfile); % Import image
s=size(I3D{1});
r=s(1);
 
% Create matrix stack for imported image
for i=1:r
  Im{i}=I3D{1}{i}; 
end
    
I=cat(3,Im{:});
ims=I;

size(ims) % Print size of imported image 


%% Construct 3D Gaussian Kernel
% This section codes for an elliptical Gaussian kernel in 3-D that is
% symmetric in XY and spreads 2.5x in Z. 

[Ker]=Gauss3D(sigma,2.5);

%% Convolve image with Gaussian Kernel to smooth

imGauss = convn(ims,Ker,'same');

%% Apply Laplacian operator to the Gaussian-smoothed image. 

imLoG=-del2(imGauss); % Apply Laplacian to Gaussian-filtered image

imLoG = imLoG-mean(imLoG(:)); % Normalize mean to zero

imLoG = imLoG/max(abs(imLoG(:))); % Normalize max to 1

%% Select regional maxima from the LoG.
 
rmLoG = imregionalmax(imLoG).*imLoG; % Take regional maxima of LoG-filtered image and send all other pixels to zero
%% Threshold for puncta with LoG above universal threshold
binarycenter=rmLoG>threshold; % Create binary image where puncta centers are 1 and all other pixels are zero

ntranscripts=sum(binarycenter(:)); % Total number of detected puncta 

end
