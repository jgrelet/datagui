function plot_map( self )
% methode plot_map de la classe datagui.netcdf
% trace la route sur un fond de carte

% $Id$

%markersize = root.markersize;
markersize_lbl   = {'1','2','3','4','6','8','10' };
markersize_value = 4;  % default
markersize       = 4;
map_label        = {'none', 'm_map'};
map_value        = 1;

% added in july 2013
route_value = 1;
visible = 'on';

%% met en place les controls
% le tag plot_map est commun a tous les objets
hdl_figure = findobj( 'Tag', 'plot_map' );
if( isempty(hdl_figure) )
  hdl_figure = figure( 'Name','Route oceano',...
    'numbertitle', 'off', ...
    'HandleVisibility','on',...
    'Position',[500 300 700 620],...
    'Tag','plot_map',...
    'MenuBar','figure',...
    'Color', get( 0, 'DefaultUIControlBackgroundColor' ));
  
  % Create axes
  hdl_axe = axes(...
    'Units','pixels',...
    'Position',[50 180 500 400],...
    'Tag', 'axe_route',...
    'Box','on');
  
  % affichage des coordonnees de la sourie (ButtonMotion)
  hdl_motion_date = uicontrol( hdl_figure, 'style','Edit',...
    'HorizontalAlignment','left',...
    'tag','tag_but1',...
    'position',[20 70 120 20] );
  hdl_motion_longitude = uicontrol( hdl_figure, 'style','Edit',...
    'HorizontalAlignment','left',...
    'tag','tag_but2',...
    'position',[20 40 80 20] );
  hdl_motion_latitude = uicontrol( hdl_figure, 'style','Edit',...
    'HorizontalAlignment','left',...
    'tag','tag_but3',...
    'position',[20 10 80 20] );
  
  % affichage des coordonnees de la sourie (ButtonMotion)
  hdl_select_date = uicontrol( hdl_figure, 'style','Edit',...
    'HorizontalAlignment','left',...
    'tag','tag_but4',...
    'position',[150 70 120 20] );
  hdl_select_longitude = uicontrol( hdl_figure, 'style','Edit',...
    'HorizontalAlignment','left',...
    'tag','tag_but5',...
    'position',[150 40 80 20] );
  hdl_select_latitude = uicontrol( hdl_figure, 'style','Edit',...
    'HorizontalAlignment','left',...
    'tag','tag_but6',...
    'position',[150 10 80 20] );
  
  %% Frame (Run/Next/Last & Reset  button)
  hdl_panel_profil = uipanel('Title','Profils',...
    'FontSize',8,...
    'Units','pixels',...
    'Position',[595 10 100 142]);
  % Run plot profiles
  hdl_button_run = uicontrol(...
    'Parent',hdl_panel_profil,...
    'Style','pushbutton',...
    'Position',[5 98 90 30],...
    'String','Run',...
    'Visible', visible,...  % ai remplace self.visible par visible
    'Tag', 'tag_button_run',...
    'Callback', 'getButtonRunCallback' );
  % Next profile
  hdl_button_next = uicontrol(...
    'Parent',hdl_panel_profil,...
    'Style','pushbutton',...
    'Position',[5 66 90 30],...
    'String','Next',...
    'Visible', visible,...
    'Callback', 'getButtonNextCallback');
  % Last profile
  hdl_button_last = uicontrol(...
    'Parent',hdl_panel_profil,...
    'Style','pushbutton',...
    'Position',[5 34 90 30],...
    'String','Last',...
    'Visible', visible,...
    'Callback', 'getButtonLastCallback' );
  % Clear profile
  hdl_button_reset = uicontrol(...
    'Parent',hdl_panel_profil,...
    'Style','pushbutton',...
    'Position',[5 2 90 30],...
    'String','Reset fig.',...
    'Visible', visible,...
    'Callback', 'getButtonResetCallback');
  
  % affichage du popup MarkerSize
  uicontrol( ...
    'Style','text',...
    'Position',[245 30 70 20],...
    'ForegroundColor','k',...
    'String','MarkerSize',...
    'HorizontalAlignment','left');
  hdl_popup_markersize = uicontrol( ...
    'Style','popupmenu',...
    'Position',[250 10 60 20], ...
    'String',markersize_lbl,...
    'BackgroundColor','w',...
    'Value',markersize_value,...
    'Tag', 'popup_markersize', ...
    'CallBack', @select_markersize_callback);
  
  % display map selection popup
  uicontrol( ...
    'Style','text',...
    'Position',[245 80 70 20],...
    'ForegroundColor','k',...
    'String','Mapping',...
    'HorizontalAlignment','left');
  hdl_popup_map = uicontrol( ...
    'Style','popupmenu',...
    'Position',[250 60 60 20], ...
    'String',map_label,...
    'BackgroundColor','w',...
    'Value',map_value,...
    'CallBack', @select_map_callback);
  
