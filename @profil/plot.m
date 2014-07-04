function plot( self )
% trace un ou plusieurs profils verticaux pour une instance de type profil

% $Id: plot.m 187 2012-09-12 13:09:40Z jgrelet $

% pour levitus, difficile de mettre LEVITUS dans la structure root
% celle ci est sauvegardee dans le fichier de config prefdir\datagui.mat
% et prend alors trop de place (25 Mo) pour un acces rapide.

global LEVITUS;

%% initialise une table de hashage (tableau associatif) qui contiendra la
%% structure utilis�e par multiProfils.m
% struct:
%            data: [1x133 double]
%           scale: [4x2 double]
%     description: 'Temperature �C'
%           style: 'b-'
hash = hashtable;
y = [];

indice = self.indice;

% get all keys
% ------------
cles    = keys(   data_2d( self ) );

% ne garde que les variables "primaires" correspondants aux codes Roscop
% 1 pour inclure PRES ou DEPH
% -----------------------------------------------------------------------
cles = get_primary_key(cles, 1);

% recupere les infos 
couleur = color(self);
roscop  = self.roscop;
mode    = edit(self);

valeur = {};
cle = {};

year = get( data_1d(self), 'REFERENCE_DATE_TIME' );
year = str2double({year(1:4)});

% determine si Y = 'PRES' ou 'DEPH'
for i=1:length( cles )
  if strcmp(cles{i}, 'PRES') || strcmp(cles{i}, 'DEPH')...
      || strcmp(cles{i}, 'HEIG')
    % if PRES and DEPH allready defined, keep only PRES for y
    if isempty(y)
      y = get( roscop, cles{i} );
      % get data for key
      % ---------------
      valeurs = get( data_2d(self), cles(i) );
      y.data = valeurs(indice,:);
      if isscalar( indice ) % trace d'un profil
        y.scale = [floor(min(y.data)) ceil(max(y.data)); y.scale];
        y.style = 'k-';
      else                  % trace de plusieurs profils
        y.scale = [floor(min(min(y.data))) ceil(max(max(y.data))); y.scale];
        y.style = [];
      end
      hash    = put( hash, cles{i}, y );
    else
      continue
    end
  else
    valeur{end+1} = get( data_2d(self), cles(i) );
    cle{end+1} = cles{i};
  end
end
cles = cle;

for i=1 : length(valeur)
  % test si radio button selectionne (1) ou non (0)
  if get(findobj('Tag',['radio_' cles{i}]),'Value')
    y = get( roscop, cles{i} );
    y.data = valeur{i}(indice,:);
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

%% met a jour la structure entete pour multiProfil
% l'ann�e de r�ference
year = get( get(self, 'data_1d'), 'REFERENCE_DATE_TIME' );
year = str2double({year(1:4)});
% la date en jour julien d�cimal
dates = get( get( self, 'data_1d'), 'DAYD');
% latitude decimal
latitudes = get( get( self, 'data_1d'), 'LATX');
% longitude decimale
longitudes = get( get( self, 'data_1d'), 'LONX');

% recupere la liste des profils
profils = get(get(self, 'data_1d'), 'PROFILS');

% on construit differamment la structure suivant la selection d'un ou
% multiple profil
if isscalar( indice )  % un seul
  entete.date = to_date(year, dates(indice), 's');
  entete.julian = dates(indice);
  entete.lat = dd2dm(latitudes(indice), 0);
  entete.latd = latitudes(indice);
  entete.long = dd2dm(longitudes(indice), 1);
  entete.longd = longitudes(indice);
  entete.profil = num2str(profils(indice));
  titre = {['\bf' get(get(self, 'data_0d'), 'CYCLE_MESURE')];...
           ['\rm\fontsize{8}Profil: ' num2str(profils(indice)) '  ' ...
           get(get(self, 'data_0d'), 'INSTRUMENT_TYPE')]};
else                   % plusieurs, on affiche le premier et dernier
  entete.date = {to_date(year, dates(indice(1)), 's');...
                 to_date(year, dates(indice(end)), 's')};
  entete.lat = {dd2dm(latitudes(indice(1)),0);dd2dm(latitudes(indice(end)),0)};
  entete.long = {dd2dm(longitudes(indice(1)),1);dd2dm(longitudes(indice(end)),1)};
  entete.profil = [num2str(profils(1)) ' - ' num2str(profils(indice(end)))];
  titre = {['\bf' get(get(self, 'data_0d'), 'CYCLE_MESURE')];...
           ['\rm\fontsize{8}Profil: ' num2str(profils(indice(1))) ' - ' ...
                                      num2str(profils(indice(end))) '  ' ...
            get(get(self, 'data_0d'), 'INSTRUMENT_TYPE')]};
end      

%% affiche les profils dans une figure       
multiProfils( hash, 'titre', titre, 'entete', entete, 'mode', mode, ...
             'path', file(self.oceano));

