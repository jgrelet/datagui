%function button_quit_callback( file )
%BUTTON_QUIT_CALLBACK
% Mis la fonction en script pour permettre l'effacement du workspace
% qui ne se faisait pas 

% $Id: button_quit_callback.m 149 2008-02-21 17:39:13Z jgrelet $

% flushes the event queue and updates the figure window.
% ------------------------------------------------------
drawnow;

% if ispc
%   config_file = [prefdir, '\', file, '.mat'];
% elseif isunix
%   config_file = [prefdir, '/', file, '.mat'];
% else
%   config_file = [ m_filename, '.mat'];
% end
file = 'datagui';

config_file = [prefdir, filesep, file, '.mat'];

% get structure root from UserData property of Matlab root object
% ---------------------------------------------------------------
root = get( 0, 'UserData' );

% disable levitus structure (empty) that will be saved in configuration
% file
% ---------------------------------------------------------------------
root.levitus = 'off';

% reset userdata property of Matlab root object before quit program
% -----------------------------------------------------------------
set(0,'UserData', [] );

% open dialog box
% ---------------
reply = questdlg('Save config ?');
switch reply
  case 'Yes',
    % cmd = [ 'save ', file, ' root' ];
    % cmd = [ 'save ', 'datagui', ' root' ];
    % eval( cmd );
     save( config_file, 'root');
    %recuperation du handle de la carte
    hdl = findobj( 'Tag','tag_route_line');
    % desactivation du handle
    set( hdl, 'ButtonDownFcn', '');
    datagui_closereq_callback;
  case 'No',
    datagui_closereq_callback;
  case 'Cancel'
    % do nonthing
  otherwise  % close dialogbox
    % do nonthing
end
