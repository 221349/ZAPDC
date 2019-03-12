close all;
clear;

propeller = 3;
%Resolution:
Xr = 320;
Yr = 240;
%Frames:
F_N = 60;
%VeScans_per_frame:
VS = 6;

for i = 1 :(F_N)
    m = i - 31;
    theta = 0:0.01:2*pi;
    rho = sin(propeller*theta + m*pi/10);
    
    [x,y] = pol2cart(theta, rho);
    f = figure('visible', 'off', 'Position', [0 0 Xr Yr]);
    plot(x,y,'k')
    xlim([-1 1])
    ylim([-1 1])
    
    F(i) = getframe;
end

A = F;
size_v = size(A(1).cdata(:,1,1));
line_h = size_v(1)/VS;
for i = 1 : F_N*VS
    for vl = 1:VS
        line_begin =  round(1 + line_h * (vl-1));
        line_end =  round(line_h * vl);
        A(i).cdata(line_begin:line_end,:,:) = F(1+mod(i*vl, F_N)).cdata(line_begin:line_end,:,:);
    end
end

%implay(A)
%implay(F)
movie2gif(F, 'F.gif', 'LoopCount', Inf, 'DelayTime', 1/F_N)
movie2gif(A, 'A.gif', 'LoopCount', Inf, 'DelayTime', VS/F_N)