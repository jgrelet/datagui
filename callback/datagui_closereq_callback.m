% datagui_closereq_callback
% #########
% renommer ce fichier en datagui_quit
%
%DATAGUI_CLOSEREQ_CALLBACK  Figure close request function.
%   DATAGUI_CLOSEREQ_CALLBACK deletes the current figure window.  By default, CLOSEREQ is
%   the CloseRequestFcn for new figures.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Id: datagui_closereq_callback.m 123 2007-02-12 08:35:45Z jgrelet $

%   Note that closereq now honors the user's ShowHiddenHandles setting
%   during figure deletion.  This means that deletion listeners and
%   DeleteFcns will now operate in an environment which is not guaranteed
%   to show hidden handles.

shh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
currFig = get(0,'CurrentFigure');
set(0,'ShowHiddenHandles',shh);
delete(currFig);
% delete all children figure
% see 'Using matlab graphic' page 7-46
delete( get(0, 'Children' ));
% Clears all variables from the workspace.
clear variables;

% appelee car clear all n'efface pas le base workspace
% datagui_clear;

% a decommenter en production
rmpathdef_datagui;



