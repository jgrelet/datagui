% change_directory

% $Id: change_directory_callback.m 149 2008-02-21 17:39:13Z jgrelet $

% test le type de fichiers a traiter

% uigetfile renvoie [0 0] si rien n'est selectionne,
% sinon, le nom et chemin de fichier
% le chemin (path) est stocke dans le UserData de l'objet popup_file

% $Id: change_directory_callback.m 149 2008-02-21 17:39:13Z jgrelet $


% recupere la struct root dans le champ UserData de 0
root = get( 0, 'UserData' );

% pour mettre a jour le popup_nom_fichier
popup_file = findobj( 'Tag', 'popup_file' );

[selected_file, root.path, filterIndex] = uigetfile( {['*' root.ext]}, ...
  'fichier', [root.path filesep],'MultiSelect', root.selectmode);

%filterIndex
if filterIndex ~= 0
  if ischar( selected_file )
    % bug de uigetfile, retourne pirata-fr4_mto_mto
    if strcmp(root.format{root.format_value}, 'dataGUI')
      % supprime la double extension retournee par uigetfile
      % que si fichier de type dataGUI
      if regexp(root.ext,'_')
        selected_file = regexprep(selected_file, root.ext,'','once');
      end
    end
    dlist = dir( fullfile(root.path, ['*'  root.ext ]) );
    root.files = {dlist.name};
    idx = strfind(root.files, selected_file);
    for i=1: length(idx)
      if idx{i}==1; root.files_value = i; end
    end

    % test test que l'indice des campagnes ne soit pas > aux nb fichiers
    if length( root.files ) < root.files_value
      root.files_value = 1;
    end;

    if isempty( dlist )
      root.files = { 'no data' };
      set( popup_file, 'String', root.files );
    else
      set( popup_file, 'String', root.files );
      set( popup_file, 'Value',  root.files_value );
      root.selected_file = fullfile(root.path, selected_file);
      set(0, 'UserData', root );
      
      % flushes the event queue and updates the figure window.
      % ------------------------------------------------------
      drawnow;
      
      read_file;
      % met a jour le plot
      plot_route;
    end
  end 
%   if iscell( selected_file )
%     %[nb,lg] = size( selected_file );
%     for i=1:length( selected_file );,
%       selected_file{i} = fullfile(root.path,selected_file{i});
%     end
%     % appel du script perl de traitement
%     % en test pour linstant, mis en dur, voir test_read_edf.m
%     opt  = {};  % empty cell array
%     opt{end+1} =  '--institute=IRD';
%     opt{end+1} =  '--pi=US025 BREST';
%     response = perl('ctd.pl', opt{:}, selected_file{:});
%     root.files = cellstr( response );
%     root.files_value = 1;
%     set( findobj( 'Tag', 'text_file' ),  'String', root.path );
%     set( popup_file, 'String', root.files );
%     set( popup_file, 'Value',  root.files_value );
%     set(0, 'UserData', root );
%     read_file;
%     plot_route;
%   end
end

clear root selected_file filterIndex dlist idx i popup_file;
