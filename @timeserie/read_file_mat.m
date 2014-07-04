function self = read_file_mat( self )
% READ_FILE_ASCII: read timeserie .mat file, datagui format

% $Id: read_file_mat.m 120 2007-02-02 13:42:20Z jgrelet $


fd = fopen( file(self), 'rt' );
fprintf('\nREAD_FILE_ASCII [%s]\n', class(self)); tic;
if( fd == -1 )
  msg = sprintf('...cannot locate %s\n', file(self));
  error(msg);
  return
end  

fprintf('...reading %s : ', file(self));
h = hashtable;

    ficmat='Dat3.mat'
    load(ficmat)
 
% on extrait des vecteurs 
    tjy = tab(:,6);
    
    hair = tab(:,7);
    tair = tab(:,8);
    irsol = tab(:,9);
    dvent = tab(:,10);
    vvent = tab(:,11);
    prec = tab(:,12);
    pres = tab(:,13);

% lit la premiere ligne
header = fgetl(fd);
hdr = strread( header, '%s' );   % disp
% disp(['File: ', file(self), '  Header: ', header]);

% on lit la deuxieme ligne contenant les entetes des colonnes
header = fgetl(fd); 
% affichage pour debug
variables = strread( header, '%s' );  % disp
columns = length( variables );
%
% cree l'equivalent d'une table de hashage des codes Roscop (GF3)
% valides -> colonne associe
% mettre le switch case avec BOTTLE ici , a revoir
for i = 1: columns
  if( ~strcmp(variables(i),'N/A') && ~strcmp(variables(i),'YEAR') )
    h = put( h, variables{i}, i );
  elseif( strcmp(variables(i),'YEAR') )
    col_year = i;
  end
end 

cles = keys(h);
val  = values(h);

[A,count] = fscanf( fd, '%g', [columns,inf] );
% 
nb = count / columns;
disp( [num2str(nb),' records'] );
% 
% on inverse la matrice
A=A';

% gere les dates
year = A(:,col_year);
year_base = year(1);
% met la date au format YYYYMMDDHHmmss
ref_date  = [num2str(year_base) '0101000000'];

self = set(self, 'data_0d', 'CRUISE', hdr{1});
assignin('base', 'CRUISE', hdr{1} );
self = set(self, 'data_1d', 'REFERENCE_DATE_TIME', ref_date);
assignin('base', 'REFERENCE_DATE_TIME', ref_date );

for i = 1 : length(cles)
  data = A(:,val{i});
  data( find( data > 1e35 ) ) = NaN;
  switch cles{i}
    case 'DAYD'
      for k=1: nb  % DAYD
        dayd(k) = to_day(year_base,to_date(year(k), data(k), 'n'));
      end
      self = set(self, 'data_1d', cles{i}, DAYD);
      assignin('base', cles{i}, days );
    case {'LATX','LONX' }
      self = set(self, 'data_1d', cles{i}, data);
      assignin('base', cles{i}, data );
    otherwise
      self = set(self, 'data_2d', cles{i}, data);
      assignin('base', cles{i}, data);
  end
end

t = toc; fprintf('...done (%6.2f sec).\n\n',t);

% memory backup
self = set( self, 'backup_0d', get(self, 'data_0d') );
self = set( self, 'backup_1d', get(self, 'data_1d') );
self = set( self, 'backup_2d', self.data_2d );

