% select_map

% script appele par callback sur "popup_select_map"
% 
% Id$
 
% flushes the event queue and updates the figure window.
% ------------------------------------------------------
drawnow;

% % recupere la struct root dans le champ UserData de main_fig
% self = get( findobj( 'Tag', 'main' ), 'UserData' ); 

root = get( 0, 'UserData' ); 
% 
% % appel la fonction select_plot_axis pour l'instance utilisee
% select_map( self );

root.map_value = get( findobj( 'Tag', 'popup_map' ), 'Value' );
set( 0, 'UserData', root );

%plot_route( root.self );
pause(0.1);
plot_route;

clear root;