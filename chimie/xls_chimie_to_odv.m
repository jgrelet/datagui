function xls_chimie_to_odv
% This script read chimical analyses (oxygen and salinity) and
% apend 3 columns (salc, oxyc, tmpo) in CADHYAC-LPO chimical file
%
% from US191 IMAGO Excel file
%
% J Grelet - LOSS cruise - IRD-US191 - dec 2014

% select Excel filename
% ---------------------
% [fileName, pathName] = uigetfile(...
%   {'*.xls;*.xlsx','Excel (*.xls,*.xlsx)'}, 'Select file');

% for debug, uncomment these lines
% --------------------------------
fileName = 'PIRATA FR 25_chimie.xlsx';
pathName = 'C:\git\datagui\chimie\';

if any(fileName)
  excel_file = fullfile(pathName, fileName);
  [pathName, fileName, ~] = fileparts(excel_file);
  odv_file = fullfile(pathName, strcat(fileName,'_odv.txt'));
  fid = fopen(odv_file,'w');
else
  error('xls_chimie_to_odv: you must select a file');
end


% read Excel worksheet in raw mode (unprocessed cell content) which
% contains both numeric and text data, empty cell is fillwith NaN
% -----------------------------------------------------------------
%[stations, dates, latitudes, longitudes, cdata] = read_excel_oxygen_file(excel_file);

[stations, dates, latitudes, longitudes, cdata] = read_excel_oxygen_automation(excel_file);



% loop over station number and jump to next station if missing
% ------------------------------------------------------------
for istn = 1 : length(stations)
  
  % get data for a station
  % ----------------------
  BOTL  = cdata(:,1,istn)';
  DEPTH = cdata(:,2,istn)';
  PSAL  = cdata(:,3,istn)';
  DOX1  = cdata(:,4,istn)';
  DOX2  = cdata(:,5,istn)';
  % tmpo  = cdata(:,6,istn)';
  NTRI  = cdata(:,7,istn)';
  NTRI_NTRA = cdata(:,8,istn)';
  NTRA  = cdata(:,9,istn)';
  PHOS  = cdata(:,10,istn)';
  SLCA  = cdata(:,11,istn)';
  
  % for each sample
  % -----------------
  for ll=1 : 24
    
    % display on console
    % -----------------
    if ~isnan(DEPTH(ll))
      fprintf(1, '%3d %s %-5.2f %-6.2f %2d %7.1f  %6.3f  %6.3f %5.1f %5.2f %5.2f %5.2f %5.2f %5.2f\n', ...
        stations(istn), dates{istn}, latitudes(istn), longitudes(istn),...
        BOTL(ll), DEPTH(ll), PSAL(ll), DOX1(ll), DOX2(ll),...
        NTRI(ll),NTRI_NTRA(ll), NTRA(ll), PHOS(ll), SLCA(ll));
      
      % write to file
      % -------------
      fprintf(fid, '%3d %2d %7.1f  %6.3f  %6.3f %5.1f %5.2f %5.2f %5.2f %5.2f %5.2f\n', ...
        stations(istn),  BOTL(ll), DEPTH(ll), PSAL(ll), DOX1(ll), DOX2(ll),...
        NTRI(ll),NTRI_NTRA(ll), NTRA(ll), PHOS(ll), SLCA(ll));
    end
  end
end

% close file
% ----------
fclose(fid);

% ----------------------------------------------------------
  function [stations, dates, latitudes, longitudes, data] = read_excel_oxygen_automation(fileName)
    
    % open
    % ------
    Excel = actxserver('Excel.Application');
    Workbook = Excel.Workbooks.Open(fileName);
    
    % get sheets filename
    % -------------------
    sheet = cell(1, Excel.Sheets.Count);
    for idx = 1 : Excel.Sheets.Count
      sheet{idx} = Excel.Sheets.Item(idx).Name;
    end
    
    match = regexp( sheet, '^(\d+)_\d+', 'tokens');
    if ~isempty(match)
      sheets = find(cellfun('isempty', match) == 0);
    else
      disp('No oxygen profil, check your Excel file...');
      return
    end
    
    % allocate arrays size
    % -------------------
    columns  = [1,7,5,14,17,3,19,21,23,25,27];
    lines    = 1:24;
    data = zeros(length(lines), length(columns), length(sheets));
    stations = zeros(1,length(sheets));
    dates = cell(length(sheets),1);  % cell for char
    latitudes = zeros(1,length(sheets));
    longitudes = zeros(1,length(sheets));
    
    % loop over each excel sheet
    % add a regex to loop over "station xx" header only
    % --------------------------
    for k = sheets   % loop over sheets station in the file
      
      % extract station number from sheet name
      % --------------------------------------
      station = str2double(match{k}{1});
      stations(k) = station;
      
      % read Excel worksheet in raw mode (unprocessed cell content) which
      % contains both numeric and text data, empty cell is fillwith NaN
      % -----------------------------------------------------------------
      fprintf('Read station %d\n', station)
      
      ActiveSheet = Excel.Worksheets.Item(sheet{k});
      dates{k} = ActiveSheet.Range('P11').Value;
      latitudes(k) = ActiveSheet.Range('Q9').Value;
      longitudes(k) = ActiveSheet.Range('Q10').Value;
      raw = ActiveSheet.Range('C34:AC57').Value;  % return cell
      
      % initialize array indice
      % ------------------------
      ii=1;jj=1;
      
      % loop over lines and columns
      % ---------------------------
      for i = lines
        
        for j = columns
          
          % get value from cell
          % -------------------
          value = raw{i,j};
          
          % get only double value, set to Nan for other cell
          % ------------------------------------------------
          if ~isempty(value)
            if ischar(value)
              data(ii,jj,k) = str2double(value);
            else
              data(ii,jj,k) = value;
            end
          else
            data(ii,jj,k) = NaN;
          end
          jj = jj + 1;  % increment array indices for data: next column
          
        end % end loop over columns
        
        ii = ii + 1; % increment array indices for data: next line
        jj = 1;      % reset column
        
      end % end loop over lines
      
    end
    
    % reverse sampling order
    % ----------------------
    data = flip(data);
    
    % Fermeture du classeur
    Workbook.Close(false);
    
    % quit Excel and delete object
    % ---------------------------
    Excel.Quit;
    delete(Excel)
    
  end % end of read_excel_oxygen_automation

