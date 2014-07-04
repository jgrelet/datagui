% getEditCallback
% script d'edition d'un profil appele sur appui du radio_bouton "Edit" 
% @profil/plot_route

% $Id: getEditCallback.m 122 2007-02-07 15:53:35Z jgrelet $



% on utilise r au lieu de root car root est une classe java !!!
r          = get( 0, 'UserData' );
hdl_figure = findobj( 'Tag', 'plot_route' );
choix      = get( findobj( 'Tag', 'edit' ), 'Value' );

% determine si Y = 'PRES' ou 'DEPH'
cle = {};
cles = keys( data_2d( r.self ) );
mode = edit(r.self);
for i=1:length( cles )
  if strcmp(cles{i}, 'PRES') || strcmp(cles{i}, 'DEPH') || ...
     strcmp(cles{i}, 'HEIG') || strcmp(cles{i}, 'ETDD')
    continue
  else  
    cle{end+1} = cles{i};
  end
end  

choix_parametres (hdl_figure, cle, choix);

% bascule le mode edition on/off, definit a off dans init_config
if strcmp( mode, 'off' )
  mode = 'on';
  r.self = set( r.self, 'edit', mode );
	% on lit le fichier en mode write/append et on ajoute var_COR et var_Q
  [r.self nc] = read_file_nc(r.self, 'write');
  set(0, 'UserData', r );
  plot(r.self);
  close( nc );
elseif strcmp( mode, 'on' )
  mode = 'off';
  r.self = set( r.self, 'edit', mode );  
	set(0, 'UserData', r );
  plot(r.self);
end

clear r i cle cles hdl_figure choix;


