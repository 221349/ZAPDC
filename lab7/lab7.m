close all;
clear;



fil = [1, 2, 1; 2, 4, 2; 1, 2, 1] / 16;

fil = [1/2,0,0; 0, 0, 0; 0, 0, 1/2];
IMG = imread('/home/lev/ZAPDC/lab3/r_wave.png');


%sum(sum(double(get_square_piece(IMG, [3, 3], 1)).*fil))


%image(splot_filter(IMG, fil))
imwrite(splot_filter(IMG, gauss_filter(5)), '/tmp/l.png')

function out = splot_filter(IMG, fil)
    R = (length(fil(1,:)) - 1) / 2 ;
    length(IMG(:,1,1))
    for y = 1:length(IMG(:,1,1))
        y
        for x = 1:length(IMG(1,:,1))
            out(y,x,:) = uint8( sum(sum( double(get_square_piece(IMG, [x, y], R)).*fil)) );
        end
    end
end    
    

function out = get_square_piece(IMG, vector_in, radius)
    pos = vector_in - radius - 1;
    for x = 1:(radius * 2 + 1)
        for y = 1:(radius * 2 + 1)
            out(y,x,:) = get_pixel(IMG, [pos(1)+x, pos(2)+y]);
        end
    end
end

function out = get_pixel(IMG, vector_in)
    Xo = length(IMG(1,:,1));
    Yo = length(IMG(:,1,1));
    vector_in = ceil(vector_in);
    if(vector_in(1) < 1) | (vector_in(1) > Xo) | (vector_in(2) < 1) | (vector_in(2) > Yo)
        % Background col:
        out(1,1,:) = uint8([0 0 0]);
    else
        out = IMG(vector_in(2), vector_in(1), :);
    end
end

function out = gauss_filter(radius)
    len = radius * 2 + 1;
    for y = 1:len
        for x = 1:len
            out(x,y) = (1/ (2^ (abs(x - radius -1)) ) ) / (2^ (abs(y - radius -1) ) );
            %out(x,y) = max - ((x - radius -1)^2  + (y - radius -1) ^2);
        end
    end
    out = out / sum(sum(out));
end