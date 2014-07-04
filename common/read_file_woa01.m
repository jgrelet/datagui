function levitus = read_file_woa01(file)
% a mettre dans la classe de base oceano puisque commun a tous
% read_woa01.m
%
% read WOA01 Levitus T-S-O2, Stddev & nb_obs Netcdf file in memory

% $Id: read_file_woa01.m 258 2013-08-16 15:24:42Z jgrelet $

filesfound = checkforfiles( file );
if filesfound == 0;
  error(['Couldn''t find ', file])
end

%% Check Netcdf library version
% -----------------------------
if verLessThan('matlab', '7.13')
  read_netcdf_toolbox;
else
  read_netcdf_native;
end

% use mexnc toolbox with version <= R2008a
% ----------------------------------------
  function read_netcdf_toolbox
    nc = netcdf(which(file),'nowrite');
    
    %recupere les variables et les mets de le workspace
    variables = var(nc);
    
    % list les variables du fichier et sort
    % if strcmp( variable, 'list' )
    %     disp(char(ncnames(var(nc))));
    %     return
    % end
    
    % Initialise la waitbar de chargement du fichier netCDF
    wb = waitbar(0,['Loading file: ' file ' Please  wait...']);
    
    for i = 1:length(variables)
      value = variables{i}(:);
      
      % je n'ai pas reussi a utiliser autonan avec l'attribue FillValue_
      value(value == fillval(variables{i})) = NaN;
      
      % Assign dynamiquely variable in struct levitus.
      levitus.(name(variables{i})) = value;
      
      % set(wb, 'Title', name(variables{i}));
      waitbar( i/length(variables), wb);
    end
    
    close(wb);
    close(nc);
    
  end

% use native toolbox +netcdf since R2008b
% ---------------------------------------
  function read_netcdf_native
    
    % get information about NetCDF file
    % ---------------------------------
    nc = ncinfo( which(file));
    if isempty(nc)
      msg = sprintf('...cannot locate %s\n', file);
      err(msg);
    end
    
    % get cell array of variables name
    % --------------------------------
    variables = {nc.Variables.Name};
    
    % iterate over each variables
    % ---------------------------
    for key = variables
      
      cle = char(key);
      value = ncread( file, cle);
      
      % Assign dynamiquely variable in struct levitus.
      levitus.(cle) = value;
      
    end
    
  end

%----------------------------------------------------------------------
%----------------------------------------------------------------------
  function filesfound = checkforfiles( file )
    
    if exist(file,'file');
      filesfound = 1;
    else
      filesfound = 0;
    end
  end

end
