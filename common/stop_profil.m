%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function stop_profil( obj, event )

% $Id: stop_profil.m 2 2005-10-12 09:35:32Z jgrelet $

tag_run  = findobj( 'Tag', 'tag_button_run' );
set( tag_run, 'String', 'Run' );
