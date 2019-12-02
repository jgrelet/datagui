function theResult = ncload(theNetCDFFile, varargin)
% datagui.ncload -- Load NetCDF variables.
%  datagui.ncload('theNetCDFFile', 'var1', 'var2', ...) loads the
%   given variables of 'theNetCDFFile' into the Matlab
%   workspace of the "caller" of this routine.  If no names
%   are given, all variables are loaded.  The names of the
%   loaded variables are returned or assigned to "ans".
%   Attributes are loaded is this case.
%   Whitout argument, datagui.ncload call uigetfile.
%
% Use the same syntax as Dr. Charles R. Denham ncload.m.
%
% $Id: ncload.m 240 2013-02-04 11:05:55Z jgrelet $

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
%    along with Datagui; if not, write to the Free Software
%    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
%    USA


% create netcdf object, call uigetfile if no filename is given
% ------------------------------------------------------------
if nargin == 0
  nc = datagui.netcdf;
else
  nc = datagui.netcdf(theNetCDFFile);
end

result = [];
if nargout > 0, theResult = result; end

% if no argument, set varargin with all variables and global attributes
% ---------------------------------------------------------------------
if isempty(varargin)
  variables  = keys(nc, 'Variables');
  attributes = keys(nc, 'Attributes');
else
  variables = varargin;
end

% loop over variables
% -------------------
for i = variables
  
  % convert cell to char
  % --------------------
  variable = char(i);
  
  % check if given variable is in the structure
  % -------------------------------------------
  if ~isfield(nc.Variables, variable)
    error('datagui.ncload: ''%s'' is not a valid variable for ''%s'' file.',...
      variable, theNetCDFFile);
  end
  
  % get variable value
  % ------------------
  var = nc.Variables.(variable).data__;
  
  % assign variable to caller workspace
  % -----------------------------------
  assignin('caller', variable, var);
  
end

% assign to base workspace attributes
% ----------------------------------
if isempty(varargin)
  
  for key = attributes
    
    % convert cell to char
    % --------------------
    attribute = char(key);
    
    % assign attribute to caller workspace
    % -------------------------------------
    assignin('caller', attribute, nc.Attributes.(attribute));
  end
end

% contain all input arg
% ---------------------
result = varargin;

if nargout > 0
  theResult = nc;
else
  % Assign a value to base-workspace.
  % ---------------------------------
  assignin('base', 'ans', result)
end

