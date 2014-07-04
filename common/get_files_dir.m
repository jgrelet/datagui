function get_files_dir

% $Id: get_files_dir.m 25 2006-02-21 15:03:49Z jgrelet $

root = get( 0, 'UserData' ); 

% avec fullfile, root.path n'a pas besoin de se terminer par 'filesep'
dlist    = dir( fullfile(root.path, root.ext) );
if( isempty( dlist ) )
  root.files = {'no data'};
  root.files_value = 1;
  % reset de l'instance self
  root.self = [];
else
  if root.files_value > length( dlist )
    root.files_value = 1;
  end  
  root.files = {dlist.name};
end
set( findobj( 'Tag', 'text_file' ),  'String', root.path );
set( findobj( 'Tag', 'popup_file' ), 'String', root.files );
set( findobj( 'Tag', 'popup_file' ), 'Value',  root.files_value );

set(0, 'UserData', root );

clear dlist root;