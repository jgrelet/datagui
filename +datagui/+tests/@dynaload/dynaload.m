%% datagui.tests.dynaload
%
% This class implements tests cases on the dynaload class
% which is part of the packaqe +datagui. It is based on the 'TestCase'
% class of the xUnit Framework.
%
% You can run one particular test case implemented in a method of dynaload named
% testMethod by typing :
%
%     >> t = datagui.tests.dynaload('testMethod');
%     >> t.run
% or
%     >> runxunit datagui.tests.dynaload:testMethod
%     >> runxunit datagui.tests.dynaload -verbose
%
% For example run all tests for datagui.dynaload :
%
%     >> runxunit datagui.tests.dynaload
%     Test suite: datagui.tests.dynaload
%     Test suite location: +datagui/+tests/@dynaload/dynaload.m
%     09-Sep-2011 13:49:32
%
%     Starting test run with 9 test cases.
%     .........
%     PASSED in 0.068 seconds.
%
%     >> t = datagui.tests.dynaload('testKeys');
%     >> t.run
%     Starting test run with 1 test case.
%     .
%     PASSED in 0.009 seconds.
%
%
%
% For more details about the use of these tests, you can have a look on the
% help of the xUnit classes 'TestCase' and 'TestSuite'.
% To use MATLAB xUnit in MATLAB, add the "xunit" folder (directory)
% to the MATLAB path.

