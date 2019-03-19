close all;
clear;

IMG = imread('dummy-reversal-featured.png');
%image(IMG)

%Resolution:
XR = 220;
YR = 220;


imwrite(v_nearest(IMG, [1, 2], -230), 'c1.png')

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

%image(nearest(IMG,XR,YR))
%imwrite(nearest(IMG,XR,YR), 'c1.png')
%imwrite(bilinear(IMG,XR,YR), 'd2.png')



%% Functions:

function out = nearest(in,Xr,Yr)
    Xo = length(in(1,:,1)) -1;
    Yo = length(in(:,1,1)) -1;
    for y = 1:Yr
        for x = 1:Xr
            %Y(y) = fix(y * Yo / Yr) +1;
            %X(x) = fix(x * Xo / Xr) +1;
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
            
            X = [(x2 - x), (x - x1)];
            Y = [(y2 - y); (y - y1)];
            Q = [in(y1, x1, :), in(y2, x1, :);  in(y1, x2, :), in(y2, x2, :)];
            for d = 1:3
                %T = double(Q(:,:,d)) * (Y);overload same arguments count
                out(yP,xP,d) = uint8((X) * double(Q(:,:,d)) * (Y));
            end
        end
    end
end

function out = rot(in, theta)
    out = in * [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
end

function out = v_nearest(in, vector, theta)
    Xo = length(in(1,:,1));
    Yo = length(in(:,1,1));
    Base = [[0 0] , 
            rot([0, Yo*vector(2)], theta) ,
            rot([Xo*vector(1),  Yo*vector(2)], theta) ,
            rot([Xo*vector(1),  0], theta)];
    offset_x = round( min(Base(:,1)) );
    offset_y = round( min(Base(:,2)) );
    size_x = abs( offset_x - round( max(Base(:,1)) ) );
    size_y = abs( offset_y - round( max(Base(:,2)) ) );
    
    for y = 1:size_y
        for x = 1:size_x
            pos = round( r_transform([x + offset_x, y + offset_y] , vector, theta) ) +1;
            
            if check_location(pos, Xo, Yo)
                out(y,x,:) = in(pos(2), pos(1), :);
            else
                out(y,x,:) = uint8([0, 0, 0]);
            end
        end
    end
end


function out = r_transform(vector_in, vector_s, theta)
    t = rot(vector_in, -theta);
    out = [t(1)/vector_s(1), t(2)/vector_s(2)];
end

function out = check_location(vector_in, Xo, Yo)
    if(vector_in(1) < 1) 
        out = false;
    elseif(vector_in(1) > Xo)
        out = false;
    elseif(vector_in(2) < 1)
        out = false;
    elseif(vector_in(2) > Yo)
        out = false;
    else
        out = true;
    end
end