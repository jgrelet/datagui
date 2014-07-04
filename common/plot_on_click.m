function plot_on_click
% script de generique d'appel aux methodes de trace d'une instance
% a partir du trace de la route

% $Id: plot_on_click.m 2 2005-10-12 09:35:32Z jgrelet $

root = get(0, 'UserData' ); 

plot( root.self );