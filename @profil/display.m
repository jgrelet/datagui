function display(this)

%$Id: display.m 135 2007-05-02 06:29:14Z jgrelet $

try
  
  % --------------------------------------------------------------------------
  % Lecture et affichage des infos de l instance
  
  s = whos('this') ;
  sz = s.size   ;
  %disp (sprintf ('\tName\tSize\tClass'));
  %disp (sprintf ('\t%s\t%s%s\n', inputname(1), mat2str(sz), s.class ));
  disp( sprintf ('Class name: %s\n', s.class ));
  disp(struct(this));
  disp( 'Parent oceano: ' );
  display(this.oceano);
  %disp( 'Parent roscop: ' );
  %display(this.roscop);
  disp( 'data_2d hashtable: ' );
  display(this.data_2d);
  
% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% Bloc catch

catch
  err ('profil', 'display', lasterr) ;
end
