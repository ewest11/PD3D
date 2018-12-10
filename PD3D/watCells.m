function [watcellseg] = watCells(wat,Labels,filename)
%This function extracts cells from a watershed image and list of cell
%labels, writing them out to a uint16 file. This can be used to quickly
%extract cells of interest.
    % wat = watershed image stack (3D matrix)
    % Labels = vector of segmentation labels to extract from original watershed
    % filename = '/path/to/desiredoutpitfile.tif' = string specifying the
    % desired output TIFF file. TIFF output can be visualized using ImageJ
    % or ITK-SNAP software.

WatCells=ismember(wat,Labels);
watcellseg=WatCells.*wat;
watcellseg=uint16(watcellseg);
   
tifFile = filename;
 imwrite(watcellseg(:,:,1), tifFile,'tif')
for i = 2:size(wat,3)
imwrite( watcellseg(:,:,i), tifFile,'tif','WriteMode','append');
end
%Output can be saved as an MHA file in ImageJ and viewed in ITK-SNAP software to
%verify result.

end
