% getButtonMotionCallback

% $Id: getButtonMotionCallback.m 2 2005-10-12 09:35:32Z jgrelet $

% recupere la struct root dans le champ UserData de main_fig
root = get(0, 'UserData' ); 
% recupere les valeurs limx et limy stockees dans les buton 2 et 3
limx = get(findobj( 'Tag', 'tag_but2' ), 'UserData' );   
limy = get(findobj( 'Tag', 'tag_but3' ), 'UserData' );   

% recupere les handles d'affichage des coordonnees
tag_but1  = findobj( 'Tag', 'tag_but1' );
tag_but2  = findobj( 'Tag', 'tag_but2' );
tag_but3  = findobj( 'Tag', 'tag_but3' );
tag_but4  = findobj( 'Tag', 'tag_but4' );

year = get( get( root.self, 'data_1d' ), 'REFERENCE_DATE_TIME' );
year = str2double({year(1:4)});

pt = get( findobj( 'Tag', 'axe_route'), 'CurrentPoint' );
t = [pt(1,1) pt(1,2)];

% suivant le type de route a tracer (lon/lat, temps/lat et temps/lon
% on test si le curseur est dans le cadre, si oui, on affiche les
% coordonnees.
switch root.route_value
  case 1
    set(tag_but1, 'Visible', 'off');
    set(tag_but4, 'Visible', 'off');
    try
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
      if limx(1) < t(1) & t(1) < limx(2) & ...
          limy(1) < t(2) & t(2) < limy(2)
        set( tag_but2, 'string', dd2dm(t(1), 1));
        set( tag_but3, 'string', dd2dm(t(2), 0));
      end
    catch
      disp( 'Error in getButtonMotionCallback' );
    end

  case 2
    set(tag_but1, 'Visible', 'on');
    if limx(1) < t(1) & t(1) < limx(2) & ...
        limy(1) < t(2) & t(2) < limy(2)
      set( tag_but1, 'string', to_date(year, t(1), 's'));
      set( tag_but2, 'string', num2str(t(1)));
      set( tag_but3, 'string', dd2dm(t(2), 0));
    end

  case 3
    set(tag_but1, 'Visible', 'on');
    if limx(1) < t(1) & t(1) < limx(2) & ...
        limy(1) < t(2) & t(2) < limy(2)
      set( tag_but1, 'string', to_date(year, t(1), 's'));
      set( tag_but2, 'string', num2str(t(1)));
      set( tag_but3, 'string', dd2dm(t(2), 1));
    end

end

%%
clear year pt t limx limy root;
clear tag_but1 tag_but2 tag_but3 tag_but4;

