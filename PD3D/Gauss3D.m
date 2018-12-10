function [Ker] = Gauss3D(sigma,spread)
%% This function produces an elliptical 3D gaussian kernel with sigma=sigma_x=sigma_y and sigma_z=spread*sigma
% Correct for PSF spread in Z - puncta in our images span approximately twice the number
% of pixels in Z as in XY. This will vary depending on the relative
% sampling in X, Y, and Z and this number can be changed accordingly. If
% sampling is unequal in X and Y, sigma_y can be individually specified in the Ker calculation.sigma_z=spread*sigma;
sigma_z=sigma*spread;



%% Construct 3D filter
d=ceil(sigma*4);

if mod(d,2)==0
d=d+1;
end
c=(d+1)/2;

e=ceil(sigma_z/sigma);
if mod(e,2)==0
e=e+1;
end
f=(e*d+1)/2;

% Construct 3D Gaussian kernel (symmetric in xy)
for p=1:d
    for q=1:d
        for r=1:e*d
Ker(p,q,r)=exp(-(((p-c)^2+(q-c)^2)/(2*sigma^2)+(r-f)^2/(2*sigma_z^2)));
        end
    end
end
% volumeViewer(Ker) can (and should) be used to visualize the kernel



end

