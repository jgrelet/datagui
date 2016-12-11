function xls_chimie_to_odv
% This script read chemical analyses oxygen, salinity and nutrients and
% write them in ODV file
%
% from US191 IMAGO Excel chemical file
%
% J Grelet - IRD-US191 - feb 2015

% define position
% ---------------
columns  = [1,7,5,14,17,3,19,21,23,25,27];
lines    = 1:24;

% open an instance of excelRead object
% ------------------------------------
% for debug
%xls = excelRead('PIRATA FR 25_chimie.xlsx');
% in production
xls = excelRead;

% get cruise name
% ---------------
cruise = xls.read(xls.sheets{1}, 'F2');

% create and open ODV file
% ------------------------
[pathName, fileName, ~] = fileparts(xls.file);
odv_file = fullfile(pathName, strcat(fileName,'_odv.txt'));
fid_odv = write_odv_header(odv_file);

% get sheet name
% ---------------
match = regexp( xls.sheets, '^(\d+)_(\d+)', 'tokens');
if ~isempty(match)
  sheets = find(cellfun('isempty', match) == 0);
else
  error('xlsRead:No oxygen profil, check your Excel file...');
end

% loop over sheets station in the file
% ------------------------------------
for k = sheets   
  
  % extract station number from sheet name
  % --------------------------------------
  station = sprintf('st%sc%s', match{k}{1}{1}, match{k}{1}{2});
  
  % read Excel worksheet in raw mode (unprocessed cell content) which
  % contains both numeric and text data, empty cell is fillwith NaN
  % -----------------------------------------------------------------
  fprintf('Read station %s\n', station)
  %
  [date,latitude,longitude,data] = ...
    xls.read(xls.sheets{k},'P11','Q9','Q10','C34:AC57');
  
  % reverse sampling order
  % ----------------------
  data = flip(data);
  
  % convert cell arrayto mat, or cell by cell if cell array contains 
  % mixed data types
  % ----------------------------------------------------------------
  try
    data = cell2mat( data );
  catch
    data = convert_cell( data );
  end
  
  % get data for a station
  % ----------------------
  BOTL  = data(:,1);
  DEPTH = data(:,2);
  PSAL  = data(:,3);
  DOX1  = data(:,4);
  DOX2  = data(:,5);
  NTIW  = data(:,7);
  NTIW_NTAW = data(:,8);
  NTAW  = data(:,9);
  PHOW  = data(:,10);
  SLCW  = data(:,11);
  
  % loop over level
  % ---------------
  for j = 1 : size(data,1)
    
    % if no bottle, goto next line
    % ---------------------------
    if isnan(DEPTH(j))
      continue
    end
        
    % save all data to ODV file, if data is NaN, print tab
    % ----------------------------------------------------
    fprintf( fid_odv, '%s\t%s\tB\t%s\t%+8.3f\t%+7.3f\t\t', ...
      cruise, station, date, longitude, latitude);
    if isnan(DEPTH(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%6.1f\t', DEPTH(j));
    end
    if isnan(BOTL(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%2d\t', BOTL(j));
    end
    if isnan(PSAL(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%7.3f\t', PSAL(j));
    end
    if isnan(DOX1(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%5.3f\t', DOX1(j));
    end
    if isnan(DOX2(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%6.2f\t', DOX2(j));
    end
    if isnan(NTIW(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%5.2f\t', NTIW(j));
    end
    if isnan(NTIW_NTAW(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%7.3f\t', NTIW_NTAW(j));
    end
    if isnan(NTAW(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%5.3f\t', NTAW(j));
    end
    if isnan(PHOW(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%6.2f\t', PHOW(j));
    end
    if isnan(SLCW(j))
      fprintf( fid_odv, '\t');
    else
      fprintf( fid_odv, '%5.2f\t', SLCW(j));
    end

    
    % print eol
    % ----------
    fprintf( fid_odv, '\n');
    
  end
  
end

% end
% ----------
fprintf( 1, 'Done ...\n');

% close object and file
% ---------------------
delete(xls);
fclose(fid_odv);


  % convert cell array cell by cell if it contains mixed data types
  % ----------------------------------------------------------------
  function [out] = convert_cell( data )
    
      out = nan(size(data));
      
      % initialize array indice
      % ------------------------
      ii=1;jj=1;
      
      % loop over lines and columns
      % ---------------------------
      for l = lines
        
        for c = columns
          
          % get value from cell
          % -------------------
          value = data{l,c};
          
          % get only double value, set to Nan for other cell
          % ------------------------------------------------
          if ~isempty(value)
            if ischar(value)
              out(ii,jj) = str2double(value);
            else
              out(ii,jj) = value;
            end
          else
            out(ii,jj) = NaN;
          end
          jj = jj + 1;  % increment array indices for data: next column
          
        end % end loop over columns
        
        ii = ii + 1; % increment array indices for data: next line
        jj = 1;      % reset column
        
      end % end loop over lines
  end

% create header for ODV file
% --------------------------
  function [fid] = write_odv_header( odv_filename)
    
    % Open the file
    % -------------
    fid = fopen( odv_filename, 'wt' );
    if fid ~= -1
      
      % Display more info about write file on console
      % ---------------------------------------------
      fprintf('...writing ODV file: %s ... \n', odv_filename);
      
      today = datestr(now, 'YYYY-mm-ddTHH:MM:SS');
      fprintf(fid, '//ODV Spreadsheet file : %s\n', odv_filename);
      fprintf(fid, '//Data treated : %s\n', today);
      fprintf(fid, '//<InstrumentType>Chemical bottle analysis</InstrumentType>\n');
      fprintf(fid, '//<Source>%s</Sources>\n', xls.file);
      fprintf(fid, '//<DataType>Bottles</DataType>\n');
      fprintf(fid, '//<Creator>Jacques.Grelet@ird.fr</Creator>\n');
      fprintf(fid, '//\n');
      fprintf(fid, 'Cruise\tStation\tType\tyyyy-mm-ddThh:mm:ss\tLongitude [degrees_east]\tLatitude [degrees_north]\t');
      fprintf(fid, 'Bot. Depth [m]\tDEPTH [m]\tBottle nb\tPSAL [Psu]\tDOX1 [ml/l]\tDOX2 [micromole/kg]\t');
      fprintf(fid, 'NTIW [micromole/kg]\tNTAW+NTIW [micromole/kg]\tNTAW [micromole/kg]\t');
      fprintf(fid, 'PHOW [micromole/kg]\tSLCW [micromole/kg]\n');
    end
    
  end % end of write_odv_header

end


