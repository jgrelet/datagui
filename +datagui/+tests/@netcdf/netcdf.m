%% datagui.tests.netcdf
%
% This class implements tests cases on the netcdf class
% which is part of the packaqe +datagui. It is based on the 'TestCase'
% class of the xUnit Framework.
%
% You can run one particular test case implemented in a method of netcdf named
% testMethod by typing :
%
%     >> t = datagui.tests.netcdf('testMethod');
%     >> t.run
% or
%     >> runtests datagui.tests.netcdf:testMethod
%     >> runtests datagui.tests.netcdf -verbose
%
% For example run all tests for datagui.netcdf :
%
%     >> runtests datagui.tests.netcdf
%     Test suite: datagui.tests.netcdf
%     Test suite location: +datagui/+tests/@netcdf/netcdf.m
%     09-Sep-2011 13:49:32
%
%     Starting test run with 9 test cases.
%     .........
%     PASSED in 0.068 seconds.
%
%     >> t = datagui.tests.netcdf('theTest');
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
classdef netcdf < TestCase
  
  % Properties definition
  % ---------------------
  properties (Access = protected)
    
    % Locations of test.xls, test.csv and testSave.csv
    filename;
    foo_filename;
    attget;
    varget;
    
  end % End of Properties definition
  
  % Class public methods
  % --------------------
  methods % (Access = public)
    
    % setup
    % -----
    function setUp(self)
      
      % get the location of directory test class netcdf
      pathstr = fileparts(mfilename('fullpath'));
      
      % construct test filename
      self.filename = fullfile(pathstr, 'test.nc');
      self.attget   = fullfile(pathstr, 'attget.nc');
      self.varget   = fullfile(pathstr, 'varget.nc');
      
    end
    
    % tearDown
    % -----
    %     function tearDown(self)
    %     end
    
    % Constructor
    %------------
    function self = netcdf(testMethod)
      % Creates the test case
      self = self@TestCase(testMethod);
    end % End of contructor
    
    
    %% tests netcdf constructor with arguments
    % test that CSV file should be load in memory and attribute file
    % from the netcdf object is the test file
    % --------------------------------------------------------------
    function testMemoryNc( self )
      self.filename = 'memory';
      nc = datagui.netcdf(self.filename);
      assertEqual(nc.Filename, self.filename, 'can''t create in memory');
    end
    
    function testLocateNcFile( self )
      nc = datagui.netcdf(self.filename, 'echo', false);
      % need to rewrite netcdf constructor with same model than dynaload
      % nc = datagui.netcdf(self.filename, 'echo', 'false');
      [~, theFilename] = fileparts(nc.Filename);
      assertEqual(theFilename, 'test' , 'can''t locate test file');
    end
    
    function testArgModeRead( self )
      nc = datagui.netcdf(self.filename, 'r', 'echo', false);
      assertEqual(nc.Mode, 'NC_NOWRITE' , ...
        sprintf('bad mode, should be: NC_NOWRITE, is: %s', nc.Mode));
    end
    
    function testArgModeWrite( self )
      nc = datagui.netcdf(self.filename, 'w', 'echo', false);
      assertEqual(nc.Mode, 'NC_WRITE' , ...
        sprintf('bad mode, should be: NC_WRITE, is: %s', nc.Mode));
    end
    
    function testArgModeAppend( self )
      nc = datagui.netcdf(self.filename, 'a', 'echo', false);
      assertEqual(nc.Mode, 'NC_SHARE' , ...
        sprintf('bad mode, should be: NC_SHARE, is: %s', nc.Mode));
    end
    
    function testArgModeFull( self )
      nc = datagui.netcdf(self.filename, 'mode', 'NC_NOWRITE', 'echo', false);
      assertEqual(nc.Mode, 'NC_NOWRITE' , ...
        sprintf('bad mode, should be: NC_NOWRITE, is: %s', nc.Mode));
    end
    
    function testArgModeShort( self )
      nc = datagui.netcdf(self.filename, 'mode', 'r', 'echo', false);
      assertEqual(nc.Mode, 'NC_NOWRITE' , ...
        sprintf('bad mode, should be: NC_NOWRITE, is: %s', nc.Mode));
    end
    
    function testArgAutoNan( self )
      nc = datagui.netcdf(self.filename, 'mode', 'r', 'echo', false, ...
        'AutoNan', true);
      assertEqual(nc.AutoNan, true , ...
        sprintf('bad AutoNan value, should be: true, is: %s', nc.AutoNan));
      nc.AutoNan = false;
      assertEqual(nc.AutoNan, false , ...
        sprintf('bad AutoNan value, should be: false, is: %s', nc.AutoNan));
    end
    
   function testArgAutoScale( self )
      nc = datagui.netcdf(self.filename, 'mode', 'r', 'echo', false, ...
        'AutoNan', true, 'AutoScale', true);
      assertEqual(nc.AutoScale, true , ...
        sprintf('bad AutoScale value, should be: true, is: %s', nc.AutoScale));
      nc.AutoScale = false;
      assertEqual(nc.AutoScale, false , ...
        sprintf('bad AutoScale value, should be: false, is: %s', nc.AutoScale));
   end    
  
   function testArgAutoForm( self )
     nc = datagui.netcdf(self.filename, 'mode', 'r', 'echo', false, ...
       'AutoNan', true, 'AutoScale', true, 'AutoForm', true);
     assertEqual(nc.AutoForm, true , ...
       sprintf('bad AutoForm value, should be: true, is: %s', nc.AutoForm));
     nc.AutoForm = false;
     assertEqual(nc.AutoForm, false , ...
       sprintf('bad AutoForm value, should be: false, is: %s', nc.AutoForm));
   end
    
    %% test error messages
    % --------------------
    function testErrorFilename( self )
      self.filename = 'foo.nc';
      assertExceptionThrown(@() datagui.netcdf(self.filename, ...
        'echo', false), 'datagui:netcdf');
    end

    function testErrorFilenameExt( self )
      self.filename = 'test.txt';
      assertExceptionThrown(@() datagui.netcdf(self.filename, ...
        'echo', false), 'datagui:netcdf');
    end   
    
    function testErrorWrongFilename( self )
      self.filename = 123;
      assertExceptionThrown(@() datagui.netcdf(self.filename, ...
        'echo', false), 'datagui:netcdf');
    end    
    
    function testErrorMode( self )
      self.filename = 'test.nc';
      assertExceptionThrown(@() datagui.netcdf(self.filename, ...
        'echo', false, 'mode', 'dummy'), 'datagui:netcdf');
    end
    
    function testErrorUknownProperty( self )
      self.filename = 'test.nc';
      assertExceptionThrown(@() datagui.netcdf(self.filename, ...
        'echo', false, 'dummy', 'dummy'), 'datagui:netcdf');
    end    
    
    function testErrorDescriptor( self )
      self.filename = 'dummyDescriptor';
      assertExceptionThrown(@() datagui.netcdf(self.filename, ...
        'echo', false), 'datagui:netcdf');
    end        
    
    %% test netcdf types and attributes
    % as we got structure, we can't use AutoAccess = true
    % ---------------------------------------------------
    function testDoubleAttributes( self )    
      nc = datagui.netcdf(self.attget, 'echo', false);
      x = nc.Variables.x_db;
      assertEqual( class(x.test_double_att), 'double', ...
        'class of retrieved attribute was not double.');
      assertEqual( x.test_double_att, 3.14159, ...
        'retrieved attribute differs from what was written.');
    end
    
    function testFloatAttributes( self )
      nc = datagui.netcdf(self.attget, 'echo', false);
      x = nc.Variables.x_db;
      assertEqual( class(x.test_float_att), 'single', ...
        'class of retrieved attribute was not float.');
      assertTrue( abs(double( x.test_float_att) - 3.14159) < 1e-5, ...
        'retrieved attribute differs from what was written.');
    end
    
    function testIntAttributes( self )
      nc = datagui.netcdf(self.attget, 'echo', false);
      x = nc.Variables.x_db;
      assertEqual( class(x.test_int_att), 'int32', ...
        'class of retrieved attribute was not int32.');
      assertEqual( x.test_int_att, int32(3), ...
        'retrieved attribute differs from what was written.');
    end
    
    function testShortAttributes( self )
      nc = datagui.netcdf(self.attget, 'echo', false);
      x = nc.Variables.x_db;
      assertEqual( class(x.test_short_att), 'int16', ...
        'class of retrieved attribute was not int16.');
      assertEqual( length(x.test_short_att), 2, ...
        'retrieved attribute length differs from what was written.');
      assertFalse( any(double(x.test_short_att) - [5 7]), ...
        'retrieved attribute differs from what was written.');
    end
    
    function testCharAttributes( self )
      nc = datagui.netcdf(self.attget, 'echo', false);
      x = nc.Variables.x_db;
      assertEqual( class(x.test_schar_att), 'int8', ...
        'class of retrieved attribute was not int8.');
      assertEqual( x.test_schar_att, int8(-100), ...
        'retrieved attribute differs from what was written.');
    end
    
    function testUcharAttributes( self )
      nc = datagui.netcdf(self.attget, 'echo', false);
      x = nc.Variables.x_db;
      assertEqual( class(x.test_uchar_att), 'int8', ...
        'class of retrieved attribute was not int8.');
      assertEqual( x.test_uchar_att, int8(100), ...
        'retrieved attribute differs from what was written.');
    end
    
    function testTextAttributes( self )
      nc = datagui.netcdf(self.attget, 'echo', false);
      x = nc.Variables.x_db;
      assertTrue( ischar(x.test_text_att), ...
        'class of retrieved attribute was not char.');
      assertEqual( x.test_text_att, 'abcdefghijklmnopqrstuvwxyz', ...
        'retrieved attribute differs from what was written.');
    end
    
    function testRetrieveGlobalAttribute( self )
      nc = datagui.netcdf(self.attget, 'echo', false);
      att = nc.Attributes.test_double_att.data__;
      assertEqual( class(att), 'double', ...
        'class of retrieved attribute was not double.');
      assertEqual( att, 3.14159, ...
        'retrieved attribute differs from what was written.');
    end
    
    function test1dVariable( self )
      nc = datagui.netcdf(self.varget, 'echo', false);
      var = nc.Variables.test_1D.data__;
      sz = size(var);
      assertFalse(sz(1) ~= 6 && sz(2) ~= 1, ...
        'retrieved variable size differ from what was written.');
    end
    
    function testReadSingleValueFrom1dVariable( self )
      nc = datagui.netcdf(self.varget, 'echo', false);
      var = nc.Variables.test_1D.data__;
      expData = 1.2;
      actData = var(2,1);
      ddiff = abs(expData - actData);
      assertFalse(any( find(ddiff > eps) ), ...
        'input data ~= output data.');
    end
    
    function testReadSingleValueFrom2dVariable( self )
      nc = datagui.netcdf(self.varget, 'echo', false);
      var = nc.Variables.test_2D.data__;
      expData = 1.5;
      getData = var(3,3);
      ddiff = abs(expData - getData);
      assertFalse(any( find(ddiff > eps) ), ...
        'input data ~= output data.');
    end
    
    function testReadSomeValuesFrom2dVariable( self )
      nc = datagui.netcdf(self.varget, 'echo', false);
      expData = [0.8 1.4; 0.9 1.5; 1.0 1.6];
      getData = nc.Variables.test_2D.data__(2:4,2:3);
      assertFalse( (ndims(getData)) ~= 2, ...
        'rank of output data was not correct' );
      assertFalse( numel(getData) ~= 6, ...
        'size of output data was not correct' );
      ddiff = abs(expData(:) - getData(:));
      assertFalse( any( find(ddiff > eps) ), ...
         'input data ~= output data ' );
    end
    
