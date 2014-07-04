function [C1,hl] = contouring(varargin)
% contouring   low level contouring function 
% =========================================================================
% $Id: contouring.m 162 2011-09-02 12:36:13Z jgrelet $
%
% Usage:
%   contouring( varargin )
%
% Description:
%   Matlab fonction for low level contouring with user select contour method
%
% Input:
%   - Method:       coutouring method, pcolor (default) or contourf
%   - Vertical:     vertical scale, one vector [0 250] or 2 vectors 
%                   [0 250;250 750], use subplot.
%   - horizontal:   vector of X data
%   - Pas:          secondary contour step, draw with bold line 
%   - VAR:       	  ...
%   - VARX:         ...
%   - VARY:         variables to be plotted
%   - interpolVert: vertical interpolation step, needed with contourf
%  
%
% Output:
%   Return figure handle
%
% Optionnals parameters :
% 
%   - interpolHoriz:  Insertion des labels ('auto','manuel','off')
%
% Exemple:
%
% contouring('method', methode, 'vertical', vertical(i,:), ...
%            'VAR', VAR, 'VARX', VARX, 'VARY', VARY, 'level', level, ... 
%            'pas', pas, 'interpolVert', interpol);
%
%
% $Id: contouring.m 162 2011-09-02 12:36:13Z jgrelet $

%% analyse properties arguments
% -----------------------------
property_argin = varargin(1:end);
while length(property_argin) >= 2,
  property = property_argin{1};
  value    = property_argin{2};
  property_argin = property_argin(3:end);
  
  switch property
    case 'method'
      method = value;
    case 'vertical'
      vertical = value;
    case 'horizontal'
      horizontal = value;
    case 'VAR'
      VAR = value;
    case 'VARX'
      VARX = value;
    case 'VARY'
      VARY = value;
    case 'level'
      level = value;
    case 'pas'
      pas = value;
    case 'interpolVert'
      interpolVert = value;
    case 'interpolHoriz'
      interpolHoriz = value;
    otherwise
      error('datagui:coutouring','Unknow property : "%s"',property);
  end
end

%% select method for coutour
% --------------------------
switch method

  case 'pcolor'

    [nx,ny] = size(VARY);
    pcolor( ones(ny,1)*VARX', VARY', VAR');
    caxis([min(level) max(level)]);
    hold on;
    shading interp;
    %shading flat;
    [C1,hl] = contour(ones(ny,1)*VARX', VARY', VAR', level, 'k');
    if pas ~= 0 
      contour(ones(ny,1)*VARX', VARY', VAR', min(level):pas:max(level),...
              'k','Linewidth',2);
    end
    % redimensionne l'axe des Y
    % -------------------------
    set( gca, 'YDir', 'reverse', 'box', 'on' );
    set(gca,'YLim', vertical);

  case 'contourf'

    % on interpole verticalement les profils en appelant la fonction
    % InterpProfilVert
    % --------------------------------------------------------------
    [ProfilsInterpVert,zi] = InterpProfilVert(VARY,VAR,vertical,interpolVert);
    
    % on interpole horizontalement si interpolHoriz existe
    % et on stocke les variables à plotter
    % ----------------------------------------------------
    if (exist('interpolHoriz','var') == 1)
      [ProfilsInterpHoriz,xi] = ...
        InterpProfilHoriz(VARX,ProfilsInterpVert,horizontal,interpolHoriz);
      Profils = ProfilsInterpHoriz;
    else
      Profils = ProfilsInterpVert;
      xi = VARX;
    end
    
    % Graphique
    % ---------
    [C1,hl] = contourf( xi, zi, Profils', level );
    hold on;
    if (exist('pas','var') == 1)
      contour( xi, zi, Profils', min(level):pas:max(level), 'k','Linewidth',2);
    end
    caxis([min(level) max(level)]);
    set( gca, 'YDir', 'reverse', 'box', 'on' );

  case 'contour3D'

    % on interpole verticalement les profils en appelant la fonction
    % InterpProfilVert
    % --------------------------------------------------------------
    [ProfilsInterpVert,zi] = InterpProfilVert(VARY,VAR,vertical,interpolVert);

    % on interpole horizontalement si interpolHoriz existe et on stocke
    % les variables à plotter
    % -----------------------------------------------------------------
    if (exist('interpolHoriz','var') == 1)
      [ProfilsInterpHoriz,xi] = ...
        InterpProfilHoriz(VARX,ProfilsInterpVert, horizontal,interpolHoriz);
      Profils = ProfilsInterpHoriz;
    else
      Profils = ProfilsInterpVert;
      xi = VARX;
    end

    % Graphique
    % ---------
    [C1,hl] = contour3( xi, zi, Profils' );
    surf(xi, zi, Profils','FaceColor','interp','FaceLighting','phong ');
    camlight headlight;
end

% end of contouring


%%-----------------------------------------------------------------
% Fonction qui interpole verticalement les profils VAR sur les niveaux
% choisis
% -----------------------------------------------------------------
  function [ProfilInterpVert,zi] = InterpProfilVert(VARY,VAR,vertical,interpolVert)

    % niveaux verticaux sur lesquels on veut interpoler
    % -------------------------------------------------
    zi = [min(vertical),min(vertical)+1:interpolVert:max(vertical)+1];
    
    % initialisation de la matrice des profils que l'on va interpoler
    % ---------------------------------------------------------------
    [nx,ny] = size(VAR);
    ProfilInterpVert = NaN*ones(nx,length(zi));
    
    % on interpole chaque profil verticalement
    % ----------------------------------------
    for k=1:nx
      
      % pour chaque profil on ne prend que les valeurs finies
      % -----------------------------------------------------
      Profil = VAR(k,isfinite(VAR(k,:))==1);
      z = VARY(k,isfinite(VAR(k,:))==1);
      
      % cherche a avoir un vecteur strictement croissant
      % ------------------------------------------------
      while isempty(find(diff(z)<=0,1)) == 0
        ind = find(diff(z)<=0);
        z(ind+1) = [];
        Profil(ind+1) = [];
      end
      
      % interpolation
      % -------------
      ProfilInterpVert(k,:) = interp1(z,Profil,zi,'linear');
    end
  end

  %%--------------------------------------------------------------------
  % Fonction qui interpole horizontalement les profils ProfilsInterpVert
  % sur les niveaux choisis
  % --------------------------------------------------------------------
  function [ProfilInterpHoriz,xi]=InterpProfilHoriz(VARX,ProfilsInterpVert,horizontal,interpolHoriz)
 
    % niveaux verticaux sur lesquels on veut interpoler
    % -------------------------------------------------
    xi = min(horizontal):interpolHoriz:max(horizontal);
    
    % initialisation de la matrice des profils que l'on va interpoler
    % ---------------------------------------------------------------
    [nx,nz] = size(ProfilsInterpVert);
    ProfilInterpHoriz = NaN*ones(length(xi),nz);
    
    % on interpole chaque profil verticalement
    % ----------------------------------------
    for k=1:nz
      
      % pour chaque profil on ne prend que les valeurs finies
      % -----------------------------------------------------
      Profil = ProfilsInterpVert(isfinite(ProfilsInterpVert(:,k))==1,k);
      x = VARX(isfinite(VARX(k,:))==1);
      
      % interpolation
      % -------------
      ProfilInterpHoriz(:,k) = interp1(x,Profil,xi,'linear');
    end

  end

end








