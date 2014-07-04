% getButtonResetCallback
% script generique appele sur appui du bouton "Reset" de plot_route

% $Id: getButtonResetCallback.m 2 2005-10-12 09:35:32Z jgrelet $

root     = get( 0, 'UserData' );

plot( root.self );
line_route;

clear root;
