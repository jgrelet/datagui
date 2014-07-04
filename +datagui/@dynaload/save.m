function save(self, varargin)
% datagui.dynaload.save
% it's a wrapper on datagui.dynaload.write method
%
% $Id: save.m 203 2013-01-22 15:15:17Z jgrelet $

% uses the comma-separated list syntax varargin{:} to pass the optional
% parameters to write
% ---------------------------------------------------------------------
write(self, varargin{:});



