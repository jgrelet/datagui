% Warning function
%
% SYNTAX :
% warn (className, methodName, message)
% 
% INPUT PARAMETERS : 
%    className  : name of the class
%    methodName : method/function name
%    message    : warning message
%
% PROPERTY NAMES / PROPERTY VALUES :
%
% OUTPUT PARAMETERS : 
%
% EXAMPLES :
%    warn ('class', 'method', 'warning message') ;
%
% REMARKS : 
%    current function call matlab built-in function disp
%
% SEE ALSO : help disp
% AUTHORS  : DCF
% VERSION  : $Id: warn.m 2 2005-10-12 09:35:32Z jgrelet $
% ----------------------------------------------------------------------------

function warn (className, methodName, message)

% ----------------------------------------------------------------------------
% HISTORIQUE DEVELOPPEMENT
%    04/12/2003 - DCF - creation
% ----------------------------------------------------------------------------

disp (sprintf ('WARNING\nClass \t: %s\nMethod \t: %s\nMessage \t: %s\n', ...
    className, methodName, message)) ;
