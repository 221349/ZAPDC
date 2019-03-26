close all;
clear;

IMG = imread('jab_s.png');
%image(IMG)

%Resolution:

XR = 2 * length(IMG(1,:,1));
YR = 2 * length(IMG(:,1,1));

vector = [XR / length(IMG(1,:,1)); YR/length(IMG(:,1,1)) ];

% for i = 1:5
%     tic;
%     nearest(IMG,XR,YR);
%     n_t(i) = toc;
%     tic;
%     bilinear(IMG,XR,YR);
%     b_t(i) = toc;
    
%     
%     tic;
%     v_nearest(IMG, vector, 132);
%     vn_t(i) = toc;
%     tic;
%     v_bilinear(IMG, vector, 132);
%     vb_t(i) = toc;
%  end
% 
% nearest_time = mean(n_t)
% % bilinear_time = mean(b_t)
% v_nearest_time = mean(vn_t)
% v_bilinear_time = mean(vb_t)

% % %image(nearest(IMG,XR,YR))
% imwrite(nearest(IMG,XR,YR), 'jab_nearest_s.png')
% imwrite(bilinear(IMG,XR,YR), 'jab_bilinear_s.png')
%imwrite(v_nearest(IMG, vector, 20), 'jab_v_nearest_r.png')
%imwrite(v_bilinear(IMG, vector, 20), 'jab_v_bilinear_r.png')



%% Main Functions:

function out = nearest(in,Xr,Yr)
    Xo = length(in(1,:,1));
    Yo = length(in(:,1,1));
    for y = 1:Yr
        for x = 1:Xr
            out(y,x,:) = get_pixel(in, [(x * Xo / Xr), (y * Yo / Yr)]);
        end
    end
end

function out = bilinear(in,Xr,Yr)
    Xo = length(in(1,:,1));
    Yo = length(in(:,1,1));
    for yP = 1:Yr
        for xP = 1:Xr
            y = yP * Yo / Yr;
            x = xP * Xo / Xr;
            y1 = fix(y);
            y2 = y1 + 1;
            x1 = fix(x);
            x2 = x1 + 1;
            
            X = [(x2 - x), (x - x1)];
            Y = [(y2 - y); (y - y1)];
            Q = [get_pixel(in, [x1, y1]), get_pixel(in, [x1, y2]);  get_pixel(in, [x2, y1]), get_pixel(in, [x2, y2])];
            for d = 1:3
                out(yP,xP,d) = uint8((X) * double(Q(:,:,d)) * (Y));
            end
        end
    end
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
            pos = r_transform([x + offset_x, y + offset_y] , vector, theta) ;
            out(y,x,:) = get_pixel(in, pos);
        end
    end
end


function out = v_bilinear(in, vector, theta)
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
            pos = r_transform([x + offset_x, y + offset_y] , vector, theta);
            pos_fixed = fix(pos);
            y1 = pos_fixed(2);
            y2 = y1 + 1;
            x1 = pos_fixed(1);
            x2 = x1 + 1;
            
            X = [(x2 - pos(1)), (pos(1) - x1)];
            Y = [(y2 - pos(2)); (pos(2) - y1)];
            Q = [get_pixel(in, [x1, y1]), get_pixel(in, [x1, y2]);  get_pixel(in, [x2, y1]), get_pixel(in, [x2, y2])];
            for d = 1:3
                out(y,x,d) = uint8((X) * double(Q(:,:,d)) * (Y));
            end
        end
    end
end

%% Helpers:

function out = rot(in, theta)
    out = in * [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
end

function out = r_transform(vector_in, vector_s, theta)
    t = rot(vector_in, -theta);
    out = [t(1)/vector_s(1), t(2)/vector_s(2)];
end

function out = get_pixel(IMG, vector_in)
    Xo = length(IMG(1,:,1));
    Yo = length(IMG(:,1,1));
    vector_in = round(vector_in);
    if(vector_in(1) < 1) | (vector_in(1) > Xo) | (vector_in(2) < 1) | (vector_in(2) > Yo)
        out(1,1,:) = uint8([255 255 255]);
    else
        out = IMG(vector_in(2), vector_in(1), :);
    end
end
