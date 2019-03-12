close all;
clear;



IMG = imread('dummy-reversal-featured.jpg');
%image(IMG)

%image(nearest(IMG,50,50))\



function out = nearest(in,Xr,Yr)
    Xo = length(in(1,:,1));
    Yo = length(in(:,1,1));
    for y = 1:Yr
        for x = 1:Xr
            out(y,x,:) = in(round(y * Yo / Yr) , round(x * Xo / Xr) , :);
        end
    end
end


function out = rot(in, theta)
    r_matrix = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    out = in*r_matrix;
end
