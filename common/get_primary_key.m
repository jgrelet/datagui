function [keys] = get_primary_key( keys, all )
% get_primary_key:
% ne garde que les variables "primaires" correspondants aux codes Roscop
% (ie: TEMP, PSAL, etc) sans prendre en compte les variables Coriolis,
% (TEMP_QC, TEMP_ADJUSTED, etc...)
%
% $Id$

codes = regexpi(keys,'(^\w{4})','match');

keys = [];

% return all primary keys including PRES, DEPH or HEIG
% ----------------------------------------------------
if all
  keys = codes{1};
  for i=2: numel(codes)
    if ~(strcmp(codes{i},'ETDD'))
      if ~(strcmp(codes{i},codes{i-1}))
        keys = [keys;codes{i}];
      end
    end
  end
else
  
  % return all primary keys without PRES, DEPH or HEIG
  % --------------------------------------------------------
  if ~(strcmp(codes{1},'PRES') || strcmp(codes{1},'DEPH')|| ...
      strcmp(codes{1},'HEIG') || strcmp(codes{1},'ETDD') )
    keys = codes{1};
  end
  % first pass, remove these parameters
  for i=2: numel(codes)
    if ~(strcmp(codes{i},'PRES') || strcmp(codes{i},'DEPH')|| ...
        strcmp(codes{i},'HEIG') || strcmp(codes{i},'ETDD') )
      keys = [keys;codes{i}];
    end
  end
  % second pass, remove _QC, _CAL, etc
  for i=2: numel(codes)
    if strcmp(codes{i},codes{i-1})
      keys = [keys;codes{i}];
    end
  end
  
end