else
  figure(hdl_figure);
  % reset(gca);
  % reset(axe);
  cla reset;
  set(gca,'tag','axe_route');
end

%% titre sur plusieurs lignes
% title({'First line';'Second line'})
title( { strcat( self.Attributes.CYCLE_MESURE.data__, ' - ', ...
  self.Attributes.PLATEFORME.data__ ), ...
  self.Attributes.INSTRUMENT_TYPE.data__});

%% selectionne X et Y
try
  switch route_value
    case 1  % X=LONX Y=LATX
      X = self.Variables.LONX.data__; Y = self.Variables.LATX.data__;
      xlabel('Longitude'); ylabel('Latitude');
    case 2  % X=DAYD Y=LATX;
      X = self.Variables.DAYD.data__; Y = self.Variables.LATX.data__;
      xlabel('Jour julien'); ylabel('Latitude');
    case 3  % X=DAYD Y=LONX;
      X = self.Variables.DAYD.data__; Y = self.Variables.LONX.data__;
      xlabel('Jour julien'); ylabel('Longitude');
  end
catch
  warn ('profil', 'plot_map', 'load datafile first') ;
  delete(hdl_figure);
  return
end
interlx = 2;   % valeur de l'intervalle entre les labels X
interly = 2;   % valeur de l'intervalle entre les labels Y
intervx = 1;   % valeur de l'intervalle entre les tickmark X
intervy = 1;   % valeur de l'intervalle entre les tickmark Y
ymin = floor(min( Y ))-2;
ymax = ceil( max( Y ))+2;
xmin = floor(min( X ))-2;
xmax = ceil( max( X ))+2;
limx   = [xmin xmax];
limy   = [ymin ymax];

%% trace la route en fonction du fdc
switch route_value
  case 1
    if length( limx(1):interlx:limx(2)) > 9
      interlx = 4;
    end
    if length( limy(1):interly:limy(2)) > 9
      interly = 4;
    end
    [tickx, labelx] = tickgeo( limx(1), limx(2), intervx, limx(1), interlx, 1);
    [ticky, labely] = tickgeo( limy(1), limy(2), intervy, limy(1), interly, 0);
    
    switch map_value
      case 1   % none
        hdl_line_route = line( X, Y, 'Color', 'r', 'Marker', '+',...
          'MarkerSize', markersize,'Tag','TagRoute',...
          'LineStyle', 'none');
        set( gca, 'YLim', limy, 'YTick', ticky, 'YtickLabel', labely,...
          'XLim', limx, 'Xtick', tickx, 'XtickLabel', labelx,...
          'Box', 'on', 'fontSize', [10],...
          'DataAspectRatio', [1 1 1], 'DataAspectRatioMode', 'manual');
        
      case 2   % m_map
        proj = 'Equidistant Cylindrical';
        %proj = 'mercator';
        %plot_m_map( ymin-5, ymax+5, xmin-5, xmax+5, proj );
        m_proj(proj, 'lat', [ymin ymax], 'long',[xmin xmax]);
        
        % Contour de cote detaille
        % ------------------------
        m_gshhs_i('patch',[.7 .7 .7]);
        m_coast('patch',[0.9 0.9 0.9]);
        m_grid;
        hold on;
        hdl_line_route = m_line( X, Y, 'Color', 'r', 'Marker', '+',...
          'MarkerSize', markersize, 'LineStyle', 'none');
        %hidem(gca);
        
      case 3   % map toolbox
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
        %pour avoir une carte rectangle
        %setm(gca,'FFaceColor',[0.7 0.9 1],'MapParallels',1)
        % on inverse les axes pour plotm
        hdl_line_route = linem( Y, X, 'Color', 'r', 'Marker', '+',...
          'MarkerSize', markersize , 'LineStyle','none');
        %hidem(gca);
    end
    
  case {2,3}  % pour DAYD = f(LATX) ou f(LONX)
    if length( xmin:interlx:xmax) > 9
      interlx = 5;
    end
    if length( limy(1):interly:limy(2)) > 9
      interly = 4;
    end
    [tickx, labelx] = ticktemps( limx(1), limx(2), intervx, limx(1), interlx);
    if route_value == 2
      [ticky, labely] = tickgeo( limy(1), limy(2), intervy, limy(1), interly, 0);
    else
      [ticky, labely] = tickgeo( limy(1), limy(2), intervy, limy(1), interly, 1);
    end
    hdl_line_route = line( X, Y, 'Color', 'r', 'Marker', '+', 'MarkerSize',...
      markersize, 'LineStyle','none');
    set(gca, 'YLim', limy, 'YTick', ticky, 'YtickLabel', labely,...
      'XLim', limx, 'Xtick', tickx, 'XtickLabel', labelx,...
      'Box', 'on', 'fontSize', [10],...
      'DataAspectRatio', [1 1 1], 'DataAspectRatioMode', 'manual');
