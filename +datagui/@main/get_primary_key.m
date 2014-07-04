function [key_list] = get_primary_key( self )
% get_primary_key:
% ne garde que les variables "primaires" correspondants aux codes Roscop
% (ie: TEMP, PSAL, etc) sans prendre en compte les variables Coriolis,
% (TEMP_QC, TEMP_ADJUSTED, etc...)
%
% $Id$

% get all variables names
% -----------------------
key_list = keys(self.nc, 'Variables');

% keep only name with 4 chars
% ---------------------------
codes = regexpi(key_list,'(^\w{4}$)','match');


key_list = [];

% return all primary key_list including PRES, DEPH or HEIG
% ----------------------------------------------------

for i=1: numel(codes)
  if ~isempty(codes{i})
    
    % return all primary key_list without PRES, DEPH or HEIG
    % --------------------------------------------------------
    if ~(strcmp(codes{i},'PRES') || strcmp(codes{i},'DEPH')|| ...
        strcmp(codes{i},'HEIG')  || strcmp(codes{i},'DAYD')|| ...
        strcmp(codes{i},'LATX')  || strcmp(codes{i},'LONX')|| ...
        strcmp(codes{i},'BATH')  || strcmp(codes{i},'TIME'))
      key_list = [key_list;codes{i}];
    end
  end
end
