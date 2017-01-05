function [] = OSctd2OneOS(varargin)
% function [] = OSctd2OneOS(varargin);
%
% function to save OceanSITES CTD data into a one OceanSITES netcdf file per profile
%
% input  : fileName, the OceanSITES netcdf file
%          start, stop: indice to process
%
% example: 
% process all files
% OSctd2OneOS('OS_PIRATA-FR25_CTD.nc')
% process stations
% OSctd2OneOS('OS_PIRATA-FR25_CTD.nc', 001, 008)
%
% for debug and test only
% fileName = 'OSctd2OScdf.nc';
% varargin = {'OSctd2OScdf.nc'};
% nargin = 1;

% check arguments
if nargin < 1
  nc = datagui.netcdf;
else
  nc = datagui.netcdf( varargin{1} );
end
  
% get profile list
profiles = nc.Variables.PROFILE.data__;

% get loop indices from station numbers
if nargin == 3
  start = find(profiles == varargin{2});
  stop  = find(profiles == varargin{3});
else  % process all
  start = 1;
  stop = length(profiles);
end

if isempty(start) || isempty(stop)
  error('bad values for start or stop');
end

% loop over each profiles
for i = start : stop
  
  % construct output filename from PROFILE variable
  fileNameOut = sprintf( 'data/nc/OS_FR26_201603_D_CTD%05d.nc', profiles(i));
  
  % open a new empty netcdf file
  ncout = datagui.netcdf( 'memory' );
  
  % write dimensions
  for k =  keys(nc, 'Dimensions');
    key = char(k);
    ncout.Dimensions.(key) = nc.Dimensions.(key);
    if strcmp(key, 'TIME')
      ncout.Dimensions.(key).dimlen = 1;
    end
    % in future, get the DEPTH for each profile to define DEPTH dimension ?
  end

%   % write dimensions (FR26) 
%   for k =  {'TIME','LATITUDE','LONGITUDE','PRES'};
%     key = char(k);
%     ncout.Dimensions.(key) = nc.Dimensions.(key);
%     if strcmp(key, 'TIME')
%       ncout.Dimensions.(key).dimlen = 1;
%     end
%     % in future, get the DEPTH for each profile to define DEPTH dimension ?
%   end
  
  % write global attributes
  for k = keys(nc, 'Attributes')
    key = char(k);
    switch lower(key)
      case 'date_creation'
%         date = datestr(datenum(nc.Attributes.(key).data__,...
%           'yyyymmddHHMMSS'), 'yyyy-mm-ddTHH:MM:SSZ');
%         ncout.Attributes.date_update.data__ = date;
      otherwise
        ncout.Attributes.(key).data__ = nc.Attributes.(key).data__;
    end
  end
  ncout.Attributes.plateform_code.data__ = 'FNFP';
  ncout.Attributes.data_mode.data__ = 'D';
  ncout.Attributes.quality_control_indicator.data__ = 0;
  ncout.Attributes.history.data__ = ...
    strcat(datestr(now,'yyyy-mm-ddTHH:MM:SSZ'), ' data collected, J. Grelet');
  ncout.Attributes.author.data__ = 'Jacques Grelet';
  ncout.Attributes.contact.data__ = 'Jacques Grelet@ird.fr, Bernard.Bourles@ird.fr';
  ncout.Attributes.geospatial_lat_min.data__ = ...
    sprintf('%+4.2f', nc.Variables.LATITUDE.data__(i));
  ncout.Attributes.geospatial_lat_max.data__ = ...
     sprintf('%+4.2f', nc.Variables.LATITUDE.data__(i));
  ncout.Attributes.geospatial_lon_min.data__ = ...
     sprintf('%+5.2f', nc.Variables.LONGITUDE.data__(i));
  ncout.Attributes.geospatial_lon_max.data__ = ...
     sprintf('%+5.2f', nc.Variables.LONGITUDE.data__(i));

  % write variables
  % get all variables names and attributes in structures (name and att)
  for k =  keys(nc, 'Variables');
    key = char(k);
    att = fieldnames(nc.Variables.(key));
    for iatt = 1 : length(att)
      ncout.Variables.(key).(att{iatt}) = nc.Variables.(key).(att{iatt});
      if strcmp(att{iatt}, 'data__')
        data = nc.Variables.(key).data__;
        [~,n] = size(nc.Variables.(key).data__);
        if n == 1
          ncout.Variables.(key).data__ = data(i);
        else
          ncout.Variables.(key).data__ = data(i,:);
        end
      end
    end
      
  end
  
  % write each netcdf file
  ncout.write( fileNameOut, 'NC_CLOBBER' );
  
  % call destructot
  close( ncout );
  
end

% close file
close(nc);
