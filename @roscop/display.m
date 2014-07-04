function display(this)

%$Id: display.m 53 2006-03-03 13:41:22Z jgrelet $

try
  
  % --------------------------------------------------------------------------
  % Lecture et affichage des infos de l instance
  
%   s = whos('this') ;
%   sz = s.size   ;
%   disp (sprintf ('\t\tName\tSize\tClass'));
%   disp (sprintf ('\t\t%s\t%s\t%s\n', inputname(1), mat2str(sz), s.class ));
%  disp (char (this)) ;
  disp(struct(this));

% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% Bloc catch

catch
  err ('roscop', 'display', lasterr) ;
end
