function choix_parametres( hdl, cles, choix )
% suivant l'etat du radio_button levitus, cree le uipanel
% correspndant
%
% hdl    : handle de la figure plot_route
% params : tableau de cellule des parametres
% choix  : 0 -> choix multiples
%          1 -> choix exclusif (uibunttongroup)
%          2 -> section
%
% $Id: choix_parametres.m 156 2008-02-21 22:13:53Z jgrelet $



%% Choix des parametres a tracer
%-------------------------------
handle_panel = findobj( 'Tag', 'parametres' );
if ~isempty( handle_panel )
  delete( handle_panel );
end  

% ne garde que les variables "primaires" correspondants aux codes Roscop
% -----------------------------------------------------------------------
params = get_primary_key(cles, 0);

% cas des traces multiples
% ------------------------
switch choix
  case 0
    hdl_param = uipanel('Title','Parametres',...
      'tag','parametres',...
      'parent', hdl,...
      'FontSize',8,...
      'Units','pixels',...
      'Position',[595 155 100 435]);
    for i=1:length( params )
      if i==1
        default_value = 1;
      else
        default_value = 0;
      end  
      uicontrol('Style','Radio',...
        'parent',hdl_param,...
        'String',params{i},...
        'Value',default_value,...  % Selectionne par defaut
        'Tag',['radio_' params{i}],...      
        'pos',[10 420-i*20 85 20],...
        'Callback', 'getRadioParamCallback',...
        'HandleVisibility','on');
        
    end
    
  % cas des traces avec Levitus  
  % ---------------------------
  case 1
    hdl_param = uibuttongroup('Title','Parametres',...
      'tag','parametres',...
      'parent', hdl,...
      'FontSize',8,...
      'Units','pixels',...
      'SelectionChangeFcn', 'getRadioButtongroupParamCallback',...
      'Position',[595 155 100 435]);
    j = 1;
    for i=1:length( params )
      if i==1
        default_value = 1;
      else
        default_value = 0;
      end  
        uicontrol('Style','Radio',...
          'parent',hdl_param,...
          'String',params{i},...
          'Value',default_value,...  % Selectionne par defaut
          'Tag',['radio_' params{i}],...
          'pos',[10 420-j*20 85 20],...
          'HandleVisibility','on');
        j = j + 1;
    end

  % cas des traces de section
  % -------------------------
  case 2
    hdl_param = uibuttongroup('Title','Parametres',...
      'tag','parametres',...
      'parent', hdl,...
      'FontSize',8,...
      'Units','pixels',...
      'SelectionChangeFcn', 'select_section',...
      'Position',[595 155 100 280]);

    j=1;
    for i=1:length( params )
      if i==1
        default_value = 1;
      else
        default_value = 0;
      end
      uicontrol('Style','Radio',...
        'parent',hdl_param,...
        'String',params{i},...
        'Value',default_value,...  % Selectionne par defaut
        'Tag',['radio_' params{i}],...
        'pos',[10 420-j*20 85 20],...
        'HandleVisibility','on');
      j=j+1;
    end

  otherwise
    warn ('profil', 'choix_parametres', 'wrong input argument choix') ;

end