%% Classdef definition
% -------------------------------------------------------------------------
classdef dynaload < TestCase
  
  % Properties definition
  % ---------------------
  properties (Access = protected)
    
    % Locations of test.xls, test.csv and testSave.csv
    xls_filename;
    csv_filename;
    json_filename;
    dummy_filename;
    bad_filetype;
    bad_arg;
    unknown_prop;
    dynaObject;
    
  end % End of Properties definition
  
  % Class public methods
  % --------------------
  methods % (Access = public)
    
    % setup
    % -----
    function setUp(self)
      
      % get the location of directory test class dynaload
      pathstr = fileparts(mfilename('fullpath'));
      
      % construct test filename
      self.xls_filename = fullfile(pathstr, 'test.xls');
      self.json_filename = fullfile(pathstr, 'test.json');
      %if ispc
      self.csv_filename = fullfile(pathstr, 'test.csv');
      %else
      %         self.csv_filename = fullfile(pathstr, 'test_linux.csv');
      %
      %         % Disable these warning for the duration of the tests.
      %         warning('off','MATLAB:xlsread:ActiveX');
      %       end
      self.dummy_filename = 'dummy.json';
      self.bad_filetype = 'dummy.txt';
      self.bad_arg = 2;
      self.unknown_prop = 'dummy';
      
      self.dynaObject = datagui.dynaload({'Mercure', 'Venus', 'Terre', 'Test'});
      
      put(self.dynaObject, 'Mercure', {'Masse', 'Diametre', 'Densite', 'Journee',...
        'Revolution', 'DistanceSoleil'}, {struct('key__', 'Masse',...
        'Num', 1, 'Description', 'Masse comparee a la Terre', 'Unit', '',...
        'Valeur', 0.056, 'TestLogical', true), struct('key__', 'Diametre', 'Num', 2,...
        'Description', 'Diametre a l''equateur', 'Unit', 'km',...
        'Valeur', 4860, 'TestLogical', false), struct('key__', 'Densite', 'Num', 3,...
        'Description', 'Densite moyenne', 'Unit', 'g/cm3','Valeur', 5.6, 'TestLogical', true),...
        struct('key__', 'Journee', 'Num', 4, 'Description',...
        'Duree d''une journee', 'Unit', 'jours', 'Valeur', 58.6250, 'TestLogical', false),...
        struct('key__', 'Revolution', 'Num', 5, 'Description',...
        'Periode de revolution', 'Unit', 'jours', 'Valeur', 88, 'TestLogical', true),...
        struct('key__', 'DistanceSoleil', 'Num', 6, 'Description',...
        'Distance au soleil','Unit', 'Mkm', 'Valeur', 58, 'TestLogical', false)});
      
      % Venus
      put(self.dynaObject, 'Venus', {'Masse', 'Diametre', 'Densite', 'Journee',...
        'Revolution', 'DistanceSoleil'}, {struct('key__', 'Masse',...
        'Num', 1, 'Description', 'Masse comparee a la Terre', 'Unit', '',...
        'Valeur', 0.82, 'TestLogical', true), struct('key__', 'Diametre', 'Num', 2,...
        'Description', 'Diametre a l''equateur', 'Unit', 'km',...
        'Valeur', 12140, 'TestLogical', false), struct('key__', 'Densite', 'Num', 3,...
        'Description', 'Densite moyenne', 'Unit', 'g/cm3', 'Valeur',...
        5.2, 'TestLogical', true), struct('key__', 'Journee', 'Num', 4, 'Description',...
        'Duree d''une journee', 'Unit', 'jours', 'Valeur', 243, 'TestLogical', false),...
        struct('key__', 'Revolution', 'Num', 5,...
        'Description', 'Periode de revolution','Unit', 'jours', ...
        'Valeur', 225, 'TestLogical', true), struct('key__', 'DistanceSoleil', 'Num', 6,...
        'Description', 'Distance au soleil',...
        'Unit', 'Mkm', 'Valeur', 108, 'TestLogical', false)});
      
      % Terre
      put(self.dynaObject, 'Terre', {'Masse', 'Diametre', 'Densite', 'Journee',...
        'Revolution', 'DistanceSoleil'}, {struct('key__', 'Masse', 'Num',...
        1, 'Description', 'Masse comparee a la Terre', 'Unit', '',...
        'Valeur', 1, 'TestLogical', true), struct('key__', 'Diametre', 'Num', 2,...
        'Description', 'Diametre a l''equateur', 'Unit', 'km',...
        'Valeur', 12760, 'TestLogical', false), struct('key__', 'Densite', 'Num', 3,...
        'Description', 'Densite moyenne', 'Unit', 'g/cm3', 'Valeur',...
        5.5, 'TestLogical', true), struct('key__', 'Journee', 'Num', 4, 'Description',...
        'Duree d''une journee', 'Unit', 'heures', 'Valeur', 23.93, 'TestLogical', false),...
        struct('key__', 'Revolution', 'Num', 5, 'Description',...
        'Periode de revolution', 'Unit', 'jours', 'Valeur', 365.25, 'TestLogical', true),...
        struct('key__', 'DistanceSoleil', 'Num', 6,...
        'Description', 'Distance au soleil',...
        'Unit', 'Mkm', 'Valeur', 150, 'TestLogical', false)});
    end
    
    % tearDown
    % -----
    %     function tearDown(self)
    %     end
    
    % Constructor
    %------------
    function self = dynaload(testMethod)
      % Creates the test case
      self = self@TestCase(testMethod);
    end % End of contructor
    
    
    %% tests files
    % test that CSV file should be load in memory and attribute file
    % from the dynaload object is the test file
    % --------------------------------------------------------------
    function testLocateCsvFile( self )
      d = datagui.dynaload(self.csv_filename, 'echo', false);
      msg = sprintf('can''t locate %s file', self.csv_filename);
      assertEqual(d.Filename, self.csv_filename , msg);
    end
    
    function testLocateXlsFile( self )
      d = datagui.dynaload(self.xls_filename, 'echo', false);
      msg = sprintf('can''t locate %s file', self.xls_filename);
      assertEqual(d.Filename, self.xls_filename , msg);
    end
    
    function testLocateJsonFile( self )
      d = datagui.dynaload(self.json_filename, 'echo', false);
      msg = sprintf('can''t locate %s file', self.json_filename);
      assertEqual(d.Filename, self.json_filename , msg);
    end
    
    % load CSV file and check that each dynamic properties of the
    % dynaload object contain struct
    % --------------------------------------------------------------
    function testLoadCsvFile( self )
      
      % load excel test file in memory: test.csv
      d = datagui.dynaload(self.csv_filename, 'echo', false);
      
      for dp = d.getDynamicProperty
        % Test if it is hashtable Structure
        assertEqual(class(d.(char(dp))), 'struct', sprintf(...
          'd.%s doesn''t seem to be a structure.', char(dp)));
      end
      
    end
    
    % load Excel file and check that each dynamic properties of the
    % dynaload object contain hashtable
    % --------------------------------------------------------------
    function testLoadXlsFile( self )
      
      % load excel test file in memory: test.csv
      d = datagui.dynaload(self.xls_filename, 'echo', false);
      
      for dp = d.getDynamicProperty
        % Test if it is hashtable Structure
        assertEqual(class(d.(char(dp))), 'struct', sprintf(...
          'd.%s doesn''t seem to be a structure.', char(dp)));
      end
      
    end
    
    % load Json file and check that each dynamic properties of the
    % dynaload object contain hashtable
    % --------------------------------------------------------------
    function testLoadJsonFile( self )
      
      % load excel test file in memory: test.csv
      d = datagui.dynaload(self.json_filename, 'echo', false);
      
      for dp = d.getDynamicProperty
        % Test if it is hashtable Structure
        assertEqual(class(d.(char(dp))), 'struct', sprintf(...
          'd.%s doesn''t seem to be a structure.', char(dp)));
      end
      
    end
    
    % load Excel file, save it in csv and compare with
    % test.csv
    % --------------------------------------------------------------
    function testCompareFiles( self )
      
      % load excel test file in memory: test.csv
      d = datagui.dynaload(self.xls_filename, 'echo', false);
      
      % get tmp file name with csv extension
      tmpfile = strcat(tempname, '.csv');
      
      % write tmp csv ascii file
      write(d, tmpfile, 'format', 'csv');
      
      % test
      assertFilesEqual(self.csv_filename, tmpfile);
      
      % delete tmp file
      delete(tmpfile);
      
    end
    
    %% test error messages
    % example:
    % f=@() datagui.dynaload('test.csv','echo',2)
    % assertExceptionThrown(f, 'datagui:dynaload:set:Echo')
    % test OK
    % f=@() datagui.dynaload('test.csv','echo',true)
    % assertExceptionThrown(f, 'datagui:dynaload:set:Echo')
    % Expected exception "datagui:dynaload:set:Echo", but none thrown.
    % -------------------
    function testErrorFilename( self )
      % give foo filename
      assertExceptionThrown(@() datagui.dynaload(self.dummy_filename), ...
        'datagui:dynaload');
    end
    
    function testErrorFileType( self )
      % give filename with bad extension
      assertExceptionThrown(@() datagui.dynaload(self.bad_filetype), ...
        'datagui:dynaload');
    end
    
    function testErrorBadArg( self )
      assertExceptionThrown(@() datagui.dynaload(self.bad_arg), ...
        'datagui:dynaload');
    end
    
    function testErrorUnknowProp( self )
      assertExceptionThrown(@() datagui.dynaload(self.json_filename, ...
        self.unknown_prop, 'dummy'), ...
        'datagui:dynaload');
    end
    
    function testErrorSetEcho( self )
      %
      assertExceptionThrown(@() datagui.dynaload(self.json_filename, ...
        'echo', 2), 'datagui:dynaload:set:Echo');
    end
    
    function testErrorSetMagicField( self )
      assertExceptionThrown(@() datagui.dynaload(self.json_filename, ...
        'magicField', 2), 'datagui:dynaload:set:MagicField');
    end
    
    function testErrorPutTheKey( self )
      assertExceptionThrown(@() self.dynaObject.put('Test', ...
        [], 'theValue'), 'datagui:dynaload:put');
    end
    
    function testErrorPutTheValue( self )
      assertExceptionThrown(@() self.dynaObject.put('Test', ...
        'theValue'), 'datagui:dynaload:put');
    end
    
    function testErrorPutTheKeyCell( self )
      assertExceptionThrown(@() self.dynaObject.put('Test', ...
        [], {'testValue1', 'testValue2'}), 'datagui:dynaload:put');
    end
    
    function testErrorPutTheValueCell( self )
      assertExceptionThrown(@() self.dynaObject.put('Test', ...
        {'testKey1', 'testKey2'}), 'datagui:dynaload:put');
    end
    
    %% test arguments
    % --------------
    function testArgEchoFalse( self )
      d = datagui.dynaload(self.csv_filename, 'echo', false);
      assertFalse( d.Echo );
    end
    
    function testArgEchoTrue( self )
      d = datagui.dynaload(self.csv_filename, 'echo', false);
      d.Echo = true;
      assertTrue( d.Echo );
    end
    
    function testArgAutoAccessFalse( self )
      d = datagui.dynaload(self.csv_filename, 'echo', false, ...
        'autoaccess', false);
      assertFalse( d.AutoAccess );
    end
    
    function testArgAutoAccessTrue( self )
      d = datagui.dynaload(self.csv_filename, 'echo', false, ...
        'autoaccess', true);
      assertTrue( d.AutoAccess );
    end
    
    function testArgAutoMagicField( self )
      d = datagui.dynaload(self.csv_filename, 'echo', false, ...
        'magicfield', 'foo__');
      assertEqual( d.MagicField, 'foo__' );
    end
    
    function testMaxArg( self )
      d = datagui.dynaload(self.csv_filename, 'echo', false, ...
        'autoaccess', false, 'magicfield', 'foo__');
      assertEqual( d.MagicField, 'foo__' );
      assertFalse( d.AutoAccess );
      assertFalse( d.Echo );
    end
    
    %% test dynaload methods
    % test put
    % ----------------------
    function testPut( self )
      self.dynaObject.put('Test', 'testKey', 'testValue');
      assertEqual( self.dynaObject.Test.testKey, 'testValue');
    end
    
    function testPutCell( self )
      self.dynaObject.put('Test', {'testKey1', 'testKey2'},...
        {'testValue1', 'testValue2'});
      assertEqual( self.dynaObject.Test.testKey1, 'testValue1');
      assertEqual( self.dynaObject.Test.testKey2, 'testValue2');
    end
    
  end % End of public methods
  
end % End of classdef
