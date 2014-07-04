% select_file_callback.m

% script appele par callback sur "select a file"
% met a jour le popup associe et la struct root
%
%$Id: select_file_callback.m 149 2008-02-21 17:39:13Z jgrelet $

% flushes the event queue and updates the figure window.
% ------------------------------------------------------
drawnow;

root = get( 0, 'UserData' ); 
% recupere l'indice du popup apres selection 
root.files_value = get( findobj( 'Tag', 'popup_file' ), 'Value' );

% si fichier present
if( ~strcmp( root.files, 'no data' ))
  % lit le fichier
  root.selected_file = fullfile( root.path, root.files{root.files_value} );
  set(0, 'UserData', root );
  read_file;
  % met a jour le plot
  plot_route;
end  


clear root;