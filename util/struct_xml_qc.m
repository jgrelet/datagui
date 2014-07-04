function [valid] = struct_xml_QC(varargin)


% Petite U.interface permettant de recuperer le nom prenom de l'utilisateur
% et la date d'ulisisation de la fonction. Cette fonction modifie alors le
% fichier en cours de lecture en rajoutant dans l'entete les données
% utilisateurs et en rajoutant dans les <DATA> une colonne cle_CQ (code
% qualité) et une colonne cle_COR (valeur corrigée) pour chacune des clé.
% En entrée : path (chemin d'accés du fichier en cours de lecture).
%             CleCQ (clés du fichier xml en cours de lecture).
% Valid est renvoyé par la fonction pour permettre de dire si le fichier à
% correctement était modifier. 

% $Id: struct_xml_qc.m 100 2006-09-06 10:44:54Z nvuillau $

% Confirmation de la modification de la structure du fichier XML
valid = 0;
reponce = questdlg('Etes vous sur de vouloir continuer ?',...
  'Modification du fichier XML');
if strcmp(reponce,'Yes')
else
  return
end
%% U.Interface recuperant les données utilisateurs.
prompt = {'Entrez votre nom :','Entrez votre prenom:'};
dlg_title = 'Données utilisateur';
num_lines = 1;
default = {'Grelet','Jacques'};
data_entete_CQ = inputdlg(prompt,dlg_title,num_lines,default);
data_entete_CQ = [ data_entete_CQ ;datestr(now)];

%% initialisation
path  = varargin{1};
CleCQ = varargin{2};

%% Script de réécriture du fichier XML
% Process un peu long, on modifie l'aspect de la sourie.
set(gcf,'Pointer','watch');
% on lit le fichier en mode 'read'.
fd = fopen( path, 'rt' );
% on crée un nouveau fichier temporaire dans le repertoire.
% Voir avec Jacques si on ecrase l'ancien fichier avec celui-ci. 
path2 = [path(1:end-4) '_temps.xml'];
fid = fopen(path2, 'W');

%% Première partie du script qui ecrit les données utilisateurs
while ~feof(fd)
  % On lit le fichier ligne par ligne.
  line = fgetl(fd);
  % On ecrit chaque ligne dans le fichier temporaire.
  fprintf( fid , '%s\n', line);
  % Si la ligne contient un fichier d'entete denomé 'Responsable'.
  [tok match] = regexp(line,'<(\w+)>','tokens');
  if isempty(match), continue, end
  if strmatch(tok{1},'RESPONSABLE')
    %on lit la ligne suivante ('ACQUISITION')
    line = fgetl(fd);
    %on ecrit la ligne suivante dans le fichier temporaire ('ACQUISITION')
    fprintf( fid , '%s\n', line);
    %On lit la ligne suivante.
    line = fgetl(fd);
    % On ecrit la ligne pour l'onglet Validation CQ, et la date de
    % modification.
    line2 = ['<VALIDATION LOGICIEL="DataGUI" VERSION="0.22c" DATE="' data_entete_CQ{3} '" OPERATEUR="' data_entete_CQ{1} '_' data_entete_CQ{2} '" CODIFICATION="OOPC">'];
    % On ecrit cette ligne dans le fichier temporaire.
    fprintf( fid , '\t%s\n', line2);

  end

  %% Deuxième partie du script qui va ajouter les deux noms de colonnes
  % dans l'entete des clefs
  % Si la ligne contient un fichier d'entete denomé 'Data'.
  if strmatch(tok{1},'DATA')
    % La ligne suivante contiendra l'entete des colonnes.
    header = fgetl(fd);
    % On enregistre ces entetes dans 2 variables différentes. L'une que
    % l'on va modifier et l'autre qui sera conservée en mémoire.
    var_all = strread( header, '%s' );
    var_all2 = strread( header, '%s' );
    t = 0;
    % On rajoute les terminaisons _CQ et _ COR à chaque clé.
    for i = 1:length(var_all)
      CleCQ = var_all{i};
      cleCQ_CQ = [CleCQ '_CQ'];
      cleCQ_COR = [CleCQ '_COR'];
      for j=1:length(var_all)
        % On recherche la position de la cle désirée
        if strcmp(CleCQ, var_all(j))
          %On rajoute les 2 entetetes à coté de celle de la clé
          var_all2{j+t} = CleCQ;
          var_all2{j+t+1} = cleCQ_CQ;
          var_all2{j+t+2} = cleCQ_COR;
          t = t+2;
        end
      end
    end
    % Initialisation de la nouvelle entete
    header = ' ';
    % On rajoute à l'entete chacune des cle séparées par 2 espaces.
    for i=1:length(var_all2)
      header = [header '  ' var_all2{i}];
    end

    % On ecrit alors notre nouvelle entête dans le fichier temporaire.
    fprintf( fid , '%s\n', header);

    %% Troisième et dernière partie du script qui ajoute les 2 colonnes
    % ligne par ligne au bon emplacement.
    % Initialisation
    % Le code qualite vaut pour l'instant 0 car aucun CQ n'a encore été
    % attribué.
    val_CQ = '0';
    match = [];
    while isempty(match)
      % Lecture ligne par ligne des 'data'.
      line = fgetl(fd);
      % on test si il s'aggit bien de données et que se ne soit pas la fin
      % des 'Data'.
      [tok match] = regexp(line,'/DATA');
      % De même que pour les entêtes, on enregistre ces données dans 2
      % variables différentes.
      valeurs = strread( line, '%s' );
      valeurs2 = strread( line, '%s' );
      t = 0;
      if isempty(match)
        for i = 1:length(valeurs)
          valeur = valeurs{i};
          valeur_CQ = '0';
          valeur_COR = valeur;
          for j=i:length(valeurs)
            % On recherche la cle désirée
            if strcmp(valeur, valeurs(j))
              %On rajoute les 2 entetetes à coté de celle de la clé
              valeurs2{j+t} = valeur;
              valeurs2{j+t+1} = valeur_CQ;
              valeurs2{j+t+2} = valeur_COR;
              t = t+2;
            end
          end
        end
        % Initialisation de la nouvelle ligne.
        new_line = ' ';
        % On enregistre les valeurs une à une séparée d'un espace.
        % A revoir avec Jacques car les colonnes sont du coup moins
        % lisibles que dans le fichier d'origine. 
        for i=1:length(valeurs2)
          new_line = [new_line '  ' valeurs2{i}];
        end
        % On ecrit ces valeurs dans le fichier temporaire.
        fprintf( fid , '%s\n', new_line);
      else % Si les données sont toutes enregistrées on enregistre les dernières lignes
        while ~feof(fd)
          fprintf( fid , '%s\n', line);
          line = fgetl(fd);
          fprintf( fid , '%s\n', line);
        end
        % Fin du traitement
        valid = 1;
        fclose('all');
        set(gcf,'Pointer','arrow');
        return
      end
    end
  end
end
% On ferme tout les fichier en cours de lecture.
fclose('all');
end





