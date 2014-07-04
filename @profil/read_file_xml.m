function self = read_file_xml( self )
% READ_FILE_XML: read XML "ROSCOP" IRD File, common to all data type
% Utilise XML Toolbox for Matlab, GeodiseLab 
% voir: http://www.geodise.org/downloads/index.htm
%
% $Id: read_file_xml.m 132 2007-03-16 14:46:17Z jgrelet $

%% ouverture du fichier
fd = fopen( file(self), 'rt' );
fprintf('\nREAD_FILE_XML [%s]\n', class(self)); tic;
if( fd == -1 )
  msg = sprintf('...cannot locate %s\n', file(self));
  err(msg);
  return
end  

fprintf('...reading %s : ', file(self));
h = hashtable;

%% parse le fichier XML
tree = xml_parseany( fileread( file( self ) ) );
%data = tree.DATA{1}.CONTENT;

% decode l'entete, a completer
cycle_mesure     = tree.ENTETE{1}.CYCLE_MESURE{1}.LIBELLE{1}.CONTENT;
plateforme       = tree.ENTETE{1}.PLATEFORME{1}.LIBELLE{1}.CONTENT;
try
  date_debut       = tree.ENTETE{1}.CYCLE_MESURE{1}.DATE_DEBUT{1}.CONTENT;
  date_fin         = tree.ENTETE{1}.CYCLE_MESURE{1}.DATE_FIN{1}.CONTENT;
catch
end
try
  institut         = tree.ENTETE{1}.CYCLE_MESURE{1}.INSTITUT{1}.CONTENT;
  instrument_type  = tree.ENTETE{1}.INSTRUMENT{1}.ATTRIBUTE.TYPE;
  instrument_numero_serie = ...
                   tree.ENTETE{1}.INSTRUMENT{1}.ATTRIBUTE.NUMERO_SERIE;
  responsable      = tree.ENTETE{1}.CYCLE_MESURE{1}.RESPONSABLE{1}.CONTENT;                 
catch
end  
fclose(fd);

%% deuxieme lecture des donnees dans le fichier apres la balise <DATA>
% on lit la deuxieme ligne contenant les entetes des colonnes
fd = fopen( file(self), 'rt' );
while ~feof(fd)
  line = fgetl(fd);
  [tok match] = regexp(line,'<(\w+)>','tokens');  
  if isempty(match), continue, end
  if strmatch(tok{1},'DATA'), break, end
end  

% lit la ligne contenant les entetes des colonnes
header = fgetl(fd);
%disp( ['Entete: ', header] );
var_all = strread( header, '%s' ); 
columns = length( var_all );

% cree l'equivalent d'une table de hashage des codes Roscop (GF3)
% valides -> colonne associe
% mettre le switch case avec BOTTLE ici , a revoir
for i = 1: columns
  if( ~strcmp(var_all(i),'ST') && ~strcmp(var_all(i),'PROFIL') && ...
      ~strcmp(var_all(i),'PRFL') && ~strcmp(var_all(i),'NAVG') && ...
      ~strcmp(var_all(i),'N/A') )
    h = put( h, var_all{i}, i );
  end
end 

cles = keys(h);
val  = values(h);

% lecture des donnees
[A,count] = fscanf( fd, '%g', [columns,inf] );
% 
nb = count / columns;
disp( [num2str(nb),' records'] );
% 
% on inverse la matrice
A=A';

debut = A(1,1);
fin   = A(nb,1);
j=0;
max_size = 0;

for i = debut : fin;  % parcourt les profils pour determiner max_size
  data = A( A(:,1) == i,: );  % on recupere les donnees du profil
  s = length(data(2:end,2));
  if s == 0  % pas de profil
    continue;
  end
  j = j+1;
  if( s > max_size )
    max_size = s;
  end  
end
columns = length(cles);
% columns -1 car on enleve la profondeur

%% pre-allocations en vecteurs colonne pour les data_1d
variables = zeros(j,max_size,columns) * NaN;
profils = ones(j,1);
dayd     = ones(j,1);
latx     = ones(j,1);
lonx     = ones(j,1);

j=0;
for i = debut : fin;  % parcourt les profils
  data = A( A(:,1) == i,: );  % on recupere les donnees du profil
  %[s,t] = size(data);
  s = length(data);
  if s == 0  % pas de profil
    continue;
  end
  j = j+1;
  % PROFIL NUMBER
  profils(j) = i;
  % REFERENCE_DATE_TIME
  if  ~exist( 'year_base', 'var' )
    ref_date  = num2str(data(1,6));
    year_base = str2double(ref_date(1:4));
  end
  % DAYD
  dayd(j) = to_day(year_base,to_date(year_base,data(1,3),'n'));
  % LATX
  latx(j)  = data(1,4);
  % LONX
  lonx(j)  = data(1,5);
  for k = 1 : columns
    s = length(data(2:end,2));
    switch cles{k}    
      case 'BOTTLE'  % on saute la colonne pour les fichier btl
      otherwise
        variables(j,(1:s),k) = data(2:end,val{k})';  
        % on recupere les donnees du profil
        % sans la ligne d'entete
    end
  end
end  

%% attributs globaux (data_0d)
self = set(self, 'data_0d', 'CYCLE_MESURE', cycle_mesure);
assignin('base', 'CYCLE_MESURE', cycle_mesure );
self = set(self, 'data_0d', 'PLATEFORME', plateforme);
assignin('base', 'PLATEFORME', plateforme );
self = set(self, 'data_0d', 'INSTRUMENT_TYPE', instrument_type);
assignin('base', 'DATE_DEBUT', date_debut );
self = set(self, 'data_0d', 'DATE_DEBUT', date_debut);
assignin('base', 'DATE_FIN', date_fin );
self = set(self, 'data_0d', 'DATE_FIN', date_fin);
assignin('base', 'INSTRUMENT', instrument_type );
self = set(self, 'data_0d', 'INSTRUMENT_NUMERO_SERIE', instrument_numero_serie);
assignin('base', 'INSTRUMENT', instrument_numero_serie );
self = set(self, 'data_0d', 'INSTITUT', institut);
assignin('base', 'INSTITUT', institut );
self = set(self, 'data_0d', 'RESPONSABLE', responsable);
assignin('base', 'RESPONSABLE', responsable );


%% variables 1 dimension (data_1d)
self = set(self, 'data_1d', 'REFERENCE_DATE_TIME', ref_date');
assignin('base', 'REFERENCE_DATE_TIME', ref_date' );
self = set(self, 'data_1d', 'PROFILS', profils);
assignin('base', 'PROFILS', profils );
self = set(self, 'data_1d', 'DAYD', dayd);
assignin('base', 'DAYD', dayd);
self = set(self, 'data_1d', 'LATX', latx);
assignin('base', 'LATX', latx);
self = set(self, 'data_1d', 'LONX', lonx);
assignin('base', 'LONX', lonx);

%% variables a 2 dimensions (data_2d)
% remplace les donnees manquantes a 1e36 par NaN
variables(variables > 1e+35) = NaN;
for i=1:length(cles)
  switch cles{i}    
    case 'BOTTLE'  % on saute la colonne pour les fichier btl
    otherwise
     self = set(self, 'data_2d', cles{i}, variables(:,:,i));
     assignin('base', cles{i}, variables(:,:,i));
  end  
end

t = toc; fprintf('...done (%6.2f sec).\n\n',t);

%% memory backup
self = set( self, 'backup_0d', get(self, 'data_0d') );
self = set( self, 'backup_1d', get(self, 'data_1d') );
self = set( self, 'backup_2d', self.data_2d );
