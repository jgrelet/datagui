% select_axis

% script appele par callback sur "select_plot_axis"
% 
%
%$Id: select_axis_callback.m 149 2008-02-21 17:39:13Z jgrelet $

% flushes the event queue and updates the figure window.
% ------------------------------------------------------
drawnow;

% recupere la struct root dans le champ UserData de main_fig
% self = get( findobj( 'Tag', 'main' ), 'UserData' ); 

root = get( 0, 'UserData' ); 

% appel la fonction select_plot_axis pour l'instance utilisee
%select_plot_axis( self );

% on retrace
% if isa( self, 'trajectoire' )
%   plot_data( self);
% end

root.axis_value = get( findobj( 'Tag', 'popup_axis' ), 'Value' );
set(0, 'UserData', root );

clear root;
