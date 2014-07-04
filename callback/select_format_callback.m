% select_format
%
% script appele par callback sur "popup_format"
% 
% $Id: select_format_callback.m 149 2008-02-21 17:39:13Z jgrelet $
 
% recupere la struct root dans le champ UserData de main_fig
%self = get( findobj( 'Tag', 'main' ), 'UserData' ); 

% flushes the event queue and updates the figure window.
% ------------------------------------------------------
drawnow;

root = get( 0, 'UserData' ); 

% recupere l'indice du popup apres selection 
%self = set( self,'format_value', get( findobj( 'Tag', 'popup_format' ), 'Value' ));

% sauve l'instance
%builtin( 'set', findobj( 'Tag', 'main' ), 'UserData', self );

%select_type;

root.format_value = get( findobj( 'Tag', 'popup_format' ), 'Value' );
set(0, 'UserData', root );

% passe de nouveau dans select_type pour mettre a jour root.ext
select_type_callback;

clear root;
