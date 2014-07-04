%% datagui.oceansites class
%
% file +datagui/@oceansites/oceansites
%
% NetCDF class using OceanSITES convention
%
%  nc = datagui.oceansites (with no argument) invokes Matlab's "uigetfile"
%  dialog for selecting NetCDF file or dynaload file descriptor. 
%
%  nc = datagui.oceansites(template, type, parameters, levels);
%  opens an Excel/CSV or JSON (default) dynaload template filename and 
%  create internal representation of profile, trajectory or time-series 
%  OceanSITES NetCDF file (sse http://www.oceansites.org/docs/).
%  Argument parameters are cell array of string describing the variables,
%  and the vertical levels. 
%
% usage:
%
% nc = datagui.oceansites('global_oceansites.csv', 'profile', ...
%   {'TEMP','PSAL','DOX2','DENS'}, {'PRES','DEPH'});
%
% nc = datagui.oceansites('global_oceansites.json', 'profile', ...
%   {'TEMP','PSAL','DOX2','DENS'}, {'PRES','DEPH'});
%
% All OceanSITES data are publicly available. 
% More information about the project is available at http://www.oceansites.org
%
% $Id: oceansites.m 226 2013-01-29 16:54:48Z jgrelet $

%% TODOS:
% write(o, 'global_oceansites.csv') -> call netcdf.write
% si o.VARIABLES.TIME.data__ n'existe pas retourne msg au lieu de []

%% Classdef definition
% -------------------

classdef oceansites < datagui.netcdf
  
  % properties definitions
  % ----------------------
  properties (Access = public)
    physicalParameters  
    levelParameters  
    type             
  end
  
  properties (Access = private, Hidden)   
  end
  
  % public functions
  % ----------------
  methods
    
    % constructor
    % -----------
    function self = oceansites(varargin)
      
      % initialize local variables
      % ---------------------------
      theFile = []; theType = 'profile';
      theVariables = []; theLevel = {'DEPH'};
      
      % check first arg, should be valid filename
      % -----------------------------------------
      if nargin >= 1
        if( isa(varargin{1}, 'char'))
          theFile = varargin{1};
        else
          error('datagui.oceansites:oceansites:invalid file\n\n');
        end
      end
      
      % check second arg (optional), should be cell array of char
      % ---------------------------------------------------------
      if nargin >= 2
        if ischar(varargin{2})
          theType = varargin{2};
        else
          error(['datagui.oceansites:oceansites:invalid arg, '...
            'should be a string\n\n']);
        end
      end
      % check second arg (optional), should be cell array of char
      % ---------------------------------------------------------
      if nargin >= 3
        if iscell(varargin{3})
          theVariables = varargin{3};
        else
          error(['datagui.oceansites:oceansites:invalid arg, '...
            'should be a cell of parameters\n\n']);
        end
      end
      
      if nargin >= 4
        if iscell(varargin{4})
          theLevel = varargin{4};
        else
          error(['datagui.oceansites:oceansites:invalid arg, '...
            'should be a cell of parameters\n\n']);
        end
      end
      
      % call base-class constructor before accessing object
      % ---------------------------------------------------
      self = self@datagui.netcdf( theFile );
 
      % set property 
      % ------------
      if isempty(theVariables) 
        if strcmp(self.Descriptor, 'dynaload')
    
          %
          % --------------
          [theVariables, theLevel, self] = parameterChoice(self);
          if isempty(theVariables) || isempty(theLevel)
            fprintf('cancel ...\n');
            return 
          end
        else
          theVariables = keys(self, 'VARIABLES');
        end
      end
      self.physicalParameters = theVariables;
      self.levelParameters    = theLevel;
      self.type               = theType;
      
      % transforma dynaload template with physicalParameters entries
      % ----------------------------------------------------------
      if strcmp( self.descriptor, 'dynaload' )
        self = transform(self);
      end  
      
    end % end of oceansites constructor
    
    % display oceansites object
    % -------------------------
    function display(self)
      
      if isempty(self.physicalParameters)
        return
      end
      
      % generate parameters list    
      % display help in hypertext link
      % ------------------------------
      fprintf('<a href="matlab:help datagui.oceansites">datagui.oceansites</a>\n\n');
      fprintf('  type:              %s\n', self.type);
      
      parametersList = ''; j = numel(self.physicalParameters);
      for i = 1: j -1
        parametersList = strcat(parametersList, self.physicalParameters{i}, ',');
      end
      parametersList = strcat('{', parametersList, self.physicalParameters{j}, '}'); 
      fprintf('  physicalParameters:  %s\n', parametersList);
      
      parametersList = ''; j = numel(self.levelParameters);
      for i = 1: j -1
        parametersList = strcat(parametersList, self.levelParameters{i}, ',');
       end    
      parametersList = strcat('{', parametersList, self.levelParameters{j}, '}');
      fprintf('  levelParameters:   %s\n\n', parametersList);
      
      % call superclass display method
      % ------------------------------
      display@datagui.netcdf(self);
      
    end % end of display method
    
    % properties physicalParameters set methods
    % ---------------------------------------
    function self = set.physicalParameters(self, params)
      if iscell(params)
          self.physicalParameters = params;
      else
          error('datagui:oceansites',...
                'invalid arg, should be a cell of parameters\n\n');
      end
    end
    
    % properties levelParameters set methods
    % ---------------------------------------
    function self = set.levelParameters(self, params)
      if iscell(params)
          self.levelParameters = params;
      else
          error('datagui:oceansites',...
                'invalid arg, should be a cell of parameters\n\n');
      end
    end
    
    % properties type set methods
    % ---------------------------------------
    function self = set.type(self, type)
      if ischar(type)
          self.type = upper(type);
      else
          error('datagui:oceansites',...
                'invalid arg, should be profile, trajectory or timeserie\n\n');
      end
    end
    
  end % end of public functions
    
  % private functions
  % -----------------
  methods (Access = 'private')
    
    % prototype of function that was in separate files
    % ------------------------------------------------
    
    % transform dynaload definition with template to oceansites definition
    % --------------------------------------------------------------------
    self = transform(self);
    [theVariables, theLevel, self] = parameterChoice(self, header )
    
  end % end of private methods
  
end