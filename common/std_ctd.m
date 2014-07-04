function std_ctd( varargin )

%-----------------------------------------------------------------------------------------------------
%std_ctd aide a la validation des acquisition de ctd
% visualisation ecart-types capteurs en fonction du temps
%
% Usage:
%    std_ctd( varagin )
%
% Description
%
% Input
% au minimum:
% - code ROSCOP de chacun des deux paramètres à tracer
%
% Output
%
% Paramètres optionnels
%
%   - Depth:	profondeur jusqu'à laquelle on veut moyenner les profils
%   - Exlusion: 	0: on inclut tous les profils, y compris ceux qui ont des données seulement jusqu'à une profondeur inférieure à prof_moy
%		1: on inclut que les profils ayant des données au moins jusque cette profondeur
%   - nbprofils     nb de profils a tracer pour comparer au profil selectionne
%
%
%
% Exemple:
%
% std_ctd ('TE01','TE02')
% std_ctd ('PSA1','PSA2','nbprofils',7)
% std_ctd ('TE01','TE02','Depth',500,'Exclusion',1,'nbprofils',9)
%
%
%-----------------------------------------------------------------------------------------------------

%% Initialisation
depth     =  2000;
Exclusion =  0;
nbprofils =  3;

%% test le nombre d'arguments
if( nargin < 2)
  error('std_ctd nécessite au minimum 2 paramètres')
end

%% Analyse des arguments
% arguments obligatoires, les parametres a comparer via leur code ROSCOP
code_roscop1 = varargin{1};
code_roscop2 = varargin{2};
% puis on parcourt les arguments par couple 'propriete', 'valeur'
property_argin = varargin(3:end);
while length(property_argin) >= 2,
  property = property_argin{1};
  value    = property_argin{2};
  property_argin = property_argin(3:end);
  switch lower(property)
    case 'Depth'
      Depth = value;
    case 'Exclusion'
      Exclusion = value;
    case 'nbprofils'
      nbprofils = value;
    otherwise
      msg = sprintf( 'Propriété inconnue: "%s"',property);
      error(msg);
  end
end

%% cree la figure contenant les traces
% test si la figure n'existe pas
hdl = findobj( 'Tag', 'plot_std_ctd');
if isempty( hdl )
  hdl = figure( ...
    'Position', leftfig( 600, 500), ...
    'Color', get(0,'DefaultUIControlBackgroundColor'),...
    'HandleVisibility','on',...
    'name',['Comparaison des capteurs ' code_roscop1 ' - ' code_roscop2],...
    'MenuBar','figure',...
    'tag', 'plot_std_ctd' );
else
  % si la figure existe, on recupere son handle, evite de creer
  % plusieurs figure superposees et de recuperer des tableaux de handles !!!
  figure( hdl );
  cla reset;
  set(gca,'tag','axe_std_ctd');
end

%% definition des panels
hdl_plot = uipanel('Parent',hdl,'FontSize',8,...
  'Position',[0 0 .8 1]);
hdl_action = uipanel('Parent',hdl,'FontSize',8,...
  'Position',[.8 .0 .2 1],'Tag','Tag_hdl_std_ctd_action');
% affichage du popup dans le panel de droite
uicontrol('Parent',hdl_action,...
  'Style','text',...
  'Units','normalized',...
  'Position',[.15 .93 .75 .05],...
  'String','Depth',...
  'HorizontalAlignment','left');

uicontrol('Parent',hdl_action,...
  'Units','normalized',...
  'Position',[.15 .9 .75 .05],...
  'Style','popupmenu',...
  'String','250|500|1000|2000|4000',...
  'Value',4,...
  'Tag','popupmenu_action_select_std_ctd_depth',...
  'BackgroundColor','w',...
  'Callback',@callback_select_depth);


%% Recupere dans le champ UserData de l'élément racine 0 les variables
%  utiles pour l'application
root = get(0, 'UserData' );
self = root.self;
r    = roscop(self);

%profils = get(data_1d(self),'PROFILS');
dayd   = get(data_1d(self),'DAYD');
reference_date_time = get(data_1d(self),'REFERENCE_DATE_TIME')
data1  = get(data_2d(self), code_roscop1);
data2  = get(data_2d(self), code_roscop2);
A      = {'roscop1','roscop2'}

%% Récupère les informations des codes ROSCOP en fonction de la cle (code)
vr = get(r, code_roscop1);        % pour variable roscop data1 (normalement, data2 memes unites)

%Gestion des dates
year_base = str2num(reference_date_time(1:4));
DATES     = to_date(year_base,dayd,'numeric');
DATES     = datestr(DATES,0);

%% ecart-type de la difference des 2 capteurs
stddiff=sqrt((data1-data2).^2);

% on cree maintenant un axe dans le bon panel
hdl_axe = axes;
set(hdl_axe,'tag','axe_std_ctd');
set(hdl_axe,'parent',hdl_plot);
% on trace la ligne par rapport a l'axe courant
hdl_line_std_ctd = line(dayd, mean_depth(depth))
xlabel('DAYD')
ylabel(['Ecart-type difference capteurs ' code_roscop1 ' et ' code_roscop2])

disp('selectionner le profil a visualiser en détail')

%% mise en place du gestionnaire d'interruption: 
%   clic de la souris sur la ligne
set( hdl_line_std_ctd, 'tag', 'line_std_ctd',...
  'ButtonDownFcn', {@getButtonDownCallback_plotProfils},'UserData',A);

