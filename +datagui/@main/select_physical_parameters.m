function select_physical_parameters( self, select )
% 
% select : 0 -> more profiles
%          1 -> exclusive selection (uibunttongroup)
%          2 -> section
%
% $Id$

%% COPYRIGHT & LICENSE
%  Copyright 2009 - IRD US191, all rights reserved.
%
%  This file is part of datagui Matlab package.
%
%    datagui package is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    datagui package is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
%    USA

% erase panel if exist
%-------------------------------
if ~isempty( self.hdl_parameters_panel )
  delete( self.hdl_parameters_panel )
end

% keep only "primary" physical parameters, not <PARAM>_CAL, _ADJUSTED, ...
% -----------------------------------------------------------------------
params = get_primary_key(self);

% common uipanel
% --------------
self.hdl_parameters_panel = uibuttongroup('Title','Parametres',...
  'tag', 'parametres',...
  'parent', self.hdl_figure,...
  'FontSize', 8,...
  'Units', 'pixels',...
  'Position', [595 155 100 290]);

% display radio parameters
% ------------------------
for i=1:length( params )
  if i==1
    default_value = 1;
  else
    default_value = 0;
  end
  uicontrol('Style','Radio',...
    'parent', self.hdl_parameters_panel,...
    'String', params{i},...
    'Value', default_value,...  % Selectionne par defaut
    'Tag', ['radio_' params{i}],...
    'pos', [10 270-i*20 85 20],...
    'HandleVisibility', 'on');
  
end

switch select
  
  % case of more profiles
  % ----------------------
  case 0
     set(self.hdl_parameters_panel, ...
       'Callback', {@radio_parameter_callback, self});
    
    % case with climatology (Levitus)
    % -------------------------------
  case 1
    set(self.hdl_parameters_panel, ...
      'SelectionChangeFcn', {@radio_button_group_parameter_callback, self});
    
    % case of ploting section
    % -------------------------
  case 2
    set(self.hdl_parameters_panel, ...
      'SelectionChangeFcn',{@select_section, self});
    
  otherwise
    warning ('datagui:select_physical_parameters', ...
      'parameters selection, wrong input argument select: %d', select);
    
end

% callbacks (nested functions)
% ----------------------------
  function radio_parameter_callback(src, evnt, self) %#ok<INUSD>
    disp( 'callback radio_parameter_callback inside choix_parameters not yet implemented');
  end

  function radio_button_group_parameter_callback(src, evnt, self) %#ok<INUSD>
    disp( 'callback radio_button_group_parameter_callback inside choix_parameters not yet implemented');
  end
  function select_section(src, evnt, self) %#ok<INUSD>
    disp( 'callback select_section inside choix_parameters not yet implemented');
  end

end