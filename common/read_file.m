% read_file
% wrapper de lecture
% en fonction du format de fichier, appel les fonctions
% de lecture ASCII, NetCDF ou Excel

% $Id: read_file.m 187 2012-09-12 13:09:40Z jgrelet $

% recupere l'instance dans le champ UserData de main_fig
%self = get( findobj( 'Tag', 'main' ), 'UserData' ); 

% efface le workspace
clear;

root = get( 0, 'UserData' );

% cree le type d'objet
type = char(root.type( root.type_value ));
switch type
  case 'TIME SERIE'     % time-serie
    root.self = timeserie( root.selected_file );
  case {'TSG','METEO','BATHYMETRIE'}  % trajectoire
    root.self = trajectoire( root.selected_file );
  case {'ADCP','CTD','XBT','BTL','BOUTEILLES','RADIOSONDAGE'}
    root.self = profil( root.selected_file );
  otherwise
    disp( 'Erreur de selection du type de donnees ...' );
    % ne devrait pas arriver
		datagui_closereq_callback;
		% on sort
end  

% lit les fichiers suivant le format
cle = char(root.format( root.format_value ));
switch cle
  case 'dataGUI'  % ASCII
    root.self = read_file_ascii( root.self );
  case 'XML'  % ASCII
    root.self = read_file_xml( root.self );    
  case 'NetCDF'  % NetCDF ARGO
    root.self = read_file_nc( root.self );
  case 'OceanSITES'  % NetCDF OceanSITES
    root.self = read_file_oceansites( root.self );  
  case 'Thermo DOS'
    root.self = read_file_thermo_dos( root.self );
  case 'Thermo Labview'
    root.self = read_file_thermo_labview( root.self );
  case 'CODAS .CON'
    root.self = read_file_codas_con( root.self );
  case 'CODAS .ASC'
    root.self = read_file_codas_asc( root.self );
  case 'Seabird .HDR/.ASC'
    root.self = read_file_ascii( root.self );
  case 'Seabird .CNV'
    root.self = read_file_seabird_cnv( root.self );
  case 'CLS Argos .DROP'
    root.self = read_file_xbt_drop( root.self );
  case 'Sippican .EDF'
    root.self = read_file_xbt_edf( root.self );
  case 'Excel'
    root.self = read_file_btl_excel( root.self );
  case '.BIL'
    root.self = read_file_btl_bil( root.self );
  otherwise
    disp( 'Erreur de selection du format de fichier....' );
    % ne devrait pas arriver
    % quit;
end  

% maj root dans UserData de fig(0)
set( 0, 'UserData', root );

clear self root value file textfile cle type;