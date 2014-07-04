%%datagui.dynaload read or create dynaload object
%
% file +datagui/@dynaload/dynaload
%
% This class is used to load complex object descriptor from Excel (.xls),
% ASCII (.csv) files or JSON (Javascript Object Notation) format (.json)
% Usually Excel file is used during development under Windows, and csv/json
% files are created and used on production.
% dynaload inherit from dynamicprops and is handle class
%
% >> d = datagui.dynaload('tsgqc_netcdf.json')
%   datagui.dynaload
%   Package: datagui
%
%         Filename:     'C:\svn\datagui\trunk\+datagui\examples\tsgqc_netcdf.json'
%   MagicField:     'data__'
%   AutoAccess:     'false'
%         Echo:     'true'
%
% 	Dimensions    	 9  [struct]
% 	Variables     	66  [struct]
% 	Attributes    	32  [struct]
% 	Quality       	10  [struct]
%
% >> d.Variables
%
%     'CNDC'                   [1x1 struct]
%     'CNDC_CAL'               [1x1 struct]
%     'CNDC_CALCOEF'           [1x1 struct]
%     'CNDC_CALCOEF_CONV'      [1x1 struct]
%      ...
%     'SSTP'                   [1x1 struct]
%     'SSTP_CAL'               [1x1 struct]
%     'SSTP_QC'                [1x1 struct]
%
% >> keys(d, 'Variables')
%
%     ''CNDC''    ''CNDC_CAL''    ''CNDC_CALCOEF''    ''CNDC_CALCOEF_CONV''
%      ...
%     ''SSTP''    ' 'SSTP_CAL''   ''SSTP_QC''
%
% % get value :
% >> d.Variables.SSTP
%
%            key__: 'SSTP'
%       dimension__: {'DAYD'}
%            type__: 'float'
%         long_name: 'SEA SURFACE TEMPERATURE'
%     standard_name: 'sea_surface_temperature'
%             units: 'degree_Celsius'
%       conventions: ''
%         valid_min: -1.5000
%         valid_max: 38
%            format: '%6.3lf'
%        FillValue_: 99999
%         epic_code: []
%              axis: ''
%        resolution: 1.0000e-003
%           comment: [1x99 char]
%     default_value: []
%        coordinate: 'DAYD'
%            data__: []
%
%
% % get field value:
% >> value = d.Variables.SSTP.long_name
% value =
% SEA SURFACE TEMPERATURE
%
% % change value :
% >> d.Variables.SSTP.long_name = 'new SEA SURFACE TEMPERATURE name'
%
% % use of AutoAccess mode :
% >> d.AutoAccess = 1;
% d.Variables.SSTP = 25.257;
% d.Variables.SSTP
% ans =
%    25.2570
%
% % convert Excel file to JSON format (default) :
% >> save(d);
% % or
% >> d.write('tsgqc_netcdf.json');
%
% % convert Excel file to csv :
% >> save(d, 'tsgqc_netcdf.csv');
% % or
% >> d.write('tsgqc_netcdf.csv');
%
% % csv file format :
% >> type +datagui/demos/netcdf/tsgqc_netcdf.csv
%
% $Id: dynaload.m 252 2013-08-16 14:58:37Z jgrelet $

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
%    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

