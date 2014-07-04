function select_multiple_profil( varargin )
% SELECT_MULTIPLE_PROFIL
% Appelé par select_type_trace_callback
% root.indice contiendra la liste des profils selectionnes
% et on appel @profil/plot
% #######
% a verifier le code
%
% $Id: select_multiple_profil.m 123 2007-02-12 08:35:45Z jgrelet $

indice = [];
%cle    = [];
root = get( 0, 'UserData' );
self = root.self;
cles    = keys(   data_2d( self ) );
profils = get(data_1d(self),'PROFILS');

%% selectionne X et Y en fonction du choix fait dans plot_route
switch root.route_value
  case 1  % X=LONX Y=LATX
    X = get(data_1d(self),'LONX'); Y = get(data_1d(self),'LATX');
    % le choix sera fait dans select_section, si X > Y en LONX, sinon LATX
    coupe = 1;  
  case 2  % X=DAYD Y=LATX;
    X = get(data_1d(self),'DAYD'); Y = get(data_1d(self),'LATX');
    coupe = 'LATX',
  case 3  % X=DAYD Y=LONX;
    X = get(data_1d(self),'DAYD'); Y = get(data_1d(self),'LONX');
    coupe = 'LONX',
end

%% recupere dans cle le parametre selectionne
for i=1:length( cles )
  if get(findobj('Tag',['radio_' cles{i}]),'Value')
    cle = cles{i};
    break
  end  
end  

%% attend une selection de l'utilisateur
ax = mousebox;

%% conversion dans le repere de fdc choisie
if root.route_value == 1    % uniquement si trace lat=f(lon)
  switch root.map_value
    case 2   % m_map
      [ax(1), ax(3)] = m_xy2ll(ax(1),ax(3));
      [ax(2), ax(4)] = m_xy2ll(ax(2),ax(4));
    case 3   % maptool matlab
      [ax(3), ax(1)] = minvtran(ax(1),ax(3),[]);
      [ax(4), ax(2)] = minvtran(ax(2),ax(4),[]);
  end
end
% a commenter !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! pour debug actuellement
% ax

%% donne la liste des profils inclus dans le rectangle de la selection
for i=1:length(profils)
  if(  X(i) > ax(1) &&  X(i) < ax(2) && Y(i) > ax(3) && Y(i) < ax(4) )
    indice = [indice,i]; 
  end  
end

% %% definit l'abcisse, on utilise pas DAYD pour l'instant
% if coupe == 1
%   if std(X(liste_profils)) > std(Y(liste_profils))
%     coupe = 'LONX';
%   else  
%     coupe = 'LATX';
%   end  
% end  

% %% affiche a l'ecran l'equivalent a taper sur la ligne de
% %% commande
% %disp( [ coupe ' ' cle ' profils: ' num2str(liste_profils') ] );
% str = sprintf( ['''%s'',''%s'',''profils'',[%s],''methode'',''contourf''' ...
%   ',''Interpol'',10,''Pmax'',250,''Contour'',[0:1:30],''Pas'',5,''ProfilSpec'',''on'',''ClabelSpec'',''auto'' '],...
%     coupe, cle, num2str(liste_profils) );
% disp( ['plot_section(' str ')']);
if isempty(indice)
  warning('Liste de profils sélectionnés vide !!!');
else
  disp( [ 'profils: ', num2str(profils(indice)') ]);
  % maj l'indice des profils selectionnes dans l'instance profil
  root.self  = set(root.self,'indice', indice );
  set( 0, 'UserData', root );
  plot(root.self);
  line_route;
end

%clear root cles cle str;
