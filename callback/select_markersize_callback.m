% select_markersize.m
% script generique appele sur appui du bouton "markersize" de plot_route

% $Id: select_markersize_callback.m 187 2012-09-12 13:09:40Z jgrelet $

root = get( 0, 'UserData' );
markersize_value = get(findobj( 'Tag', 'popup_markersize' ), 'Value' );

switch markersize_value
  case 1
    marker = 1;
  case 2
    marker = 2;
  case 3
    marker = 3;
  case 4
    marker = 4;
  case 5
    marker = 6;
  case 6
    marker = 8;
  case 7
    marker = 10;
  otherwise
    marker = 4;
end

root.markersize = marker;


% sauvegarde l'instance dans root (UserData)
set(0, 'UserData', root );
% retarce fdc
plot_route( root.self );
line_route;

clear root markersize_value markersize;

