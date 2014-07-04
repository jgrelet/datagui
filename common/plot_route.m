%plot_route

% $Id: plot_route.m 74 2006-07-11 08:55:27Z nvuillau $

root = get( 0, 'UserData' );

%recuperation du handle d'un trace de donnees hors plot_route
% a verifier cette modif
% avec l'utilisation de plot_section_dataGUI, retournait 3 handle avec
% d'autres fenetres a l'ecran: eg profil par ex
% >> findobj(  '-regexp','Tag', 'plot_[^route]')
% 
% ans =
% 
%     4.0000
%     3.0000
%   213.0038
%
%hdl = findobj(  '-regexp','Tag', 'plot_[^route]');
hdl = findobj(  '-regexp','Tag', 'plot_route');
if hdl  % si exist, on efface la figure
  close( hdl );
end
% si instance self non vide (fichier lu et en memoire), on trace la route
if ~isempty( root.self )
  plot_route(root.self);
  line_route;  % permet d'afficher la premiere station
end

clear root hdl;