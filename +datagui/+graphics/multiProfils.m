%% Classdef definition
% -------------------
classdef (CaseInsensitiveProperties = true) multiProfils < datagui.graphics.graph
  
  % private properties definitions
  % --------------------------------
  % properties (Access = private, Hidden)
  % only for debug
  properties %(Access = private)
  
    Events = [];
    listeners = struct();
    roscop;
    keys                  = {'TEMP','PSAL'};
    profile               = 1;
    
    % get pathname
    % ------------
    DEFAULT_PATH_FILE;
    
    % default label and value for uicontrol
    markersize_label      = {'1','2','3','4','5','6','7','8','9','10' };
    markersize_value      = 2;  % default
    markertype_label      = {'none','+','o','*','.','x','s','d','p','h' };
    markertype_value      = 1;  % default
    markertype
    linestyle_label       = {'Solid line','Dashed line','Dotted line','Dash-dot line','No line'};
    linestyle_value       = 1
    linestyle             = {'-','--',':','-.','none'};
    visible               = 'on';
    label_fontsize        = 7;
    
  end
  
  properties (Access = public, SetObservable)
    
  end
  
  properties %(Access = private, SetObservable)
    hdl_figure;
    hdl_panel_plot;
    hdl_panel_select;
    hdl_panel_action;
    hdl_date;
    hdl_latitude;
    hdl_longitude;
    
  end
  
  % public methods
  % --------------
  methods
    
    % constructor
    % -----------
    function self = multiProfils(varargin)
      
      % test constructor argument
      % ------------------------
      switch nargin
        
        % choose a netcdf file
        case 0
          self.nc = datagui.netcdf;
          
          % assign a netcdf file
        otherwise
          if (isa(varargin{1}, 'datagui.netcdf'))
            self.nc = varargin{1};
          elseif( isa(varargin{1}, 'char'))
            self.nc = datagui.netcdf(varargin{1});
          end
          
          % could be add seabird .cnv ou .hdr file here
          
          % check for additional properties
          % -------------------------------
          property_argin = varargin(2:end);
          while length(property_argin) >= 2,
            property = property_argin{1};
            value    = property_argin{2};
            property_argin = property_argin(3:end);
            switch lower(property)
              case {'param', 'params','parameter','parameters'}
                self.keys = value;
              case {'profile', 'cast', 'number'}
                self.profile = value;              otherwise
                error('datagui:graphics:multiprofils', 'Unknown property: "%s"', property);
            end
          end
      end  % end switch nargin
      
      % test if multiprofiles figure exist
      hdl = findobj( 'Tag', 'MULTIPROFILES_FIGURE' );
      if isempty( hdl )
        
        % define multiprofiles interface
        self.hdl_figure = figure( ...
          'units', 'normalized', ...
          'Position', [0.1 0.1, 0.4, 0.8], ...
          'Color', get(0,'DefaultUIControlBackgroundColor'),...
          'HandleVisibility','on',...
          'name','Profils Oceano',...
          'MenuBar','figure',...
          'tag', 'MULTIPROFILES_FIGURE',...
          'CloseRequestFcn', @(obj, event) delete(self));
        
        % initialize the default path
        self.DEFAULT_PATH_FILE = fileparts(mfilename('fullpath'));
        
        % initialize roscop attribute from dynaload object
        self.roscop = datagui.dynaload('code_roscop.json', 'echo', false);
        
        % call function that define the GUI
        self.setUi;           
      else
        self.hdl_figure = figure( hdl );
      end
      
      % draw profiles
      self.draw;
      
      
    end % end of constructor
    
    % destructor
    % ----------
    function delete(self)
      if ~isempty(self.hdl_figure) && ishandle(self.hdl_figure);
        delete(self.hdl_figure);
        self.hdl_figure = [];
      end
      if ~isempty(self.nc)
        self.nc.close;
      end
      self.deleteListeners;
    end
    
    % properties value get methods by name, useful for private properties
    % -------------------------------------------------------------------
    function value = getPropValue(self, PropName)
      
      % Returns value of KeyType property
      value = self.(PropName);
    end
    
    % implement draw from graph interface
    % -----------------------------------
    function  draw(self)
      
      if ~isempty(self.Primitive)
        %delete(self.Primitive);
        delete(findobj('-regexp','Tag', 'MULTIPLOTX'));
        delete(findobj('-regexp','Tag', '[AXE]_'));
      end
      % set axe in the rigth panel
      self.Primitive = axes('parent', self.hdl_panel_plot);
      % get position of axes
      axePos = get(self.Primitive,'position');
      % move axe down to get more place
      set(self.Primitive,...
        'Position',[axePos(1) axePos(2)-0.05 axePos(3) axePos(4)+0.05]);
      
      % plot the first variable
      y = self.keys{1};
      key = self.keys{2};
      set(self.Primitive, ...
        'Xlim', [min(self.nc.Variables.(key).data__(self.profile,:)) ...
        max(self.nc.Variables.(key).data__(self.profile,:))] );
      hdl_line = plot(self.Primitive, self.nc.Variables.(key).data__(self.profile,:), ...
        self.nc.Variables.(y).data__(self.profile,:));
      set(self.Primitive, 'ydir', 'reverse', 'FontSize', self.label_fontsize, ...
        'Tag', strcat('AXE_', key));
      set(hdl_line, 'Tag', 'MULTIPLOTX');
      
      % display labels on axes
      ylabel(self.roscop.code_roscop.(y).long_name, 'FontSize', self.label_fontsize);
      xlabel(self.roscop.code_roscop.(key).long_name, 'FontSize', self.label_fontsize);
      
      % plot the last variables with multiPlotX
      for i = 3 : length(self.keys)
        key = self.keys{i};
        
        [~, axe_handle, floating_axe_handle] = ...
          datagui.graphics.multiPlotX(self.nc.Variables.(key).data__(self.profile,:), ...
          self.nc.Variables.(y).data__(self.profile,:), 'handle', self.hdl_panel_plot);
        set(axe_handle, 'ydir', 'reverse', 'Tag', strcat('AXE_', key));
        set(floating_axe_handle,'Xlim', [min(self.nc.Variables.(key).data__(self.profile,:)) ...
          max(self.nc.Variables.(key).data__(self.profile,:))], 'FontSize', self.label_fontsize,...
          'Tag', strcat('FLOAT_AXE_', key));
        xlabel(self.roscop.code_roscop.(key).long_name, 'FontSize', self.label_fontsize);
      end
      
      % display date and position
      set(self.hdl_date, 'string', to_date(self.year_ref,...
        self.nc.Variables.(self.day_name).data__(self.profile), 's'));
      set(self.hdl_latitude, 'string', dd2dm(self.nc.Variables.(self.lat_name).data__(self.profile), 0));
      set(self.hdl_longitude, 'string', dd2dm(self.nc.Variables.(self.lon_name).data__(self.profile), 1));
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
      if isempty(self.Primitive)
        self.draw;
      end
     %% add here !!!!
    end
    
    % set un new profile number
    % -------------------------
    function set.profile(self, profile)
      self.profile = profile;
      if ~isempty(self.hdl_figure)
        self.updateGraph;
      end
    end
    
    % go to next profile
    % ------------------
    function next(self)
      if self.profile + 1 <= length(self.nc.Variables.PROFILE.data__)
        self.profile = self.profile + 1;
        self.updateGraph;
      else
        fprintf(1, 'Maximum profile %d reach\n', self.profile);
      end
    end
    
    % go to last profile
    % ------------------
    function last(self)
      if self.profile - 1 > 0
        self.profile = self.profile - 1;
        self.updateGraph;
      else
        fprintf(1, 'Minimum profile %d reach\n', self.profile);
      end
    end
    
  end  % end of public method
  
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
    
    % function setUitoolbar that define user interface
    % --------------------------------------------------
    function setUi(self)
      
      %  panels definition
      self.hdl_panel_plot = uipanel('Parent',self.hdl_figure,...
        'FontSize',8, 'Position',[0 .2 .8 .8]);
      self.hdl_panel_select = uipanel('Parent',self.hdl_figure,...
        'FontSize',8, 'Position',[0 0 1 .2]);
      self.hdl_panel_action = uipanel('Parent',self.hdl_figure,...
        'FontSize',8, 'Position',[.8 .2 .2 .8], 'Tag', 'Tag_hdl_action');
      
      % display the profile date and position
      uicontrol('Parent',self.hdl_panel_select,...
        'Style','text',...
        'Units','normalized',...
        'Position',[.05 .77 .13 .22],...
        'FontWeight','bold',...
        'String','Date:',...
        'HorizontalAlignment','left');
      self.hdl_date = uicontrol('Parent',self.hdl_panel_select,...
        'Style','text',...
        'Units','normalized',...
        'Position',[.12 .77 .30 .22],...
        'HorizontalAlignment','left');
      % latitude
      uicontrol('Parent',self.hdl_panel_select,...
        'Style','text',...
        'Units','normalized',...
        'Position',[.4 .77 .13 .22],...
        'FontWeight','bold',...
        'String','Lat:',...
        'HorizontalAlignment','left');
      self.hdl_latitude = uicontrol('Parent',self.hdl_panel_select,...
        'Style','text',...
        'Units','normalized',...
        'Position',[.45 .77 .15 .22],...
        'HorizontalAlignment','left');
      % longitude
      uicontrol('Parent',self.hdl_panel_select,...
        'Style','text',...
        'Units','normalized',...
        'Position',[.65 .77 .13 .22],...
        'FontWeight','bold',...
        'String','Long:',...
        'HorizontalAlignment','left');
      self.hdl_longitude = uicontrol('Parent',self.hdl_panel_select,...
        'Style','text',...
        'Units','normalized',...
        'Position',[.72 .77 .15 .22],...
        'HorizontalAlignment','left');
      
      % dynamicaly create the parameters scale for popup menus
      % ------------------------------------------------------
      for i = 1 : length(self.keys)
        key = self.keys{i};
        string = self.roscop.code_roscop.(key).popup_string;
        % definition du nom du paramètre
        uicontrol('Parent',self.hdl_panel_select,...
          'Style','text',...
          'Units','normalized',...
          'Position',[.02+((i-1)*.12) .61 .13 .15],...
          'FontWeight','bold',...
          'String',key,...
          'HorizontalAlignment','left');
        % valeur mini
        uicontrol('Parent',self.hdl_panel_select,...
          'Style','edit',...
          'Units','normalized',...
          'Position',[.02+((i-1)*.12) .51 .1 .11],...
          'String',min(min(self.nc.Variables.(key).data__)),...
          'HorizontalAlignment','left');
        % valeur maxi
        uicontrol('Parent',self.hdl_panel_select,...
          'Style','edit',...
          'Units','normalized',...
          'Position',[.02+((i-1)*.12) .36 .1 .11],...
          'String',max(max(self.nc.Variables.(key).data__)),...
          'HorizontalAlignment','left');
        
        % definition des popup pour panel self.hdl_panel_select
        uicontrol('Parent',self.hdl_panel_select,...
          'Units','normalized',...
          'Position',[.02+((i-1)*.12) .19 .10 .13],...
          'Style','popupmenu',...
          'String',string,...
          'Value', 1,...
          'Tag',['popupmenu_' self.keys{i}],...
          'BackgroundColor','w',...
          'Callback',{@callback_plot_select, self, key});
      end
      
      % select line marker type
      uicontrol('Parent',self.hdl_panel_action,...
        'Style','text',...
        'Units','normalized',...
        'Position',[.15 .93 .75 .05],...
        'String','Marqueur',...
        'HorizontalAlignment','left');
      
      
      uicontrol('Parent',self.hdl_panel_action,...
        'Units','normalized',...
        'Position',[.15 .9 .75 .05],...
        'Style','popupmenu',...
        'String', self.markertype_label,...
        'Value',self.markertype_value,...
        'Tag','popupmenu_action_select_line_marker',...
        'BackgroundColor','w',...
        'Callback',{@select_markertype_callback, self});
      
      % select line marker size
      uicontrol('Parent',self.hdl_panel_action,...
        'Style','text',...
        'Units','normalized',...
        'Position',[.15 .86 .75 .05],...
        'String','Marqueur',...
        'HorizontalAlignment','left');
      
      
      uicontrol('Parent',self.hdl_panel_action,...
        'Units','normalized',...
        'Position',[.15 .83 .75 .05],...
        'Style','popupmenu',...
        'String', self.markersize_label,...
        'Value',self.markersize_value,...
        'Tag','popupmenu_action_select_size_marker',...
        'BackgroundColor','w',...
        'Callback',{@select_markersize_callback, self});
      
      % select line style
      uicontrol('Parent',self.hdl_panel_action,...
        'Style','text',...
        'Units','normalized',...
        'Position',[.15 .79 .75 .05],...
        'String','Style',...
        'HorizontalAlignment','left');
      
      uicontrol('Parent',self.hdl_panel_action,...
        'Units','normalized',...
        'Position',[.15 .76 .75 .05],...
        'Style','popupmenu',...
        'String', self.linestyle_label,...
        'Value',self.linestyle_value,...
        'Tag','popupmenu_action_select_line_style',...
        'BackgroundColor','w',...
        'Callback',{@select_line_style_callback, self});
      
    end % of of setUi
    
    % callbacks when popup scale are selected
    % ---------------------------------------
    function callback_plot_select(src, ~, self, key)
      
      value = get(src, 'Value');
      p = regexp(self.roscop.code_roscop.(key).popup_string,'(\d+)\s(\d+)|','tokens');
      if strcmp(key,'DEPH') || strcmp(key,'DEPTH') || ...
          strcmp(key,'PRES') || strcmp(key,'HEIG')
        hdl_axe = findobj('-regexp','Tag', '[AXE]_');
        set(hdl_axe, 'YMinorTick', 'on', ...
          'YLim', [str2double(p{value}{1}) str2double(p{value}{2})]);
      else
        hdl_float = findobj('Tag', strcat('FLOAT_AXE_', key));
        hdl_axe = findobj('Tag', strcat('AXE_', key));
        set(hdl_axe, 'XMinorTick', 'on', 'box', 'on', ...
          'XLim', [str2double(p{value}{1}) str2double(p{value}{2})]);
        set(hdl_float, 'XMinorTick', 'on', 'XLim', [str2double(p{value}{1}) str2double(p{value}{2})]);
        
      end
    end
    
    % select the markertype callback
    % ---------------------------------------
    function select_markertype_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.markertype_value = get(src, 'value');
      self.markertype = self.markertype_label{self.markertype_value};
      %set(self.Primitive, 'Marker', self.markertype);
      hdl_line = findobj('-regexp','Tag', 'MULTIPLOTX');
      set(hdl_line, 'Marker', self.markertype);
      
    end  % end of select_markertype_callback
    
    % select the markersize callback
    % ---------------------------------------
    function select_markersize_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.markersize_value = get(src, 'value');
      %set(self.Primitive, 'MarkerSize', self.markersize_value);
      hdl_line = findobj('-regexp','Tag', 'MULTIPLOTX');
      set(hdl_line, 'MarkerSize', self.markersize_value);
      
    end  % end of select_markersize_callback
    
    % select the markerline callback
    % ---------------------------------------
    function select_line_style_callback(src, ~, self)
      
      % get index value of the popup
      % ----------------------------
      self.linestyle_value = get(src, 'value');
      %set(self.Primitive, 'Marker', self.markertype);
      hdl_axe = findobj('-regexp','Tag', 'MULTIPLOTX');
      set(hdl_axe, 'LineStyle', self.linestyle{self.linestyle_value});
      
    end  % end of select_markertype_callback
    
    
    
  end  % end of private method
  
end % end of main classdef