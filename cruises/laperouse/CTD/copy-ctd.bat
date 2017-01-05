rem "script de copie des fichiers CTD vers le reseau pour LAPEROUSE
set "CRUISE=LAPEROUSE"
set "PREFIX=lape"
set "PREFIXM=LAPE"
echo "copy des fichiers vers -> M:\%CRUISE%\data-raw\CTD"
copy c:\SEASOFT\%CRUISE%\data\%PREFIX%%1.hex M:\%CRUISE%\data-raw\CTD\
copy c:\SEASOFT\%CRUISE%\data\%PREFIX%%1.hdr M:\%CRUISE%\data-raw\CTD\
copy c:\SEASOFT\%CRUISE%\data\%PREFIXM%%1.XMLCON M:\%CRUISE%\data-raw\CTD\%PREFIX%%1.xmlcon
copy c:\SEASOFT\%CRUISE%\data\%PREFIX%%1.bl M:\%CRUISE%\data-raw\CTD\%PREFIX%%1.bl
echo "copy des fichiers vers -> M:\%CRUISE%\data-processing\CTD\data\raw"
copy c:\SEASOFT\%CRUISE%\data\%PREFIX%%1.hex M:\%CRUISE%\data-processing\CTD\data\raw\
copy c:\SEASOFT\%CRUISE%\data\%PREFIX%%1.hdr M:\%CRUISE%\data-processing\CTD\data\raw\
copy c:\SEASOFT\%CRUISE%\data\%PREFIXM%%1.XMLCON M:\%CRUISE%\data-processing\CTD\data\raw\%PREFIX%%1.xmlcon
copy c:\SEASOFT\%CRUISE%\data\%PREFIX%%1.bl M:\%CRUISE%\data-processing\CTD\data\raw\%PREFIX%%1.bl
pause
