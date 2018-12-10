
function [im3D]=tiff2mat(filename);
%% Import tiff file as 3-D stack (uint8 or uint16)
% *This function requires bfmatlab toolbox.
% filename = string ('/path/to/filename.tif') 

            
I3D=bfopen(filename);
s=size(I3D{1});
z=s(1);

for i=1:z
  Im{i}=I3D{1}{i};
end
    
I=cat(3,Im{:});
im3D=I;


end
