function r = roscop( varargin )
% ROSCOP constructor function for ROSCOP object
% Use:  r = roscop( file )
% Fields:
%   file = string
%  

% $Id: roscop.m 146 2008-02-01 13:59:05Z jgrelet $

switch nargin
  case 0  % create default object
    file = 'code_roscop.csv';
  case 1
    if( isa(varargin{1}, 'char'))
      file = varargin{1};      
    else
      error('Wrong input argument');
    end
  otherwise
    error('Wrong number of input arguments');
end

if exist(file, 'file') ~= 2
  disp(['The specified data file ' file  ' does not exist ...']);
  disp('Or is not in the directory which is on the MATLAB search path');
  datagui_closereq_callback;
end

[codes,description,unit,min,max,format,bad,scale] = textread(...
      file,'%s%s%s%f%f%s%f%s','delimiter',';','headerlines', 4 );

r.file = which(file);
r.size = length(codes);
keys   = hashtable;

for i=1:length(codes)
  s.description = description{i};
  s.unit   = unit{i};
  s.min    = min(i);
  s.max    = max(i);
  s.format = format{i};
  s.bad    = bad(i);
  % par defaut, sera modifie plus tard avec la commande set
  % r = set( r,'scale','PSAL',[0 50;33 37] );
  % 
  % on va remplacer la derniere chaine, lorsqu'elle contient la chaine
  % '0 50|0 100|... par 0 50;0 100;... pour créer la matrice
  if ~isempty(char(scale(i)))
    chaine = char(scale(i));
    ind = findstr(chaine, '|');
    chaine(ind) = ';';
    s.scale  = [str2num(chaine);s.min s.max]; 
  else
    s.scale  = [s.min s.max];
  end  
  keys = put(keys, char(codes(i)), s);
end	

r = class(r, 'roscop', keys );
