function control_select(varargin)

% Fonction qui met en place tout les bouttons permettant a l'utilisateur
% de selectionner l'action desire pour la gestion du code qualite.

% Initialisation des variables. 
hash = varargin{1};
liste_points = [];


%% Affichage des boutons d'actions Code Qualite. 

if isempty(findobj('tag','tag_qualite_panel'))
  % UI_panel des boutons d'action Qualit�.
  hdl_qualite = uipanel('parent',findobj('Tag','Tag_hdl_action'),...
    'Title','Type de Contour',...
    'tag','tag_qualite_panel',...
    'FontSize',8,...
    'Units','pixels',...
    'Position',[6 140 105 250]);

  % Radio bouton du zoom
  uicontrol('Parent',hdl_qualite,...
    'style','radio',...
    'String','zoom',...
    'tag','tag_qualite_zoom',...
    'Units','normalized',...
    'Position',[.2 .92 .6 .08],...
    'value',0,...
    'Callback',@zoom_callback);

  % Radio bouton du pan.
  uicontrol('Parent',hdl_qualite,...
    'style','radio',...
    'String','pan',...
    'tag','tag_qualite_pan',...
    'Units','normalized',...
    'Position',[.2 .82 .6 .08],...
    'value',0,...
    'Callback',@pan_callback);

  % Premier boutons de selection des points � supprimer. 
  uicontrol('Parent',hdl_qualite,...
    'String','Supprimer_points',...
    'tag','tag_qualite_select',...
    'Units','normalized',...
    'Position',[.05 .70 .9 .1],...
    'Callback',{@select_callback, hash, liste_points});

  % Deuxieme bouton... le callback associ� reste � definir.
  uicontrol('Parent',findobj('tag','tag_qualite_panel'),...
    'String','Supprimer_lim',...
    'tag','tag_qualite_select',...
    'Units','normalized',...
    'Position',[.05 .58 .9 .1],...
    'Callback',{@callback_define_QC, liste_points});

  % De meme pour les bouttons suivants, les callbacks ne sont pas definis. 
  uicontrol('Parent',findobj('tag','tag_qualite_panel'),...
    'String','interpoler',...
    'tag','tag_qualite_select',...
    'Units','normalized',...
    'Position',[.05 .46 .9 .1]);

  uicontrol('Parent',findobj('tag','tag_qualite_panel'),...
    'String','lissage',...
    'tag','tag_qualite_select',...
    'Units','normalized',...
    'Position',[.05 .33 .9 .1]);

  uicontrol('Parent',findobj('tag','tag_qualite_panel'),...
    'String','Undefine',...
    'tag','tag_qualite_select',...
    'Units','normalized',...
    'Position',[.05 .20 .9 .1]);

  uicontrol('Parent',findobj('tag','tag_qualite_panel'),...
    'String','Undefine',...
    'tag','tag_qualite_select',...
    'Units','normalized',...
    'Position',[.05 .07 .9 .1]);

  uicontrol('Parent',findobj('tag','Tag_hdl_action'),...
    'String','Enregistrer',...
    'tag','tag_qualite_select',...
    'Units','normalized',...
    'Position',[.05 .15 .9 .05]);

  uicontrol('Parent',findobj('tag','Tag_hdl_action'),...
    'String','Cancel_all',...
    'tag','tag_qualite_select',...
    'Units','normalized',...
    'Position',[.05 .06 .9 .05]);
end

end

%% Nested Functions. 

%% Fonction ZOOM
% Fonction permettant de gerer le zoom. 
function zoom_callback(obj, eventdata)
% Si le radio_button pan est deja selectionn�, on le decoche. 
if get(findobj('Tag','tag_qualite_pan'),'value')==1
  set(findobj('Tag','tag_qualite_pan'),'value',0);
end
% On recupere l'etat du radio_bouton apr�s le click. 
value = get(findobj('tag','tag_qualite_zoom'),'value');
switch value
  case 0
    zoom off;
  case 1
    zoom on;
end
value = ' ';
end

%% Fonction PAN

function pan_callback(obj, eventdata)
% Si le radio_button zoom est deja selectionn�, on le decoche.
if get(findobj('Tag','tag_qualite_zoom'),'value')==1
  set(findobj('Tag','tag_qualite_zoom'),'value',0);
end
% On recupere l'etat du radio_bouton apr�s le click. 
value = get(findobj('tag','tag_qualite_pan'),'value');
switch value
  case 0
    pan off;
  case 1
    pan on;
end
value = ' ';
end

%% Fonction selection de points � supprimer. 

function select_callback(obj, eventdata, hash, liste_points)
% Fonction permettant de creer une boxe avec la sourie afin de selectionner
% des points et de les taguer pour les supprimer. 
% On decoche les radio_boutons zoom et pan si ils sont coch�s. 
if get(findobj('Tag','tag_qualite_pan'),'value')==1
  set(findobj('Tag','tag_qualite_pan'),'value',0);
  pan_callback
end
if get(findobj('Tag','tag_qualite_zoom'),'value')==1
  set(findobj('Tag','tag_qualite_zoom'),'value',0);
  zoom_callback;
end
% Modification de l'affichage de la sourie. 
set(gcf,'Pointer','cross');

k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % Bouton enffonc�
finalRect = rbbox;                   % renvoie les dimentions de la box
point2 = get(gca,'CurrentPoint');    % bouton relach�
point1 = point1(1,1:2);              % extraction de x et y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calcul des positions
offset = abs(point1-point2);         % et des dimentions.
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
hold on
axis manual
plot(x,y,':r','Tag','tag_rect');
a = max(x);
b = min(x);
c = max(y);
d = min(y);
cles = keys(hash);
y = get(hash,cles(1));
y = y.data;
x = get(hash,cles(2));
x = x.data;
for i= 1:length(y)
  if (x(i)<a && x(i)>b && y(i)<c && y(i)>d)
    liste_points = [liste_points, i];
  end
end
if isempty(liste_points)
  disp('Aucun point selectionn�.')
else
  for i= 1:length(liste_points)
    tag = ['tag_points_' num2str(liste_points(i))];
    plot(x(liste_points(i)), y(liste_points(i)),'--ko','Tag',tag);
  end
end
set(gcf,'Pointer','arrow');
end

%% Fonction de definition du code qualite desire. 

function  callback_define_QC(obj, eventdata, liste_points)
QC_defined = define_QC;
color_points_QC(liste_points, QC_defined);
%write_xml_QC(x, y, liste_points);
end

%% Fonction determinant une couleur a partir d'un code qualite selectionne.

function color_points_QC(liste_points, QC_defined)
switch str2num(QC_defined)
  case 0
    color_style = 'w';
  case 1
    color_style = 'b';
  case 2
    color_style = 'c';
  case 3
    color_style = 'm';
  case 4
    color_style = 'r';
end
set(findobj('Tag','tag_rect'),'visible','off','HandleVisibility','off');
if str2num(QC_defined) ~= 0
  for i= 1:length(liste_points)
    tag_point = ['tag_points_' num2str(liste_points(i))];
    set(findobj('Tag',tag_point),'color',color_style);
  end
else
  for i= 1:length(liste_points)
    tag_point = ['tag_points_' num2str(liste_points(i))];
    set(findobj('Tag',tag_point),'visible','off','HandleVisibility','off');
  end
end
end

