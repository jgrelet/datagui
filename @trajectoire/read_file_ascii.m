function self = read_file_ascii( self )
% READ_FILE_ASCII: read trajectory file Ascii, datagui format

% $Id: read_file_ascii.m 126 2007-02-28 14:08:00Z jgrelet $


fd = fopen( file(self), 'rt' );
fprintf('\nREAD_FILE_ASCII [%s]\n', class(self)); tic;
if( fd == -1 )
  msg = sprintf('...cannot locate %s\n', file(self));
  error(msg);
  return
end  

fprintf('...reading %s : ', file(self));
h = hashtable;

% lit la premiere ligne
header = fgetl(fd);
hdr = strsplit( header, '  ' );   % disp

% on lit la deuxieme ligne contenant les entetes des colonnes
header = fgetl(fd); 
% affichage pour debug
variables = strread( header, '%s' );  % disp
columns = length( variables );
%
% cree l'equivalent d'une table de hashage des codes Roscop (GF3)
% valides -> colonne associe
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

% test si filtre median necessaire
root = get(0, 'UserData' );
prompt = {'Enter median filter size:'};
dlg_title = 'Input for median filter';
num_lines = 1;
size = inputdlg(prompt,dlg_title,num_lines,{num2str(root.medianSize)});
% si l'utilisateur sort par cancel, pas de filtre mais on ne sauvegarde pas
% la structure root
if (isempty(size))
  root.medianSize = 0;
else  
  root.medianSize = str2num(size{1});
  set(0, 'UserData', root );
end

% gere les dates
year = A(:,col_year);
year_base = year(1);
% met la date au format YYYYMMDDHHmmss
ref_date  = [num2str(year_base) '0101000000'];

%% attributs globaux (data_0d)
self = set(self, 'data_0d', 'CYCLE_MESURE', hdr{1});
assignin('base', 'CYCLE_MESURE', hdr{1} );
self = set(self, 'data_0d', 'PLATEFORME', hdr{2});
assignin('base', 'PLATEFORME',  hdr{2} );
self = set(self, 'data_0d', 'INSTITUT', hdr{3});
assignin('base', 'INSTITUT',  hdr{3} );
self = set(self, 'data_0d', 'INSTRUMENT', hdr{4});
assignin('base', 'INSTRUMENT',  hdr{4} );

%% variables 1 dimension (data_1d)
self = set(self, 'data_1d', 'REFERENCE_DATE_TIME', ref_date);
assignin('base', 'REFERENCE_DATE_TIME', ref_date );

for i = 1 : length(cles)
  data = A(:,val{i});
  data( find( data > 1e35 ) ) = NaN;
  switch cles{i}
    case 'DAYD'
      % allocation
      dayd = ones(nb,1);
      for k=1: nb  % DAYS
        dayd(k) = to_day(year_base,to_date(year(k), data(k), 'n'));
      end
      if (root.medianSize > 0 )
        % filtre median
        dayd = medianf( dayd, root.medianSize );
        % affichage de la taille apres 
        fprintf('...find %d records after median filter', length(dayd) );
      end  % cas de thermo antea
      self = set(self, 'data_1d', cles{i}, dayd);
      assignin('base', cles{i}, dayd );
    case {'LATX','LONX' }
      if (root.medianSize > 0 ); data = medianf( data, root.medianSize ); end  % cas de thermo antea    
      self = set(self, 'data_1d', cles{i}, data);
      assignin('base', cles{i}, data );
    otherwise
      if (root.medianSize > 0 ); data = medianf( data, root.medianSize ); end  % cas de thermo antea
      self = set(self, 'data_2d', cles{i}, data);
      assignin('base', cles{i}, data);
  end
end

t = toc; fprintf('...done (%6.2f sec).\n\n',t);

% memory backup
self = set( self, 'backup_0d', get(self, 'data_0d') );
self = set( self, 'backup_1d', get(self, 'data_1d') );
self = set( self, 'backup_2d', self.data_2d );