%% Classdef definition
% -------------------
classdef dynaload < dynamicprops

   % public  properties definitions
  % ----------------------------------
  properties (Access = public, Hidden)   
    
    % enable/disable automatic access to MagicField
    AutoAccess = false;
    
    % Print or not the results of read and write methods
    Echo = true;
    
  end
  
  % public read properties definitions
  % ----------------------------------
  properties (SetAccess = protected, Hidden)
    
    % private property, inherited class must be redefine this property
    Filename           = '';
    
    % the MagicField, used  to set direct access from/to special
    % field when value is a structure
    MagicField = 'data__';            %  by default
    
  end
  
  % protected properties definitions
  % --------------------------------
  properties (Access = protected, Hidden)
    
    % store dynamic property names (cell array) given by
    % meta.DynamicProperty instance, used by display method
    meta;
    
  end
  
  % private properties definitions
  % --------------------------------
  properties (Access = private, Hidden)
    
    % internal properties used for descriptor file informations
    line               = 0;
    fid                = 0;
    
  end
  
  % public functions
  % ----------------
  methods
    
    % constructor
    % -----------
    function self = dynaload(varargin)
      
      % init default value
      % ------------------
      filterIndex = 0; theArg = []; theFilename = 'memory';
      
      % test constructor argument
      % ------------------------
      switch nargin
        
        % default constructor, try to open dynaload file descriptor
        % ---------------------------------------------------------
        case 0
          [filename, pathname, filterIndex] = uigetfile(...
            {'*.json', 'JSON-file (*.json)';...
            '*.csv;*.txt','Ascii-file (*.csv,*.txt)';...
            '*.xls;*.xlsx','Excel-file (*.xls,*.xlsx)'}, 'Select file');
          if ~any(filename)
            self.Filename = 'memory';
            return
          else
            theFilename = fullfile(pathname, filename);
          end
          
          % one arg, if it is a dynaload filename, open it, otherwise,
          % create new dynamic propertiy
          % ----------------------------------------------------------
        otherwise
          
          if (isa(varargin{1}, 'char'))
            
            % if file exist and is in the search path, return 2
            % --------------------------------------------------
            if exist(varargin{1}, 'file') == 2
              % theFilename = fullfile(pwd, varargin{1});
              theFilename = varargin{1};
            else
              
              if strcmp(varargin{1}, 'memory')
                 theFilename = varargin{1};
              else
                
              % if file is in matlab path directories
              % -------------------------------------
                theFilename = which(varargin{1});
              end
              
              % if not, bad name, return an error
              % ---------------------------------
              
              if isempty( theFilename)
                error('datagui:dynaload', ...
                  'Wrong or bad file: %s', varargin{1});
              end
            end
            
            % return the pieces of a theFilename specification
            % -------------------------------------------------
            [pathname, filename, fileExt] = fileparts(theFilename); %#ok<ASGLU>
            
            % switch from file extension to numeric val like uigetfile
            % ---------------------------------------------------------
            switch fileExt
              case '.json'
                filterIndex = 1;
              case {'.csv','.txt'}
                filterIndex = 2;
              case {'.xls', '.xlsx'}
                filterIndex = 3;
              otherwise
                error('datagui:dynaload', 'Wrong file type: %s', fileExt);
            end
            
            % if argument is a cell, initialise theArg for dynamic prop
            % ---------------------------------------------------------
          elseif (isa(varargin{1}, 'cell'))
            theArg = varargin{1};

            % bad or unknow constructor argument
            % ----------------------------------
          else
            error('datagui:dynaload', 'Wrong input argument');
          end
          
          % check for additional properties
          % -------------------------------
          property_argin = varargin(2:end);
          while length(property_argin) >= 2,
            property = property_argin{1};
            value    = property_argin{2};
            property_argin = property_argin(3:end);
            switch lower(property)
              case 'echo'
                self.Echo = value;
              case 'magicfield'
                self.MagicField = value;
              case 'autoaccess'
                self.AutoAccess = value;
              otherwise
                error('datagui:dynaload', 'Unknown property: "%s"', property);
            end
          end
      end
      
      % execute the rigth statement following file extention
      % ---------------------------------------------------
      self.Filename = theFilename;
      
      % create dynamics properties and initialize to empty structure
      % only when theArg is defined
      % -----------------------------------------------------------------
      for i = 1: length(theArg)
        
        % create new dynamic property
        % ----------------------------
        prop = theArg{i};
        metaDP = self.addprop(prop);
        
        % fill property meta with new created dynamic property name
        % ---------------------------------------------------------
        if isempty(self.meta)
          self.meta{1} = metaDP.Name;
        else
          self.meta{end+1} = metaDP.Name;
        end
        
        % assign structure to dynamic property
        % ------------------------------------
        self.(prop) = struct;
      end
      
      % call read_xxx_file functions
      % ----------------------------
      switch filterIndex
        case 0
          % memory, do nothing
        case 1
          read_json_file(self);
        case 2
          read_csv_file(self);
        case 3
          read_xls_file(self);
        otherwise
          error('datagui:dynaload', 'Wrong file type');
      end
      
    end % end of constructor
    
    % property file is private, we can't use get.file interface
    % ---------------------------------------------------------
    function theFilename = get.Filename(self)
      theFilename = self.Filename;
    end
    
    % assessors
    % ---------
    function theMagicField = get.MagicField(self)
      theMagicField = self.MagicField;
    end
    
    function set.MagicField(self, MagicField)
      if ischar(MagicField)
        self.MagicField = MagicField;
      else
        error('datagui:dynaload:set:MagicField', ...
          'MagicField should be a string');
      end
    end
    
    function theAutoAccess = get.AutoAccess(self)
      theAutoAccess = self.AutoAccess;
    end
    
    function set.AutoAccess(self, theAutoAccess)
      self.AutoAccess = theAutoAccess;
    end
    
    function theEcho = get.Echo(self)
      theEcho = logical(self.Echo);
    end
    
    function set.Echo(self, theEcho)
      if isnumeric(theEcho)
        if theEcho == 1 || theEcho == 0
          theEcho = logical(theEcho);
        end
      end
      if islogical(theEcho)
        self.Echo = theEcho;
      else
        if isnumeric(theEcho)
          msg = num2str(theEcho);
        else
          if iscell(theEcho)
            msg = '';
          else
            msg = char(theEcho);
          end
        end
        error('datagui:dynaload:set:Echo', ...
          'arg %s is %s, not logical', msg, class(theEcho));
      end
    end
    
    % access to dynamic properties names isn't possible
    % with meteclass info, we need to store their properties names
    % in meta property for later access
    % -------------------------------------------------------------
    function dp = getDynamicProperty(self)
      dp = self.meta;
    end
    
    % add new key/value in dynamic property with hashtable syntax
    % -----------------------------------------------------------
    function put(self, dp, theKey, theValue)
      
      % test if dp is a dynamic property
      % ---------------------------------
      % add test here
      
      if ~exist('theKey', 'var')  
        error('datagui:dynaload:put', 'theKey: MATLAB:undefinedVariable');
      end
      if ~exist('theValue', 'var')
        error('datagui:dynaload:put', 'theValue: MATLAB:undefinedVariable');
      end
      
      % add new member(s)/value(s) pair(s)
      % ex: self.Variables.TEMP = value
      % Field names, like variable names, must begin with a letter, can
      % contain letters, digits, or underscore characters, 
      % and are case sensitive. 
      % ----------------------------------------------------------------
      if ischar(theKey)
        % add a regexp for testing a valid theValue and got error
        %  MATLAB:AddField:InvalidFieldName
        self.(dp).(theKey) = theValue;
      elseif iscell(theKey)
        for i = 1 : length(theKey)
          % add a regexp for testing a valid theValue and got error
          %  MATLAB:AddField:InvalidFieldName
          self.(dp).(theKey{i}) = theValue{i};
        end
      else
        error('datagui:dynaload:put', ...
          'arg key: %s, (class %) must be char or cell', theKey, class(theKey));
      end
    end
    
    % get fieldnames from a structure with hashtable syntax
    % if d is dynaload object :
    %   keys(d)
    %   keys(d,'Variables')
    % ---------------------------------------------
    function theKeys = keys(self, varargin)
      if isempty(varargin)
        theKeys = self.meta;
      else
        theKeys = fieldnames(self.(varargin{1}));
        theKeys = theKeys';  % transpose to return cell array,
        % needed to iterate with for loop
      end
    end
    
    % get values from a structure with hashtable syntax, return cell array
    % --------------------------------------------------------------------
    function theValues = values(self, varargin)
      if isempty(varargin)
        theValues = cell(1, length(self.meta));
        for i = 1: length(self.meta)
          theValues{i} = self.(self.meta{i});
        end
      else
        theFields = fieldnames(self.(varargin{1}))';
        theValues = cell(1, length(theFields));
        for i = 1: length(theFields)
          theValues{i} = self.(varargin{1}).(theFields{i});
        end
      end
    end
    
    % display dynaload object
    % -----------------------
    function disp(self)
      
      % diplay metaclass informations  in hypertext link
      % -------------------------------------------------
      mc = metaclass(self);
      fprintf('  <a href="matlab: help %s">%s</a>\n', mc.Name, mc.Name);
      
      % Print the package name
      % ----------------------
      if ~isempty(mc.ContainingPackage)
        %strPackage = getString(message('MATLAB:datagui:dynaload:display'));
        fprintf('  Package: %s\n\n', mc.ContainingPackage.Name);
      else
        fprintf('\n');
      end
      
      % convert logical AutoAccess to char
      % ----------------------------------
      if self.AutoAccess, theAutoAccess = 'true'; else theAutoAccess = 'false'; end
      if isempty(self.MagicField), theMagicField ='[]'; else theMagicField = self.MagicField; end
      if self.Echo, theEcho = 'true'; else theEcho = 'false'; end
      
      % diplay help in hypertext link
      % -----------------------------
      %fprintf('<a href="matlab:help datagui.dynaload">datagui.dynaload</a>\n');
      fprintf('    Filename:     ''%s''\n',   self.Filename);
      fprintf('  MagicField:     ''%s''\n',   theMagicField);
      fprintf('  AutoAccess:      %s\n',      theAutoAccess);
      fprintf('        Echo:      %s\n\n',    theEcho);
      
      % display dynamic properties names and types
      % ------------------------------------------
      for dp = self.meta
        fprintf('  %-14s\t%2d  [%s]\n', ...
          char(dp), length(fieldnames(self.(char(dp)))), class(self.(char(dp))));
      end
      fprintf('\n');
      
      % diplay methods list in hypertext link, debug only
      % -------------------------------------------------
      % disp('list of <a href="matlab:methods(''datagui.dynaload'')">methods</a>');
    end
    
