function gen_datagui_test
%GEN_DATGUI_TEST Generate Netcdf test file using Matlab high-level function
%
% use last version of netcdf toolbox of Matlab > R2011a
%
% $ ncdump us191_test.nc
%
% netcdf us191_test {
% dimensions:
% 	LONX = 3 ;
% 	LATX = 2 ;
% 	LEVEL = 2 ;
% 	TIME = UNLIMITED ; // (1 currently)
% variables:
% 	short TEMP(TIME, LEVEL, LATX, LONX) ;
% 		TEMP:scale_factor = 0.0005 ;
% 		TEMP:add_offset = 20. ;
% 		TEMP:_FillValue = 9999s ;
% 	double test(LATX, LONX) ;
% 
% // global attributes:
% 		:creation_date = "20120110T093750Z" ;
% data:
% 
%  TEMP =
%   222, 666, 1110,
%   444, 888, 1332,
%   3554, 3998, _,
%   3776, 2246, 2642 ;
% 
%  test =
%   20.1, 20.3, NaN,
%   20.2, 20.4, 20.6 ;
% }
%
% check file under Matlab:
%
% >> datagui.ncload('us191_test.nc','TEMP','test')
% 
% READ_NETCDF_FILE
% ...reading 'us191_test.nc' : ...done (  0.03 sec).
% TEMP
% 
% TEMP(:,:,1) =
% 
%    20.1110   20.2220
%    20.3330   20.4440
%    20.5550   20.6660
% 
% 
% TEMP(:,:,2) =
% 
%    21.7770   21.8880
%    21.9990   21.1230
%        NaN   21.3210

clear all

% define FillValue for integer or int16 -> NC_SHORT
fill_value = int16(9999);

% set fileName
fileName = 'datagui_test.nc';

% delete file when exist 
if ispc
  system(['del ', fileName]);
elseif isunix
  system(['\rm ', fileName]);
else
  error('unknow system');
end

% create netcdf file with it's dimensions
% matrix(lines, rows) -> TEMP(LONX, LATX)
nccreate(fileName, 'TEMP','Dimensions',{'LONGITUDE' 3 'LATITUDE' 2, 'DEPTH' 2, 'TIME',Inf},...
          'Datatype', 'int16', 'Format','classic'); 
nccreate(fileName, 'test','Dimensions',{'LONGITUDE' 3 'LATITUDE' 2});

% define and write variable attributes (single -> float)
ncwriteatt(fileName, 'TEMP', 'scale_factor', 0.0005);
ncwriteatt(fileName, 'TEMP', 'add_offset',   20.);
% define and write _FillValue (int16 -> NC_SHORT)
ncwriteatt(fileName, 'TEMP', '_FillValue', fill_value);

% write global attribute
ncwriteatt(fileName, '/', 'creation_date', datestr(now, 'yyyymmddTHHMMSSZ'));

% define the temperature variable TEMP for test
TEMP(:,:,1,1) = [20.111 20.222; 20.333 20.444; 20.555 20.666];
TEMP(:,:,2,1) = [21.777 21.8882; 21.999 21.123; NaN 21.321];

% get NaN indices
ind = isnan(TEMP);

% need convert TEMP to short
TEMP = int16(round((TEMP - 20.)/ 0.0005));

% set _Fillvalue into variable
TEMP(ind) = fill_value;

% just another test
test = [20.1 20.2; 20.3 20.4; NaN 20.6];

% write variables
ncwrite(fileName,'TEMP', TEMP);
ncwrite(fileName,'test', test);

% display info with Matlab hi-level function
ncdisp(fileName);

% display info with datagui toolbox
datagui.ncdump(fileName);

% load into workspace with datagui toolbox
datagui.ncload(fileName);