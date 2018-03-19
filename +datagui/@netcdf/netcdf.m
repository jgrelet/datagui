%DATAGUI.NETCDF object
%
% NetCDF object interface based on Matlab R2008b NetCDF Library Functions
% This toolbox is under development, be careful....
%
%   OBJ = DATAGUI.NETCDF
%     Open a read-only NetCDF object  with no argument invokes Matlab's "uigetfile"
%     dialog box for selecting the file to open.
%
%   OBJ = DATAGUI.NETCDF(FILENAME)
%     Open a read-only NetCDF object from FILENAME.
%
%   OBJ = DATAGUI.NETCDF(FILENAME, MODE)
%     Open a NetCDF object with specified mode.
%
%   MODE can be one of:
%
%         'r'   Open FILENAME in read-only mode. (Default).
%         'a'   Open or create FILENAME for writing; keep existing content.
%         'w'   Open FILENAME for writing; discard existing content.
%
%  datagui.netcdf (with no argument) invokes Matlab's "uigetfile" dialog box
%  for selecting the file to open.
%  datagui.netcdf(name) opens the specified file or variable in the
%  appropriate application.
%
%  Input:
%    1. name is a NetCDF file,
%    2. name is an Excel or CSV dynaload file
%    3. name is a cell array: {'Dimensions','Variables','Attributes'}
%
% usage:
%
% >> nc = datagui.netcdf('foo.nc')
%
% 	Descriptor:   'netcdf'
% 	Mode:         'NC_WRITE'
% 	AutoNan:       true
% 	AutoScale:     false
% 	AutoForm:      false
% 	Filename:         'foo.nc'
%
% 	Dimensions    	 3  [struct]
% 	Variables     	48  [struct]
% 	Attributes    	21  [struct]
%
% >> nc.Dimensions
% 
%      TIME: [1x1 struct]
%     DEPTH: [1x1 struct]
% 
% nc.Dimensions is a structure, syntax as :
%   keys(nc.Dimensions) is not valid, use instead:
%
% >> keys(nc, 'Dimensions')'
%
%     'TIME'
%     'DEPTH'
%
% >> keys(nc, 'Variables')'
% 
%     'PROFILE'
%     'TIME'
%     'LATITUDE'
%     'LONGITUDE'
%     'PRES'
%     'DEPTH'
%     'TEMP'
%     'PSAL'
%     'DENS'
%     'SVEL'
%     'DOX2'
%
% >> nc.Attributes
%
% >> keys(nc, 'Attributes')'
%
%                data_type: [1x1 struct]
%             cycle_mesure: [1x1 struct]
%             project_name: [1x1 struct]
%          plateforme_name: [1x1 struct]
%      time_coverage_start: [1x1 struct]
%        time_coverage_end: [1x1 struct]
%                 timezone: [1x1 struct]
% ...
%
% >> nc.Attributes.cycle_mesure
%
%     data__: 'PIRATA-FR25'
%
% access to variable :
%
%  >> nc.Variables.TEMP
%
%     standard_name: 'TEMP'
%         long_name: 'sea temperature'
%             units: 'Celsius degree'
%         valid_min: 0
%         valid_max: 30
%        FillValue_: 1.0000e+36
%            type__: 'float'
%            data__: [4x2023 single]
%       dimension__: {'TIME'  'DEPTH'}
%
% >> nc.Variables.TEMP.long_name
%
% ans = 'sea temperature'
%
% Create NetCDF file with template:
%
% >> nc = datagui.netcdf('tsgqc_netcdf.csv')
%
% 	Descriptor:   'dynaload'
% 	Mode:         'NC_CLOBBER'
% 	AutoNan:       true
% 	AutoScale:     false
% 	AutoForm:      false
% 	Filename:         ''
%
% 	Dimensions    	 9  [struct]
% 	Variables     	66  [struct]
% 	Attributes    	32  [struct]
% 	Quality       	10  [struct]
%
% Read data from file and set following example:
%
% >> nc.Attributes.cycle_mesure.data__  = 'TOUC0702';
% >> nc.Attributes.plateforme_name.data__ = 'TOUCAN';
% >> nc.Variables.TIME.data__ = [2.101736111111113];
%
% add a new Dimensions :
%
% >> nc.Dimensions.N2 = struct('key__', 'N2', 'value', 2, ...
%                                 'unlimited', 0)
%
% 	Descriptor:   'dynaload'
% 	Mode:         'NC_CLOBBER'
% 	AutoNan:       true
% 	AutoScale:     false
% 	AutoForm:      false
% 	Filename:         ''
%
% 	Dimensions    	10  [struct]
% 	Variables     	66  [struct]
% 	Attributes    	32  [struct]
% 	Quality       	10  [struct]
%
% nc.Dimensions.N2
%
% ans =
%      code: 'N2'
%     value: 2
%
% write to NetCDF file :
%
% >> nc.write('toto.nc', 'NC_CLOBBER')
%
% WRITE_NETCDF_FILE
% ...writing toto.nc : ...done (  0.84 sec).
%
% If a NetCDF variable has _FillValue attributes,
% then the data with _FillValue are set to NaN.
% AutoNan is set to true by default
%
% >> nc.AutoNan = 0;  % disable AutoNan mode
%
% If a NetCDF variable has valid scale_factor and add_offset
% attributes, then the data is scaled accordingly.
% AutoScale is set to false by default
%
% >> nc.AutoScale = 1; % enable AutoScale mode
%
% $Id: netcdf.m 265 2014-02-12 04:25:29Z jgrelet $

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

