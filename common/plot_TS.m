%plot_TS

%ncload('filamentos1_ctd.nc','LATX','LONX','PRES','TEMP','PSAL','DOX2','DENS')

root = get( 0, 'UserData' );
self = root.self;

CM   = get( get( self, 'data_0d'), 'CYCLE_MESURE');
PRES = get( get( self, 'data_2d'), 'PRES');
TEMP = get( get( self, 'data_2d'), 'TEMP');
PSAL = get( get( self, 'data_2d'), 'PSAL');
DOX2 = get( get( self, 'data_2d'), 'DOX2');
DENS = get( get( self, 'data_2d'), 'DENS');

PRES(PRES>1e35) = NaN; 
TEMP(TEMP>1e35) = NaN;
PSAL(PSAL>1e35) = NaN;
DOX2(DOX2>1e35) = NaN;
DENS(DENS>1e35) = NaN;

Z = min(PRES(:)):max(PRES(:));

X = repmat(LONX,[1,length(Z)]);
Y = repmat(LATX,[1,length(Z)]);
Z = repmat(Z,[length(LONX),1]);

% n = 150
% x = X(:,1:n+1);
% y = Y(:,1:n+1);
% z = Z(:,1:n+1);
% T = TEMP(:,1:n+1);
% S = PSAL(:,1:n+1);
% D = DENS(:,1:n+1);
% Ox = DOX2(:,1:n+1);
ss = floor(min(PSAL(:)*10))/10:0.02:ceil(max(PSAL(:)*10))/10;
tt = floor(min(TEMP(:))):0.2:ceil(max(TEMP(:)));

[ss1,tt1] = meshgrid(ss,tt); ss1=ss1';tt1=tt1';
pp1 = 0*ss1;
dens = sw_dens(ss1,tt1,pp1)-1000;

figure;
[c,h]=contour(ss,tt,dens',[floor(min(dens(:)*10))/10:0.2:ceil(max(dens(:)*10))/10],'k-');
set(h,'color',[.6 .6 .6]);
hold on;
for i=1:size(X,1)
h=scatter(PSAL(i,:),TEMP(i,:),100,DOX2(i,:),'tag','TAG_SCATTER_TS');
set(h,'marker','.');
end
caxis([floor(min(DOX2(:))) ceil(max(DOX2(:)))]);
colorbar;

ylabel('Temperature (ºC)');
xlabel('Salinity (PSS)');
title({CM; 'T-S vs 02 diagram'});
%title_colorbar('mL L^-^1')
good_titles(14);
box on;

%print -djpeg100 TS_diagram





