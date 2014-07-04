function root = init_config( m_filename, version )
%INIT_CONFIG Initialize le fichier de configuration
%
%   INIT_CONFIG(S1,S2) returns struct root saved in S1.mat file and S2 
%   internal version number. 
%   If file dosn't exist, create & save it in prefdir directory
%

% $Id: init_config.m 187 2012-09-12 13:09:40Z jgrelet $

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

root = struct([]);
config_file = [prefdir, filesep, m_filename, '.mat'];

% test si le fichier de config existe
% il existe un pb avec fopen qui retourne vrai meme si datagui.mat n'est
% pas present dans le repertoire (utilise alors le path, a voir)
config = fopen( config_file, 'r' );
if config == -1             % si pas de fichier, valeurs pas defaut
  root = init_struct( version );
  save(config_file, 'root');
else
  try
  load( config_file,'root' ); % sinon, on charge struct dans le workspace
  catch
    disp(['Warning, can''t load'  config_file]);
		datagui_closereq_callback;
  end  
  % si pas de champ version (wrong version) ou version differente
  % on reinitialize
  if ~isfield( root, 'version') || ~strcmp(root.version, version)
    root = init_struct( version );
    save(config_file, 'root');
  end
end;

% sauvegarde root dans le champs UserData de la figure racine (0)
set(0,'UserData', root );

% cas d'erreur si l'utilisation change de disque (cle USB -> disque dur
% par ex, self.path ne sera pas a jour et la lecture fichier genere une
% erreur
if ~exist( root.path, 'dir' )
  root.path = [pwd filesep]; 
end  

return;

%***********************************************************************
% function privee d'initialisation de la structure root 
%***********************************************************************
function root = init_struct( ver )

root.version          = ver;
root.matlab_ver       = version;
root.selectmode       = 'off';
% initialise les menus (popup) et leurs indices
root.files            = { 'no data'};
root.files_value      = 1;
root.selected_file    = [];
root.path             = pwd;
root.format           = {'dataGUI','XML','NetCDF','OceanSITES','ASCII'};
root.format_value     = 3;     % choix fichier NetCDF par defaut
root.ext              = '_ctd.nc';
root.type             = {'TIME SERIE','TSG','METEO','BATHYMETRIE',...
                         'CTD','XBT','ADCP','BOUTEILLES','RADIOSONDAGE'};
root.type_value       = 5;     % choix donn�es CTD par d�faut
root.axis             = {'DAYD','LATX','LONX'};
root.axis_value       = 1;
root.route            = {'LAT/LON','DAYD/LAT','DAYD/LON'};
root.route_value      = 1;
root.map              = {'NONE','M_MAP'};
root.map_value        = 1;
root.markersize_lbl   = {'1','2','3','4','6','8','10' };
root.markersize_value = 4;  % default
root.markersize       = 4;
root.markertype_lbl   = {'dot','cross','plus','stair', 'circle' };
root.markertype_value = 2;  % default
root.markertype       = '+';
root.type_trace       = {'Profil','Section','Multiple','TS'};
root.type_trace_value = 1; % trace les profils par defaut
% sauvegarde l'instance un cours
root.self             = [];
root.levitus          = 'off';
root.medianSize       = 0;
