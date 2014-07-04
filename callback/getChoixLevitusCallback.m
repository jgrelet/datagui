% getChoixLevitusCallback
% script generique appele sur appui du radio_bouton "WOA01" de plot_route

% $Id: getChoixLevitusCallback.m 121 2007-02-05 17:16:33Z jgrelet $

global LEVITUS;

% on utilise r au lieu de root car root est une classe java !!!
r          = get( 0, 'UserData' );
hdl_figure = findobj( 'Tag', 'plot_route' );
choix      = get( findobj( 'Tag', 'Climatology' ), 'Value' );

% determine si Y = 'PRES' ou 'DEPH'
cle = {};
cles = keys( data_2d( r.self ) );
for i=1:length( cles )
  if strcmp(cles{i}, 'PRES') || strcmp(cles{i}, 'DEPH') || ...
     strcmp(cles{i}, 'HEIG') || strcmp(cles{i}, 'ETDD')
    continue
  else  
    cle{end+1} = cles{i};
  end
end  

choix_parametres( hdl_figure, cle, choix );

if strcmp( r.levitus, 'on' )
  %levitus = read_file_woa01( 'woa01an.nc' );
  % ne marche pas, flingue le contenu de root !!!!!
  % exist('root') retourne 8, root est une classe java
  LEVITUS = read_file_woa01( 'woa01an.nc' );
  r.levitus = 'on';
end

set(0, 'UserData', r );
plot(r.self);

clear r i cle cles hdl_figure choix;