%% Moyenne sur la profondeur
  function [std_diff_ave] = mean_depth( depth )
    % !!RQ1!! Pour faire la moyenne, y a t il mieux que de faire une boucle?
    % calcul
    for iprof=1:length(dayd)
      depthmax(iprof) = max(find(~isnan(squeeze(data1(iprof,:)))));
      if Exclusion == 0
        std_diff_ave(iprof) = mean(stddiff(iprof,1:min(depth,depthmax(iprof))));
      else
        if depth>depthmax(iprof)
          std_diff_ave(iprof) = NaN;
        else
          std_diff_ave(iprof) = mean(stddiff(iprof,1:min(depth,depthmax(iprof))));
        end;
      end;
    end;
  end

%% callback, modifie la profondeur max (Depth) par popup
  function callback_select_depth(obj, eventdata)
    value = get(findobj('Tag','popupmenu_action_select_std_ctd_depth'),'Value');
    switch value
      case 1
        depth = 250;
      case 2
        depth = 500;
      case 3
        depth = 1000;
      case 4
        depth = 2000;
      case 5
        depth = 4000;
    end
    % on retrace la ligne, attention l'ordre des lignes suivantes est tres
    % important
    h = findobj('Tag', 'axe_std_ctd');
    cla(h,'reset');   
    hdl = line(dayd, mean_depth(depth));
    set(gca,'tag','axe_std_ctd','parent',hdl_plot);
    set( hdl, 'tag', 'line_std_ctd',...
      'ButtonDownFcn', {@getButtonDownCallback_plotProfils},'UserData',A);
   
  end

%% les fonctions imbriquees pour les callback_<action>(nested function)
% Trace des profils d'ecart-type autour d'un profil particulier 
% selectionne a la souris
% Il faut maintenant faire la meme chose que dans la fenetre pricipale
% pour mettre nbprofil dans un popup
% -----------------------------------------------------------------------
  function getButtonDownCallback_plotProfils(obj, eventdata)
    pt = get( findobj( 'Tag', 'axe_std_ctd'), 'CurrentPoint' );
    sel = [pt(1,1) pt(1,2)];
    
    [Y,isel]=(min(abs(sel(1)-dayd)))
    %Preparation trace
    figure;
    selprof=max(1,isel-floor(nbprofils/2)):min(isel+floor(nbprofils/2),length(dayd))
    %Gestion de l'echelle horizontale
    %pour que ts les profils de la figure soient traces sur la meme échelle
    %horizontale
    stddiff=sqrt((data1-data2).^2);% ecart-type de la difference des 2 capteurs: je suis obligee de le recalculer??
    stddiff_zoom=stddiff(selprof,:);
    stddiff_zoom=reshape(stddiff_zoom,size(stddiff_zoom,1)*size(stddiff_zoom,2),1);
    valmax=nanmax(stddiff_zoom);
    clear stddiff_zoom
    %fin
    isubplot=0;
    %Trace
    for iprof=selprof(1):selprof(end)
      isubplot=isubplot+1;
      axes('Position',[.04+(isubplot-1)*(1/nbprofils-.01) .1 1/nbprofils-.04 .8])
      h=plot(stddiff(iprof,:),-[1:size(data1,2)])
      set(gca,'ylim',[-depth 0],'Xlim',[0 valmax],'FontSize',8,'FontWeight','Bold')
      if isubplot>1
        set(gca,'YTickLabel',[])
      else
        ylabel('profondeur (m)')
      end;
      if iprof~=isel
        set(gca,'XTicklabel',[])
      else
        xlabel(vr.unit)
        title(DATES(isel,:),'FontSize',8,'FontWeight','Bold')
      end;
      if iprof==isel
        set(h,'color','r')
      else
        set(h,'color','b')
      end;
    end; %for iprof
    % Titre general de la page
    ax = axes('Position',[.05 .96 .9 .03],'Box','on','XTick',[],'YTick',[]);
    text(.5,.5,['Ecart-type entre les 2 capteurs'],'FontSize',12,'Units', 'Normalized', 'HorizontalAlignment', 'Center');

%% Trace des profils primaires (rouge) et secondaire (bleu)
    % --------------------------------------------------------
    % disp('selectionner la profondeur minimale a analyser')
    % profmin=ginput;profmin=-profmin(2)
    % disp('selectionner la profondeur maximale a analyser')
    % profmax=ginput;profmax=-profmax(2)
    disp('selectionner la tranche de profondeurs a analyser')
    ax=mousebox
    profmin=-ax(4); profmax=-ax(3);
    figure;
    isubplot=0;
    %je cale les echelles horizontales en fct de data1
    valmax=nanmax(data1(isel,profmin:profmax))
    valmin=nanmin(data1(isel,profmin:profmax))
    %Trace
    for iprof=selprof(1):selprof(end)
      isubplot=isubplot+1;
      axes('Position',[.04+(isubplot-1)*(1/nbprofils-.01) .1 1/nbprofils-.04 .8])
      h=plot(data1(iprof,:),-[1:size(data1,2)],'r')
      hold on
      h=plot(data2(iprof,:),-[1:size(data2,2)],'b')
      set(gca,'ylim',[-profmax -profmin],'xlim',[valmin valmax],...
        'FontSize',8,'FontWeight','Bold')
      if isubplot>1
        set(gca,'YTickLabel',[])
      else
        ylabel('profondeur (m)')
      end;
      if iprof~=isel
        set(gca,'XTicklabel',[])
      else
        xlabel(vr.unit)
        title(DATES(isel,:),'FontSize',8,'FontWeight','Bold')
      end;
    end; %for iprof

    % Titre general de la page
    ax=axes('Position',[.05 .96 .9 .03],'Box','on','XTick',[],'YTick',[]);
    text(.5,.5,['PROFILS - Capteur1: rouge, Capteur 2: bleu'],...
      'FontSize',12,'Units', 'Normalized', 'HorizontalAlignment', 'Center');
  end

end

