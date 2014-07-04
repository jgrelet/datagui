%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function start_profil

root     = get( 0, 'UserData' );
indice   = get(root.self, 'indice');  % indice du profil en cours
profils = get(get(root.self,'data_1d'),'PROFILS'); % tous les profils

if isempty( indice ) 
  indice = profils(1);
else
  if i < profils( length(profils) )
    indice = indice + 1;
    root.self  = set( root.self, 'indice', indice );
    % sauvegarde l'instance dans root (UserData)
    set(0, 'UserData', root );
    plot( root.self );
    line_route;
  else
    if t
      t = timerfind('Tag', 'Run_timer');
      stop(t);
      delete(t);
    end
  end
end
