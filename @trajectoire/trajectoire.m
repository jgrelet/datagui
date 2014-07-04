function t = trajectoire( varargin )
% TRAJECTOIRE  class constructor

% $Id: trajectoire.m 2 2005-10-12 09:35:32Z jgrelet $

switch nargin
  case 0  % create default object
    t = init_struct;
    % create object to define parent class
    r = roscop;
    o = oceano; 
    %h = hashtable;
    t = class(t, 'trajectoire', r, o);
  case 1
    if( isa(varargin{1}, 'char'))       % default constructor
      t = trajectoire();   
      t = set(t, 'file', varargin{1});
    elseif( isa(varargin{1}, 'trajectoire')) % copy constructor
      t = varargin{1};
    elseif( isa(varargin{1}, 'oceano')) % create from oceano
      t = init_struct;
      r = roscop;
      o = varargin{1};  
      %h = hashtable;
      t = class(t, 'trajectoire', r, o);
    else
      error('Wrong input argument');
    end
  otherwise
    error('Wrong number of input arguments');
end

%
function t = init_struct
    t.indice = 1;   % indice de la mesure selectionnee
    t.data_2d = hashtable;
    t.backup_2d = hashtable;
    
