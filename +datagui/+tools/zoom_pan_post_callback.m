% Callback function run when zoom or pan action finishes: redraw axes
% bug: this function don't work inside a class as a method, hgfeval
% run an exeption in line 63
%--------------------------------------------------------------------
function zoom_pan_post_callback(src, evnt, obj)

% get datagui.main hdl_axe private property
nc = obj.getPropValue('nc');
ax = obj.getPropValue('hdl_axe');

% get datagui.main hdl_popup_map private property as a struct
popup_map = get(obj.getPropValue('hdl_popup_map'));
markersize = get(obj.getPropValue('hdl_popup_markersize'));


limx =  get(evnt.Axes,'Xlim');
limy =  get(evnt.Axes,'ylim');
xmin = limx(1); xmax = limx(2);
ymin = limy(1); ymax = limy(2);

% Positionning the right axes (set map current axe)
% -------------------------------------------------
axes(ax);

if popup_map.Value == 2
  proj = 'Equidistant Cylindrical';
  m_proj(proj, 'lat', [ymin ymax], 'long',[xmin xmax]);
  
  % Contour de cote detaille
  % ------------------------
  m_gshhs_i('patch',[.7 .7 .7]);
  m_grid('box','fancy');
  hold on;
  X = nc.Variables.LONX.data__;
  Y = nc.Variables.LATX.data__;
  m_line( X, Y, 'Color', 'r', 'Marker', '+',...
    'MarkerSize', markersize.Value, 'LineStyle', 'none');
end

