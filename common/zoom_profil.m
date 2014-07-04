%zoom_profil

hdl = findobj('Tag','plot_profil');
ax = mousebox

% recuperer l'axe courant plus proprement qu'avec gca
set(gca,'Xlim',[ax(1) ax(2)], 'Ylim', [ax(3) ax(4)]);

switch get(get(gca,'Parent'),'Tag')
  case 'plot_route'
    disp('zoom sur route selectionne');
  case 'plot_profil'
    disp('zoom sur profil selectionne');  
  otherwise
    warn('common', 'zoom_profil', 'mauvaise selection');
end
