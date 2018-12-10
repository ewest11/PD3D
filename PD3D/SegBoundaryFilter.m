function [SegBoundaryFilt,watboundaryfilt] = SegBoundaryFilter(Seg,wat)
%% Filters watershed to only include elements that do not intersect image boundaries
[partialcells] = boundaryWat(wat); % Find segmented objects that intersect image boundary

nonint=setdiff(Seg.LabelId,double(partialcells)); 
rowsnew=ismember(Seg.LabelId,nonint);

% Define table with size-filtered, non-intersecting cells
SegBoundaryFilt=Seg(rowsnew,:);


% Create new watershed object file with only size-filtered objects
Labelsizefilt=SegBoundaryFilt.LabelId;
WatCells=ismember(wat,double(Labelsizefilt));
watboundaryfilt=double(WatCells).*double(wat);
watboundaryfilt=uint16(watboundaryfilt);

end