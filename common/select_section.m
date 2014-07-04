function select_section( varargin )
% SELECT_SECTION
% Appelé par select_type_trace_callback
%
% $Id: select_section.m 120 2007-02-02 13:42:20Z jgrelet $

liste_profils = [];
cle = '';
root = get( 0, 'UserData' );
self = root.self;
cles    = keys(   data_2d( self ) );
profils = get(data_1d(self),'PROFILS');

%% selectionne X et Y en fonction du choix fait dans plot_rout
% #####
% change le root.route_value et root.axis_value, voir sous cvs pourquoi ?
%switch root.axis_value
switch root.axis_value
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
    liste_profils = [liste_profils,i];
  end
end

%% definit l'abcisse, on utilise pas DAYD pour l'instant
if coupe == 1
  if std(X(liste_profils)) > std(Y(liste_profils))
    coupe = 'LONX';
  else
    coupe = 'LATX';
  end
end

%% affiche a l'ecran l'equivalent a taper sur la ligne de commande
% a reprendre differemment
var  = get(data_2d(self), cle);
scale = [floor(min(min(var))) ceil(max(max(var)))];
if( scale(2)-scale(1) > 30 )
  scale = sprintf( '[%d:10:%d]',scale(1),scale(2) );
  pas = '20';
elseif( scale(2)-scale(1) < 5 )
  scale = sprintf( '[%d:.1:%d]',scale(1),scale(2) );
  pas = '1';
else
  scale = sprintf( '[%d:1:%d]',scale(1),scale(2) );
  pas = '5';
end
str = sprintf( ['''%s'',''%s'',''profils'',[%s],''methode'',''contourf''' ...
  ',''Interpol'',10,''Vertical'',[0 500],''Contour'',%s,''Pas'',%s,''ProfilSpec'',''on'',''ClabelSpec'',''auto'' '],...
  coupe, cle, num2str(liste_profils),scale,pas );
disp( ['plot_section(' str ')']);
if isempty(liste_profils)
  warning('Liste de profils sélectionnés vide !!!');
else
  cles    =    data_2d( self );
	%###### a reprendre correctement, pas le temps, dans l'avion Mahe/Paris,
	% plus batterie !!!
  profondeurs = get(cles,'PRES');
  if isempty(profondeurs)
    profondeurs = get(cles,'DEPH');
	end
	  if isempty(profondeurs)
    profondeurs = get(cles,'HEIG');
  end
  for i=1:length(liste_profils)
    s(i) = struct('profil',liste_profils(i),'longitude',{X(liste_profils(i))},'latitude',{Y(liste_profils(i))},'profondeur',{max(profondeurs(liste_profils(i),:))});
  end
  % A COMMENTER !!!!!!!!!!!!!!!!!!!!!!!!
  liste_profils = extract_profil(s);
  s = section('var_x', coupe, 'code_roscop', cle, 'liste_profils', liste_profils);
  plot(s);
  %plot_section_dataGUI( coupe, cle, liste_profils);
end;

