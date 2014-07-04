function [self nc] = read_file_oceansites( self, varargin )
% read_file_oceansites( self, varargin )
% read OceanSites profiles and translate to ARGO format for datagui
% elements(self.data_0d)
% elements(self.data_1d)
% elements(self.data_2d)
%
%  example
% cles = keys( data_2d(self) );
% for i=1:length(cles)
%   v = get( data_2d(self), cles(i) );
%   v(1:5,1:10)
% end

% $Id: read_file_nc.m 260 2013-08-16 15:27:09Z jgrelet $

mode = 0; permission = 'nowrite'; % par defaut, en lecture seule
% test les arguments
if nargin == 2 && strcmp(varargin{1},'write')
  mode = 1; permission = 'write';
end

% lecture fichier
fprintf('\nREAD_FILE_OCEANSITES NETCDF [%s]  MODE: ''%s''\n', class(self), ...
  permission); tic;

%% Check Netcdf library version
% -----------------------------
if verLessThan('matlab', '7.13')
    read_netcdf_toolbox;
else
    read_netcdf_native;
end

t = toc; fprintf('...done (%6.2f sec).\n\n',t);

% memory backup
%self.backup_0d = hashtable(self.data_0d);
%self.backup_1d = hashtable(self.data_1d);
%self.backup_2d = hashtable(self.data_2d);
self = set( self, 'backup_0d', get(self, 'data_0d') );
self = set( self, 'backup_1d', get(self, 'data_1d') );
self = set( self, 'backup_2d', self.data_2d );

% use mexnc toolbox with version <= R2008a
% ----------------------------------------
  function read_netcdf_toolbox
    nc = netcdf( file(self), permission );
    if isempty(nc)
      msg = sprintf('...cannot locate %s\n', file(self));
      err(msg);
    end
    
    fprintf('...reading %s\n', file(self));
    
    % recupere les attribut globaux et les mets de le workspace dynamique
    % rempli egalement le hashtable data_0d
    global_att = att(nc);
    for i = 1:length(global_att)
      attribute = name(global_att{i});
      value = global_att{i}(:);
      % verrue rajoutee car depuis l'utilisation des fichiers xml
      % CRUISE => CYCLE_MESURE
      % on transforme donc CRUISE en CYCLE_MESURE
      [tok match]=regexp(attribute,'CRUISE(\w*)','tokens');
      if match
        attribute = strcat('CYCLE_MESURE',char(tok{1}));
      end
      assignin('base', attribute, value );
      % met les couples attribute/value dans le hashtable (key/value)
      %self.data_0d = put( self.data_0d, attribute, value );
      self = set(self, 'data_0d', attribute, value );
      % utiliser :
      %             hdr = data_1d(p)
      %             keys(hdr)
      %             values(hdr)
      %             elements(hdr)
      %             get(hdr,<cle>)
    end
    
    %recupere l'ensemble des variables et les mets dans le workspace
    variables = var(nc);
    for i = 1:length(variables)
      % on utilise les attributs add_offset et scale_value des variables, par
      % defaut (non definit) add_offset = 0 et scale_factor = 1
      % on utilise pas pour l'instant car transforme REFERENCE_DATE_TIME qui
      % est de type char en double. Il faudrait faire un test dans ce cas
      %valeur = addoffset(variables{i}) + scalefactor(variables{i}) * variables{i}(:);
      valeur = variables{i}(:);
      if str2double(version('-release')) < 14
        if isnumeric( valeur )
          % je n'ai pas reussi a utiliser autonan avec l'attribue FillValue_
          valeur(valeur > 1e35) = NaN;
        end
      else
        if isfloat( valeur )
          % je n'ai pas reussi a utiliser autonan avec l'attribut FillValue_
          valeur(valeur > 1e35) = NaN;
        end
      end
      
      cle = name(variables{i});
      assignin('base', cle, valeur );
      % !!!!!!
      % !!! A verifier mais case 'REFERENCE_DATE_TIME' plus necessaire
      % !!!!!!
      switch cle
        case 'REFERENCE_DATE_TIME'
          % year_base = str2double({valeur(1:4)});
          %self.data_1d = put(self.data_1d, cle, valeur);
          self = set( self, 'data_1d', cle, valeur);
        case {'PROFILE','PROFILS', 'PRFL', 'ST'}
          % self.data_1d = put(self.data_1d, cle, valeur);
          if strcmp(cle,'PROFILE')
            cle = 'PROFILS';
          end
          DIMX = cle;
          self = set( self, 'data_1d', cle, valeur);
        case {'DAYD', 'LATX', 'LONX', 'BATH'}
          self = set( self, 'data_1d', cle, valeur);
        otherwise
          % l'un ou l'autre, verifier le plus rapide
          % self.data_2d = put(self.data_2d, cle, valeur);
          self = set( self, 'data_2d', cle, valeur);
          if strcmp(cle, 'PRES') || strcmp(cle, 'DEPH') || ...
              strcmp(cle, 'HEIG')
            DIMY = cle;
          elseif mode == 1
            new_cle     = strcat(cle, '_C');
            nc{new_cle} = ncfloat(DIMX,DIMY);
            nc{new_cle}(:) = valeur;
            assignin('base', new_cle, nc{new_cle}(:) );
            new_cle     = strcat(cle, '_Q');
            nc{new_cle} = ncint(DIMX,DIMY);
            nc{new_cle}(:) = 0;
            assignin('base', cle, nc{new_cle}(:) );
          end
      end
      
      
    end
    
    if mode == 0
      close(nc);
    end
    
  end

