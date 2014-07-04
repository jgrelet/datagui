% addpathdef_datagui
% Initialize subdirectories for datagui to matlabpath
% use rmpathdef_datagui to remove subdirectories added when quit
% from matlabpath
%
% $Id: addpathdef_datagui.m 188 2012-10-03 14:25:01Z jgrelet $

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

s = what('datagui/tags/V1_0');
pathHome = s.path;
% cname = computer;
p = [pathsep,...
     pathHome,[filesep 'util' pathsep],...
     pathHome,[filesep 'common' pathsep],...
     pathHome,[filesep 'callback' pathsep]
    ];
    
version = str2double(version('-release'));
if version < 14 
  path( [pathdef, p] );
else
  addpath( p, '-END' );
end

rehash;

clear s p version pathHome;
