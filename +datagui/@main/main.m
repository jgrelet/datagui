%DATAGUI.MAIN class
%
% Main class of datagui package used to load ans display Netcdf files
%
%   OBJ = DATAGUI.MAIN
%     With no argument invokes Matlab's "uigetfile" dialog box
%     for selecting the NetCDF file to read.
%
%   OBJ = DATAGUI.MAIN(FILENAME)
%     Read and display the NetCDF FILENAME.
%
%   OBJ = DATAGUI.MAIN(NC)
%     Display the previously NetCDF NC object read with
%     nc = datagui.netcdf((FILENAME).
%
% $Id: main.m  2013-07-12 jgrelet $

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

% tips:  %  'Callback', {@(src,evnt) save( self.config_file, 'self', '-v7.3')});


%% Classdef definition
% -------------------
classdef main < datagui.graphics.graph
  
  % private properties definitions
  % --------------------------------
  % properties (Access = private, Hidden)
  % only for debug
  properties %(Access = private)
 
    % not implemented at this state
    % -----------------------------
    listeners = struct();
    
    % get pathname
    % ------------
    DEFAULT_PATH_FILE;
    
    % default label and value for uicontrol
    markersize_label      = {'1','2','3','4','5','6','7','8','9','10' };
    markersize_value      = 4;  % default
    markertype_label      = {'+','o','*','.','x','s','d','p','h','none' };
    markertype_value      = 5;  % default
    markertype            = 'x';
    map_label             = {'NONE', 'M_MAP'};
    map_value             = 1;
    map                   = 'NONE';
    coastline_label       = {'ETOPO', 'TBASE', 'GSHHS crude', 'GSHHS low',...
      'GSHHS med', 'GSHHS high', 'GSHHS full'};
    coastline_value       = 2;
    coastline             = 'TBASE';
    route_label           = {'LAT/LON','TIME/LAT','TIME/LON'};
    route_value           = 1;
    type_trace_label      = {'PROFILE', 'SECTION', 'MULTIPLE'}
    type_trace_value      = 1;
    climatology_label     = {'NONE', 'WOA01', 'WOA05'}
    climatology_value     = 1;
    visible               = 'on';
    
    % define where save user preferences
    config_file           = [prefdir, filesep, 'datagui.main', '.mat'];
    
  end
  
  properties (Access = public, SetObservable)
    
  end
  
  properties (Access = private, SetObservable)
    hdl_figure;
    %hdl_axe;
    hdl_toolbar;
    hdl_open_pushtool;
    hdl_save_pushtool;
    hdl_print_pushtool;
    hdl_zoomIn_toggletool;
    hdl_zoomOut_toggletool;
    hdl_pan_toggletool;
    hdl_qc_toggletool;
    %hdl_line_route;
    hdl_zoom;
    hdl_pan;
    hdl_motion_z;
    hdl_motion_x;
    hdl_motion_y;
    hdl_selected_z;
    hdl_selected_x;
    hdl_selected_y;
    hdl_mmr_panel;
    hdl_profil_panel;
    hdl_parameters_panel;
    hdl_type_trace_panel;
    hdl_climatology_panel;
    hdl_button_run;
    hdl_button_next;
    hdl_button_last;
    hdl_button_reset;
    hdl_popup_markersize;
    hdl_popup_markertype;
    hdl_popup_map;
    hdl_popup_coastline;
    hdl_popup_route;
        
    % handle to graphics data
    hdl_graphics;
    
  end
  
  % public methods
  % --------------
  methods
    
    % constructor
    % -----------
    function self = main(varargin)
      
      % initialize the default path
      self.DEFAULT_PATH_FILE = fileparts(mfilename('fullpath'));
      
      % define main interface
      % call destructor when user close the main windows
      % ------------------------------------------------
      self.hdl_figure = figure( ...
        'Name','Map trajectory',...
        'NumberTitle', 'off', ...
        'MenuBar', 'None',...
        'Toolbar', 'None', ...
        'WindowStyle', 'normal', ...
        'numbertitle', 'off',...
        'HandleVisibility','on',...
        'Position',[100 400 700 620],...
        'Tag','MAIN_FIGURE',...
        'MenuBar','figure',...
        'Color', get( 0, 'DefaultUIControlBackgroundColor' ),...
        'CloseRequestFcn', {@delete, self});
      
      % bug ? don't work in figure !!!
      set(self.hdl_figure,'menubar', 'none');
      
      % initialize properties value from mat file
      % -----------------------------------------
      datagui.main.load_config(self);
      
      % call function that define the GUI
      % ---------------------------------
      self.setUitoolbar;
      self.setUicontrols;
      
      % test arguments and open netcdf file
      % -----------------------------------
      if (nargin == 0)
        self.nc = datagui.netcdf;
      elseif (isa(varargin{1}, 'datagui.netcdf'))
        self.nc = varargin{1};
      elseif( isa(varargin{1}, 'char'))
        self.nc = datagui.netcdf(varargin{1});
      end
      
      % Radio buttons pour choix parametres GF3 (ROSCOP)
      self.select_physical_parameters( self.type_trace_value );
      
      % draw data on map only for file with data
      % ----------------------------------------
      if ~strcmp(self.nc.descriptor, 'memory')
        self.draw;
      end
      
    end % end of constructor
    
    % destructor
    % ----------
    function delete(src, ~, self)
      % save configuration inside user preference directory, call static
      % method save_config
      datagui.main.save_config(self);
      % close figure and listeners
      if ~isempty(src) && ishandle(src)
        delete(src);
      end
      % close opened netcdf file
      if ~isempty(self.nc)
        close(self.nc);
      end
      self.deleteListeners;
    end
    
    % display object
    % --------------
    function disp(self) %#ok<MANU>
      % do nothing
    end
    
    % properties value get methods by name, useful for private properties
    % -------------------------------------------------------------------
    function value = getPropValue(self, PropName)
      
      % Returns value of KeyType property
      value = self.(PropName);
    end
    
    % implement zoom from graph interface 
    % -----------------------------------
    function zoom(~, ~, self, factor)
      zoom(self.hdl_axe, factor);
      %       xlim = get(self.hdl_axe, 'Xlim');
      %       ylim = get(self.hdl_axe, 'Ylim');
      %       [LONGITUDE,LATITUDE]=m_ll2xy(xlim(1),ylim(1))
      drawnow;
    end
    
    % implement updateGraph from graph interface 
    % ------------------------------------------
    function updateGraph(self)
      
      switch self.route_value
        case 1  % X=(self.lon_name) Y=(self.lat_name)
          X = self.nc.Variables.(self.lon_name).data__;
          Y = self.nc.Variables.(self.lat_name).data__;
        case 2  % X=(self.day_name) Y=(self.lat_name);
          X = self.nc.Variables.(self.day_name).data__;
          Y = self.nc.Variables.(self.lat_name).data__;
        case 3  % X=(self.day_name) Y=(self.lon_name);
          X = self.nc.Variables.(self.day_name).data__;
          Y = self.nc.Variables.(self.lon_name).data__;
      end
      
      if isempty(self.Primitive)
        self.draw;
      end
      
      self.select_physical_parameters( self.type_trace_value );
      
      set(self.Primitive,'XData',X,'YData',Y);
      
    end % end of updateGraph method
    
  end  % end of public method
  
  % static methods
  % ---------------
  methods(Static)
    
    % save user preferences to MAT file in user preference directory
    %
    % -------------------------------------------------------------------
    function save_config(self)
      
      % save property values in struct
      S.map_value = self.map_value;
      S.markersize_value = self.markersize_value;
      S.markertype_value = self.markertype_value;
      S.route_value = self.route_value;
      S.type_trace_value = self.type_trace_value;
      S.coastline_value = self.coastline_value;
      S.climatology_value = self.climatology_value; %#ok<STRNU>
      save( self.config_file, 'S', '-v7.3')
      % return struct for save function to write to MAT-file
    end
    
    % load user preferences from  MAT file in user preference directory
    % -------------------------------------------------------------------
    function load_config(self)
      
      % test if config_file exist
      % -------------------------
      if exist(self.config_file, 'file') == 2
        
        % load properties values from struct
        % ----------------------------------
        load( self.config_file, 'S');
        self.map_value = S.map_value;
        self.map = self.map_label{self.map_value};
        self.markersize_value = S.markersize_value;
        self.markertype_value = S.markertype_value;
        self.markertype = self.markertype_label{self.markertype_value};
        self.route_value = S.route_value;
        self.type_trace_value = S.type_trace_value;
        self.coastline_value = S.coastline_value;
        self.coastline = self.coastline_label{self.coastline_value};
        self.climatology_value = S.climatology_value;
        
      end
      
    end % end of load_config method
    
  end % end of static methods
  
  % private methods
  % ---------------
  methods(Access = private)
    
    % destructor for listenners
    % -------------------------
    function deleteListeners(self)
      % would like to use struct2array, but
      % cannot concatenate event.listener with event.proplistener
      % so, iterate the struct fields
      fn = fieldnames(self.listeners);
      if ~isempty(fn)
        for ii = 1:length(fn)
          delete([self.listeners.(fn{ii})]);
        end
      end
    end
    
    % function setUitoolbar that define Toolbar
    % -----------------------------------------
    function setUitoolbar(self)
      
      %  Toolbar pushbuttons
      %  -------------------
      self.hdl_toolbar = uitoolbar(...
        'Parent',self.hdl_figure, ...
        'HandleVisibility','on');
      
      self.hdl_open_pushtool  =   uipushtool(...   % Open toolbar button
        'Parent',self.hdl_toolbar,...
        'TooltipString','Open file',...
        'CData', datagui.tools.iconRead(fullfile(matlabroot, ...
        '/toolbox/matlab/icons/opendoc.mat')),...
        'HandleVisibility','on', ...
        'Tag','PUSHTOOL_OPEN',...
        'UserData', 'off',...
        'Enable', 'on',...
        'ClickedCallback', {@open_menu_callback, self});
      self.hdl_save_pushtool  =   uipushtool(...   % Save toolbar button
        'Parent',self.hdl_toolbar,...
        'TooltipString','Save NetCDF file',...
        'CData',datagui.tools.iconRead( ...
        [self.DEFAULT_PATH_FILE filesep 'icons' filesep 'savedoc.mat']),...
        'HandleVisibility','on', ...
        'Tag','PUSHTOOL_SAVE',...
        'Enable', 'off',...
        'ClickedCallback', {@save_menu_callback, self});
      self.hdl_print_pushtool  =   uipushtool(...   % Print toolbar button
        'Parent',self.hdl_toolbar,...
        'TooltipString','Print figures',...
        'CData',datagui.tools.iconRead( ...
        [self.DEFAULT_PATH_FILE filesep 'icons' filesep 'printdoc.mat']),...
        'HandleVisibility','on', ...
        'Tag','PUSHTOOL_PRINT',...
        'visible', 'on', 'Enable', 'on',...
        'ClickedCallback', {@print_menu_callback, self});
      
      self.hdl_zoomIn_toggletool = uipushtool(...   % Open Zoom In (increase) toolbar button
        'Parent',self.hdl_toolbar,...
        'Separator', 'on', ...
        'TooltipString','Zoom In (increase)',...
        'CData', datagui.tools.iconRead(fullfile(matlabroot,...
        '/toolbox/matlab/icons/zoomplus.mat')),...
        'HandleVisibility','on', ...
        'Tag','PUSHTOOL_ZOOM_IN',...
        'ClickedCallback', {@zoom, self, 2});
      %         'OnCallback',  {@zoom_in_on_menu_callback, self},...
      %         'OffCallback', {@zoom_in_off_menu_callback, self});
      %
      self.hdl_zoomOut_toggletool = uipushtool(...   % Open Zoom Out (decrease) toolbar button
        'Parent',self.hdl_toolbar,...
        'Separator', 'on', ...
        'TooltipString','Zoom Out (decrease)',...
        'CData', datagui.tools.iconRead(fullfile(matlabroot,...
        '/toolbox/matlab/icons/zoomminus.mat')),...
        'HandleVisibility','on', ...
        'Tag','PUSHTOOL_ZOOM_OUT',...
        'ClickedCallback', @(src,evnt)zoom(self.hdl_axe, .5));
      %         'OnCallback',  {@zoom_out_on_menu_callback, self},...
      %         'OffCallback', {@zoom_out_off_menu_callback, self});
      
      self.hdl_pan_toggletool  =   uitoggletool(...   % Open Pan toolbar button
        'Parent',self.hdl_toolbar,...
        'TooltipString','Pan',...
        'CData',datagui.tools.iconRead(fullfile(matlabroot, ...
        '/toolbox/matlab/icons/pan.mat')),...
        'HandleVisibility','on', ...
        'Tag','PUSHTOOL_PAN',...
        'Enable', 'off',...
        'OnCallback',  {@pan_on_menu_callback, self},...
        'OffCallback', {@pan_off_menu_callback, self});
      
    end
    
    % function setUicontrols that define Uicontrols
    % ---------------------------------------------
    function setUicontrols(self)
      
      % display mouse coordinates with ButtonMotion callback
      self.hdl_motion_z = uicontrol( self.hdl_figure, 'style','Edit',...
        'HorizontalAlignment','left',...
        'position',[20 70 110 20] );
      self.hdl_motion_x = uicontrol( self.hdl_figure, 'style','Edit',...
        'HorizontalAlignment','left',...
        'position',[20 40 80 20] );
      self.hdl_motion_y = uicontrol( self.hdl_figure, 'style','Edit',...
        'HorizontalAlignment','left',...
        'position',[20 10 80 20] );
      
      % display mouse click coordinates
      self.hdl_selected_z = uicontrol( self.hdl_figure, 'style','Edit',...
        'HorizontalAlignment','left',...
        'position',[150 70 110 20] );
      self.hdl_selected_x = uicontrol( self.hdl_figure, 'style','Edit',...
        'HorizontalAlignment','left',...
        'position',[150 40 80 20] );
      self.hdl_selected_y = uicontrol( self.hdl_figure, 'style','Edit',...
        'HorizontalAlignment','left',...
        'position',[150 10 80 20] );
      
      % Frame (Run/Next/Last & Reset  button)
      self.hdl_profil_panel = uipanel('Title','Profiles',...
        'FontSize',8,...
        'Units','pixels',...
        'Position',[595 10 100 142]);
      % Run plot profiles
      self.hdl_button_run = uicontrol(...
        'Parent',self.hdl_profil_panel,...
        'Style','pushbutton',...
        'Position',[5 98 90 30],...
        'String','Run',...
        'Visible', self.visible,...
        'Tag', 'TAG_BUTTON_RUN',...
        'Callback', {@button_run_callback, self} );
      
      % Next profile
      self.hdl_button_next = uicontrol(...
        'Parent',self.hdl_profil_panel,...
        'Style','pushbutton',...
        'Position',[5 66 90 30],...
        'String','Next',...
        'Visible', self.visible,...
        'Callback', {@button_next_callback, self});
      % Last profile
      self.hdl_button_last = uicontrol(...
        'Parent',self.hdl_profil_panel,...
        'Style','pushbutton',...
        'Position',[5 34 90 30],...
        'String','Last',...
        'Visible', self.visible,...
        'Callback', {@button_last_callback, self} );
      % Clear profile
      self.hdl_button_reset = uicontrol(...
        'Parent',self.hdl_profil_panel,...
        'Style','pushbutton',...
        'Position',[5 2 90 30],...
        'String','Reset fig.',...
        'Visible', self.visible,...
        'Callback', {@button_reset_callback, self});
      
      % Frame (Markersize, map & route popup)
      self.hdl_mmr_panel = uipanel('Title','Display map',...
        'FontSize',8,...
        'Units','pixels',...
        'Position',[265 5 200 140]);
      
      % display popup MarkerSize
      uicontrol( ...
        'Parent',self.hdl_mmr_panel,...
        'Style','text',...
        'Position',[5 25 80 20],...
        'ForegroundColor','k',...
        'String','Marker size',...
        'HorizontalAlignment','left');
      self.hdl_popup_markersize = uicontrol( ...
        'Parent',self.hdl_mmr_panel,...
        'Style','popupmenu',...
        'Position',[5 10 80 20], ...
        'String',self.markersize_label,...
        'BackgroundColor','w',...
        'Value',self.markersize_value,...
        'Tag', 'popup_markersize', ...
        'CallBack', {@select_markersize_callback, self});
      
      % display popup MarkerType
      uicontrol( ...
        'Parent',self.hdl_mmr_panel,...
        'Style','text',...
        'Position',[95 25 92 20],...
        'ForegroundColor','k',...
        'String','Marker type',...
        'HorizontalAlignment','left');
      self.hdl_popup_markertype = uicontrol( ...
        'Parent',self.hdl_mmr_panel,...
        'Style','popupmenu',...
        'Position',[95 10 92 20], ...
        'String',self.markertype_label,...
        'BackgroundColor','w',...
        'Value',self.markertype_value,...
        'Tag', 'popup_markertype', ...
        'CallBack', {@select_markertype_callback, self});
      
      % display map selection popup
      uicontrol( ...
        'Parent',self.hdl_mmr_panel,...
        'Style','text',...
        'Position',[5 65 80 20],...
        'ForegroundColor','k',...
        'String','Map toolbox',...
        'HorizontalAlignment','left');
      self.hdl_popup_map = uicontrol( ...
        'Parent',self.hdl_mmr_panel,...
        'Style','popupmenu',...
        'Position',[5 50 80 20], ...
        'String',self.map_label,...
        'BackgroundColor','w',...
        'Value',self.map_value,...
        'CallBack', {@select_map_callback, self});
      
      % display coastline selection popup
      uicontrol( ...
        'Parent',self.hdl_mmr_panel,...
        'Style','text',...
        'Position',[95 65 92 20],...
        'ForegroundColor','k',...
        'String','Coastline',...
        'HorizontalAlignment','left');
      self.hdl_popup_map = uicontrol( ...
        'Parent',self.hdl_mmr_panel,...
        'Style','popupmenu',...
        'Position',[95 50 92 20], ...
        'String',self.coastline_label,...
        'BackgroundColor','w',...
        'Value',self.coastline_value,...
        'CallBack', {@select_coastline_callback, self});
      
      % select route axis popup
      uicontrol( 'Style','text',...
        'Parent',self.hdl_mmr_panel,...
        'Position', [5 105 80 20],...
        'ForegroundColor', 'k',...
        'String', 'Set route axis',...
        'HorizontalAlignment', 'left');
      
      self.hdl_popup_route = uicontrol( 'Style','popupmenu',...
        'Parent',self.hdl_mmr_panel,...
        'Position', [5 90 80 20],...
        'String', self.route_label,...
        'Value', self.route_value,...
        'Tag', 'popup_route',...
        'BackgroundColor', 'w',...
        'Callback', {@select_route_callback, self});
      
      % select type of plotting panel
      self.hdl_type_trace_panel = uipanel('Title','Plotting',...
        'Tag','type_trace',...
        'FontSize',8,...
        'Units','pixels',...
        'Position',[595 555 100 50]);
      
      uicontrol('Style','popupmenu',...
        'parent',self.hdl_type_trace_panel,...
        'String',self.type_trace_label,...
        'Tag','popup_type_trace',...
        'Value', self.type_trace_value,...
        'pos',[10 10 85 20],...
        'BackgroundColor','w',...
        'Callback', {@select_type_trace_callback, self} );
      
      % select climatology panel
      self.hdl_climatology_panel = uipanel('Title','Climatology',...
        'FontSize',8,...
        'Units','pixels',...
        'Position',[595 500 100 50]);
      uicontrol('Style','popupmenu',...
        'parent',self.hdl_climatology_panel,...
        'String',self.climatology_label,...
        'Tag','climatology',...
        'Value', self.climatology_value,...
        'pos',[10 10 85 20],...
        'BackgroundColor','w',...
        'HandleVisibility','on',...
        'Callback', {@select_climatology_callback, self} );
      
    end % end of setuicontrol
    
    % display position inside edit uicontrol, src is hdl_figure
    % ---------------------------------------------------------
    function mouse_button_motion_callback(~, ~, self)
      
      % get values of limx et limy saved with appdata
      limx = getappdata(self.hdl_figure, 'Limx');
      limy = getappdata(self.hdl_figure, 'Limy');
      
      % get mouse position
      cp = get( findobj( 'Tag', 'axe_route'), 'CurrentPoint' );
      % display x and y coordinates
      x = cp(1,1);
      y = cp(1,2);
      
      % get current date
      current_date = to_date(self.year_ref, x(1), 's');
      current_year = current_date(1:4);
      % get current year
      origin = datenum(self.year_ref, 1, 1);
      julian = x(1)+ origin - datenum(str2double(current_year), 1, 1);
      
      % following plot (lon/lat, temps/lat or temps/lon
      % test if mouse coordinates are inside frame.
      switch self.route_value
        case 1
          set(self.hdl_motion_z, 'Visible', 'off');
          set(self.hdl_selected_z, 'Visible', 'off');
          % try
          % [LAT, LON] = MINVTRAN(X, Y) the inverse transformation for the selected projection
          % Use text as an object to represent a point calculation
          if strcmp( self.map, 'MAP') % maptool
            [x, y] = minvtran(x, y, []);
          end
          % [LON,LAT] = M_XY2LL Converts X,Y to  coordinates using the
          % current projection
          if strcmp(self.map, 'M_MAP') % m_map
            [x, y] = m_xy2ll(x, y);
          end
          if limx(1) < x && x < limx(2) && ...
              limy(1) < y && y < limy(2)
            set( self.hdl_motion_x, 'string', dd2dm(x, 1));
            set( self.hdl_motion_y, 'string', dd2dm(y, 0));
          end
          
        case 2
          set(self.hdl_motion_z, 'Visible', 'on');
          if limx(1) < x && x < limx(2) && ...
              limy(1) < y && y < limy(2)
            set( self.hdl_motion_z, 'string', to_date(self.year_ref, x, 's'));
            set( self.hdl_motion_y, 'string', ...
              sprintf('%s  %7.3f', current_year, julian));
            set( self.hdl_motion_x, 'string', dd2dm(y, 0));
          end
          
        case 3
          set(self.hdl_motion_z, 'Visible', 'on');
          if limx(1) < x && x < limx(2) && ...
              limy(1) < y && y < limy(2)
            set( self.hdl_motion_z, 'string', to_date(self.year_ref, x, 's'));
            set( self.hdl_motion_y, 'string', ...
              sprintf('%s  %7.3f', current_year, julian));
            set( self.hdl_motion_x, 'string', dd2dm(y, 1));
          end
          
      end
      
    end % end of mouse_button_motion_callback
    
    % display cliked position in uicontrol edit
    % -----------------------------------------
    function mouse_button_down_callback(src, ~, self)
      
      % get current point in parent axe handle
      cp = get(get(src, 'parent'), 'CurrentPoint');
      
      % display x and y coordinates
      x = cp(1,1);
      y = cp(1,2);
      
      switch self.map_value
        case 2  % m_map
          [x, y] = m_xy2ll(x, y);
        case 3
          [x, y]  = minvtran(t(1),t(2),[]);
      end
      
      % get current date
      current_date = to_date(self.year_ref, x(1), 's');
      current_year = current_date(1:4);
      % get current year
      origin = datenum(self.year_ref, 1, 1);
      julian = x(1)+ origin - datenum(str2double(current_year), 1, 1);
      
      % populate text box hdl_selected_
      switch self.route_value
        case 1  % LATITUDE/LONGITUDE
          set( self.hdl_selected_x, 'string', dd2dm(x, 1));
          set( self.hdl_selected_y,  'string', dd2dm(y, 0));
          X = self.nc.Variables.LONX.data__;
          Y = self.nc.Variables.LATX.data__;
        case 2  % LATITUDE/TIME
          set( self.hdl_selected_z, 'string', current_date);
          % convert julian day from 1950 to current year
          set( self.hdl_selected_x, 'string', dd2dm(y, 0));
          set( self.hdl_selected_y, 'string', ...
            sprintf('%s  %7.3f', current_year, julian));
        case 3  % LONGITUDE/TIME
          set( self.hdl_selected_z, 'string', current_date);
          % convert julian day from 1950 to current year
          set( self.hdl_selected_x, 'string', dd2dm(y, 1));
          set( self.hdl_selected_y, 'string', ...
            sprintf('%s  %7.3f', current_year, julian));
      end
      
      % Calculate the point to determine
      % which point is closest to the mouse
      [~,indice] = min((X-x).^2 + (Y-y).^2);
      
      if isempty(self.hdl_graphics)
        self.hdl_graphics = datagui.graphics.multiProfils(self.nc,...
          'params',{'PRES','TEMP','PSAL','DOX2'},'profile', indice);
      else
        self.hdl_graphics.profile = indice;
      end
      
      
    end % end of mouse_button_down_callback
    
    % select the map callback (none or m_map)
    % ---------------------------------------
    function select_map_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.map_value = get(src, 'value');
      switch self.map_value
        case 1
          self.map = 'NONE';
          self.draw;
        case 2
          if exist('m_plot', 'file') == 2
            self.map = 'M_MAP';
            self.draw;
          else
            disp( 'Toolbox m_map not yet installed');
            disp( 'M_Map v1.4 is available via the web at http://www.eos.ubc.ca/~rich');
            set(src, 'value', 1);
          end
        case 3
          self.map_value = 1;
          disp( 'using Matlab toolbox Map not yet implemented');
      end
      
    end  % end of select_map_callback
    
    % select coastline callback
    % ---------------------------------------
    function select_coastline_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.coastline_value = get(src, 'value');
      self.coastline = self.coastline_label{self.coastline_value};
      self.draw;
      
    end  % end of select_coastline_callback
    
    % select route callback (LAT/LON)
    % ----------------------------------------
    function select_route_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.route_value = get(src, 'value');
      self.draw;
      
    end % end of select_route_callback
    
    % select the markersize callback
    % ---------------------------------------
    function select_markersize_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.markersize_value = get(src, 'value');
      set(self.Primitive, 'MarkerSize', self.markersize_value);
      %self.draw;
      
    end  % end of select_markersize_callback
    
    % select the markertype callback
    % ---------------------------------------
    function select_markertype_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.markertype_value = get(src, 'value');
      self.markertype = self.markertype_label{self.markertype_value};
      set(self.Primitive, 'Marker', self.markertype);
      %self.draw;
      
    end  % end of select_markertype_callback
    
    % select the type_trace callback
    % ---------------------------------------
    function select_type_trace_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.type_trace_value = get(src, 'value');
      disp( 'callback select_type_trace_callback not yet implemented');
      
    end  % end of select_type_trace_callback
    
    % select the type_trace callback
    % ---------------------------------------
    function select_climatology_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.climatology_value = get(src, 'value');
      disp( 'callback select_climatology_callback yet implemented');
      fprintf(1, 'climatology selected : %s\n', ...
        self.climatology_label{self.climatology_value});
      
    end  % end of select_climatology_callback
    
    % select button RUN callback
    % ---------------------------------------
    function button_run_callback(src, ~, self) %#ok<INUSD>
      
      % dummy function not yet implemented
      % ----------------------------
      disp( 'button_run_callback for datagui.main not yet implemented');
      
    end  % end of button_run_callback
    
    % select button Next callback
    % ---------------------------------------
    function button_next_callback(src, ~, self) %#ok<INUSD>
      
      % dummy function not yet implemented
      % ----------------------------
      disp( 'button_next_callback for datagui.main not yet implemented');
      
    end  % end of button_next_callback
    
    % select button Last callback
    % ---------------------------------------
    function button_last_callback(src, ~, self) %#ok<INUSD>
      
      % dummy function not yet implemented
      % ----------------------------
      disp( 'button_last_callback for datagui.main not yet implemented');
      
    end  % end of button_last_callback
    
    % select button Reset callback
    % ---------------------------------------
    function button_reset_callback(src, ~, self) %#ok<INUSD>
      
      % dummy function not yet implemented
      % ----------------------------
      disp( 'button_reset_callback for datagui.main not yet implemented');
      
    end  % end of button_reset_callback
    
    
    % Open toolbar callback, open and read a new file
    % -------------------------------------------
    function open_menu_callback(~, ~, self)
      
      % Open standard dialog box for retrieving files
      % ---------------------------------------------
      [fileName, pathname] = uigetfile( ...
        {'*.nc';}, 'Pick a file');
      
      % flushes the event queue and updates the closed uigetfile window
      % ---------------------------------------------------------------
      drawnow;
      
      % if the user clicks the Cancel button or closes the dialog window,
      % FileName and PathName are set to 0.
      % -----------------------------------------------------------------
      if ~isequal(fileName, 0)
        
        % Pointer set to watch during reading and plotting
        % ------------------------------------------------
        set( self.hdl_figure, 'Pointer', 'watch' );
        
        % construct valid and full file path
        % -----------------------------------
        fullFileName = strcat(pathname, fileName);
        
        % Read the data
        % -------------
        self.nc = datagui.netcdf(fullFileName);
        
        % plot trajectory
        % ---------------
        self.draw;
        
      end  % if ~isequal(fileName, 0)
      
      % Pointer reset to arrow
      % ----------------------
      set( self.hdl_figure, 'Pointer', 'arrow' );
      
    end  % end of OpenMenuCallback
    
    % Save toolbar callback, save the file
    % ---------------------------------
    function save_menu_callback(~, ~, self) %#ok<INUSD>
      
      % dummy function not yet implemented
      % ----------------------------
      disp( 'callback save_menu_callback not yet implemented');
      
    end  % end of SaveMenuCallback
    
    % Print figure toolbar Callback
    % --------------------------
    function print_menu_callback(~, ~, self) %#ok<INUSD>
      
      % dummy function not yet implemented
      % ----------------------------
      disp( 'callback print_menu_callback not yet implemented');
      
    end  % end of PrintFigMenuCallback
    
    % zoomIn on toolbar callback
    %---------------------------
    function zoom_in_on_menu_callback(~, ~, self)
      
      % Desactivate some toggle buttons, hZoomOutToggletool changed state
      % must be call before zoom function because the callback set zoom to
      % off
      % -------------------------------------------------------------------
      %set( hZoomOutToggletool,   'state', 'off' );
      %set( hQCToggletool,        'state', 'off' );
      %    set( hPanToggletool,       'state', 'off' );
      %set( hTimelimitToggletool, 'state', 'off' );
      
      % Hide the map. Otherwise it slows down the zooming
      % -------------------------------------------------
      %     set( hMapToggletool,       'state', 'off' );
      
      % returns a zoom mode object for the figure hdl_figure handle
      % ---------------------------------------------------------
      self.hdl_zoom = zoom(self.hdl_figure);
      
      % turns off the automatic adaptation of date ticks
      % ------------------------------------------------
      datagui.tools.zoom_adaptive_date_ticks('off');
      
      % turns interactive zooming to in (increase)
      % ------------------------------------------
      set(self.hdl_zoom, 'direction', 'in');
      
      % Disallows a zoom operation on the MAP axes objects
      % --------------------------------------------------
      %      setAllowAxesZoom(self.hdl_zoom, hPlotAxes(4), false);
      
      % turns on interactive zooming (same effect than zoom on) but prevent
      % side effect on another figure
      % -------------------------------------------------------------------
      set(self.hdl_zoom, 'enable', 'on');
      
      % Set this callback to listen to when a zoom operation finishes
      % bug ?: must be call after enable zoom
      % bug: this function don't work inside a class as a method, hgfeval
      % run an exeption in line 63
      % -------------------------------------------------------------
      set(self.hdl_zoom, 'ActionPostCallback', ...
        {@datagui.tools.zoom_pan_post_callback, self});
      
    end  % end of zoom_in_on_menu_callback
    
    % ZoomIn off toolbar callback
    %---------------------------
    function zoom_in_off_menu_callback(~, ~, self) %#ok<INUSD>
      
      % disable zoom mode
      % -----------------
      zoom off;
      
    end  % end of zoom_in_off_menu_callback
    
    % ZoomOut on toolbar callback
    %----------------------------
    function zoom_out_on_menu_callback(~, ~, self)
      % ----------------------------
      
      % Desactivate Zoom In Toggle toggle button
      % -----------------------------------------
      set( self.hdl_zoomIn_toggletool,    'state', 'off' );
      %set( self.hdl_qc_toggletool,        'state', 'off' );
      set( self.hdl_pan_toggletool,       'state', 'off' );
      
      % returns a zoom mode object for the figure hdl_figure handle
      % ---------------------------------------------------------
      self.hdl_zoom = zoom(self.hdl_figure);
      
      % turns interactive zooming out (decrease)
      % ----------------------------------------
      set(self.hdl_zoom, 'direction', 'out');
      
      % Disallows a zoom operation on the MAP axes objects
      % --------------------------------------------------
      %     setAllowAxesZoom(self.hdl_zoom, hPlotAxes(4), false);
      
      % turns on interactive zooming (same effect than zoom on) but prevent
      % side effect on another figure
      % -------------------------------------------------------------------
      set(self.hdl_zoom, 'enable', 'on');
      
      % Set this callback to listen to when a zoom operation finishes
      % -------------------------------------------------------------
      set(self.hdl_zoom, 'ActionPostCallback', ...
        {@datagui.tools.zoom_pan_post_callback, self.hdl_zoom});
      
    end  % end of zoom_out_on_menu_callback
    
    % ZoomOut off toolbar callback
    %-----------------------------
    function zoom_out_off_menu_callback(~, ~, self) %#ok<INUSD>
      % ----------------------------
      
      % turns interactive zooming off
      % -----------------------------
      zoom off;
      
    end  % end of zoom_out_off_menu_callback
    
    % Pan on toolbar callback
    %-------------------------
    function pan_on_menu_callback(~, ~, self)
      
      % Desactivate some toggle buttons
      % -------------------------------
      %set( self.hdl_qc_toggletool,        'state', 'off' );
      %set( hTimelimitToggletool, 'state', 'off' );
      set( self.hdl_zoomIn_toggletool,    'state', 'off' );
      set( self.hdl_zoomOut_toggletool,   'state', 'off' );
      
      % Hide the map. Otherwise it slows down the panning
      % -------------------------------------------------
      %     set( hMapToggletool,       'state', 'off' );
      
      % Returns a pan mode object for the figure handle
      % -----------------------------------------------
      hPan = pan(self.hdl_figure);
      
      % Disallows a pan operation on the MAP axes objects
      % --------------------------------------------------
      %     setAllowAxesPan(hPan, hPlotAxes(4), false);
      
      % turns on interactive pan (same effect than pan on) but prevent
      % side effect on another figure
      % --------------------------------------------------------------
      set(hPan, 'enable', 'on');
      
      % Set this callback to listen to when a zoom operation finishes
      % must be call after enable zoom (bug ?)
      % -------------------------------------------------------------
      set(self.hdl_zoom, 'ActionPostCallback', ...
        {@datagui.tools.ZoomPan_PostCallback, self.hdl_zoom});
      
    end  % end of pan_on_menu_callback
    
    % Pan off toolbar callback
    %-------------------------
    function pan_off_menu_callback(~, ~, self) %#ok<INUSD>
      % ----------------------------
      
      % turns interactive pan off
      % -------------------------
      pan off;
      
    end  % end of pan_off_menu_callback
    
  end  % end of private method
  
end % end of main classdef
