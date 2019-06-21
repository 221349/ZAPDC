close all;
clear;

IMG = imread('jab_s.png');
%image(IMG)

%Resolution:



XR = (4) * length(IMG(1,:,1));
YR = (3) * length(IMG(:,1,1));

vector = [-XR / length(IMG(1,:,1)); YR/length(IMG(:,1,1)) ];
% 
% % Time test
% for i = 1:5
%     tic;
%     nearest(IMG,XR,YR);
%     n_t(i) = toc
%     tic;
%     bilinear(IMG,XR,YR);
%     b_t(i) = toc
%     
%     
%     tic;
%     v_nearest(IMG, vector, 132);
%     vn_t(i) = toc
%     tic;
%     v_bilinear(IMG, vector, 132);
%     vb_t(i) = toc
%  end
% 
% nearest_time = mean(n_t)
% bilinear_time = mean(b_t)
% v_nearest_time = mean(vn_t)
% v_bilinear_time = mean(vb_t)
% 
% % Write interpolation results:
% imwrite(nearest(IMG,XR,YR), 'jab_nearest_s.png')
% imwrite(bilinear(IMG,XR,YR), 'jab_bilinear_s.png')n
% imwrite(v_nearest(IMG, vector, 1), 'jab_v_nearest_r.png')
% imwrite(v_bilinear(IMG, vector, 1), 'jab_v_bilinear_r.png')

imwrite(v_keys(IMG, vector, 210), 'outks.png')

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
            y = yP * Yo / Yr + 0.5;
            x = xP * Xo / Xr + 0.5;
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

function out = keys(in,Xr,Yr)
Lo = [
    0,  2,  0,  0;
    -1, 0,  1,  0;
    2,  -5, 4, -1;
    -1, 3,  -3, 1;
]
Ro = transpose(Lo)

    Xo = length(in(1,:,1));
    Yo = length(in(:,1,1));
    for yP = 1:Yr
        for xP = 1:Xr
            y = yP * Yo / Yr + 0.5;
            x = xP * Xo / Xr + 0.5;
            F = get_F(in, x, y);
            x = x - fix(x);
            y = y - fix(y);
            X = [1, x, x^2, x^3];
            Y = [1; y; y^2; y^3];
            for d = 1:3
                A(:,:,d) = (Lo * double(F(:,:,d))) * Ro;
                out(yP,xP,d) =  uint8(((X * A(:,:,d)) * Y) * 0.25);
            end
        end
    end
end

function out = get_F(in, x, y)
    y0 = fix(y) - 1;
    x0 = fix(x) - 1;
    for xP = 0:3
        for yP = 0:3
            out(xP+1,yP+1,:) = get_pixel(in, [x0 + xP, y0 + yP]);
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
            pos = r_transform([x + offset_x, y + offset_y] , vector, theta) + 0.5;
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

function out = v_keys(in, vector, theta)
Lo = [
    0,  2,  0,  0;
    -1, 0,  1,  0;
    2,  -5, 4, -1;
    -1, 3,  -3, 1;
]
Ro = transpose(Lo)

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
    
    for yP = 1:size_y
        for xP = 1:size_x
            pos = r_transform([xP + offset_x, yP + offset_y] , vector, theta) + 0.5;           
            
            y = pos(2);
            x = pos(1);
            F = get_F(in, x, y);
            x = x - fix(x);
            y = y - fix(y);
            X = [1, x, x^2, x^3];
            Y = [1; y; y^2; y^3];
            for d = 1:3
                A(:,:,d) = (Lo * double(F(:,:,d))) * Ro;
                %o = uint8(X * A(:,:,d) * Y)
                out(yP,xP,d) =  uint8(((X * A(:,:,d)) * Y) * 0.25);
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
    vector_in = ceil(vector_in);
    if(vector_in(1) < 1) | (vector_in(1) > Xo) | (vector_in(2) < 1) | (vector_in(2) > Yo)
        % Background col:
        out(1,1,:) = uint8([255 255 255]);
    else
        out = IMG(vector_in(2), vector_in(1), :);
    end
end
