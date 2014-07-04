function [hl1,ax2,ax3] = multiPlotX(varargin)
% multiPlotX  create floating x-axis for multi-parameter plot
% =========================================================================
% $Id: multiPlotX.m 272 2007-04-20 09:24:20Z jgrelet $
%
% Usage: 
%   [h1,ax2,ax3] = multiPlotX(x,y)
%   [h1,ax2,ax3] = multiPlotX(x,y,'PropertyName',PropertyValue,...)
%
% Description:
%   This Matlab function creates a floating x-axis for mutli-parameter
%   plots with different units on the same figure. For example, in oceanography,
%   it is common to plot temperature, salinity, and density versus depth.
%   Uicontrol (popupmenu) are are generated dynamically for each parameter
%
% Input:
%   A minimum of two parameters is required. The first and second parameters are
%   the x,y pairs to plot. 
%   Properties values (optional) are:
%   'style'     = 'r+'   (defaults to 'k-' solid black). 
%   'label'     = string
%   'name'      = string/
%   'handle'    = parent handle (defauts to gcf )
%   'connected' = 'on|off' (defauts to off) specifies if a small thin black
%                 line should be plotted under normal plot 
%   'tag'       = string (defauts to 'MULTIPLOTX')
%
% Output:
%   [line_handle, axe_handle, floating axe handle]
%
%
% Author:
%   Original floatAxisX:        Blair Greenan
%   Adapted multiPlotX version: Jacques Grelet
% =========================================================================
% $Id: multiPlotX.m 272 2007-04-20 09:24:20Z jgrelet $

%% Initialisation
dplot = 0;
lstyle = 'k-';  
handle = gcf;
xlbl = [];
tag  = 'MULTIPLOTX';

%% Test le nombre d'arguments 
if( nargin < 2)
  error('datagui:graphics:multiPlotX', 'not enough input argument');
end  

%% Analyse les arguments par couples 'property', value
x = varargin{1};
y = varargin{2};
property_argin = varargin(3:end);
while length(property_argin) >= 2,
  property = property_argin{1};
  value    = property_argin{2};
  property_argin = property_argin(3:end);
  switch lower(property)
    case 'style'
        lstyle = value;
    case 'label'
        xlbl = value;
    case 'handle'
        handle = value;
    case 'connected'
        dplot = value;
    case 'tag'
        tag = value;        
    otherwise
        error(datagui:graphics:multiPlotX, 'Unknow property: %s', property);
  end
end

if( strcmp(dplot,'on' ) )
  dplot = 1;
else 
  dplot = 0;
end

% get childs axes handles from handle
allAxes = get_handle(handle,'axes');
if allAxes == 0 
  error('datagui:graphics:multiPlotX', 'no axes child handle');
end
% get position of axes
ax1Pos = get(allAxes(length(allAxes)),'position');

% rescale and reposition all axes to handle additional axes
for ii = 1:length(allAxes)-1
   if (rem(ii,2)==0) 
      % even ones in array of axes handles represent axes on which lines are plotted
      set(allAxes(ii),'Position',[ax1Pos(1) ax1Pos(2)+0.05 ax1Pos(3) ax1Pos(4)-0.05])
   else
      % odd ones in array of axes handles represent axes on which floating x-axss exist
      axPos = get(allAxes(ii),'Position');
      set(allAxes(ii),'Position',[axPos(1) axPos(2)+0.05 axPos(3) axPos(4)])
   end
end
% first axis a special case (doesn't fall into even/odd scenario of figure children)
set(allAxes(length(allAxes)),'Position',[ax1Pos(1) ax1Pos(2)+0.05 ax1Pos(3) ax1Pos(4)-0.05])
ylimit1 = get(allAxes(length(allAxes)),'Ylim');

% get new position for plotting area of figure
ax1Pos = get(allAxes(length(allAxes)),'position');

% axis to which the floating axes will be referenced
ref_axis = allAxes(1);
refPosition = get(ref_axis,'position');

% overlay new axes on the existing one
% et fait reference au pere (uipanel)
ax2 = axes('Position',ax1Pos,'parent',handle);

% plot data and return handle for the line
if( dplot == 1 ) 
  plot(x,y,'k-');
  hold on;
end
hl1 = plot(x,y,lstyle);
% permettra de retrouver la ligne par la suite, par defaut 'MULTIPLOTX'
set(hl1,'Tag',tag);
% make the new axes invisible, leaving only the line visible
%set(ax2,'visible','off','ylim',ylimit1,'Tag',['AXES_' cle])
set(ax2,'visible','off','ylim',ylimit1);

% set the axis limit mode so that it does not change if the
% user resizes the figure window
set(ax2,'xLimMode','manual')

% set up another set of axes to act as floater
ax3 = axes('Position',[refPosition(1) refPosition(2)-0.05 refPosition(3) 0.01]);
% display only X axis
set(ax3,'box','off','ycolor','w','yticklabel',[],'ytick',[],...
        'parent',handle);
set(ax3,'XMinorTick','on','color','none','xcolor',get(hl1,'color'));

% label the axis
if (nargin > 3)
   xlabel(xlbl)
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [hdl] = get_handle( handle, type )
%GET_HANDLE
%
%[hdl] = get_handle( handle, type ) return all childrens
% from object 'handle' with type 'type' 

hdl = [];
hd = get(handle,'children');
h = get(get(handle,'children'),'type');
indice = find( strcmp( h, type ));
if isempty(indice)
  return
end 
hdl = hd(indice);



