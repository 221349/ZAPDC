close all;
clear;

IMG = imread('4demosaicking.bmp');
out = demosaic(IMG);
image(out)

%imwrite(v_nearest(IMG, vector, 0), 'v_nearest_1.png'


function out = demosaic(in)
    Xo = length(in(1,:,1));
    Yo = length(in(:,1,1));
    
    for y = 1:Yo
        for x = 1:Xo
            if mod(Xo,2) == 1
                if mod(Yo,2) == 1
                    out(y,x,1) = in(y,x,1);
                    out(y,x,2) = uint8(1);
                    out(y,x,3) = uint8(1);
                else
                    out(y,x,1) = uint8(1)
                    out(y,x,2) = in(y,x,2);
                    out(y,x,3) = uint8(1);
                end
            else
                if mod(Yo,2) == 1
                    out(y,x,1) = uint8(1)
                    out(y,x,2) = in(y,x,2);
                    out(y,x,3) = uint8(1);
                else
                    out(y,x,1) = uint8(1);
                    out(y,x,2) = uint8(1);
                    out(y,x,3) = in(y,x,3);
                end
            end
        end
    end
end