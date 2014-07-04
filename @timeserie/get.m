function val = get( self, prop )
% GET: Get timeserie properties from specified object

% $Id: get.m 2 2005-10-12 09:35:32Z jgrelet $

if nargin==1  % list properties if only object is given
  disp('timeserie properties:')
  disp(sprintf(' descriptor, date, type_file, path, file, color'));
  disp(sprintf(' visible,  indice,  data_0d,  data_1d\n'));
  return
end

if ~ischar(prop), error('GET: prop must be string.'), end
%prop = lower(prop(isletter(prop))); %remove nonletters
%if (length(prop) < 2), error('GET: prop must be at least 2 chars.'), end
%switch prop(1:2)

switch prop
  % get parent properties
  case 'descriptor'
    val = get(self.oceano,'descriptor');  % call oceano GET method
  case 'date'
    val = get(self.oceano,'date');  % call oceano GET method
  case 'visible'
    val = self.visible;
  case 'visible'
    val = get(self.oceano,'visible');  % call oceano GET method
  case 'path'
    val = get(self.oceano,'path');  % call oceano GET method
  case 'file'
    val = get(self.oceano,'file');  % call oceano GET method
  case 'color'
    val = get(self.oceano,'color');  % call oceano GET method
  case 'data_0d'
    val = get(self.oceano,'data_0d');  % call oceano GET method
  case 'data_1d'
    val = get(self.oceano,'data_1d');  % call oceano GET method
  case 'backup_0d'
    val = get(self.oceano,'backup_0d');  % call oceano GET method
  case 'backup_1d'
    val = get(self.oceano,'backup_1d');  % call oceano GET method
 % get timeserie properties
  case 'indice'
    val = self.indice;
  case 'data_2d'
    val = self.data_2d;
  case 'backup_2d'
    val = self.backup_2d;
  otherwise
    error(['GET: ', prop,' is not a valid timeserie property.']);
end

