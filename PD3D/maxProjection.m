function [MP]=maxProjection(ims)
%% This function takes in a 3D image matrix and returns a 2-D projection of the max values in each z position
% MP = (double) output 2D max projeciton

MP=zeros(size(ims,1),size(ims,2));

for i = 1:size(ims,1)
    for j=1:size(ims,2)
        MIP=max(ims(i,j,:)); % Take max across z planes at each XY coordinate
        MP(i,j)=MIP;
    end 
end


end