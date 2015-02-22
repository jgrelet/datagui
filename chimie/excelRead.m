classdef excelRead
  % Read Microsoft Excel spreadsheet file using low level fonction under
  % Windows
  %
  % xls = excelRead('test_chemical.xlsx')
  % [varargout] = xls.read(worhsheet,range,...);
  %
  % example:
  % xls = excelRead('test_chemical.xlsx')
  % [date,lat,lon,data] = xls.read('041_01','P11','Q9','Q10','C34:AC57')
  
  % Properties definition
  % ---------------------
  properties
    file
    sheets
  end
  
  properties( Access = private)
    excel
    workbook
  end
  
  methods
    
    % Constructor
    % -----------
    function self = excelRead(file)
      
      % pre initialization - select Excel filename
      % ------------------------------------------
      if nargin < 1 || isempty(file)
        [fileName, pathName] = uigetfile(...
          {'*.xls;*.xlsx','Excel (*.xls,*.xlsx)'}, 'Select file');
        
        if isempty(fileName)
          error(message('MATLAB:xlsread:FileName'));
        else
          file = fullfile(pathName, fileName);
        end
      end
      
      if ~ischar(file)
        error(message('MATLAB:xlsread:InvalidFileName'));
      end
      
      % excel automation need full file
      file = fullfile(which(file));
      
      % post initialization
      self.file = file;
      
      self.excel = actxserver('Excel.Application');
      self.workbook = self.excel.Workbooks.Open(self.file);
      
      % get sheets filename
      % -------------------
      %sheet = cell(1, self.excel.Sheets.Count);
      for idx = 1 : self.excel.Sheets.Count
        self.sheets{idx} = self.excel.Sheets.Item(idx).Name;
      end
      
    end % end of constructor
    
    % destructor
    % -----------------------
    function delete(self)
      
      % close the worksheet
      % -------------------
      self.workbook.Close(false);
      
      % quit Excel and delete object
      % ---------------------------
      self.excel.Quit;
      delete(self.excel)
    end
    
    % return 
    function [varargout] = read(self, sheet, varargin)
      
      ActiveSheet = self.excel.Worksheets.Item(sheet);
      
      varargout = cell(1,nargin -2);
      for i=1 : nargin -2
        varargout{i} = ActiveSheet.Range(varargin{i}).Value;
      end
    end
  
  end % end of public methods

end  % end of class

