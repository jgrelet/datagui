% datagui.draw
% plot position on map with coastline

%% COPYRIGHT & LICENSE
%  Copyright 2009 - IRD US191, all rights reserved.
%
%  This file is part of datagui Matlab package.
%
%    datagui package is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    datagui package is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
%    USA

% implement draw from graph interface 
% -----------------------------------
function draw( self )

% Pointer set to watch during reading and plotting
% ------------------------------------------------
set( self.hdl_figure, 'Pointer', 'watch' );
drawnow; % needed to see wath pointer

% if axe exist, clear it
if ishghandle(self.hdl_axe)
  delete(self.hdl_axe)  % cla don't works
end

% create a new axe
self.hdl_axe = axes(...
  'Units','pixels',...
  'Position',[60 180 500 400],...
  'Tag', 'axe_route',...
  'Box','on');

% try to get global attributes from ARGO, TSG-GOSUD and OceanSITES
% netcdf files
cycle_mesure = 'N/A';
plateforme = 'N/A';
inst_type = 'N/A';
codes = regexpi(keys(self.nc,'Attributes'),'CYCLE_?\w*','match');
for i=1: numel(codes)
  if ~isempty(codes{i})
    cycle_mesure = self.nc.Attributes.(char(codes{i})).data__;
  end
end
codes = regexpi(keys(self.nc,'Attributes'),'PLAT\w?FORM\w_?\w*','match');
for i=1: numel(codes)
  if ~isempty(codes{i})
    plateforme = self.nc.Attributes.(char(codes{i})).data__;
  end
end
codes = regexpi(keys(self.nc,'Attributes'),'\w*_?TYPE_?\w*','match');
for i=1: numel(codes)
  if ~isempty(codes{i})
    inst_type = self.nc.Attributes.(char(codes{i})).data__;
    break;
  end
end

% add title({'First line';'Second line'})
title(self.hdl_axe, ...
  { strcat( cycle_mesure, ' - ', plateforme), inst_type });

switch self.route_value
  case 1  % X=LONX Y=LATX
    X = self.nc.Variables.(self.lon_name).data__;
    Y = self.nc.Variables.(self.lat_name).data__;
    xlabel(self.nc.Variables.(self.lon_name).long_name);
    ylabel(self.nc.Variables.(self.lat_name).long_name);
  case 2  % X=DAYD Y=LATX;
    X = self.nc.Variables.(self.day_name).data__;
    Y = self.nc.Variables.(self.lat_name).data__;
    xlabel(self.nc.Variables.(self.day_name).long_name);
    ylabel(self.nc.Variables.(self.lat_name).long_name);
  case 3  % X=DAYD Y=LONX;
    X = self.nc.Variables.(self.day_name).data__;
    Y = self.nc.Variables.(self.lon_name).data__;
    xlabel(self.nc.Variables.(self.day_name).long_name);
    ylabel(self.nc.Variables.(self.lon_name).long_name);
end

interlx = 2;   % interval value between X labels
interly = 2;   % interval value between Y labels 
intervx = 1;   % interval value between X tickmarks 
intervy = 1;   % interval value between Y tickmarks 
ymin = floor(min( Y ))-2;
ymax = ceil( max( Y ))+2;
xmin = floor(min( X ))-2;
xmax = ceil( max( X ))+2;
limx   = [xmin xmax];
limy   = [ymin ymax];

