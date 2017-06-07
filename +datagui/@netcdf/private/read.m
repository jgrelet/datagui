function read(self)
% datagui.netcdf.read
% private function read of netcdf toolbox
%
% $Id: read.m 249 2013-02-07 14:28:33Z jgrelet $

% check file validity
% -------------------
self.nc_id = netcdf.open(self.Filename, self.Mode);
if self.nc_id == -1
  error(['datagui:netcdf:read', ...
    'The specified data file ''%s'' does not exist\n' ...
    'or is not in the directory which is on the MATLAB path'],...
    self.Filename);
end

% display more info about read file on console
% ---------------------------------------------
if self.Echo
  fprintf('\nREAD_NETCDF_FILE\n'); tic;
  fprintf('nc_id: %u\tmode: %s\n', self.nc_id, self.Mode);
  fprintf('...reading ''%s'' : ', self.Filename);
end

% returns the number of dimensions, variables, global attributes and
% eventually unlimited dimension in a netCDF file.
% ------------------------------------------------------------------
[n_dims, nvars, ngatts, unlimdimid] = netcdf.inq(self.nc_id);

% get dimensions and store to netcdf hashtable
% --------------------------------------------
for dimid = 0:n_dims-1
  
  % initialize empty structure
  % --------------------------
  s = [];
  
  % Get name and length of id dimension
  % -------------------------------------
  [dimname, dimlen] = netcdf.inqDim(self.nc_id, dimid);
  
  % Get dimid (dimension id) from name
  % normalement pas besoin, a verifier....
  % ----------------------------------
  %dimid = netcdf.inqDimId(self.nc_id, dimname);
  
  % fill dimension structure with name and boolean for unlimdimid
  % -------------------------------------------------------------
  s.dimlen = dimlen;
  if(dimid == unlimdimid)
    s.unlimited = true;
  else
    s.unlimited = false;
  end
  
  % put dimension name and length to Dimensions struct
  % --------------------------------------------------
  self.Dimensions.(dimname) = s;
end

% get variables and store to netcdf hashtable
% -------------------------------------------
for id = 0:nvars-1
  
  % initialize empty structure
  % --------------------------
  s = [];
  
  % return information about variable
  % ---------------------------------
  [varName, xtype, dimids, natts] = netcdf.inqVar(self.nc_id, id);
  
  % fill structure s with variable attribute names and values
  % ---------------------------------------------------------
  for attid = 0:natts-1
    
    % get attribute name
    % ------------------
    attName = netcdf.inqAttName(self.nc_id, id, attid);
    
    % if attribute name is '_FillValue', transforme to 'FillValue,
    % because Matlab dosn't handle member name begining with '_'
    % ------------------------------------------------------------
    if strcmp(attName, '_FillValue')
      s.('FillValue_') = netcdf.getAtt(self.nc_id, id, attName);
      
    else
      
      % otherwise, dynamically fill attribute member of structure s
      % with it's value
      % -----------------------------------------------------------
      s.(attName) = netcdf.getAtt(self.nc_id, id, attName);
    end
    
  end  % end for loop over variable attributes
  
  % add internal type__ member from xtype 2->char, 6->double
  % --------------------------------------------------------
  s.type__ = datagui.netcdf.getConstantNames(xtype);
  
  % fill temporary structure s with value
  % -------------------------------------
  s.data__ = netcdf.getVar(self.nc_id, id);
  
  % If a NetCDF variable has valid scale_factor and add_offset
  % attributes, then the data is scaled accordingly.
  % ----------------------------------------------------------
  if self.AutoScale
    if isfield(s, 'scale_factor') && isfield(s, 'add_offset')
      s.data__ = s.data__ * s.scale_factor + s.add_offset;
    end
  end
  
  % replace FillValue_ by NaN only for numeric variable
  % AutoNan mode is set to true by default
  % ---------------------------------------------------
  if self.AutoNan && isfield(s, 'FillValue_')
    switch(xtype)
      case self.NC_CHAR
        % do nothing, FillValue as no sense for char.
        
      case { self.NC_DOUBLE, self.NC_FLOAT, self.NC_LONG,...
          self.NC_SHORT, self.NC_BYTE }
        
        % sometimes, FillValue could be a char in malformed NetCDF
        % files
        % --------------------------------------------------------
        if isnumeric(s.('FillValue_'))
          s.data__(s.data__ == s.('FillValue_')) = NaN;
        else
          s.data__(s.data__ == str2double(s.('FillValue_'))) = NaN;
          
          % verrue, pour les fichiers Roscop netcdf mal form�s
          % --------------------------------------------------
          if str2double(s.('FillValue_')) > 1e35
            s.data__(s.data__ >= 1e35) = NaN;
          end
        end
        
      otherwise
        error('datagui:netcdf:read', 'unhandled datatype %d\n', xtype );
    end % end switch
  end % end if
  
  % if var is char and as vertical alignment, transpose it
  % ------------------------------------------------------
  if xtype == self.NC_CHAR && (size(s.data__', 1) == 1)
    s.data__ = s.data__';
    
    % Because MATLAB uses FORTRAN-style indexing, we need to transpose
    % N-D array (k,i,j,...) to (i,j,k,...) however, the order of
    % the dimension IDs is reversed relative to what would be obtained
    % from the C API
    % If s.data__ is a vector, NetCDF API return vertical vector,
    % do nothing, it's OK
    % -----------------------------------------------------------------
  elseif length(dimids) > 1
    s.data__ = permute(s.data__, fliplr(1:length(dimids)));
    dimids = fliplr(dimids);
  end
  
  % add internal dimension__ member with dimensions names
  % -----------------------------------------------------
  for dimid = 1:numel(dimids)
    dimname = netcdf.inqDim(self.nc_id, dimids(dimid));
    
    % add next dimension name to cell
    % -------------------------------
    s.dimension__{dimid} = dimname;
  end
  
  % in case of unlimited dimensions set at 0
  % ----------------------------------------
  if isempty(dimids)
    s.dimension__ = [];
  end
  
  % put variable name and value to Variables struct
  % -----------------------------------------------
  self.Variables.(varName) = s;
  
end

% get gloabal attributes and store to netcdf object
% -------------------------------------------------
for id = 0:ngatts-1
  
  % Get the name of the global attribute associated with the
  % variable.
  % --------------------------------------------------------
  gattName = netcdf.inqAttName(self.nc_id, ...
    datagui.netcdf.NC_GLOBAL, id);
  
  % Get value of global attribute.
  % ------------------------------
  theValue = netcdf.getAtt(self.nc_id, ...
    datagui.netcdf.NC_GLOBAL, gattName);
  
  % put variable name and value to Attributes struct
  % dynamically fill attribute member of structure swith it's value
  % ------------------------------------------------------------
  if isvarname(gattName)
    self.Attributes.(gattName) = theValue;
  else
    % if attribute name begin with invalid variable name and has the
    % form '_varname' like '_NCProperties', transforme to 'NCProperties_'
    % because Matlab doesn't handle member name begining with '_'
    % --------------------------------------------------------------
    match = regexp( gattName, '^(_)(.*$)', 'tokens');
    if ~isempty(match)
      gattName = strcat(match{1}{2}, match{1}{1});
      self.Attributes.(gattName) = theValue;
    else
      error(message('MATLAB:datagui:netcdf;read;InvalidAttributeName'));
    end
  end
 
end

% close netcdf file
% -----------------
netcdf.close(self.nc_id)

% Display time to read file on console
% -------------------------------------
if self.Echo
  t = toc; fprintf('...done (%6.2f sec).\n',t);
end

end
