% $Id: datagui_startup.m 138 2007-08-17 17:46:34Z jgrelet $

%% COPYRIGHT & LICENSE
% Copyright 2007 Jacques Grelet - IRD, all rights reserved.
%
% This file is part of Datagui.
%
%    Datagui is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    Datagui is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with Datagui; if not, write to the Free Software
%    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

root_datagui = which ('datagui') ;
[root_datagui, tmp, tmp] = fileparts (root_datagui) ;
addpath (fullfile (root_datagui, 'common')) ;
addpath (fullfile (root_datagui, 'callback')) ;
addpath (fullfile (root_datagui, 'util'))   ;