%% Classdef definition
% -------------------

classdef netcdf < datagui.dynaload
  
  % public properties definitions
  % -----------------------------
  properties (Access = public, Hidden)
    
    AutoNan            = true;          % fill _Fillvalue attribute with N/A
    AutoScale          = false;         % compute real value from slope and offset
    AutoForm           = false;         % display attribute form
    Mode               = 'NC_NOWRITE';  % netcdf acces mode
  end
  
  % protected properties definitions
  % --------------------------------
  properties (Access = public, Hidden)
    
    descriptor         = '';            % file descriptor, sould be :
    % netcdf, dynaload or memory
  end
  
  % private properties definitions
  % --------------------------------
  properties (Access = private, Hidden)
    
    nc_id              = -1;
  end
  
  % constant properties definitions
  % --------------------------------
  properties (Constant = true, Hidden)
    
    % constants for netcdf data types
    % -------------------------------
    NC_BYTE             = netcdf.getConstant('NC_BYTE');    % 1
    NC_CHAR             = netcdf.getConstant('NC_CHAR');    % 2
    NC_SHORT            = netcdf.getConstant('NC_SHORT');   % 3
    NC_INT              = netcdf.getConstant('NC_INT');     % 4
    NC_LONG             = netcdf.getConstant('NC_LONG');    % 4
    NC_FLOAT            = netcdf.getConstant('NC_FLOAT');   % 5
    NC_DOUBLE           = netcdf.getConstant('NC_DOUBLE');  % 6
    
    NC_MEMORY           = -1;
    
    % constants for netcdf.open()
    % ---------------------------
    % read-only access
    NC_NOWRITE          = netcdf.getConstant('NC_NOWRITE');   % 0
    
    % NC_WRITE:      	Read-write access
    NC_WRITE            = netcdf.getConstant('NC_WRITE');     % 1
    
    % allow synchronous file updates.
    NC_SHARE            = netcdf.getConstant('NC_SHARE');     % 2048
    
    % constants for netcdf.create()
    % -----------------------------
    % overwrite any existing file with the same name.
    NC_CLOBBER          = netcdf.getConstant('NC_CLOBBER');   % 0
    
    % prevent overwriting of existing file with the same name.
    NC_NOCLOBBER        = netcdf.getConstant('NC_NOCLOBBER'); % 4
    
    % allow easier creation of files and variables which
    % are larger than two gigabytes.
    NC_64BIT_OFFSET     = netcdf.getConstant('NC_64BIT_OFFSET');  % 512
    
    % general constant
    % ----------------
    NC2_ERR             = netcdf.getConstant('NC2_ERR');      % -1
    NC_EBADDIM          = netcdf.getConstant('NC_EBADDIM');   % -46
    NC_EBADID           = netcdf.getConstant('NC_EBADID');    % -33
    NC_EBADNAME         = netcdf.getConstant('NC_EBADNAME');  % -59
    NC_EBADTYPE         = netcdf.getConstant('NC_EBADTYPE');  % -45
    NC_ECHAR            = netcdf.getConstant('NC_ECHAR');
    NC_EDIMSIZE         = netcdf.getConstant('NC_EDIMSIZE');
    NC_EEDGE            = netcdf.getConstant('NC_EEDGE');
    NC_EEXIST           = netcdf.getConstant('NC_EEXIST');
    NC_EGLOBAL          = netcdf.getConstant('NC_EGLOBAL');
    NC_EINDEFINE        = netcdf.getConstant('NC_EINDEFINE');
    NC_EINVAL           = netcdf.getConstant('NC_EINVAL');
    NC_EINVALCOORDS     = netcdf.getConstant('NC_EINVALCOORDS');
    NC_EMAXATTS         = netcdf.getConstant('NC_EMAXATTS');
    NC_EMAXDIMS         = netcdf.getConstant('NC_EMAXDIMS');
    NC_EMAXNAME         = netcdf.getConstant('NC_EMAXNAME');
    NC_EMAXVARS         = netcdf.getConstant('NC_EMAXVARS');
    NC_ENAMEINUSE       = netcdf.getConstant('NC_ENAMEINUSE');
    NC_ENFILE           = netcdf.getConstant('NC_ENFILE');
    NC_ENOMEM           = netcdf.getConstant('NC_ENOMEM');
    NC_ENORECVARS       = netcdf.getConstant('NC_ENORECVARS');
    NC_ENOTATT          = netcdf.getConstant('NC_ENOTATT');
    NC_ENOTINDEFINE     = netcdf.getConstant('NC_ENOTINDEFINE');
    NC_ENOTNC           = netcdf.getConstant('NC_ENOTNC');
    NC_ENOTVAR          = netcdf.getConstant('NC_ENOTVAR');
    NC_EPERM            = netcdf.getConstant('NC_EPERM');
    NC_ERANGE           = netcdf.getConstant('NC_ERANGE');
    NC_ESTRIDE          = netcdf.getConstant('NC_ESTRIDE');
    NC_ESTS             = netcdf.getConstant('NC_ESTS');
    NC_ETRUNC           = netcdf.getConstant('NC_ETRUNC');
    NC_EUNLIMIT         = netcdf.getConstant('NC_EUNLIMIT');
    NC_EUNLIMPOS        = netcdf.getConstant('NC_EUNLIMPOS');
    NC_EVARSIZE         = netcdf.getConstant('NC_EVARSIZE');
    NC_FATAL            = netcdf.getConstant('NC_FATAL');       % 1
    NC_FILL             = netcdf.getConstant('NC_FILL');        % 0
    NC_FILL_BYTE        = netcdf.getConstant('NC_FILL_BYTE');   % -127
    NC_FILL_CHAR        = netcdf.getConstant('NC_FILL_CHAR');   % 0
    NC_FILL_DOUBLE      = netcdf.getConstant('NC_FILL_DOUBLE'); % 9.9692e+036
    NC_FILL_FLOAT       = netcdf.getConstant('NC_FILL_FLOAT');  % 9.9692e+036
    NC_FILL_INT         = netcdf.getConstant('NC_FILL_INT');    % -2.1475e+009
    NC_FILL_SHORT       = netcdf.getConstant('NC_FILL_SHORT');  % -32767
    NC_FORMAT_64BIT     = netcdf.getConstant('NC_FORMAT_64BIT');   % 2
    NC_FORMAT_CLASSIC   = netcdf.getConstant('NC_FORMAT_CLASSIC'); % 1
    NC_GLOBAL           = netcdf.getConstant('NC_GLOBAL');       % -1
    NC_LOCK             = netcdf.getConstant('NC_LOCK');         % 1024
    NC_MAX_ATTRS        = netcdf.getConstant('NC_MAX_ATTRS');    % 8192
    NC_MAX_DIMS         = netcdf.getConstant('NC_MAX_DIMS');     % 1024
    NC_MAX_NAME         = netcdf.getConstant('NC_MAX_NAME');     % 256
    NC_MAX_VARS         = netcdf.getConstant('NC_MAX_VARS');     % 8192
    NC_MAX_VAR_DIMS     = netcdf.getConstant('NC_MAX_VAR_DIMS'); % 1024
    NC_NAT              = netcdf.getConstant('NC_NAT');          % 0
    NC_NOERR            = netcdf.getConstant('NC_NOERR');        % 0
    NC_NOFILL           = netcdf.getConstant('NC_NOFILL');       % 256
    NC_SIZEHINT_DEFAULT = netcdf.getConstant('NC_SIZEHINT_DEFAULT');  % 0
    NC_UNLIMITED        = netcdf.getConstant('NC_UNLIMITED');    % 0
    NC_VERBOSE          = netcdf.getConstant('NC_VERBOSE');      % 2
    
  end
  
  % public functions
  % ----------------
  methods
    
    % constructor
    % -----------
    function self = netcdf(varargin)
      
      % initialisation
      theFilename = ''; theDescriptor = ''; theDynaload = '';
      theAutoNan = true; theAutoScale = false; theAutoForm = false;
      theEcho = true;
      
      % with not arg, read netcdf file with uigetfile
      % ---------------------------------------------
      if (nargin == 0)
        [fileName, pathName] = uigetfile(...
          {'*.nc;*.cdf','NetCDF (*.nc,*.cdf)';
          '*.xls;*.xlsx;*.json;*.csv','Dynaload (*.xls,*.xlsx,*.json,*.csv)'}, ...
          'Select file');
        if any(fileName)
          theFilename = fullfile(pathName, fileName);
          [pathName, fileName, fileExt] = fileparts(theFilename); %#ok<ASGLU>
          theDynaload = {'Dimensions','Variables','Attributes'};
          switch fileExt
            case {'.nc', 'cdf'}
              theDescriptor = 'netcdf';
              theMode = 'NC_NOWRITE';
            case { '.xls', '.xlsx', '.json', '.csv' }
              theDynaload = theFilename;
              theFilename = '';
              theDescriptor = 'dynaload';
              theMode = 'NC_WRITE';
            otherwise
              error('Wrong file type');
          end
        else
          theDynaload   = {'Dimensions','Variables','Attributes'};
          theFilename   = 'memory';
          theDescriptor = 'memory';
          theMode = 'NC_NOWRITE';
        end
      end
      
      % with one arg, read given netcdf filename
      % ----------------------------------------
      if (nargin >= 1)
        if( strcmp(varargin{1}, 'memory'))
          theDescriptor = 'memory';
          theMode       = 'NC_CLOBBER';
          theFilename   = 'memory';
          theDynaload   = {'Dimensions','Variables','Attributes'};
          
        elseif( isa(varargin{1}, 'char'))
          theFilename = varargin{1};
          if ~exist(theFilename, 'file')
            error('datagui:netcdf', '%s file don''t exist', theFilename);
          end
          [pathName, fileName, fileExt] = fileparts(theFilename); %#ok<ASGLU>
          
          switch fileExt
            case {'.nc', 'cdf'}
              theDescriptor = 'netcdf';
              theMode       = 'NC_NOWRITE';
              theDynaload   = {'Dimensions','Variables','Attributes'};
            case {'.csv', '.xls', '.xlsx', '.json'}
              theDynaload   = theFilename;
              theFilename       = '';
              theDescriptor = 'dynaload';
              theMode       = 'NC_CLOBBER';
            otherwise
              error('datagui:netcdf', 'Wrong file type: %s', fileExt);
          end
          
        else
          error('datagui:netcdf', 'Wrong input file argument %s', varargin{1});
        end
      end
      
      % work with given filename and mode
      % todos:  'NC_WRITE', 'NC_CLOBBER', 'NC_NOCLOBBER', 'NC_SHARE'
      % ---------------------------------
      if (nargin >= 2)
        if length(varargin{2}) == 1
          next = 3;
          switch(varargin{2})
            case 'r'
              theMode = 'NC_NOWRITE';
            case 'a'
              theMode = 'NC_SHARE';
            case 'w'
              theMode = 'NC_WRITE';
            otherwise
              error('datagui:netcdf', 'bad Mode %s', varargin{2});
          end
        else
          next = 2;
        end
      end
      
      % check for additional properties
      % -------------------------------
      if (nargin >= 3 )
        property_argin = varargin(next:end);
        while length(property_argin) >= 2
          property = property_argin{1};
          value    = property_argin{2};
          property_argin = property_argin(3:end);
          switch lower(property)
            case 'echo'
              theEcho = value;
            case 'mode'
              switch(value)
                case {'r', 'NC_NOWRITE', 'NOWRITE'}
                  theMode = 'NC_NOWRITE';
                case {'a', 'NC_SHARE', 'SHARE' }
                  theMode = 'NC_SHARE';
                case {'w', 'NC_WRITE', 'WRITE'}
                  theMode = 'NC_WRITE';
                otherwise
                  error('datagui:netcdf', 'bad Mode %s', value);
              end
            case 'autonan'
              theAutoNan = value;
            case 'autoscale'
              theAutoScale = value;
            case 'autoform'
              theAutoForm = value;
            otherwise
              error('datagui:netcdf', 'Unknown property: %s', property);
          end
        end
      end
  
      % this sould but change in future
      % -------------------------------
