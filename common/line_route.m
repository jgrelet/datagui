function line_route
% retrace la route avec la profil selectionnee en bleu
% a mettre eventuelement comme methode de classe

% $Id: line_route.m 187 2012-09-12 13:09:40Z jgrelet $

root  = get( 0, 'UserData' );

markersize = root.markersize;
markertype = root.markertype;

% recupere le handle de trace de la ligne route
%hdl_line = findobj( 'Tag', 'line_route' );
hdl_axe = findobj( 'Tag', 'axe_route' );
indice  = get(root.self, 'indice');
%profils = get(get(root.self,'data_1d'),'REFERENCE_DATE_TIME'); 
%profils = profils(1:4);
% recupere la handle du texte du profil precedement selectionnee
% et le supprime
hdl_text_profil =  findobj( 'tag', 'text_profil');
if  ~isempty( hdl_text_profil )
  delete( hdl_text_profil );
end

%% plusieurs profils selectionnés, cas des sections par ex
% a reprendre, si plusieurs profils, afficher le premier et le dernier
% avec valeurs intermédiaires en bleu, 
% le tests posaient pb avec la gestion des handles
if ~isscalar( indice )
  return;
end  

%% initialise X et Y
switch root.route_value
  case 1     % LONX / LATX
    X = get(get(root.self,'data_1d'),'LONX'); 
    Y = get(get(root.self,'data_1d'),'LATX');   
  case 2     % DAYD / LATX
    X = get(get(root.self,'data_1d'),'DAYD'); 
    Y = get(get(root.self,'data_1d'),'LATX');  
  case 3      % DAYD / LONX
    X = get(get(root.self,'data_1d'),'DAYD'); 
    Y = get(get(root.self,'data_1d'),'LONX'); 
end

%% selectionne le label de la fleche en fonction du contexte
% type:  'TIME SERIE','TSG','METEO','BATHYMETRIE','CTD','XBT','ADCP',...
%        'BOUTEILLES','RADIOSONDAGE'}
switch root.type_value
    case {1,2,3,4}  
        entete = 'Mesure';
    case {7,9}
        entete = 'Profil';
    case {5,8}
        entete = 'Station';
    case 6
        entete = 'Sonde';
end     

%str = sprintf(['%s: %d \\rightarrow'], entete, profils);
% recupere la liste des profils, ne commencent pas necessairement a 1
profils = get(get(root.self,'data_1d'),'PROFILS'); 
%plante avec trajectoire car data_1d STATION_NUMBER n'existe pas
% temporaire, a corriger.
if (isempty(profils))
  str = 'trajectoire';
else  
  str = sprintf('%s: %d \\rightarrow', entete, profils(indice));
  %str = sprintf('%s: %d ->', entete, profils(indice));
end

%% trace le nouveau poit sur la route
switch root.route_value
  case 1  % lon/lat
    switch root.map_value
      case 3
        % a faire avec un eval (plot ou plotm)
        h = linem( Y, X, 'Marker', markertype, 'LineStyle','none', 'Color','r');
        linem( Y(indice), X(indice), 'Marker', markertype, ...
               'MarkerSize', markersize,'Color','b');
        ht = textm( Y(indice), X(indice),str,'Clipping','off', ...
               'HorizontalAlignment','right', 'Interpreter', 'Tex');
      case 2
        h = m_line( X, Y, 'Color', 'r', 'Marker', markertype,'LineStyle', 'none');
        m_line( X(indice), Y(indice), 'Color','b', 'Marker', markertype, ...
                'MarkerSize', markersize );
        ht = m_text(X(indice),Y(indice), str,'Clipping','off', ...
          'HorizontalAlignment','right', 'Interpreter', 'Tex');
      otherwise
        h = line( X, Y, 'Color','r','Marker', markertype,'LineStyle','none');
        line( X(indice), Y(indice),'Color','b', 'Marker', markertype, ...
              'MarkerSize', markersize );
        ht = text(X(indice),Y(indice),str,'Clipping','off', ...
          'HorizontalAlignment','right',  'Interpreter', 'Tex');
    end
  otherwise
    h = line( X, Y, 'Color','r','Marker', markertype,'LineStyle','none');
    line( X(indice), Y(indice),'Color','b', 'Marker', markertype, ...
          'MarkerSize', markersize );
    ht = text(X(indice),Y(indice),str,'Clipping','off', ...
      'HorizontalAlignment','right',  'Interpreter', 'Tex');
end
set( ht,'FontSize',8,'Color','blue','Tag','text_profil');
% sinon, par default met 'MarkerSize' a 6
set( h, 'Parent', hdl_axe, 'MarkerSize', markersize );
set( ht, 'Parent', hdl_axe);
set( h, 'tag', 'line_route',...
  'ButtonDownFcn', 'getButtonDownCallback');

%clear self hdl_axe hdl_text_profil X Y entete str h ht;
%clear indice markersize;

