close all;
clear;

IMG = imread('dummy-reversal-featured.png');
%image(IMG)

%Resolution:
XR = 220;
YR = 220;

% 
% for i = 1:0
%     tic;
%     nearest(IMG,XR,YR);
%     n_t(i) = toc;
%     tic;
%     bilinear(IMG,XR,YR);
%     b_t(i) = toc;
% end
% nearest_time = mean(n_t)
% bilinear_time = mean(b_t)

image(nearest(IMG,XR,YR))
%imwrite(nearest(IMG,XR,YR), 'c1.png')
%imwrite(bilinear(IMG,XR,YR), 'd2.png')



%% Functions:

function out = nearest(in,Xr,Yr)
    Xo = length(in(1,:,1)) -1;
    Yo = length(in(:,1,1)) -1;
    for y = 1:Yr
        for x = 1:Xr
            Y(y) = fix(y * Yo / Yr) +1;
            X(x) = fix(x * Xo / Xr) +1;
            %%FIX when in(0,0..
            out(y,x,:) = in(fix(y * Yo / Yr) +1, fix(x * Xo / Xr) +1, :);
        end
    end
end

function out = bilinear(in,Xr,Yr)
    Xo = length(in(1,:,1)) -2;
    Yo = length(in(:,1,1)) -2;
    for yP = 1:Yr
        for xP = 1:Xr
            y = yP * Yo / Yr +1;
            x = xP * Xo / Xr +1;
            y1 = fix(y);
            y2 = y1 + 1;
            x1 = fix(x);
            x2 = x1 + 1;
            
            X = [(x2 - x), (x - x1)]
            Y = [(y2 - y); (y - y1)];
            Q = [in(y1, x1, :), in(y2, x1, :);  in(y1, x2, :), in(y2, x2, :)];
            for d = 1:3
                %T = double(Q(:,:,d)) * (Y);
                out(yP,xP,d) = uint8((X) * double(Q(:,:,d)) * (Y));
            end
        end
    end
end


function out = rot(in, theta)
    r_matrix = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    out = in*r_matrix;
end
