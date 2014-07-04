function display(this)

%$Id: display.m 142 2008-02-01 13:54:45Z jgrelet $

try
  
  % --------------------------------------------------------------------------
  % Lecture et affichage des infos de l instance
  
%   s = whos('this') ;
%   sz = s.size   ;
%   disp (sprintf ('\t\tName\tSize\tClass'));
%   disp (sprintf ('\t\t%s\t%s\t%s\n', inputname(1), mat2str(sz), s.class ));
%   %disp (char (this)) ;
  disp(struct(this));
  disp( 'data_0d hashtable: ' );
  display(this.data_0d);
  disp( 'data_1d hashtable: ' );
  display(this.data_1d);

% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% Bloc catch

catch
  error ('oceano', 'display', lasterr) ;
end