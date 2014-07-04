% select_type_trace_callback
%
% script appele par callback sur "popup type_trace dans @profil/plot_route"
% 
%
%$Id: select_type_trace_callback.m 149 2008-02-21 17:39:13Z jgrelet $


root = get( 0, 'UserData' ); 
hdl_figure = findobj( 'Tag', 'plot_route' );

% probleme, root.type_trace_value se transforme en tableau de cellules
% corrigé dans profil/plot_route mais a verifier en details
root.type_trace_value = get( findobj( 'Tag', 'popup_type_trace' ), 'Value' );

% #########
% ligne inutilse, mise en commentaire le 31/01/2006
%set(0, 'UserData', root );

%% a verifir si necessaire
% determine si Y = 'PRES' ou 'DEPH'
cle = {};
cles = keys( data_2d( root.self ) );
for i=1:length( cles )
  if strcmp(cles{i},'PRES') || strcmp(cles{i},'DEPH') || ...
    strcmp(cles{i},'HEIG') || strcmp(cles{i},'ETDD')
    continue
  else  
    cle{end+1} = cles{i};
  end
end 
% a verifier si necessaire

% si trace = section, cache le choix levitus et passe en mode exclusif
% choix  : 0 -> choix multiples
%          1 -> choix exclusif (uibunttongroup)
switch root.type_trace_value 
  case 1  % profil
    set( findobj( 'Tag', 'levitus' ), 'Visible', 'on' );
    choix_parametres( hdl_figure, cle, 0 );
    % active de nouveau le handle pour les profils sur la route
    hdl_line_route = findobj( 'tag', 'line_route' );
    set( hdl_line_route, 'tag', 'line_route',...
      'ButtonDownFcn', 'getButtonDownCallback');
  
  case 2  % section
    set( findobj( 'Tag', 'levitus' ), 'Visible', 'off' );
    choix_parametres( hdl_figure, cle, 2 );
    % en section, desactive le handle ButtonDownFcn sur line_route
    % (plot des profils)
    hdl_line_route = findobj( 'tag', 'line_route' );
    set( hdl_line_route, 'tag', 'line_route',...
      'ButtonDownFcn', []);
    % prepare la selection graphique des profils et le trace de la section
    drawnow
    select_section;
    
  case 3  % multiple profils
    set( findobj( 'Tag', 'levitus' ), 'Visible', 'off' );
    choix_parametres( hdl_figure, cle, 1 );
    % en section, desactive le handle ButtonDownFcn sur line_route
    % (plot des profils)
    hdl_line_route = findobj( 'tag', 'line_route' );
    set( hdl_line_route, 'tag', 'line_route',...
      'ButtonDownFcn', []);
    % prepare la selection graphique des profils et le trace de la section
    drawnow
    select_multiple_profil;

    
  case 4  % TS
    set( findobj( 'Tag', 'levitus' ), 'Visible', 'off' );
    % en TS, desactive le handle ButtonDownFcn sur line_route
    hdl_line_route = findobj( 'tag', 'line_route' );
    set( hdl_line_route, 'tag', 'line_route',...
      'ButtonDownFcn', []);
    % prepare la selection graphique des profils et le trace de la section
    drawnow;
    plot_TS;
    
end  

pause(0.1);
% on remet le popup sur profil par defaut
% il faut recuperer root car on est passe dans d'autres fonctions, sinon
% ca ne marche pas
root = get( 0, 'UserData' ); 
root.type_trace_value = 1;
set( findobj( 'Tag', 'popup_type_trace_value' ), 'Value', 1);
set(0, 'UserData', root);

clear root hdl_figure cle cles type_trace_value hdl_line_route;
