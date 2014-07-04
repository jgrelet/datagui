function self = set( self, varargin )

% modifier set pour modifier plusieurs propriete 
% (voir doc Programing Matlab, page 8-41)

if nargin == 3
  prop  = varargin{1};
  value = varargin{2};

  switch prop
    % set parent properties
    case 'descriptor' 
      self.oceano = set( self.oceano, 'descriptor', value);
    case 'date'
      self.oceano = set( self.oceano, 'date', value);
    case 'visible'
      self.oceano = set( self.oceano, 'visible', value);
    case 'type_file'
      self.oceano = set( self.oceano, 'type_file', value);
    case 'path'
      self.oceano = set( self.oceano, 'file', value);
    case 'file'
      self.oceano = set( self.oceano, 'file', value);
    case 'color'
      self.oceano = set( self.oceano, 'color', value); 
    case 'edit'
      self.oceano = set( self.oceano, 'edit', value);
    case 'backup_0d'
      self.oceano = set( self.oceano, 'backup_0d', value );
    case 'backup_1d'
      self.oceano = set( self.oceano, 'backup_1d', value );
  
    % set class properties
    case 'indice'
      self.indice  = value;
    case 'backup_2d' % copy constructor
      self.backup_2d = hashtable( value );
    otherwise
      error(sprintf('Unrecognized property name ''%s''.',prop)); 
  end
  
elseif nargin == 4
  prop  = varargin{1};
  cle   = varargin{2};
  value = varargin{3};
  switch prop
    case 'data_0d'
      self.oceano = set( self.oceano, 'data_0d', cle, value );
    case 'data_1d'
      self.oceano = set( self.oceano, 'data_1d', cle, value );
    case 'data_2d'
      self.data_2d = put( self.data_2d, cle, value );
    otherwise
      error(sprintf('Unrecognized property name ''%s''.',prop));
  end
else
  %val = get( self, varargin{:});

end

    
