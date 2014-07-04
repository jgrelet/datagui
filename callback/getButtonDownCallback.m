% getButtonDownCallback

% $Id: getButtonDownCallback.m 120 2007-02-02 13:42:20Z jgrelet $

% recupere la struct root dans le champ UserData de main_fig
root = get(0, 'UserData' ); 

% recupere les handles d'affichage des coordonnees
tag_but4  = findobj( 'Tag', 'tag_but4' );
tag_but5  = findobj( 'Tag', 'tag_but5' );
tag_but6  = findobj( 'Tag', 'tag_but6' );


pt = get( findobj( 'Tag', 'axe_route'), 'CurrentPoint' );

t = [pt(1,1) pt(1,2)];   % [x,y]

year = get(get(root.self,'data_1d'), 'REFERENCE_DATE_TIME' );
year = str2double({year(1:4)});

switch root.route_value
  case 1
    set(tag_but4, 'Visible', 'off');
    X = get( get( root.self, 'data_1d' ), 'LONX' );  % LONX
    Y = get( get( root.self, 'data_1d' ), 'LATX' );  % LATX
    % [LAT, LON] = MINVTRAN(X, Y) the inverse transformation for the selected projection
    % Use text as an object to represent a point calculation
    if root.map_value == 3 % maptool
      [t(2), t(1)] = minvtran(t(1),t(2),[]);
    end
    % [LON,LAT] = M_XY2LL Converts X,Y to  coordinates using the
    % current projection
    if root.map_value == 2 % m_map
      [t(1), t(2)] = m_xy2ll(t(1),t(2));
    end
    set( tag_but5, 'string', dd2dm(t(1), 1));
    set( tag_but6, 'string', dd2dm(t(2), 0));

  case 2
    X = get( get( root.self, 'data_1d' ), 'DAYD' );  % DAYD
    Y = get( get( root.self, 'data_1d' ), 'LATX' );  % LATX
    set(tag_but4, 'Visible', 'on');
    set( tag_but4, 'string', to_date(year, t(1), 's'));
    set( tag_but5, 'string', num2str(t(1)));
    set( tag_but6, 'string', dd2dm(t(2), 0));

  case 3
    X = get( get( root.self, 'data_1d' ), 'DAYD' );  % DAYD
    Y = get( get( root.self, 'data_1d' ), 'LONX' );  % LONX
    set(tag_but4, 'Visible', 'on');
    set( tag_but4, 'string', to_date(year, t(1), 's'));
    set( tag_but5, 'string', num2str(t(1)));
    set( tag_but6, 'string', dd2dm(t(2), 1));

end

% Calculate the point to determine
% which point is closest to the mouse
[dp,indice] = min((X-t(1)).^2 + (Y-t(2)).^2);

if indice
  % disp( ['appel de plot (profil) : ' num2str(indice)] );
  
  % maj l'indice du profil selectionnee dans l'instance profil
  root.self  = set(root.self,'indice', indice );
  set( 0, 'UserData', root );
  plot_on_click;
  line_route;    
else
  disp('Error: profil not selected');
end

%%
clear pt;
clear indice;
clear X;
clear Y;
clear t;
clear dp;
clear year;
clear tag_but4;
clear tag_but5;
clear tag_but6;
clear self;
clear root;