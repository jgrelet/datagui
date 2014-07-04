function val = get( self, prop )
% GET: Get oceano properties from specified object

% $Id: get.m 121 2007-02-05 17:16:33Z jgrelet $

% if ~ischar(prop), error('GET: prop must be string.'), end
% prop = lower(prop(isletter(prop))); %remove nonletters
% if (length(prop) < 2), error('GET: prop must be at least 2 chars.'), end
% switch prop(1:2)

switch prop
  case 'descriptor'
    val = self.descriptor;
  case 'date'
    val = self.date;
  case 'visible'
    val = self.visible;
  case 'type_file'
    val = self.type_file;
  case 'path'
    val = self.path;
  case 'file'
    val = self.file;
  case 'color'
    val = self.color;
  case 'edit'
    val = self.edit;
  case 'data_0d'
    val = self.data_0d;
  case 'data_1d'
    val = self.data_1d;
  case 'backup_0d'
    val = self.backup_0d;
  case 'backup_1d'
    val = self.backup_1d;
  otherwise
    error(['GET: ',prop,' is not a valid oceano property.']);
end

