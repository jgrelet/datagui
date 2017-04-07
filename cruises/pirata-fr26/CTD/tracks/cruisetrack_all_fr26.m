% Programme de la route de la campagne PIRATA-FR26
%

clear all; close all; clc

% identifiant de la campagne pour les fichiers à lire
% ---------------------------------------------------
cruise = 'pirata-fr26';

% Tailles des marques
% -------------------
markersize_XBT       = 5;
markersize_MOUILLAGE = 7;
markersize_VILLE     = 6;

% Nom pour le fichier d'impression
% --------------------------------
TitlePlot = upper(cruise);
fileName = strcat(TitlePlot, '-ALL');

% Fichier contenant le trajet de la campagne XBT
% --------------------------------------------------------------
% scripts perl
% FileStaPos = strcat('../', cruise, '.ctd');
% programme Go
FileStaPos = strcat('../ascii', filesep, cruise, '.ctd');
FileXBTPos = strcat('../../CELERITE/ascii', filesep, cruise, '.xbt');

% Fichier contenant le trajet de la campagne TSG
% --------------------------------------------------------------
FileTsgPos = strcat('../../THERMO/ascii', filesep, cruise, '_tsg');

% Zone geographique
% Pour tracer une carte qui chevauche le meridien 180, il
% faut exprimer les longitudes de 0 a 360. Ceci impose de
% transformer les longitudes lors de la lecture des donnees
% ---------------------------------------------------------
latmin = -15; latmax = 20; latint = 5;
lonmin = -30; lonmax = 15; lonint = 5;

% Contours de bathymétrie
% -----------------------
niveaux = [-3000 -1000 -200];

% Projection cartographique
% -------------------------
F = figure;
m_proj('mercator','lat',[latmin latmax],'long',[lonmin lonmax]);

% Contour de cote detaille
% ------------------------
 m_gshhs_i('patch',[.7 .7 .7]);

% Contour de cote moins detaille
% ------------------------------
%m_gshhs_l('patch',[.7 .7 .7]);

% Bathymetrie 5'x5'
% -----------------
[cs,h] = m_tbase('contour',niveaux);
% m_tbase('contourf',[ -4000 -3000 -2000 -200], 'edgecolor','k');

% Trace de la grille
% ------------------
m_grid('box','fancy','tickdir','in', 'ytick', [latmin:latint:latmax], ...
  'xtick', [lonmin:lonint:lonmax], 'Fontsize', [10]);

% Ajoute un titre
% ---------------
title( TitlePlot, 'Fontsize', 12, 'FontWeight', 'bold' );

% trace de la route prévue
% ------------------------
%m_plot([-23,0,2.37],[0,0,6.2],'LineWidth',1,'color','k');

% affichage Cotonou  6°20 N et 2°26 E
% -----------------------------------
m_line( HMtoH(2.27), HMtoH(6.2), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_VILLE,'color','k','markerfacecolor','k');
m_text( 1, 7.5,'Cotonou','vertical','middle', 'Fontsize', [11]);

% affichage Abidjan  5°15 N et 4° W 
% --------------------------------------------------
m_line( HMtoH(-4.02), HMtoH(5.15), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_VILLE,'color','k','markerfacecolor','k');
m_text( -6, 6,'Abidjan','vertical','middle', 'Fontsize', [11]);

% affichage Dakar 14°42 N et 17°20 W
% ----------------------------------
m_line( HMtoH(-17.20), HMtoH(14.42), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_VILLE,'color','k','markerfacecolor','k');
m_text( -16, 15,'Dakar','vertical','middle', 'Fontsize', [11]);

% affichage Midelo 16°53 N et 25°00 W
% ----------------------------------
m_line( HMtoH(-25), HMtoH(16.53), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_VILLE,'color','k','markerfacecolor','k');
m_text( -25, 18,'Midelo','vertical','middle', 'Fontsize', [11]);


% affichage bouées PIRATA
% ----------------------
m_line( HMtoH(-23), HMtoH(0), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_MOUILLAGE,'color','k','markerfacecolor','r');
m_line( HMtoH(-10), HMtoH(0), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_MOUILLAGE,'color','k','markerfacecolor','r');
m_line( HMtoH(0), HMtoH(0), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_MOUILLAGE,'color','k','markerfacecolor', 'r');
m_line( HMtoH(-10), HMtoH(-10), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_MOUILLAGE,'color','k','markerfacecolor','r');
m_line( HMtoH(-10), HMtoH(-6), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_MOUILLAGE,'color','k','markerfacecolor','r');  
m_line( HMtoH(8), HMtoH(-6), 'LineStyle', 'none','marker','o',...
    'markersize',markersize_MOUILLAGE,'color','k','markerfacecolor','r');


