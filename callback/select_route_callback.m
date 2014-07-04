% select_route

% script appele par callback sur "popup routeaxis"
% 
%
%$Id: select_route_callback.m 149 2008-02-21 17:39:13Z jgrelet $

% flushes the event queue and updates the figure window.
% ------------------------------------------------------
drawnow;

% recupere la struct root dans le champ UserData de main_fig
%self = get(findobj( 'Tag', 'main' ), 'UserData' ); 
% ou 
%self = get( findobj( 'Tag', 'main' ), 'UserData' ); 

% appel la fonction select_plot_axis pour l'instance utilisee
%select_route_axis( self );

root = get( 0, 'UserData' ); 

root.route_value = get( findobj( 'Tag', 'popup_route' ), 'Value' );
set(0, 'UserData', root );

% si tracer different de lat/lon, supprime le popup map de l'interface GUI
if root.route_value > 1
  set( findobj( 'Tag', 'popup_map' ), 'Enable', 'off' );
  set( findobj( 'Tag', 'Select map' ), 'Enable', 'off' );
else  
  set( findobj( 'Tag', 'popup_map' ), 'Enable', 'on' );
  set( findobj( 'Tag', 'Select map' ), 'Enable', 'on' );
end  

pause(0.1);
%plot_route( root.self );
plot_route;

clear root;