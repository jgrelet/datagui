classdef tmp < handle
  
  % private properties definitions
  % --------------------------------
  % properties (Access = private, Hidden)
  % only for debug
  properties (Access = private)
    
  end
  
  properties (Access = private, SetObservable)
    hdl_figure;
    hdl_axe;
    hdl_toolbar;
    hdl_zoomIn_toggletool;
%    hdl_zoom;
    
  end
  
  methods
    
    % constructor
    % -----------
    function self = tmp(varargin)
      
      % define main interface
      % ---------------------
      self.hdl_figure = figure( ...
        'Name','Map trajectory',...
        'NumberTitle', 'off', ...
        'MenuBar', 'None',...
        'Toolbar', 'None', ...
        'WindowStyle', 'normal', ...
        'numbertitle', 'off',...
        'HandleVisibility','on',...
        'Position',[500 300 700 620],...
        'Tag','plot_map',...
        'MenuBar','figure',...
        'Color', get( 0, 'DefaultUIControlBackgroundColor' ),...
        'CloseRequestFcn', @(obj, event) delete(self));
      
      set(self.hdl_figure,'menubar', 'none');
      
      %  Toolbar pushbuttons
      %  -------------------
      self.hdl_toolbar = uitoolbar(...
        'Parent',self.hdl_figure, ...
        'HandleVisibility','on');
      
      self.hdl_zoomIn_toggletool = uitoggletool(...   % Open Zoom In (increase) toolbar button
        'Parent',self.hdl_toolbar,...
        'Separator', 'on', ...
        'TooltipString','Zoom In (increase)',...
        'CData', datagui.tools.iconRead(fullfile(matlabroot,...
        '/toolbox/matlab/icons/zoomplus.mat')),...
        'HandleVisibility','on', ...
        'Tag','PUSHTOOL_ZOOM_IN',...
        'OnCallback',  {@ZoomIn_OnMenuCallback, self},...
        'OffCallback', {@ZoomIn_OffMenuCallback, self});
      
      % create a new axe
      self.hdl_axe = plot(1:10);
      
    end % end of constructor
    
    % destructor
    % ----------
    function delete(self)
      if ~isempty(self.hdl_figure) && ishandle(self.hdl_figure);
        delete(self.hdl_figure);
        self.hdl_figure = [];
      end
    end
    
    % ZoomIn on toolbar callback
    %---------------------------
    function ZoomIn_OnMenuCallback(src, evnt, self)
      hdl_zoom = zoom(self.hdl_figure);
      set(hdl_zoom, 'direction', 'in');
      set(hdl_zoom, 'enable', 'on');
      set(hdl_zoom, 'ActionPostCallback', ...
        {@datagui.tools.ZoomPan_PostCallback, self.hdl_axe});
      
    end
    
    % ZoomIn off toolbar callback
    %---------------------------
    function ZoomIn_OffMenuCallback(src, evnt, self)
      
      % disable zoom mode
      % -----------------
      zoom off;
      
    end  % end of ZoomIn_OffMenuCallback
    
  
    
  end
  
end

