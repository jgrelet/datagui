classdef graph < handle
  % Abstract class for creating data graphs
  % Subclass constructor should accept
  % a netcdf file
  properties (SetAccess = protected, GetAccess = protected)
    % handle for data on map (line)
    Primitive
    % handle of main axe
    hdl_axe
  end
  properties (SetAccess = protected, GetAccess = protected)
    nc                          % netcd instance of datagui.netcdf
  end
  properties(SetAccess = protected, GetAccess = protected)
    list_assign_vars = {};      % list of attributes and variables
    convention;                 % ARGO ou OceanSITES
    data_type;                  % PROFILE or OceanSITES profile data
    lat_name;                   % LATX for ARGO, LATITUDE for OceanSITES
    lon_name;                   % LONX or LONGITUDE
    day_name;                   % DAYD or TIME
    depth_name;                 % DEPH or DEPTH
    year_ref;
  end
  
  methods (Abstract)
    
    % draw the main interface and plot track
    % --------------------------------------
    draw(self)
    
    % zoom track and coastline
    % ----------------------------
    zoom(self,factor)
    
    % Update the Data property and
    % update the drawing primitive
    % ----------------------------
    updateGraph(self)
    
  end
  
  methods
    function set.nc(self, new_nc)
      
      % test if there is attributes and variables in base workspace
      % -----------------------------------------------------------
      if ~isempty( self.list_assign_vars )
        
        % for each attributes an variables names stored in list_assign_vars
        % call evalin in base workspace to clear the variable
        % ----------------------------------------------------------------
        for i = 1 : length(self.list_assign_vars)
         %evalin('base', ['clear(' '''self.list_assign_vars{i}''' ')']);
          evalin('base', ['clear ' '''self.list_assign_vars{i}''']);
        end
        
        % initialize the list befor read the next Netcdf file
        % ---------------------------------------------------
        self.list_assign_vars = {};
      end
      
      self.nc = new_nc;
      
      % test the type of NetCDF file: OceanSITES or ARGO
      % ------------------------------------------------
      if isfield(self.nc.Attributes,'TYPE')
        switch self.nc.Attributes.TYPE.data__
          case {'PROFILE','PROFIL'}
            self.data_type = 'profile';
          case 'TRAJECTOIRE'
            self.data_type = 'trajectory';
          case 'SERIE'
            self.data_type = 'time-series';
        end
        self.convention = 'ARGO';
        self.lat_name = 'LATX';
        self.lon_name = 'LONX';
        self.day_name = 'DAYD';
        self.depth_name = 'DEPH';
        
      elseif isfield(self.nc.Attributes,'data_type')
        [tok, ~] = regexp(self.nc.Attributes.data_type.data__,...
          'OceanSITES\s+(\w*)','tokens');
        if isempty( tok )
          error('datagui:main',...
            'wrong NetCDF file for attribute ''data_type'': %s',...
            self.nc.Attributes.data_type.data__);
        end
        
        self.data_type = char(tok{1});
        self.convention = 'OceanSITES';
        self.lat_name = 'LATITUDE';
        self.lon_name = 'LONGITUDE';
        self.day_name = 'TIME';
        self.depth_name = 'DEPTH';
      else
        error('datagui:graph', 'wrong NetCDF file');
      end
      
      % define year reference
      % ---------------------
      switch self.convention
        case 'ARGO'
          year = self.nc.Variables.REFERENCE_DATE_TIME.data__;
          self.year_ref = str2double({year(1:4)});
        case 'OceanSITES'
          self.year_ref = 1950;
      end
      
      % update plot
      % ------------
      updateGraph(self)
      
      % assign global attributes and variables in workspace
      % ---------------------------------------------------
      for name = {'Attributes', 'Variables'}
        k = keys(self.nc, char(name));
        v = values(self.nc, char(name));
        for i = 1 : length(k)
          assignin('base', k{i}, v{i}.data__);
          self.list_assign_vars{end+1} = k{i};
        end
      end
    end
  end
  
end % end of abstract class graph