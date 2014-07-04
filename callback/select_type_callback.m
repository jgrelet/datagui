% select_type
%
% script appele par callback sur "select data type"
% permet de selectionne le type de fichier et son extension
% met a jour le popup associe et la struct root

% $Id: select_type_callback.m 149 2008-02-21 17:39:13Z jgrelet $

% flushes the event queue and updates the figure window.
% ------------------------------------------------------
drawnow;

% % recupere la valeur du popup_type (ALL,TSG ou MTO) apres l'appel
% % du callback
type_value = get(findobj( 'Tag', 'popup_type' ), 'Value' );
fmt  = get(findobj( 'Tag', 'popup_format' ), 'Value' );
old  = get( findobj( 'Tag', 'main' ), 'UserData' );
root = get( 0, 'UserData' ); 
% il faut memoriser le chemin avant de creer une nouvelle instance
%path = get(old,'path');

switch type_value
  case 1  %  TIME SERIE
    handle = findobj('-regexp','Tag','plot');
    if ~isempty(handle)
      delete(handle);
    end
    root.format = {'dataGUI','XML','NetCDF','OceanSITES','ASCII'};
    switch fmt
      case 1  % fichier ASCII datagui
        root.ext = '*_tms';
        root.selectmode = 'off';     
      case 2  % XML
        root.ext = '*_tms.xml';
        root.selectmode = 'off';                
      case 3  % NetCDF
        root.ext = '*_tms.nc';
        root.selectmode = 'off';   
      case 4  % OceanSITES
        root.ext = 'OS_*_TMS.nc';
        root.selectmode = 'off';                
      case 5  % ASCII
        root.ext = '.*';
        root.selectmode = 'on';        
      otherwise
        root.ext = '.*';
        root.selectmode = 'on';        
    end
  case 2  %  TSG
    handle = findobj('-regexp','Tag','plot');
    if ~isempty(handle)
      delete(handle);
    end
    root.format = {'dataGUI','XML','NetCDF','OceanSITES','Thermo DOS','Thermo Labview'};
    switch fmt
      case 1  % fichier ASCII datagui
        root.ext = '*_tsg';
        root.selectmode = 'off';        
     case 2  % XML
        root.ext = '*_tsg.xml';
        root.selectmode = 'off';        
     case 3  % NetCDF
        root.ext = '*_tsg.nc';
        root.selectmode = 'off';        
     case 4  % OceanSITES
        root.ext = 'OS_*_TSG.nc';
        root.selectmode = 'off';        
     case 5  % ASCII
        root.ext = '.*';
        root.selectmode = 'on';        
     otherwise
        root.ext = '.*';
        root.selectmode = 'on';        
    end

  case 3  %  METEO
    handle = findobj('-regexp','Tag','plot');
    if ~isempty(handle)
      delete(handle);
    end
    root.format = {'dataGUI','XML','NetCDF','OceanSITES','ASCII'};
    switch fmt
      case 1  % fichier ASCII datagui
        root.ext = '*_mto';
        root.selectmode = 'off';        
      case 2  % XML
        root.ext = '*_mto.xml';
        root.selectmode = 'off';        
      case 3  % NetCDF
        root.ext = '*_mto.nc';
      case 4  % OceanSITES
        root.ext = 'OS_*_MTO.nc';
        root.selectmode = 'off';        
      case 5  % ASCII
        root.ext = '.*';
        root.selectmode = 'on';        
      otherwise
        root.ext = '.*';
        root.selectmode = 'on';        
    end

  case 4  %  BATHYMETRIE
    handle = findobj('-regexp','Tag','plot');
    if ~isempty(handle)
      delete(handle);
    end
    root.format = {'dataGUI','XML','NetCDF','OceanSITES'};
    switch fmt
      case 1  % fichier ASCII datagui
        root.ext = '*_snd';
        root.selectmode = 'off';        
     case 2  % XML
        root.ext = '*_snd.xml';
        root.selectmode = 'off';        
     case 3  % NetCDF
        root.ext = '*_snd.nc';
        root.selectmode = 'off';            
     case 4  % OceanSITES
        root.ext = 'OS_*_SND.nc';
        root.selectmode = 'off';            
     otherwise
        root.ext = '.*';
        root.selectmode = 'on';        
    end
    
  case 5  %  CTD
    handle = findobj('-regexp','Tag','plot');
    if ~isempty(handle)
      delete(handle);
    end
    root.format = {'dataGUI','XML','NetCDF','OceanSITES','Seabird .HDR/.ASC','Seabird .CNV'};
    switch fmt
      case 1  % fichier ASCII datagui
        root.ext = '*_ctd';
        root.selectmode = 'off';
      case 2  % XML
        root.ext = '*_ctd.xml';
        root.selectmode = 'off';        
      case 3  % NetCDF
        root.ext = '*_ctd.nc';
        root.selectmode = 'off';        
      case 4  % OceanSITES
        root.ext = 'OS_*_CTD.nc';
        root.selectmode = 'off';        
      case 5  % HDR/ASC
        root.ext = '.hdr';
        root.selectmode = 'on';
      case 6  % CNV
        root.ext = '.cnv';
        root.selectmode = 'on';
     otherwise
        root.ext = '.*';
        root.selectmode = 'on';
    end
    
  case 6  %  XBT
    handle = findobj('-regexp','Tag','plot');
    if ~isempty(handle)
      delete(handle);
    end
    root.format = {'dataGUI','XML','NetCDF','OceanSITES','CLS Argos .DROP','Sippican .EDF'};
    switch fmt
      case 1  % fichier ASCII datagui
        root.ext = '*_xbt';
        root.selectmode = 'off';        
      case 2  % XML
        root.ext = '*_xbt.xml';
        root.selectmode = 'off';        
      case 3  % NetCDF
        root.ext = '*_xbt.nc';
        root.selectmode = 'off';        
      case 4  % OceanSITES
        root.ext = 'OS_*_XBT.nc';
        root.selectmode = 'off';        
      case 5  % DROP
        root.ext = '.*';
        root.selectmode = 'on';
      case 6  % EDF
        root.ext = '.edf';
        root.selectmode = 'on';
     otherwise
        root.ext = '.*';
    end
    
  case 7  %  ADCP
    handle = findobj('-regexp','Tag','plot');
    if ~isempty(handle)
      delete(handle);
    end
    root.format = {'dataGUI','XML','NetCDF','OceanSITES','CODAS .CON','CODAS .ASC'};
    switch fmt
      case 1  % fichier ASCII datagui
        root.ext = '*_adcp';
        root.selectmode = 'off';        
      case 2  % XML
        root.ext = '*_adcp.xml';
        root.selectmode = 'off';        
      case 3  % NetCDF
        root.ext = '*_adcp.nc';
        root.selectmode = 'off';        
      case 4  % OceanSITES
        root.ext = 'OS_*_ADCP.nc';
        root.selectmode = 'off';        
      case 5  % CON
        root.ext = '.con';
        root.selectmode = 'on';        
      case 6  % ASC
        root.ext = '.asc';
        root.selectmode = 'on';        
     otherwise
        root.ext = '.*';
        root.selectmode = 'on';        
    end
    
  case 8  %  BTL
    handle = findobj('-regexp','Tag','plot');
    %if ~isempty(handle) && delete(handle) end
    if ~isempty(handle)
      delete(handle);
    end
    root.format = {'dataGUI','XML','NetCDF','OceanSITES','Excel','.BIL'};
    switch fmt
      case 1  % fichier ASCII datagui
        root.ext = '*_btl';
        root.selectmode = 'off';        
      case 2  % XML
        root.ext = '*_btl.xml';
        root.selectmode = 'off';        
      case 3  % NetCDF
        root.ext = '*_btl.nc';
        root.selectmode = 'off';        
      case 4  % OceanSITES
        root.ext = 'OS_*_BTL.nc';
        root.selectmode = 'off';        
      case 5  % Excel
        root.ext = '.xls';
         root.selectmode = 'off';        
      case 6  % BIL
        root.ext = '.bil';
        root.selectmode = 'on';
     otherwise
        root.ext = '.*';
    end
    
  case 9  %  RADIO SONDAGE
    handle = findobj('-regexp','Tag','plot');
    if ~isempty(handle)
      delete(handle);
    end
    root.format = {'dataGUI','XML','NetCDF','OceanSITES'};
    switch fmt
      case 1  % fichier ASCII datagui
        root.ext = '*_rsm';
        root.selectmode = 'off';
      case 2  % XML
        root.ext = '*_rsm.xml';
        root.selectmode = 'off';        
      case 3  % NetCDF
        root.ext = '*_rsm.nc';
        root.selectmode = 'off';        
      case 4  % OceanSITES
        root.ext = 'OS_*_RSM.nc';
        root.selectmode = 'off';        
     otherwise
        root.ext = '.*';
        root.selectmode = 'on';
    end

    
end;

% met a jour le popup format
lt = root.format;
lt = length( lt );
if root.format_value > lt
  root.format_value = 1;
  set( findobj( 'Tag', 'popup_format' ), 'Value', root.format_value);
end  
set( findobj( 'Tag', 'popup_format' ), 'String', root.format);
root.type_value = type_value;


% maj root dans UserData de 0
set(0, 'UserData', root );

% met a jour la liste des fichiers dispo dans le repertoire courant
get_files_dir;

%clear  dlist self old root path type fmt format handle textfile;
clear root lt type_value fmt old handle;