end

% on va stocker les valeurs limx et limy dans les chanps UserData
% de button 2 (Lat) et 3 (lon)
set( findobj( 'Tag', 'tag_but2' ), 'UserData', limx );
set( findobj( 'Tag', 'tag_but3' ), 'UserData', limy );

% met en place les gestionnaires de sourie sur la zone de travail
set( hdl_figure, 'WindowButtonMotionFcn', @getButtonMotionCallback );

% sur la route + click uniquement
% set( hdl_line_route, 'tag', 'line_route',...
%                      'ButtonDownFcn', 'getButtonDownCallback');

  function getButtonMotionCallback(src,eventdata)
    
    % recupere les valeurs limx et limy stockees dans les buton 2 et 3
    limx = get(findobj( 'Tag', 'tag_but2' ), 'UserData' );
    limy = get(findobj( 'Tag', 'tag_but3' ), 'UserData' );
    
    year = self.Variables.REFERENCE_DATE_TIME.data__;
    year = str2double({year(1:4)});
    
    pt = get( findobj( 'Tag', 'axe_route'), 'CurrentPoint' );
    t = [pt(1,1) pt(1,2)];
    
    % suivant le type de route a tracer (lon/lat, temps/lat et temps/lon
    % on test si le curseur est dans le cadre, si oui, on affiche les
    % coordonnees.
    switch route_value
      case 1
        set(hdl_motion_date, 'Visible', 'off');
        set(hdl_select_date, 'Visible', 'off');
        try
          % [LAT, LON] = MINVTRAN(X, Y) the inverse transformation for the selected projection
          % Use text as an object to represent a point calculation
          if map_value == 3 % maptool
            [t(2), t(1)] = minvtran(t(1),t(2),[]);
          end
          % [LON,LAT] = M_XY2LL Converts X,Y to  coordinates using the
          % current projection
          if map_value == 2 % m_map
            [t(1), t(2)] = m_xy2ll(t(1),t(2));
          end
          if limx(1) < t(1) & t(1) < limx(2) & ...
              limy(1) < t(2) & t(2) < limy(2)
            set( hdl_motion_longitude, 'string', dd2dm(t(1), 1));
            set( hdl_motion_latitude, 'string', dd2dm(t(2), 0));
          end
        catch
          disp( 'Error in getButtonMotionCallback' );
        end
        
      case 2
        set(tag_but1, 'Visible', 'on');
        if limx(1) < t(1) & t(1) < limx(2) & ...
            limy(1) < t(2) & t(2) < limy(2)
          set( hdl_motion_date, 'string', to_date(year, t(1), 's'));
          set( hdl_motion_longitude, 'string', num2str(t(1)));
          set( hdl_motion_latitude, 'string', dd2dm(t(2), 0));
        end
        
      case 3
        set(tag_but1, 'Visible', 'on');
        if limx(1) < t(1) & t(1) < limx(2) & ...
            limy(1) < t(2) & t(2) < limy(2)
          set( hdl_motion_date, 'string', to_date(year, t(1), 's'));
          set( hdl_motion_latitude, 'string', num2str(t(1)));
          set( hdl_motion_latitude, 'string', dd2dm(t(2), 1));
        end
        
    end
    
    
    
  end % end of getButtonMotionCallback

  % select the map (none or m_map)
  function select_map_callback(src, evt)
    
      % get index value of the popup
      % ----------------------------
      map_value = get(src, 'value');
      self.plot_map
      
  end  % end of select_map_callback

end  % end of plot_map