% use native toolbox +netcdf since R2008b
% ---------------------------------------
  function read_netcdf_native
    %error('Not yet implemented');
    
    % get information about NetCDF file
    % ---------------------------------
    nc = ncinfo( file(self));
    if isempty(nc)
      msg = sprintf('...cannot locate %s\n', file(self));
      err(msg);
    end
    
    % iterate over each attributes
    % ---------------------------
    for i = 1: length(nc.Attributes)
      if strcmp(nc.Attributes(i).Name, 'type_instrument')
        cle = 'INSTRUMENT_TYPE';
      else
        cle = upper(nc.Attributes(i).Name);     
      end
      value = nc.Attributes(i).Value;
      self = set(self, 'data_0d', cle, value );
      assignin('base', cle, value );
    end
    
    % get cell array of variables name
    % --------------------------------
    variables = {nc.Variables.Name};
    
    % iterate over each variables
    % ---------------------------
    for key = variables
      
      cle = char(key);
      valeur = ncread( file(self), cle);
      
      switch cle

        case {'PROFILE','PROFILS', 'PRFL', 'ST'}
          self = set( self, 'data_1d', 'PROFILS', valeur);
        case 'TIME'
          % convert from origine 1950 to current year
          valeur = to_date(1950, valeur, 'numeric');
          ref_date = valeur(1,1);
          valeur = to_day(ref_date, valeur);
          self = set( self, 'data_1d', 'DAYD', valeur);
          self = set( self, 'data_1d', 'REFERENCE_DATE_TIME', ...
            sprintf('%04d0101000000', ref_date));
        case 'LONGITUDE'
          self = set( self, 'data_1d', 'LONX', valeur);
        case 'LATITUDE'
          self = set( self, 'data_1d', 'LATX', valeur);    
        case 'BATH'
          self = set( self, 'data_1d', cle, valeur);              
        otherwise
          
          % il faut transposer les matrices avec la toolbox native
          % ------------------------------------------------------
          valeur = valeur';
          switch cle
            case 'DEPTH'
              self = set( self, 'data_2d', 'DEPH', valeur);
          otherwise
              self = set( self, 'data_2d', cle, valeur);
          end
      end
      
      % assign les donnees dans le workspace
      % ------------------------------------
      assignin('base', cle, valeur);
    end
    
  end



end % end of read_file_nc




