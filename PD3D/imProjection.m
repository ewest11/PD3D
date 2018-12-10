function [projection] = imProjection(imStack)
%% Make projection of 3-D image stack
%   Detailed explanation goes here'
projection=imStack(:,:,1);
for i=1:size(imStack,3)
    projection=projection+imStack(:,:,i);
end
end

