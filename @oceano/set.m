function self = set( self, varargin )

% modifier set pour modifier plusieurs propriete (voir doc Using Matlab)
% $Id: set.m 121 2007-02-05 17:16:33Z jgrelet $

if nargin == 3
  prop  = varargin{1};
  value = varargin{2};

  switch prop
    case 'descriptor'
      self.descriptor = value;
    case 'date'
      self.date = value;
    case 'visible'
      self.visible  = value;  
    case 'path'
      self.path  = value;
    case 'ext'
      self.ext  = value;
      dlist    = dir( [self.path '*_' self.ext] );
      if( isempty( dlist ) )
        self.files = {'no data'};
      else
        self.files = {dlist.name};
      end
    case 'files'
      self.files = value; 
    case 'file'
      self.file = value; 
    case 'type_file'
      self.type_file = value; 
    case 'edit'
      self.edit = value;
    case 'backup_0d'   % copy constructor
      self.backup_0d = hashtable(  value );
    case 'backup_1d'
      self.backup_1d = hashtable(  value );

    otherwise
      error(sprintf('Unrecognized property name ''%s''.',prop)); 
  end
  
elseif nargin == 4
  prop  = varargin{1};
  cle   = varargin{2};
  value = varargin{3};
  switch prop
    case 'data_0d'
      % hash  = put( hash, cle, value )
      % cle   = varagin{2}
      % value = varagin{3}
      self.data_0d = put( self.data_0d, cle, value );
    case 'data_1d'
      self.data_1d = put( self.data_1d, cle, value );
    otherwise
      error(sprintf('Unrecognized property name ''%s''.',prop));
  end
else
  %val = get( self, varargin{:});

end
    
