function s = section( varargin )
% SECTION  constructeur de la classe section
% trace une coupe par paramètre ROSCOP, eg TEMP,PSAL,etc
% =========================================================================
% $Id: section.m 120 2007-02-02 13:42:20Z jgrelet $
%
% Usage:
%   s = section( varargin );
%   set(s, 'property', value, ...);
%   plot(s);
%
% Description:
%   Fonction Matlab de tracé de coupes/sections basé sur datagui
%
% Input:
%   Au minimum 3 paramètres sont requis :
%   - axe de la coupe: 'LATX','LONX' ou 'DAYD'
%   - code ROSCOP du paramètre à tracer: 'TEMP','PSAL,'DOX2', etc...
%   - profondeur max
%   - vecteur de l'echelle et lignes de contour
%   - pas des lignes de contour secondaire
%
% Exemple:
% section('LATX','PSAL')
% section('LATX','PSAL','Profils',[5:25])
% section('LATX','TEMP','Profils',[5:25],'Pmax',500)
% section('LATX','TEMP','Profils',[5:25],'Pmax',500,...
%            'Interpolation',[0:1:30])
% section('LATX','TEMP','Profils',[5:25],'Pmax',500,...
%            'Interpolation',[0:1:30],'Pas',5)


% TODOS:
% changer STATION_NUMBER en PROFIL_NUMBER
% section constructor function for section object
%
% $Id: section.m 120 2007-02-02 13:42:20Z jgrelet $

% TODOS

if isempty(nargin)
  i = init_struct;
end

switch nargin
  case 1
    if( isa(varargin{1}, 'section')) % copy constructor
      s = varargin{1};
    else
      error('Wrong input argument');
    end
  otherwise
    %% Analyse les arguments par couples 'property', value
    s = init_struct;
    s.var_x = varargin{1};
    s.code_roscop = varargin{2};
    property_argin = varargin(3:end);
    while length(property_argin) >= 2
      property = property_argin{1};
      value    = property_argin{2};
      property_argin = property_argin(3:end);
      switch lower(property)
        case 'liste_profils'
          s.liste_profils = value;
        case 'var_x'
          s.var_x = value;
        case 'var_y'
          s.var_y = value;
        case 'var'
          s.var = value;
        case 'code_roscop'
          s.cle = value;
        otherwise
          error(['Propriété inconnue: ' property ' !!!']);
      end
    end
end

s = class(s,'section');

function s = init_struct

s.liste_profils = [];
s.code_roscop = 'TEMP';
s.var = [];
s.var_x =[];
s.var_y = [];
s.popup_contour_min = 1;
s.popup_contour_max = 1;
s.contour_min = 1;
s.contour_max = 1;
s.pmax_lbl    = {'50','100','250','500','1000'};
s.pmax_value  = 3;
s.pmin_lbl    = {'0','5','10','50','100','200'};
s.pmin_value  = 1;
s.pas_lbl    = {'aucun','1','2','3','4','5','6','7','8'};
s.pas_value  = 1;
s.pas_interpol_lbl    = {'0.5','1','2','3','4','6'};
s.pas_interpol_value  = 1;
s.M_contour_min = {};
s.M_contour_max = {};
s.titre = 1;
s.Clabel_value = 3;
s.Clabel = 'none';
s.ProfilSpec = 'on';
s.ProfilSpec_value = 0;
s.methode_value = 1;
s.methode = 'contourf';
s.sub_plot_lbl = {'aucun','100','200','250','500'};
s.sub_plot_value = 1;
s.interpolation_lbl = {'0.5','1','2','4','10','20','40','50','100'};
s.interpolation_value = 5;
s.geo = 'off';
s.geo_value = 0;
s.VARX = [];