% Lecture et stockage de la feuille des profils XBT
% -------------------------------------------------
[st,date,heure,lat,lats,lon,lons,depth,type,t] = ...
   textread(FileXBTPos,'%d %s %s %s %s %s %s %d %s %s','headerlines',2);
   
% Conversion lat et lon en degre decimaux
% -------------------------------------------
lat = char(lat);
lat = HMtoH(str2num(lat(:,(1:2))) +  str2num(lat(:,(4:8))) /100);
ind =find(char(lats) == 'S');
for i=1:size(ind)
  lat(ind(i)) = lat(ind(i)) * -1;
end  
lon = char(lon);
lon = HMtoH(str2num(lon(:,(1:3))) +  str2num(lon(:,(5:9))) /100);
ind =find(char(lons) == 'W');
for i=1:size(ind)
  lon(ind(i)) = lon(ind(i)) * -1;
end 

% Lecture et stockage de la route depuis les donnees TSG
% ------------------------------------------------------
[year,dayd,latx,lonx,ssjt,ssps,cndc,sstp] = ...
    textread(FileTsgPos,'%f %f %f %f %f %f %f %f','headerlines',2);

% Trace du trajet tsg
% -------------------
m_plot(lonx,latx,'LineWidth',1,'color','k');

% Trace de la position des stations XBT
% --------------------------------------------------
% Couleur rouge pour XCTD, vert pour XBT
ind = strncmp(type,'XCTD',4);
for i=1:length(ind)
  if ind(i) == 0
    m_line( lon(i), lat(i),'marker','o','markersize',4,'color','k','markerfacecolor','g');
  end  
end
for i=1:length(ind)
  if ind(i)
    m_line( lon(i), lat(i),'marker','o','markersize',4,'color','k','markerfacecolor','r');
  end  
end

% Lecture et stockage de la feuille des profils CTD
% -------------------------------------------------
feature('DefaultCharacterSet', 'UTF8')
[st,date,heure,date_fin,heure_fin,lat,lats,lon,lons,depth,type,t] = ...
   textread(FileStaPos,'%d %s %s %s %s %s %s %s %s %d %s %s','headerlines',2);
feature('DefaultCharacterSet', 'ISO-8859-1')   

% Conversion lat et lon en degre decimaux
% -------------------------------------------
lat = char(lat);
lat = HMtoH(str2num(lat(:,(1:2))) +  str2num(lat(:,(4:8))) /100);
ind =find(char(lats) == 'S');
for i=1:size(ind)
  lat(ind(i)) = lat(ind(i)) * -1;
end  
lon = char(lon);
lon = HMtoH(str2num(lon(:,(1:3))) +  str2num(lon(:,(5:9))) /100);
ind =find(char(lons) == 'W');
for i=1:size(ind)
  lon(ind(i)) = lon(ind(i)) * -1;
end 

% Trace de la position des stations CTD
% -------------------------------------
for i=1:size(st)
  m_line(lon(i), lat(i),'marker','o','markersize',4,'color','k','markerfacecolor','b');
end

% tracé en X (long) Y (lat) des legendes
% -----------------------------------------
m_line( -5.5, -8,'LineStyle', 'none','marker','o','markersize',5,'color','k','markerfacecolor','b');
m_text( -5, -8,'Profils CTD   2000 m','vertical','middle', 'Fontsize', [12]);
m_line( -5.5, -10,'LineStyle', 'none','marker','o','markersize',5,'color','k','markerfacecolor','g');
m_text( -5, -10,'Profils XBT   800 m','vertical','middle', 'Fontsize', [12]);
m_line( -5.5, -12,'LineStyle', 'none','marker','o','markersize',5,'color','k','markerfacecolor','r');
m_text( -5, -12,'Mouillages PIRATA','vertical','middle', 'Fontsize', [12]);
%m_line( -5.5, -14,'LineStyle', 'none','marker','o','markersize',5,'color','k','markerfacecolor','y');
%m_text( -5, -14,'Hydrophone mooring','vertical','middle', 'Fontsize', [12]);

% m_line( -2.5, -12,'LineStyle', 'none','marker','o','markersize',5,'color','k','markerfacecolor','r');
% m_text( -2, -12,'Profils XCTD 1100 m','vertical','middle', 'Fontsize', [12]);

% get the figure number, starting in R2014b figure bacame an object
if verLessThan('matlab','8.4')
    figureNumber = num2str(F);
else
    figureNumber = num2str(F.Number);
end

% impression
% ----------
cmd = ['print -f' ,figureNumber, ' -d', 'png', ' ', fileName];
eval(cmd);
cmd = ['print -f' ,figureNumber, ' -d', 'jpeg', ' ', fileName];
eval(cmd);



