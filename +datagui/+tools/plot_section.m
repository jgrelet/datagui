function F = plot_section( varargin )
% plot_section  trace une section par paramètre ROSCOP, eg TEMP,PSAL,etc
% =========================================================================
% $Id: plot_section.m 270 2014-09-14 17:44:10Z jgrelet $
%
% Usage:
%   plot_section( varargin )
%
% Description:
%   Fonction Matlab de tracé de section basée sur datagui
%
% Input:
%   Au minimum 2 paramètres sont requis :
%    - axe de la section: 'LATX','LONX' ou 'DAYD'
%    - code ROSCOP du paramètre à tracer: 'TEMP','PSAL,'DOX2', etc...
%
% Output:
%   Retourne le handle de la figure
%
% Paramètres optionnels:
%   - Profils:     vecteur des profils utilisés pour la section
%   - Methode:     methode de contour utilisée, pcolor (par defaut)
%                  ou contourf
%   - Interpol:    pas d'interpolation, obligatoire avec contourf
%   - Vertical:    echelle verticale, un vecteur [0 250]
%                  ou 2 vecteurs [0 250;250 750] pour un tracé avec
%                  subplot
%   - Contour:     vecteur de l'echelle et lignes de contour
%   - Pas:         pas des lignes de contour secondaire, 0 pour none
%   - Padding      Fill missing surface value with first valid value, usefull
%                  to get interpolation in the first 10m and plot
%   - Titre:       Titre de la figure (string)
%   - Label:       affiche les labels en nombres décimaux ('off') ou
%                  en degrés ('on')
%   - ClabelSpec:  Insertion des labels ('auto','manuel','off')
%   - ProfilSpec:  Visualise les numéros de profils ('on','off')
%   - Print:       Imprime la figure, recoit une cellule contenant le type
%                  d'imprimante et le nom de fichier {'printer','filename'}
%
% Exemple:
%
% plot_section('LATX','PSAL')
% plot_section('LATX','PSAL','Profils',[5:25])
% plot_section('LATX','TEMP','Profils',[5:25],'Vertical',[0 500])
% plot_section('LATX','TEMP','Profils',[5:25],'Methode','contourf','Interpol',10,...
%   'Vertical',[0 500],'Contour',[0:1:30])
% plot_section('LATX','TEMP','Profils',[5:25],'Methode','contourf','Interpol',10,...
%   'Vertical',[0 500],'Contour',[0:1:30],'Pas',5)
% plot_section('LATX','TEMP','Profils',[5:25],'Methode','contourf','Interpol',10,...
%   'Vertical',[0 500],'Contour',[0:1:30],'Pas',5,'ProfilSpec','on','ClabelSpec','on')
% plot_section('LATX','TEMP','Profils',[5:25],...
%   'Vertical',[0 500],'Contour',[0:1:30],'Pas',5,'ProfilSpec','on','ClabelSpec','on')
% plot_section('LATX','TEMP','Profils',[5:25], 'Vertical',[0 500],...
%   'Contour',[0:1:30],'Pas',5,'Print',{'jpeg','section/mafigure'}
% h = plot_section(...)
% plot_section(axe_handle,...)
%
% TODOS:
% interp1 et 2, voir commentaires Yves (entre min et max) puis chgt d'axe
% aux valeurs rondes
% changer STATION_NUMBER en PROFIL_NUMBER
% detecter automatiquement DEPH et PRES
%
% Pour les fichiers OceanSITES, et dans un soucis de retro-compatibilite,
% les variables TIME, LATITUDE, LONGITUDE et DEPTH sont tarduite en 
% DAYD, LATX, LONX et DEPH dans les attributs data_1d et data_2d 
% de la classe profil.
% Pour utiliser les variables TIME, LATITUDE, LONGITUDE et DEPTH
% disponibles dans le "base workspace", utiliser new_plot_section

%% Initialisation
% ---------------
VAR = []; VARX = []; VARY = [];profil = [];
H = []; % vecteur du/des handle(s) des axes
j=1;i=1;
profilSpec = 'off';   % trace la position des profils
clabelSpec = 'off';
label      = 'off';
padding    = 'off';
methode    = 'pcolor';

%% Test le nombre d'arguments
%----------------------------
if( nargin < 2)
  error('plot_section nécessite au minimum 2 paramètres')
end

%% Analyse des arguments
% ----------------------

% si le premier argument de type handle, a implementer
% ----------------------------------------------------
if ishandle(varargin{1})
  %
else
  %
end

% premier argument obligatoire, la variable en X, soit DAYD,LATX ou LONX
% -----------------------------------------------------------------------
varx = varargin{1};
vary = PRES;
varz = varargin{2};

% deuxieme argument obligatoire, le parametre a tracer via son code ROSCOP
% ------------------------------------------------------------------------
code_roscop = varargin{2};

% puis on parcourt les arguments par couple 'propriete', 'valeur'
% ---------------------------------------------------------------
property_argin = varargin(3:end);
while length(property_argin) >= 2,
  property = property_argin{1};
  value    = property_argin{2};
  property_argin = property_argin(3:end);
  switch lower(property)
    case 'methode'
      methode = value;
    case 'interpol'
      interpol = value;
    case 'profils'
      liste_profils = value;
    case 'vertical'
      vertical = value;
      [lastPlot rows] = size(vertical);  % indice du dernier subplot
    case 'contour'
      level = value;
    case 'pas'
      pas = value;
    case 'label'
      label= value;
    case 'padding'
      padding = value;
    case 'profilspec'
      profilSpec = value;
    case 'clabelspec'
      clabelSpec = value;
    case 'print'
      if (iscell(value) && length(value) == 2)
        printer  = value{1};
        fileName = value{2};
      else
        error('Propriété mal formée: "%s"',property);
      end
    case 'titre'
      titre = value;
    otherwise
      error('Propriété inconnue: "%s"',property);
  end
end

if( strcmp(methode,'pcolor' ) )
  methode = 'pcolor';
elseif (~exist('interpol','var') == 1)
  error('Il faut définir le vecteur d''interpolation avec contourf');
end




% %###### A REPRENDRE !!!!!!!
% % la coupe n'est faites qu'en LATITUDE on doit pouvoir faire en fonction de
% % DAYD
% if( ~isa( vary,'double') )   % a verifier
%   vary = get(data_2d(self), 'DEPH');
%   yr = get(r, 'DEPH');  % pour y roscop
%   y_cle = 'DEPH';
% end
% if( ~isa( vary,'double') )   % a verifier
%   vary = get(data_2d(self), 'HEIG');
%   yr = get(r, 'HEIG');  % pour y roscop
%   y_cle = 'HEIG';
% end

%% Récupère les informations des codes ROSCOP en fonction de la cle (code)
xr = get(r, varx);        % pour x roscop LATX, LONX ou DAYD
vr = get(r, code_roscop);  % pour variable roscop
% pour mode auto
vr.scale = [floor(min(min(var))) ceil(max(max(var))); vr.scale];

%% initialise qq valeurs par défaut si non définie
if (~exist( 'liste_profils','var') == 1)
  liste_profils = PROFILE; % trace tous les profils par défaut
end
if (~exist( 'vertical','var') == 1)
  vertical = [min(min(vary)) max(max(vary))];  % #####################
end
if (~exist( 'level','var') == 1)
  level = vr.scale(1,:);                       %  mode auto
end

if( length(liste_profils) > length(PROFILE) )
  disp('Erreur, nombre de profils sélectionnés > aux profils dispo' );
  return;
end;

%% Création des matrices aux profils selectionnés
while( length(PROFILE(i:end)) > 0 )
  %a = profils(i);
  %b = liste_profils(j);
  if( liste_profils(j) == PROFILE(i) )
    %disp(['Traite profil: ' num2str(profils(i))]);
    profil = [profil,PROFILE(i)];
    VARX = [VARX;varx(i)];
    VAR  = [VAR;var(i,:)];
    VARY = [VARY;vary(i,:)];
    i=i+1;
    j=j+1;
    if( j > length( liste_profils ) )
      break;
    end
  else
    if( PROFILE(i) > liste_profils(j) )
      j=j+1;
      if( j > length( liste_profils ) )
        break;
      end
      continue
    else
      i=i+1;
    end
  end;
end;


%% Positionnement de la figure
F = figure;
if lastPlot > 1
  p = get(F,'Position');
  p(2)=p(4)+p(2)-p(3)/.75;
  p(4)=p(4)/.75;
  set(F, 'Position', p);
end


%% padding pour boucher les trous
switch padding
  case 'on'
    % backup variables
    VAR_OLD = VAR;
    VARY_OLD = VARY;
    
    % create new variables to zero with one more column
    VAR  = zeros(size(VAR_OLD,1),size(VAR_OLD,2)+1);
    VARY = zeros(size(VARY_OLD,1),size(VARY_OLD,2)+1);
    
    % duplicate first colum of VAR
    VAR(:,1) = VAR_OLD(:,1);
    % and copy original VAR
    VAR(:,2:size(VAR,2)) = VAR_OLD;

    % copy original VARY
    VARY(:,2:size(VARY,2)) = VARY_OLD;
    
    clear VAR_OLD VARY_OLD;
end


%% Contourage
for i = 1 : lastPlot
  
  % création d'un vecteur de handle_axe
  % -----------------------------------
  H = [H;subplot(lastPlot,1,i)];        
  
  % call low level contouring with selected user variables 
  % ------------------------------------------------------
  [C1,hl] = contouring('method', methode, 'vertical', vertical(i,:), ...
            'VAR', VAR, 'VARX', VARX, 'VARY', VARY, 'level', level, ... 
            'pas', pas, 'interpolVert', interpol);
          
  % set tag on current axes
  % -----------------------
  set(gca, 'Tag', 'Tag_section');
  
  % change axes position
  % --------------------
  if (i == lastPlot && i > 1)
    set(H(i),'Position',[0.1300    0.1100    0.7750    0.42])
  end
end


%% Affichage des labels sur les axes
switch label
  case 'on'
    switch varx
      case 'DAYD'
        % 
        [tickx, labelx] = ticktemps(min(VARX), max(VARX), 1, min(VARX), 2);
      case 'LATX'
        % a modifier %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [tickx, labelx] = tickgeo(min(VARX), max(VARX), 1, min(VARX), 2, 0);
      case 'LONX'
        [tickx, labelx] = tickgeo(min(VARX), max(VARX), 1, min(VARX), 2, 1);
    end
    % maj le dernier axe avec les labels en degres
    for i = 1 : lastPlot
      set(H(i), 'Xtick', tickx, 'XtickLabel', labelx );
    end
end

%% Affichage des labels et titre
% le label en X uniquement sur le dernier axe (du bas)
xlabel(H(end), [varx ': ' xr.description  ' (' xr.unit ')']);
hyl = ylabel(H(end), {y_cle;yr.description});
if lastPlot > 1
  set(hyl, 'Units', 'normalized');
  pos = get(hyl, 'Position');
  set(hyl, 'Position', [pos(1) (pos(2)+1/lastPlot)]);
end
if (exist('titre','var') == 1)
  title(H(1), titre);
  %set(get(H(1),'Title'),'string',theTitle);
else
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ?? doit etre deplacé et passé sous forme de propriete 'Titre' ??
  %Laissé pour être affiché si l'utilisateur veux generer une nouvelle
  %fenêtre à partir de la ligne la Command Windows.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  title(H(1), {[get( get( self, 'data_0d'), 'CYCLE_MESURE') ...
    '  Profils: ' num2str(min(liste_profils)) ' - '...
    num2str(max(liste_profils))];...
    [code_roscop ': ' vr.description  ' (' vr.unit ')'] } );
end

%% colorbar
for i=1 : lastPlot
  hc = colorbar('peer', H(i));
  %colormap(jet(100));
  unitc = get(hc, 'Units');
  set(hc, 'Units', 'pixels');
  %pos_hc = get(hc, 'Position');
  %pos_hc_new = [pos_hc(1)*1.07 pos_hc(2) 20 pos_hc(4)];
  %set(hc, 'Position', pos_hc_new);
  set(hc, 'Units', unitc);
  set(hc,'Tag','Tag_section_colorbar')
  %posit = [.9 .1  .03 .7];
  %barcol( level,posit );
end

%% Ajout manuel des labels
% doit se faire obligatoirement avant l'affichage des numeros de
% profils sur l'axe superieur

switch clabelSpec
  case {'on','manual','manuel'}
    clabel(C1,hl,'manual','fontsize',7);
  case 'auto'
    clabel(C1,hl,'fontsize',7);
end


%% Affichage des positions de profils sur l'axe du bas

switch profilSpec
  case 'on'
    hold on;
    pos = get(H(end), 'position');
    axProfil = axes('position',[pos(1) pos(2)+pos(4) pos(3) .000001],'Tag','Tag_profil');
    % utilise sort(VARX) pour les coupes en longitude, est/ouest
    % car le vecteur doit etre croissant, monotone
    % correct bug, use profils instead profil JG fev 2008
    % ---------------------------------------------------
    if varx(find(PROFILE == profil(1))) < varx(find(PROFILE == profil(2)))
      set(axProfil, 'XLim', [min(VARX) max(VARX)], ...
        'XTick', sort(unique(VARX)),'XTickLabel', profil, ...
        'YTick', [], 'YColor', [1 1 1], 'Box', 'off', 'Fontsize', [6] );
      set(axProfil, 'Xaxislocation', 'top');
    else
      profil2=profil(end);
      for i=1:length(profil)-1
        profil2 = [ profil2, profil(length(profil) - i)];
      end
      set(axProfil, 'XLim', [min(VARX) max(VARX)], ...
        'XTick', sort(unique(VARX)),'XTickLabel', profil2, ...
        'YTick', [], 'YColor', [1 1 1], 'Box', 'off', 'Fontsize', [6] );
    end
    set(axProfil, 'Xaxislocation', 'top');
    % mets les ticks a l'exterieur du graphique
    %set(axProfil, 'tickdir', 'out');
    set(axProfil, 'TickLength', [0.005 0.025])
    hold off;
end

%% impression
if (exist('printer','var') == 1)
  switch printer
    case 'none'
      % on fait rien
      disp('Affichage à l''écran seulement');
    case {'jpeg','epsc2','png','tiff','pdf','bmp'}
      extension = ['-',num2str(min(min(vertical))),'-',...
        num2str(max(max(vertical))),'m-',code_roscop];
      cmd = ['print -f' ,num2str(F), ' -d', printer, ' ', fileName extension];
      disp(cmd);
      eval(cmd);
    case 'win'
      cmd = ['print -f' ,num2str(F), ' -d', printer];
      disp(cmd);
      eval(cmd);
    otherwise
      disp(['Driver d''impression: ', printer, ' inconnu']);
  end
  
end