%     function test_write_scale_offset( self )
%       % Put a scale factor of 2 and add offset of 1.
%       % Write some data,
%       % Put a scale factor of 4 and add offset of 2.
%       % data read back should be twice as large
%       
%       ncfile = 'foo.nc';
%       ncid = datagui.netcdf('memory');
%       ncid.AutoScale = true;
%       ncid.Echo = false;
%       ncid.Dimensions.x = struct('key__', 'x', 'dimlen', 4, ...
%         'unlimited', 0);
%       ncid.Dimensions.y = struct('key__', 'y', 'dimlen', 6, ...
%         'unlimited', 0);
%       %  To create fields that contain cell arrays, place the cell arrays
%       % within a VALUE cell array.
%       ncid.Variables.data_2D = struct('key__', 'data_2D', ...
%          'type__', 'short', 'dimension__', {{'x','y'}},...
%          'scale_factor', 2.0, 'add_offset', 0, 'data__', []);
%        
%       sz = [4 6];
%       count = sz;
%       input_data = 1:prod(count);
%       input_data = reshape(input_data, count);
%       % ncid.AutoAccess = true;
%       value = int16(input_data);
%       ncid.Variables.data_2D.data__ = value;
%       ncid.write(ncfile, 'w');
%       
%       ncid = datagui.netcdf('foo.nc');
%       %ncid.AutoAccess = true;
%       
%       output_data = ncid.Variables.data_2D.data__;
%       
% %       nc_attput ( ncfile, 'test_2D', 'scale_factor', 4.0 );
% %       nc_attput ( ncfile, 'test_2D', 'add_offset', 2.0 );
%       
%       ddiff = abs(input_data - (output_data)/2);
%       assertFalse( any( find(ddiff > eps) ), 'failed');
%       
%     end
    
  end % End of public methods
  
end % End of classdef