%% plot data following user choice
switch self.route_value
  case 1
    if length( limx(1):interlx:limx(2)) > 9
      interlx = 4;
    end
    if length( limy(1):interly:limy(2)) > 9
      interly = 4;
    end
    [tickx, labelx] = datagui.tools.tickgeo( limx(1), limx(2), intervx, limx(1), interlx, 1);
    [ticky, labely] = datagui.tools.tickgeo( limy(1), limy(2), intervy, limy(1), interly, 0);
    
    switch self.map
      case 'NONE'   % none
        self.Primitive = line( X, Y, 'Color', 'r',...
          'MarkerSize', self.markersize_value, 'Marker',self.markertype,...
          'Tag','TagRoute', 'LineStyle', 'none');
        set( gca, 'YLim', limy, 'YTick', ticky, 'YtickLabel', labely,...
          'XLim', limx, 'Xtick', tickx, 'XtickLabel', labelx,...
          'Box', 'on', 'fontSize', [10], 'visible', 'on', ...
          'DataAspectRatio', [1 1 1], 'DataAspectRatioMode', 'manual');
        
      case 'M_MAP'   % m_map toolbox
        proj = 'Equidistant Cylindrical';
        %proj = 'mercator';
        m_proj(proj, 'lat', [ymin ymax], 'long',[xmin xmax]);
        
        % coastline
        % ------------------------
        switch self.coastline
          case {'ETOPO', 'TBASE'}
            m_coast('patch',[0.9 0.9 0.9]);
          case 'GSHHS crude'
            m_gshhs_c('patch',[.7 .7 .7]);
          case 'GSHHS low'
            m_gshhs_l('patch',[.7 .7 .7]);
          case 'GSHHS med'
            m_gshhs_i('patch',[.7 .7 .7]);
          case 'GSHHS high'
            m_gshhs_h('patch',[.7 .7 .7]);            
           case 'GSHHS full'
            m_gshhs_f('patch',[.7 .7 .7]);         
        end
        
        m_grid('box','fancy');
        %               m_grid('box','fancy','tickdir','in', 'Fontsize', [10],...
        %                 'xtick', [limx(1),intervx,limx(2)], ...
        %                 'ytick', [limy(1),intervy,limy(2)]);
        
        hold on;
        self.Primitive = m_line( X, Y, 'Color', 'r',...
          'MarkerSize', self.markersize_value, 'Marker',self.markertype,...
          'LineStyle', 'none');
        %hidem(gca);
        
      case 'MAP'   % Matlab map toolbox
        hw = worldmap([ymin-5 ymax+5],[xmin-5 xmax+5]);
        land = shaperead('landareas', 'UseGeoCoords', visible);
        geoshow(hw, land, 'FaceColor', [1 1 0.7]);      % terre jaune pale
        setm(gca,'FFaceColor',[0.7 0.9 1]);             % mer bleue
        %       obsolete
        %         hw = worldmap([ymin-5 ymax+5],[xmin-5 xmax+5],'patch');
        %         % pour une carte plus detaillee, mieux pour zoomer
        %         % mais tres tres long!
        %         %worldmap('hi',[ymin ymax],[lonmin lonmax],'patch')
        %         set(handlem('allpatch'),'Facecolor',[1 1 0.7]); % terre jaune pale
        %         setm(gca,'FFaceColor',[0.7 0.9 1]); % mer bleue
        % pour avoir une carte rectangle
        % setm(gca,'FFaceColor',[0.7 0.9 1],'MapParallels',1)
        % on inverse les axes pour plotm
        self.Primitive = linem( Y, X, 'Color', 'r',...
          'MarkerSize', self.markersize_value, 'Marker',self.markertype,...
          'LineStyle','none');
        %hidem(gca);
    end
    
  case {2,3}  % when DAYD = f(LATX) ou f(LONX)
    if length( xmin:interlx:xmax) > 9
      interlx = 5;
    end
    if length( limy(1):interly:limy(2)) > 9
      interly = 4;
    end
    [tickx, labelx] = ticktemps( limx(1), limx(2), intervx, limx(1), interlx);
    if self.route_value == 2
      [ticky, labely] = tickgeo( limy(1), limy(2), intervy, limy(1), interly, 0);
    else
      [ticky, labely] = tickgeo( limy(1), limy(2), intervy, limy(1), interly, 1);
    end
    self.Primitive = line( X, Y, 'Color', 'r', 'MarkerSize',...
      self.markersize_value, 'Marker',self.markertype,...tag
      'LineStyle','none');
    set(gca, 'YLim', limy, 'YTick', ticky, 'YtickLabel', labely,...
      'XLim', limx, 'Xtick', tickx, 'XtickLabel', labelx,...
      'Box', 'on', 'fontSize', [10], 'visible', 'on',...
      'DataAspectRatio', [1 1 1], 'DataAspectRatioMode', 'manual');
end

%self.AxesHandle = get(self.Primitive, 'Parent');

% set event when the mouse button move within the figure window
set( self.hdl_figure, 'WindowButtonMotionFcn', ...
  {@mouse_button_motion_callback, self} );

% set event when a mouse button is clicked while the cursor is over 
% the figure background
set( self.Primitive, 'tag', 'line_route', 'ButtonDownFcn', ...
  {@mouse_button_down_callback, self} );

% save limx et limy with appdata
% de button 2 (Lat) et 3 (lon)
setappdata(self.hdl_figure, 'Limx', limx);
setappdata(self.hdl_figure, 'Limy', limy);

% Pointer reset to arrow
% ----------------------
set( self.hdl_figure, 'Pointer', 'arrow' );


end