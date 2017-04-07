pwd
set "CRUISE=LAPEROUSE"
set "CONFIG=laperouse.ini"
set "PREFIX=lape"
M:\%CRUISE%\local\sbin\oceano2oceansites -c M:\%CRUISE%\data-processing\%CONFIG% -r M:\%CRUISE%\local\code_roscop.csv -e --files=M:\%CRUISE%\data-processing\CTD\data\cnv\%PREFIX%*.cnv 
rem M:\%CRUISE%\local\sbin\oceano2oceansites -c M:\%CRUISE%\data-processing\%CONFIG% -r M:\%CRUISE%\local\code_roscop.csv -e -a --files=M:\%CRUISE%\data-processing\CTD\data\cnv\%PREFIX%*.cnv 
pause
