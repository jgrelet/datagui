function display(this)

%$Id: display.m 143 2008-02-01 13:55:14Z jgrelet $

try
  
  % --------------------------------------------------------------------------
  % Lecture et affichage des infos de l instance
  
  s = whos('this') ;
  sz = s.size   ;
  %disp (sprintf ('\tName\tSize\tClass'));
  %disp (sprintf ('\t%s\t%s%s\n', inputname(1), mat2str(sz), s.class ));
  disp( sprintf ('Class name: %s\n', s.class ));
  disp( 'Parent oceano: ' );
  display(this.oceano);
  %disp( 'Parent roscop: ' );
  %display(this.roscop);
  disp(struct(this));
  disp( 'data_2d hashtable: ' );
  display(this.data_2d);


% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% ----------------------------------------------------------------------------
% Bloc catch

catch
  error ('trajectoire', 'display', lasterr) ;
end
