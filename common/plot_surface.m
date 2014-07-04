clear all
close all
% lecture des donnees et on remplace les Fill values
ncload('upsen2_ctd.nc','LATX','LONX','PRES','TEMP','PSAL','DOX2','DENS','PROFILS')
PRES(PRES>1e35) = NaN; 
TEMP(TEMP>1e35) = NaN;
PSAL(PSAL>1e35) = NaN;
DOX2(DOX2>1e35) = NaN;
DENS(DENS>1e35) = NaN;
DENS(DENS<10) = NaN;
Z = min(PRES(:)):max(PRES(:));


% INTERPOLATION SUR UNE GRILLE REGULIERE
%---------------------------------------

% grille sur laquelle on veut interpoler
x = min(LONX):0.05:max(LONX);
y = min(LATX):0.05:max(LATX);

% choix du niveau:
niv = input('Profondeur de l''interpolation :   ');
ind_niv = find(Z==niv);

% interpolation
[xx,yy] = meshgrid(x,y);xx=xx';yy=yy';
SST = griddata(LONX,LATX,TEMP(:,ind_niv),xx,yy);
SSS = griddata(LONX,LATX,PSAL(:,ind_niv),xx,yy);
SSD = griddata(LONX,LATX,DENS(:,ind_niv),xx,yy);
SSO = griddata(LONX,LATX,DOX2(:,ind_niv),xx,yy);

% Figure m_map
%---------------
m_proj('mercator','lon',[-82.5 -79],'lat',[-9.5 -6.5])
figure
subplot(2,2,1)
m_contourf(xx,yy,SST,50);
shading flat
hold on
m_plot(LONX,LATX,'k.')
m_coast('patch',[.6 .6 .6])
m_grid('box','fancy')
title(['Temperature at ' num2str(niv) 'm'])
colorbar
%good_titles(14)
m_contour(xx,yy,SST,[floor(min(SST(:))):0.5:ceil(max(SST(:)))],'k');
%title_colorbar('ºC')

subplot(2,2,2)
m_contourf(xx,yy,SSS,50);
shading flat
hold on
m_plot(LONX,LATX,'k.')
m_coast('patch',[.6 .6 .6])
m_grid('box','fancy')
title(['Salinity at ' num2str(niv) 'm'])
colorbar
%good_titles(14)
m_contour(xx,yy,SSS,[floor(min(SSS(:))):0.1:ceil(max(SSS(:)))],'k');

subplot(2,2,3)
m_contourf(xx,yy,SSO,50);
shading flat
hold on
m_plot(LONX,LATX,'k.')
m_coast('patch',[.6 .6 .6])
m_grid('box','fancy')
title(['Oxygen at ' num2str(niv) 'm'])
colorbar
%good_titles(14)
m_contour(xx,yy,SSO,[floor(min(SSO(:))):10:ceil(max(SSO(:)))],'k');
%title_colorbar('ml L^-^1')

subplot(2,2,4)
m_contourf(xx,yy,SSD,50);
shading flat
hold on
m_plot(LONX,LATX,'k.')
m_coast('patch',[.6 .6 .6])
m_grid('box','fancy')
title(['Density at ' num2str(niv) 'm'])
colorbar
%good_titles(14)
m_contour(xx,yy,SSD,[floor(min(SSD(:))):0.2:ceil(max(SSD(:)))],'k');
%title_colorbar('kg m^-^3')
m_bug






