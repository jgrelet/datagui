function write(self, varargin)
% datagui.dynaload.write: write dynaload structure to ASCII CSV file
% (Comma Separated Value) or JSON (JavaScript Object Notation).
%
% Usage:
%   d.save
%   d.save(filename)
%   d.save(filename, varargin)
%
% Optional parameters:
%   'format': 'json' (default) or 'csv'
%
% Example:
%   d = datagui.dynaload('test.xls');
%   d.save                     % default, save to test.json
%   d.save('demo.csv')         % save to demo.csv
%   d.save('format', 'csv')    % save to test.csv
%
% $Id: write.m 252 2013-08-16 14:58:37Z jgrelet $

% default format
% --------------
theFormat = 'json';

% check args
% ----------
if isempty(varargin)
  
  % no arg, set default output format to JSON
  % -----------------------------------------
  theFilename = self.Filename;
  
end

% check property/value args
% -------------------------
if mod(length(varargin), 2)
  n= 2;
  % first arg is theFilename
  % ------------------
  if (isa(varargin{1}, 'char'))
    theFilename = varargin{1};
    match = regexp(theFilename, '[^\\]*\.(\w+)$', 'tokens');
    if ~isempty(match)
      theFormat = char(match{:});
    end
  end
else
  n = 1;
  theFilename = self.Filename;
end

property_argin = varargin(n:end);
while length(property_argin) >= 2,
  property = property_argin{1};
  value    = property_argin{2};
  property_argin = property_argin(n+2:end);
  switch lower(property)
    case 'format'
      theFormat = value;
    otherwise
      error('MATLAB:datagui:dynaload:write: Unknown property: ''%s''', property);
  end
end

% construct extension
% -------------------
ext = strcat('.', theFormat);

% by default, save file in JSON format
% ------------------------------------
[path, name, ~] = fileparts(theFilename);
if isempty(path)
  self.Filename = fullfile(pwd, strcat(name, ext));
else
  self.Filename = fullfile(path, strcat(name, ext));
end

switch ext
  case '.json'
    write_json_file(self, '', self.Filename);
  case {'.csv', '.txt'}
    write_csv_file(self);
  case {'.xls','.xlsx'}
    error(['MATLAB:datagui:dynaload:write: Save in Excel format.',...
      'This functionality is not yet implemented']);
  otherwise
    error('MATLAB:datagui:dynaload:write: Wrong file extension: ''%s''', ext);
end

end

