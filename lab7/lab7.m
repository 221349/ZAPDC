close all;
clear;


IMG = imread('Leopard-with-noise.jpg');


%sum(sum(double(get_square_piece(IMG, [3, 3], 1)).*fil))


%image(splot_filter(IMG, fil))
imwrite(splot_filter(IMG, gauss_filter(1)), 'sprawozdanie/img/g3.png')
imwrite(splot_filter(IMG, gauss_filter(3)), 'sprawozdanie/img/b7.png')
imwrite(median_filter(IMG, 1), 'sprawozdanie/img/m3.png')
imwrite(median_filter(IMG, 3), 'sprawozdanie/img/b7.png')

imwrite(bilateral_filter(IMG, 40), 'sprawozdanie/img/b40.png')
imwrite(bilateral_filter(IMG, 100), 'sprawozdanie/img/b100.png')

%% Functions:


function out = bilateral_filter(IMG, fr)
    %X=double(XR);
    IMG=double(IMG);
    bis=7;
    bis_t=(bis-1)/2;
    bis_tt=bis_t+1;
    gs=4;
    
    y_length = length(IMG(:, 1, 1));
    x_length = length(IMG(1, :, 1))
    for i=1:bis
        for j=1:bis
            range_matrix(i,j)= sqrt((bis_tt-i)^2+(bis_tt-j)^2);
        end
    end

    for c=1:3
        for i=bis_tt:1:(y_length - bis_tt)
            i
            for j=bis_tt:1:(x_length - bis_tt)
                light_matrix=IMG(i-bis_t:i+bis_t, j-bis_t:j+bis_t, c);
                common=gaussmf(abs(light_matrix-IMG(i,j,c)),[fr 0]).*gaussmf(range_matrix,[gs 0]);
                out(i-bis_t,j-bis_t,c)=uint8(sum(sum(light_matrix.*common))/sum(sum(common)));
            end
        end
    end
end 


function out = median_filter(IMG, radius)
    l = (radius * 2 + 1)^2;
    for y = 1:length(IMG(:,1,1))
        y
        for x = 1:length(IMG(1,:,1))
            tmp = get_square_piece(IMG, [x, y], radius);
            for i = 1:3
                map = tmp(:,:,i);
                sorted = sort(map(:));
                out(y,x,i) = sorted(ceil(l/2));
            end
        end
    end
end 

function out = splot_filter(IMG, fil)
    R = (length(fil(1,:)) - 1) / 2 ;
    for y = 1:length(IMG(:,1,1))
        y
        for x = 1:length(IMG(1,:,1))
            out(y,x,:) = uint8( sum(sum( double(get_square_piece(IMG, [x, y], R)).*fil)) );
        end
    end
end  

%% Helpers:

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