function self = read_file_xml( self )
% READ_FILE_XML: read XML "ROSCOP" IRD File, common to all data type
% Utilise XML Toolbox for Matlab, GeodiseLab 
% voir: http://www.geodise.org/downloads/index.htm
%
% $Id: read_file_xml.m 137 2007-07-13 14:11:14Z jgrelet $

%% ouverture du fichier
fd = fopen( file(self), 'rt' );
fprintf('\nREAD_FILE_XML [%s]\n', class(self)); tic;
if( fd == -1 )
  msg = sprintf('...cannot locate %s\n', file(self));
  error(msg);
  return
end  

fprintf('...reading %s : ', file(self));
h = hashtable;

%% parse le fichier XML
tree = xml_parseany( fileread( file( self ) ) );
%data = tree.DATA{1}.CONTENT;

% decode l'entete, a completer
cycle_mesure = tree.ENTETE{1}.CYCLE_MESURE{1}.LIBELLE{1}.CONTENT;
institut     = tree.ENTETE{1}.CYCLE_MESURE{1}.INSTITUT{1}.CONTENT;
plateforme   = tree.ENTETE{1}.PLATEFORME{1}.LIBELLE{1}.CONTENT;
instrument   = tree.ENTETE{1}.INSTRUMENT{1}.ATTRIBUTE.TYPE;
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
variables = strread( header, '%s' ); 
columns = length( variables );

% cree l'equivalent d'une table de hashage des codes Roscop (GF3)
% valides -> colonne associe
for i = 1: columns
  if (~strcmp(variables(i),'N/A') && ~strcmp(variables(i),'YEAR') )
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
self = set(self, 'data_0d', 'CYCLE_MESURE', cycle_mesure);
assignin('base', 'CYCLE_MESURE', cycle_mesure );
self = set(self, 'data_0d', 'INSTITUT', institut);
assignin('base', 'INSTITUT', institut );
self = set(self, 'data_0d', 'PLATEFORME', plateforme);
assignin('base', 'INSTITUT', plateforme );
self = set(self, 'data_0d', 'INSTRUMENT', instrument);
assignin('base', 'INSTRUMENT', instrument );

%% variables 1 dimension (data_1d)
self = set(self, 'data_1d', 'REFERENCE_DATE_TIME', ref_date);
assignin('base', 'REFERENCE_DATE_TIME', ref_date );

for i = 1 : length(cles)
  data = A(:,val{i});
  data( find( data > 1e35 ) ) = NaN;
  switch cles{i}
    case 'DAYD'
      % pre-allocation
      %days = ones(nb,1);
      %for k=1: nb  % DAYD
      %  days(k) = to_day(year_base,to_date(year(k), data(k), 'n'));
      %end
      days = to_day(year_base,to_date(year,data,'n'));
      if (root.medianSize > 0 )
        % filtre median
        days = medianf( days, root.medianSize );
        % affichage de la taille apres 
        fprintf('...find %d records after median filter', length(days) );
      end  % cas de thermo antea
      self = set(self, 'data_1d', cles{i}, days);
      assignin('base', cles{i}, days );
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
%self = set( self, 'backup_2d', self.data_2d );

