% getButtonRunCallback
% script generique appele sur appui du bouton run de plot_route

% $Id: getButtonRunCallback.m 120 2007-02-02 13:42:20Z jgrelet $

root     = get( 0, 'UserData' );
indice   = get(root.self, 'indice');  % indice du profil en cours
profils = get(get(root.self,'data_1d'),'PROFILS'); % tous les profils

tag_run  = findobj( 'Tag', 'tag_button_run' );
t = timerfind('Tag', 'Run_timer');
st_max = profils( length(profils) );
np = st_max - indice;

if isempty( t ) % si pas de timer, on en demarre un
  if  np ~= 0   % sauf si on est au dernier profil
    set( tag_run, 'String', 'Pause' );
    t = timer( 'Tag', 'Run_timer',...
               'Name', 'Datagui_Timer',...
               'TimerFcn', 'start_profil', ... 
               'StopFcn', 'stop_profil', ...
               'Period', 1,...
               'ExecutionMode', 'fixedDelay',...
               'StartDelay', 0,...
               'TasksToExecute', np );
               %'StartFcn', 'run_profil', ...
    %set(findobj('Tag','plot_profil'),'HandleVisibility','on');
    %set(findobj('Tag','plot_route'),'HandleVisibility','on');
    start(t);
    % disp('on demarre timer');
  end  
else
  set( tag_run, 'String', 'Run' );
  stop(t);
  delete(t);
  % disp('on stop le timer');
end


clear root indice profils tag_run st_max t np;


