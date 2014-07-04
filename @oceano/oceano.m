function o = oceano( varargin )
% OCEANO constructor function for OCEANO object
% Use:  a = oceano(descriptor, current_value)
% Fields:
%   descriptor = string
%   date = date string (automatically set to current)
%   current_value = asset value ($)

% $Id: oceano.m 138 2007-08-17 17:46:34Z jgrelet $

% TODOS
% 1:
% Il n'est pas evident qu'il soit necessaire maintenant de garder les
% membres path et file dans la classe oceano, la mecanique etant dorenavant
% deleguee a la struct root
% A verifier si pas d'implications supplementaires

% 2:
%

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

switch nargin
  case 0  % create default object
    o.descriptor   = 'none';
    o.date         = date;
    o.visible      = 'on';
    o.type_file    = 'undef';  % ASCII, NetCDF, Excel, EDF, DROP, etc
    %o.ext          = '';
    o.path         = [pwd filesep];
    o.file         = 'no data';
    o.edit         = 'off';
    % data_0d  (equivalent des attributs globaux)
    % (ie CYCLE_MESURE, INSTITUT, INSTRUMENT, SHIP, CRUISE_START_DATE, etc)
    o.data_0d = hashtable;
    % data 1D (ie STATION_NUMBER, DAYD, LATX, LONX)
    o.data_1d = hashtable;
    o.backup_0d = hashtable;
    o.backup_1d = hashtable;
    % lit fichier codes ROSCOP
		% ########
    % changer l'attribution des couleurs, mettre eventuellement dans
    % fichier code_roscop ? Tester implication(s) avec scripts Perl !!!
    o.color = { 'b','r','k','g','y','c','m','b','r','k','g','y','c','m','b','r','k','g','y','c','m' };
    o = class(o, 'oceano');
  case 1
    if( isa(varargin{1}, 'char'))
      o = oceano();   % default constructor
      o.type_file = varargin{1};      
    elseif( isa(varargin{1}, 'oceano')) % copy constructor
      o = varargin{1};
    else
      error('Wrong input argument');
    end
  otherwise
    error('Wrong number of input arguments');
end