%     % subscripted reference for objects, it's the only way to get data
%     % with autoaccess = true
%     % ex: 
%     % nc = datagui.netcdf('pirata-fr22_ctd.nc')
%     % nc.AutoAccess = true
%     % nc.Variables.TEMP
%     % ---------------------------------
%     function theValue = subsref(self, theStruct)  
%       if length(theStruct) == 2 && self.AutoAccess
%         theValue = self.(theStruct(1).subs).(theStruct(2).subs).data__;
%       else
%         try
%         theValue = builtin('subsref', self, theStruct);
%         catch err
%           error(err.identifier, err.message);
%         end
%       end
%     end
%     
%     % subscripted assignment for object dynaload
%     % ------------------------------------------
%     function subsasgn(self, theStruct, val)    
%      if length(theStruct) == 2 && self.AutoAccess
%         self.(theStruct(1).subs).(theStruct(2).subs).data__ = val;
%       else
%         builtin('subsasgn', self, theStruct, val);
%       end
%     end
    
    % prototype of public functions in separate files
    % -----------------------------------------------
    write(self, varargin);
    save(self, varargin);
    
  end % end of public methods
  
  % private functions
  % -----------------
  methods (Access = private)
    
    % prototype of function that was in separate files
    % ------------------------------------------------
    read_json_file(self);
    read_csv_file(self);
    read_xls_file(self);
    [h, nb_members, blk_size, nb_line] = read_block(self, h );
    write_json_file(self, rootname, varargin);
    write_csv_file(self);
    
  end % end of private methods
  
end % end of class