%       if (nargin >=3 )
%           error('Wrong number of input arguments');
%       end
      
      % Object Initialization
      % Call base-class constructor before accessing object
      % ---------------------------------------------------
      self@datagui.dynaload( theDynaload );
      
      % properties initialization
      % -------------------------
      self.Filename   = theFilename;
      self.descriptor = theDescriptor;
      self.Echo       = theEcho;
      self.Mode       = theMode;
      self.AutoNan    = theAutoNan;
      self.AutoScale  = theAutoScale;
      self.AutoForm   = theAutoForm;
      
      % call private function following mode state
      % a revoir !!!!!!!!!!!!!!!
      % ------------------------------------------
      switch self.descriptor
        case 'netcdf'     %
          read(self);
          %self.Mode = 'NC_WRITE';
        case 'memory'
          self.Mode = 'NC_WRITE';
        case 'dynaload'
          self.Mode = 'NC_WRITE';
        otherwise
          error('datagui:netcdf', 'Wrong descriptor: %s', self.descriptor);
      end
      
    end % end of constructor
    
    % destructor
    % -----------------------
    function delete(self)
      % This is the object destructor.
      self.close();
    end
    %------------------------------------------------------------------
    function close(self)
      if(self.nc_id ~= -1)
        netcdf.close(self.nc_id);
        % Prevent the close call from the destructor from
        % attempting to call netcdf.close again in case close is
        % called manually.
        self.nc_id = -1;
      end
    end
    
    % display netcdf object
    % -----------------------
    function disp(self)
      
      % diplay help in hypertext link
      % ------------------------------
      %fprintf('<a href="matlab:help datagui.netcdf">datagui.netcdf</a>\n');
      
      % use local variables for displaying boolean
      % ------------------------------------------
      if self.AutoNan,   theAutonan   = 'true'; else, theAutonan   = 'false'; end
      if self.AutoScale, theAutoscale = 'true'; else, theAutoscale = 'false'; end
      if self.AutoForm,  theAutoform  = 'true'; else, theAutoform  = 'false'; end
      
      
      % display properties
      % ------------------
      fprintf('\n');
      fprintf('  Descriptor:     ''%s''\n', self.descriptor);
      fprintf('        Mode:     ''%s''\n', self.Mode);
      fprintf('     AutoNan:      %s\n', theAutonan);
      fprintf('   AutoScale:      %s\n', theAutoscale);
      fprintf('    AutoForm:      %s\n', theAutoform);
      fprintf('\n');
      
      % call base class display
      % -----------------------
      disp@datagui.dynaload(self);
      
      % diplay methods list in hypertext link
      % -------------------------------------
      disp('list of <a href="matlab:methods(''datagui.netcdf'')">methods</a>');
      
    end
    
    % properties set/get methods
    % --------------------------
    function set.Mode(self, theValue)
      self.Mode = theValue;
    end
    
    function theMode = get.Mode(self)
      theMode = self.Mode;
    end
    
    function theDescriptor = get.descriptor(self)
      theDescriptor = self.descriptor;
    end
    
    function theAutoNan = get.AutoNan(self)
      theAutoNan = self.AutoNan;
    end
    
    function set.AutoNan(self, theValue)
      if (~islogical(theValue))
        error('datagui:netcdf:autoNan', 'datagui.netcdf:set.autoNan: value must be a boolean')
      end
      self.AutoNan = logical(theValue);
    end
    
    function theAutoScale = get.AutoScale(self)
      theAutoScale = self.AutoScale;
    end
    
    function set.AutoScale(self, theValue)
      if (~islogical(theValue))
        error('datagui:netcdf:autoScale', 'datagui.netcdf:set.autoScale: value must be a boolean')
      end
      self.AutoScale = logical(theValue);
    end
    
    function theAutoForm = get.AutoForm(self)
      theAutoForm = self.AutoForm;
    end
    
    function set.AutoForm(self, theValue)
      if (~islogical(theValue))
        error('datagui:netcdf:autoForm', 'datagui.netcdf:set.autoForm: value must be a boolean')
      end
      self.AutoForm = logical(theValue);
    end
    
    % prototype of public functions in separate files
    % -----------------------------------------------
    theResult = load(self, varargin);
    write(self, varargin);
    form(self);
    plot_map(self);
%     theResult = subsref(self, theStruct);
%     self = subsasgn(self, theStruct, theValue);
    
  end % end of public methods
  
  % static methods
  % --------------
  methods (Static)
    
    % get netcdf constant name from data type
    % ----------------------------------------------------
    function name = getConstantNames(xtype)
      switch xtype
        case  1   % NC_BYTE 1
          name = 'byte';
        case  2   % NC_CHAR 2
          name = 'char';
        case  3   % NC_SHORT 3
          name = 'short';
        case  4   % NC_INT, NC_LONG 4
          name = 'int';
        case  5   %NC_FLOAT 5
          name = 'float';
        case  6   % NC_DOUBLE 6
          name = 'double';
        otherwise
          error('datagui:netcdf', 'unhandled data type %d\n', xtype );
      end
    end
    
  end % end of static methods
  
  % private functions
  % -----------------
  methods %(Access = private)
    
    % prototype of function that was in separate files
    % ------------------------------------------------
    read(self);
    
  end % end of private methods
  
end % end of class netcdf
