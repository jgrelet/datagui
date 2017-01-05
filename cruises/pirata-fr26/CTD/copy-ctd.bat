rem "script de copie des fichiers CTD vers le reseau pour PIRATA-FR26
echo "copy des fichiers vers -> M:\PIRATA-FR26\data-raw\CTD"
copy c:\SEASOFT\PIRATA-FR26\data\fr26%1.hex M:\PIRATA-FR26\data-raw\CTD\
copy c:\SEASOFT\PIRATA-FR26\data\FR26%1.XMLCON M:\PIRATA-FR26\data-raw\CTD\fr26%1.xmlcon
copy c:\SEASOFT\PIRATA-FR26\data\fr26%1.bl M:\PIRATA-FR26\data-raw\CTD\fr26%1.bl
echo "copy des fichiers vers -> M:\PIRATA-FR26\data-processing\CTD\data\raw"
copy c:\SEASOFT\PIRATA-FR26\data\fr26%1.hex M:\PIRATA-FR26\data-processing\CTD\data\raw\
copy c:\SEASOFT\PIRATA-FR26\data\FR26%1.XMLCON M:\PIRATA-FR26\data-processing\CTD\data\raw\fr26%1.xmlcon
copy c:\SEASOFT\PIRATA-FR26\data\fr26%1.bl M:\PIRATA-FR26\data-processing\CTD\data\raw\fr26%1.bl
pause
