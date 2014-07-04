function self = read_file_ascii( self )

% $Id: read_file_ascii.m 187 2012-09-12 13:09:40Z jgrelet $

%% ouverture du fichier
fd = fopen( file(self), 'rt' );
fprintf('\nREAD_FILE_ASCII [%s]\n', class(self)); tic;
if( fd == -1 )
  msg = sprintf('...cannot locate %s\n', file(self));
  err(msg);
  return
end  

fprintf('...reading %s : ', file(self));
h = hashtable;

header = fgetl(fd);

% hdr = strsplit( header, '  ' );  
hdr = regexp( header, '  ', 'split');

% on lit la deuxieme ligne contenant les entetes des colonnes
header = fgetl(fd); 
% affichage pour debug
var_all = strread( header, '%s' );  % disp
columns = length( var_all );
%
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
  % PROFILS
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
self = set(self, 'data_0d', 'CYCLE_MESURE', hdr{1});
assignin('base', 'CYCLE_MESURE', hdr{1} );
self = set(self, 'data_0d', 'PLATEFORME', hdr{2});
assignin('base', 'PLATEFORME',  hdr{2} );
self = set(self, 'data_0d', 'INSTITUT', hdr{3});
assignin('base', 'INSTITUT',  hdr{3} );
self = set(self, 'data_0d', 'INSTRUMENT_TYPE', hdr{4});
assignin('base', 'INSTRUMENT_TYPE',  hdr{4} );

%% variables 1 dimension (data_1d)
self = set(self, 'data_1d', 'REFERENCE_DATE_TIME', ref_date');
assignin('base', 'REFERENCE_DATE_TIME', ref_date' );
self = set(self, 'data_1d', 'PROFILS', profils);
assignin('base', 'PROFILS', profils );
self = set(self, 'data_1d', 'DAYD', dayd);
assignin('base', 'DAYD', dayd );
self = set(self, 'data_1d', 'LATX', latx);
assignin('base', 'LATX', latx );
self = set(self, 'data_1d', 'LONX', lonx);
assignin('base', 'LONX', lonx );

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

% memory backup
self = set( self, 'backup_0d', get(self, 'data_0d') );
self = set( self, 'backup_1d', get(self, 'data_1d') );
self = set( self, 'backup_2d', self.data_2d );

