function self = transform(self)
% private datagui.oceansites function used to transform a dynaload
% template to real netcdf structure
%
% $Id: transform.m 213 2013-01-23 16:52:18Z jgrelet $

% get template variables list 
% ---------------------------
variables = self.VARIABLES;

% get parameters codesRoscop from PARAMETERS list 
% -----------------------------------------------
codesRoscop = self.PARAMETERS;

% call process
% -----------------------------------------
process(self.physicalParameters, 'x_variable_x');
process(self.levelParameters,  'x_level_x');
if regexpi(self.type, 'profil')
  process({'STATION'}, 'x_station_x');
  process({'CAST'}, 'x_cast_x');
else
  % for trajectory and timeseries, remove {station} & {cast}
  % --------------------------------------------------------
  for tpl = {'x_station_x', 'x_cast_x'}
     variables = rmfield( variables, char(tpl));
  end
%   variables = rmfield( variables, 'x_station_x'); 
%   variables = rmfield( variables, 'x_cast_x'); 
end

  % nested function process
  % -----------------------
  function process(parameters, template)
    % iterate on each physical parameters
    % self.physicParameters = {'TEMP','PSAL','DOX2',...}
    % -------------------------------------------------
    for para = parameters
      
      % convert cell to char
      % --------------------
      pp = char(para);
      
      % get the structure of physical parameter  (ssop)
      % ----------------------------------------------
      sopp = codesRoscop.(pp);
      
      % add new physical parameter to the hashtable property VARIABLES
      % ------------------------------------------------------------------
      self.VARIABLES.(pp) = sopp;
      
      % get keys and templates structure (cell array)
      % --------------------------------------------
      cles = keys(self, 'VARIABLES');
      ts   = values(self,'VARIABLES');
      
      % produce indexing cell array that match '{template}'
      % ---------------------------------------------------
      match = regexp(cles, (template), 'once');
      
      % loop over templates structure
      % -----------------------------
      for i = 1: numel(match)
        
        % s is the template structure
        % ---------------------------
        s = ts{i};
        
        % process only matching values (==1)
        % ---------------------------------
        if ~isempty(match{i})
          
          % get key for each physical parameter template,
          % eg TEMP, TEMP_QC, TEMP_CAL, ....
          % -----------------------------------------------
          variable = regexprep(cles{i}, template, pp);
          
          % don't process physical parameter, eg TEMP, PSAL, ...
          % ----------------------------------------------------
          if ~strcmp(cles{i}, template)
            
            % replace template {variable} in all variable attribute
            % -----------------------------------------------------
            for j = fieldnames(s)'
              
              % convert cell 2 char
              % -------------------
              member = char(j);
              
              % find and replace template only on string member
              % -----------------------------------------------
              if ischar(s.(char(j)))
                
                % replace in each structure member template with parameter
                % --------------------------------------------------------
                s.(member) = regexprep(s.(member), '{variable}', pp);
                
                % produce indexing cell array that match '{template}'
                % ---------------------------------------------------
                memberMatch = regexp(s.(char(j)), '(.*)x_(\w+)_x(.*)','tokens');
                
                if ~isempty(memberMatch)
                  try
                    if strcmp(j, 'key__')
                      s.(char(j)) = [char(memberMatch{1}{1}) ...
                        sopp.key__ char(memberMatch{1}{3})];
                    else
                      s.(char(j)) = [char(memberMatch{1}{1}) ...
                        sopp.(char(memberMatch{1}{2})) char(memberMatch{1}{3})];
                    end
                  catch ME
                    %disp(s);
                    warning('oceansites:transform', ...
                      ' ''%s'' function: %s, line: %d, parameter: %s \n',...
                      ME.message, ME.stack(1).name, ME.stack(1).line, s.key__);
                  end
                end
                
              end
            end
            
            % add new physical parameter key to Map
            % -----------------------------------------------
            self.VARIABLES.(variable) = s;
            
          end % if ~strcmp(cles{i}, template)
          
        end % if ~isempty(match{i})
        
      end % for i = 1: numel(match)
      
    end % for para = parameters
    
    for i = 1: numel(match)
      
      % process only matching values (=1)
      % ---------------------------------
      if ~isempty(match{i})
        
        % remove key from structure
        % -------------------------
        self.VARIABLES = rmfield(self.VARIABLES, cles{i});
        
      end
      
    end % for i = 1: numel(match)
    
  end % end function process

end % end function transform


