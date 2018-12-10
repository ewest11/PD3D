function [WatTable]=watTable(watershed)
%% Generate table with centroid positions and volume of each object in voxels.
% wat = 3-D image label matrix (uint8, uint16, or uint32)

%% Make table for segmentation info
%Create table with watershed labels for each segmented object
LabelId=unique(watershed);
WatTable=table(LabelId);

% Calculate volume of segmented objects
vol=hist(watershed(:),LabelId)';   %provides a count of each element's occurrence
cellvol=[LabelId vol];
WatTable.Volume_vox=vol;


%% Manually extract cell centroid coordinates
S=regionprops3(watershed,'Volume','Centroid');

Snew=S(S.Volume>0,:); % Eliminate objects with zero volume

WatTable(1,:) = [];

%Pull out coordinates of cell centroids from regionprops function
centroids = cat(1, Snew.Centroid);

% Add x, y, and z coordinate of cell centroid to independent columns in WatTable
WatTable.xcoord=centroids(:,1,:);
WatTable.ycoord=centroids(:,2,:);
WatTable.zcoord=centroids(:,3,:);

end
