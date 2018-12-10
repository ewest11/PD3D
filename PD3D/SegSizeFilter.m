function [SegSizeFilt,watsizefilt] = SegSizeFilter(Seg,wat,min_vox,max_vox)
%% Size filtration by defined sizes based specified min and max object volumes
vol_min=find(Seg.Volume_vox>min_vox);
vol_max=find(Seg.Volume_vox<max_vox);
m=intersect(vol_min,vol_max);
% Define new table with cells filtered by volume
SegSizeFilt=Seg(m,:);

% Create new watershed object file with only size-filtered objects
Labelsizefilt=SegSizeFilt.LabelId;
WatCells=ismember(wat,Labelsizefilt);
watsizefilt=double(WatCells).*double(wat);
watsizefilt=uint16(watsizefilt);

end