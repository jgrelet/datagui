function p = profil( varargin )
% PROFIL  class constructor

% $Id: profil.m 120 2007-02-02 13:42:20Z jgrelet $

switch nargin
  case 0  % create default object
    p = init_struct;
    % create object to define parent class
    r = roscop;
    o = oceano; 
    %h = hashtable;
    p = class(p, 'profil', r, o );
  case 1
    if( isa(varargin{1}, 'char'))       % default constructor
      p = profil();   
      p = set(p, 'file', varargin{1});
    elseif( isa(varargin{1}, 'profil')) % copy constructor
      p = varargin{1};
    elseif( isa(varargin{1}, 'oceano')) % create from oceano
      p = init_struct;
      r = roscop;
      o = varargin{1};  
      %h = hashtable;
      p = class(p, 'profil', r, o );
    else
      error('Wrong input argument');
    end
  otherwise
    error('Wrong number of input arguments');
end

%
function p = init_struct
    p.indice = 1;   % indice du profil selectionne
    % data 2D (ie PRES, DEPH, TEMP, PSAL, DOX1, etc)
    p.data_2d = hashtable;
    % backup
    p.backup_2d = hashtable;
    
