% getButtonNextCallback
% script generique appele sur appui du bouton "Next" de plot_route

% $Id: getButtonNextCallback.m 120 2007-02-02 13:42:20Z jgrelet $

root    = get( 0, 'UserData' );
indice  = get(root.self, 'indice');  % indice du profil en cours
profils = get(get(root.self,'data_1d'),'PROFILS'); % les profils

if indice < length(profils)
  indice = indice + 1;
  root.self  = set( root.self, 'indice', indice );
  % sauvegarde l'instance dans root (UserData)
  set(0, 'UserData', root );
  plot( root.self );
  line_route;
else
  fprintf(1, 'Max profile %d  reach\n',  profils(indice) );;
end

clear root indice profils;


% mettre a jour les boutons de position!!!!!