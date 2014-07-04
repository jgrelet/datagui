function plot( self )

% pour levitus, difficile de mettre LEVITUS dans la structure root
% celle ci est sauvegardee dans le fichier de config prefdir\datagui.mat
% et prend alors trop de place (25 Mo) pour un acces rapide.
%
% $Id: plot.m 120 2007-02-02 13:42:20Z jgrelet $

global LEVITUS;
set(findobj('Tag','plot_route'),'Pointer','watch');
%% initialise une table de hashage (tableau associatif) qui contiendra la
%% structure utilisée par multiProfils.m
% struct:
%            data: [1x133 double]
%           scale: [4x2 double]
%     description: 'Temperature °C'
%           style: 'b-'
hash = hashtable;

indice = self.indice;

cles    = keys(   data_2d( self ) );
valeurs = values( data_2d( self ) );

% recupere les infos
couleur = color(self);
roscop  = self.roscop;

valeur = {};
cle = {};

year = get( data_1d(self), 'REFERENCE_DATE_TIME' );
year = str2double({year(1:4)});

% determine si Y = 'PRES' ou 'DEPH'
for i=1:length( cles )
    valeur{end+1} = valeurs{i};
    cle{end+1} = cles{i};
end

cles = cle;
jours.data = get(data_1d(self.oceano),'DAYD');
jours.style = char(['']);
%jours.style = char(['r'; '+']);
jours.description = 'Jours Juliens';
hash = put( hash, 'Jours', jours );

for i=1 : length(valeur)
    % test si radio button selectionne (1) ou non (0)
    if get(findobj('Tag',['radio_' cles{i}]),'Value')
        y = get( roscop, cles{i} );
        y.data = valeur{i};
        if isscalar( indice ) % trace d'un profil
            y.scale = [floor(min(y.data)) ceil(max(y.data)); y.scale];
            y.style = char([couleur(i) '-']);
        else                  % trace de plusieurs profils
            y.scale = [floor(min(min(y.data))) ceil(max(max(y.data))); y.scale];
            y.style = [];
        end
        hash    = put( hash, cles{i}, y );
    end
end

%% met à jour la structure entete pour multiProfil
% l'année de réference
year = get( get(self, 'data_1d'), 'REFERENCE_DATE_TIME' );
year = str2double({year(1:4)});
% la date en jour julien décimal
dates = get( get( self, 'data_1d'), 'DAYD');
% latitude decimal
latitudes = get( get( self, 'data_1d'), 'LATX');
% longitude decimale
longitudes = get( get( self, 'data_1d'), 'LONX');

% on construit differamment la structure suivant la selection d'un ou
% multiple profil
if isscalar( indice )  % un seul
    entete.date = char(to_date(year, dates(indice), 's'));
    entete.date2= char(to_date(year, dates(length(dates)), 's'));
    entete.julian = dates(indice);
    entete.lat = dd2dm(latitudes(indice), 0);
    entete.latd = latitudes(indice);
    entete.long = dd2dm(longitudes(indice), 1);
    entete.longd = longitudes(indice);

    titre = {['\bf' get(get(self, 'data_0d'), 'CYCLE_MESURE')]};
else                   % plusieurs, on affiche le premier et dernier
    entete.date = {to_date(year, dates(indice(1)), 's');...
        to_date(year, dates(indice(end)), 's')};
    entete.lat = {dd2dm(latitudes(indice(1)),0);dd2dm(latitudes(indice(end)),0)};
    entete.long = {dd2dm(longitudes(indice(1)),1);dd2dm(longitudes(indice(end)),1)};
    entete.profil = [num2str(profils(1)) ' - ' num2str(profils(indice(end)))];
    titre = {['\bf' get(get(self, 'data_0d'), 'CYCLE_MESURE')];...
        ['\rm\fontsize{8}Profil: ' num2str(profils(indice(1))) ' - ' ...
        num2str(profils(indice(end))) '  ' ...
        get(get(self, 'data_0d'), 'INSTRUMENT')]};
end

%% Trace la trajectoire de couleur.
y = self.oceano;
z = data_1d(y);
a = get(z, 'LONX');
b = get(z, 'LATX');
%Affiche les trajectoires de couleurs dans une nouvelle fenetre.
if get(findobj('Tag', 'Tag_trajcol'),'Value')==1
    multiScatter(hash,'titre', titre, 'entete', entete, 'valeur_x', a, 'valeur_y', b);
end
%% affiche les profils dans une figure
multiTrajectoires( hash, 'titre', titre, 'entete', entete );
set(findobj('Tag','plot_route'),'Pointer','arrow');
