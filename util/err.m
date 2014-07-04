% Error function
%
% SYNTAX :
% err (className, methodName, message)
% 
% INPUT PARAMETERS : 
%    className  : name of the class
%    methodName : method/function name
%    message    : error message
%
% PROPERTY NAMES / PROPERTY VALUES :
%
% OUTPUT PARAMETERS : 
%
% EXAMPLES :
%    err ('class', 'method', 'error message') ;
%
% REMARKS : 
%    current function call matlab built-in function error.
%
% SEE ALSO : help error
% AUTHORS  : DCF
% VERSION  : $Id: err.m 2 2005-10-12 09:35:32Z jgrelet $
% ----------------------------------------------------------------------------

function err (className, methodName, message)

% ----------------------------------------------------------------------------
% HISTORIQUE DEVELOPPEMENT
%    04/12/2003 - DCF - creation
% ----------------------------------------------------------------------------

error (sprintf ('ERROR\nClass \t: %s\nMethod \t: %s\nMessage \t: %s\n', ...
    className, methodName, message)) ;
