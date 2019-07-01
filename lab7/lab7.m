close all;
clear;

IMG = imread('Leopard-with-noise.jpg');
IMG_ORG = imread('Leopard.jpg');


I = splot_filter(IMG, gauss_filter(2));
s5 = square_error(I, IMG_ORG)
imwrite(I, 'sprawozdanie/img/s5.png')

I = splot_filter(IMG, gauss_filter(3));
s7 = square_error(I, IMG_ORG)
imwrite(I, 'sprawozdanie/img/s7.png')



I = median_filter(IMG, 2);
m5 = square_error(I, IMG_ORG)
imwrite(I, 'sprawozdanie/img/m5.png')

I = median_filter(IMG, 3);
m7 = square_error(I, IMG_ORG)
imwrite(I, 'sprawozdanie/img/m7.png')



I = bilateral_filter(IMG, 50, 2);
b5 = square_error(I, IMG_ORG)
imwrite(I, 'sprawozdanie/img/b5.png')

I = bilateral_filter(IMG, 50, 3);
b7 = square_error(I, IMG_ORG)
imwrite(I, 'sprawozdanie/img/b7.png')


%% Functions:

function out = square_error(IMG_A, IMG_B)
    out = sum( sum( sum( (IMG_A - IMG_B).^2 ) ) ) / (length(IMG_A(:, 1, 1)) * length(IMG_A(1, :, 1)) * 3 );
end

function out = bilateral_filter(IMGin, fr, radius)
    y_length = length(IMGin(:, 1, 1));
    x_length = length(IMGin(1, :, 1));
    
    l = radius * 2 + 1;
    radius_p = radius +1;
    
    IMG=double(zeros((y_length + radius*2), (x_length + radius*2), 3));
    
    IMG(radius_p:(y_length+radius), radius_p:(x_length+radius), :)=double(IMGin);
    
    for i=1:l
        for j=1:l
            range_matrix(i,j)= sqrt((radius_p-i)^2+(radius_p-j)^2);
        end
    end

    
    for y=1:y_length
        y
        for x=1:x_length
            for c=1:3
                light_matrix=IMG(y:(y+radius*2), x:(x+radius*2), c);
                common=gaussmf(abs(light_matrix-IMG((y+radius),(x+radius),c)),[fr 0]).*gaussmf(range_matrix,[radius_p 0]);
                out(y,x,c)=uint8(sum(sum(light_matrix.*common))/sum(sum(common)));
            end
        end
    end
end


function out = median_filter(IMGin, radius)
    y_length = length(IMGin(:, 1, 1));
    x_length = length(IMGin(1, :, 1));
    
    l = (radius * 2 + 1)^2;
    radius_p = radius +1;
    
    IMG=uint8(zeros((y_length + radius*2), (x_length + radius*2), 3));
    
    IMG(radius_p:(y_length+radius), radius_p:(x_length+radius), :)= IMGin;
    
    for y = 1:y_length
        y
        for x = 1:x_length
            for c = 1:3
                map = IMG(y:(y+radius*2), x:(x+radius*2), c);
                sorted = sort(map(:));
                out(y,x,c) = sorted(ceil(l/2));
            end
        end
    end
end 

function out = splot_filter(IMGin, fil)
    radius = (length(fil(1,:)) - 1) / 2 ;
    
    y_length = length(IMGin(:, 1, 1));
    x_length = length(IMGin(1, :, 1));
    
    l = (radius * 2 + 1)^2;
    radius_p = radius +1;
    
    IMG=uint8(zeros((y_length + radius*2), (x_length + radius*2), 3));
    
    IMG(radius_p:(y_length+radius), radius_p:(x_length+radius), :)= IMGin;
    
    for y = 1:y_length
        y
        for x = 1:x_length
            
            out(y,x,:) = uint8( sum(sum( double(IMG(y:(y+radius*2), x:(x+radius*2), :)).*fil)) );
        end
    end
end  

%% Helpers:

function out = gauss_filter(radius)
    len = radius * 2 + 1;
    for y = 1:len
        for x = 1:len
            out(x,y) = (1/ (2^ (abs(x - radius -1)) ) ) / (2^ (abs(y - radius -1) ) );
        end
    end
    out = out / sum(sum(out));
end