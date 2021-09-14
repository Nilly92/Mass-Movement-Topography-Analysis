clc
clear 
close all

%% a
filename = 'DGM_Tirol_5m_epsg31254.tif';
lat = 47.301944;%47.3000 ; % latitude of Kleiner Solstein
lon = 11.324167;%11.3167; % longitude of Kleiner Solstein
proj = geotiffinfo(filename); % derives image properties in ...
%.tif file
[x,y] = projfwd(proj,lat,lon);% transform lat and long into ...
%plane
% coordinates
[row,col] = map2pix(proj.RefMatrix,x,y); % calculates pixel ...
% cordinates
% from plane coordinates
s = 2000; % defines the area around the peak by including ...
px (10km)
% distance in each direction.
z = ...
    imread(filename,'PixelRegion',{[row-s+1,row+s],[col-s+1,col+ ...
    s]});%reads
% the data in defined row and columns and returns 4000x4000
% array.
% convert pixel to plane coordinates.
[x,~] = pix2map(proj.RefMatrix,ones(1,2*s),[col-s+1:col+s]);
[~,y] = pix2map(proj.RefMatrix,[row-s+1:row+s],ones(1,2*s));


x0=[74924;240758];
dt=1;
xi=0.5;
T = Topography ( x, y, z );
c=talweg(T,xi,x0,dt);

%% b

figure(1)
imagesc(x,y,z)
demcmap(z)
cc=colorbar;
set(gca,'Ydir','normal')
ax=gca;
grid on
xlabel('x [m]')
ylabel('y [m]')
title('topography map')
cc.Label.String='elevation [m]';

hold on

x10=randn(1,100);
y10=randn(1,100);
rng(4562741)

[x50,y50]=projfwd(proj,lat,lon);
M50=[(50*x10)+x50 ; (50*y10)+y50];


for i=1:numel(x10)
    c=talweg(T,xi,M50(:,i),dt);
    plot(c(1,:),c(2,:),'Linewidth',1.5);
    h(i)=c(3,1)-c(3,end);
    dist(i)=norm([c(1,end)-c(1,1) c(2,end)-c(2,1)]);
    trac(i)= c(4,end);
    
    pause(0.01)
end

H=z(2000,2000)-z;
[xnew,ynew]= meshgrid(x,y);
L= sqrt((xnew(2000,2000)-xnew).^2+(ynew(2000,2000)-ynew).^2);
F= H./L;
contour(x,y,F,[xi xi],'k')

% Black line on the map defines max runout of moving mass by
% fahrboeschung
% value (xi). Talweg lines inside follow this decribed slope
% by this value.

%% c
figure(2)
scatter(trac,h)
xlabel('track legth [m]')
ylabel('height difference [m]')
grid on

% As long as the H/L ratio doesnt go over xi value
% scatter plot will follow a straight pattern.

figure(3)
scatter(dist,h)
xlabel('travelled distance [m]')
ylabel('height difference [m]')
grid on
hold off

% H/L ratio will change during traveling distance there for
% it will not
% follow a straight pattern.

%% d

for i=1:numel(x10)/2
    figure(4)
    c=talweg(T,xi,M50(:,2*i),dt);
    plot(c(4,:),c(3,:));
    if i==1
        hold on
    end
    grid on
end
xlabel('travelled distance [m]')
ylabel('height difference [m]')

% at the end of some plots height difference will not change
% after some distance,however , travelled distance will change
% following straight line pattern. Ratio of H/L goes nearly slope of 0
% degrees which is below 0.5 so it becomes flat