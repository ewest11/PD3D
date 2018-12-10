function [C] = boundaryWat(watershed)
% Given a watershed segmentation (image array), this function returns the
% label numbers that intersect the boundaries as a vector.
%% Filter for whole cells
z=size(watershed,3);
C1=unique(watershed(:,:,1)); % Objects that intersect the first image in watershed stack
Cz=unique(watershed(:,:,z)); % Objects that intersect the last image in watershed stack
Cyfirst=unique(watershed(:,1,:)); % Objects that intersect y boundary 1
Cylast=unique(watershed(:,size(watershed,1),:)); % Objects that intersect y boundary 2
Cx=unique(watershed(size(watershed,2),:,:)); % Objects that intersect x boundary 1
Cxlast=unique(watershed(size(watershed,2),:,:)); % Objects that intersect x boundary 2

% Take union of all boundary-intersecting objects
C=union(C1,Cz);
C=union(C,Cylast);
C=union(C,Cyfirst);
C=union(C,Cxlast);
C=union(C,Cx);


