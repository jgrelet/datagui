function display(this)

%$Id: display.m 73 2006-07-11 08:15:09Z nvuillau $

try
  
  % --------------------------------------------------------------------------
  % Lecture et affichage des infos de l instance
  
  s = whos('this') ;
  sz = s.size   ;
  %disp (sprintf ('\tName\tSize\tClass'));
  %disp (sprintf ('\t%s\t%s%s\n', inputname(1), mat2str(sz), s.class ));
  disp( sprintf ('Class name: %s\n', s.class ));
  disp(struct(this));
%   disp( 'data_2d hashtable: ' );
%   display(this.data_2d);
%   disp( 'Parent oceano: ' );
%   display(this.oceano);
%   disp( 'Parent roscop: ' );
%   display(this.roscop);
  %display(this.hashtable);
  %disp (char (this)) ;
% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% Bloc catch

catch
  err ('profil', 'display', lasterr) ;
end
