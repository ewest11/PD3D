function tiffWrite(im3Dmat,filename)
% filename = '/path/to/filename.tif'
% im3Dmat is a uint8 or uint16 3-D array of image intensity values
for i = 1:size(im3Dmat,3)
imwrite( im3Dmat(:,:,i), filename,'WriteMode','append');
end

end
