function [HR] = highres_Puncta(binarycenter,detectedtiff)
%% This function produces a higher resolution image of detected puncta from the binary image of detected puncta centers

% A=imresize3(double(binarycenter),[size(binarycenter,1)*5,size(binarycenter,2)*5,size(binarycenter,3)]);
HR=imresize3(binarycenter,[size(binarycenter,1)*20,size(binarycenter,2)*20,size(binarycenter,3)*10],'cubic');
%HR=imdilate(A,strel('sphere',10));

%figure;imshow(imProjection(HR));
%% Write enhanced out tiff image stack
tiffWrite(HR,detectedtiff)

end