% This function read chimical analyses (salinity and oxygen)
% from US191 IMAGO Excel file
% return an array data [depth, salinity, oxygen, station]
%
% J Grelet - PANDORA cruise - IRD-US191 - July 2012
% ----------------------------------------------------------
  function [stations, dates, latitudes, longitudes, data] = read_excel_oxygen_file(fileName)
    
    % open xls info and get informations
    % ----------------------------------
    [~, sheet] = xlsfinfo( fileName);
    
    % line 33 to 44 pour rosette 12 bouteilles
    % line 33 to 56 pour rosette 24 bouteilles
    %
    % profondeur: column 9 (I)
    % num btl:    column 3 (C)
    % salinity:   column 7 (G)
    % oxygen (ml/l): column 16 (P)
    % oxygen (umol/kg): column 19 (S)
    % tmp0 (T prelevement): column 5 (E)
    % ----------------
    columns  = [3,9,7,16,19,5,21,23,25,27,29];
    lines    = 34:57;
    
    % get sheets name and number in Excel file
    % ----------------------------------------
    match = regexp( sheet, '^(\d+)_\d+', 'tokens');
    if ~isempty(match)
      sheets = find(cellfun('isempty', match) == 0);
    else
      disp('No oxygen profil, check your Excel file...');
      return
    end
    
    % for debug only
    % --------------
    %     if isempty(last_station)
    %       last_station = length(sheets);
    %     end
    
    % allocate arrays size
    % -------------------
    data = zeros(length(lines), length(columns), length(sheets));
    stations = zeros(1,length(sheets));
    dates = cell(length(sheets),1);  % cell for char
    latitudes = zeros(1,length(sheets));
    longitudes = zeros(1,length(sheets));
    
    % loop over each excel sheet
    % add a regex to loop over "station xx" header only
    % --------------------------
    for k = sheets   % loop over sheets station in the file
      
      % extract station number from sheet name
      % --------------------------------------
      station = str2double(match{k}{1});
      stations(k) = station;
      
      % read Excel worksheet in raw mode (unprocessed cell content) which
      % contains both numeric and text data, empty cell is fillwith NaN
      % -----------------------------------------------------------------
      fprintf('Read station %d\n', station)
      [~,~,raw] = xlsread( fileName, sheet{k} );
      
      % get date and position
      % ---------------------
      dates{k}      = raw{11, 16};
      latitudes(k)  = raw{9, 17};
      longitudes(k) = raw{10, 17};
      
      % initialize array indice
      % ------------------------
      ii=1;jj=1;
      
      % loop over lines and columns
      % ---------------------------
      for i = lines
        
        for j = columns
          
          % get value from cell
          % -------------------
          value = raw{i,j};
          
          % get only double value, set to Nan for other cell
          % ------------------------------------------------
          if ~isempty(value)
            if ischar(value)
              data(ii,jj,k) = str2double(value);
            else
              data(ii,jj,k) = value;
            end
          else
            data(ii,jj,k) = NaN;
          end
          jj = jj + 1;  % increment array indices for data: next column
          
        end % end loop over columns
        
        ii = ii + 1; % increment array indices for data: next line
        jj = 1;      % reset column
        
      end % end loop over lines
      
    end  % end loop over sheets
    
    % reverse sampling order
    % ----------------------
    data = flip(data);
    
  end % end read_excel function

end % end of main function
