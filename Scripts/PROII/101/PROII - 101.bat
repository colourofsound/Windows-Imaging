@echo on

setx IPASSI_LICENSE_FILE "27011@vwansys.chester.lan" /m

xcopy /y %~dp0PROII.ini "C:\Program Files\SimSci\PROII101\System"

rem just to be sure we can remove Default quickly
rmdir "C:\Users\Default\AppData\Roaming\SIMSCI" /S /Q

rem delete in each users profile if the folder is there
cd /d "C:\Users"
for /d %%a in (*) do rd /s /q "C:\Users\%%a\AppData\Roaming\SIMSCI" >nul 2>&1

echo [+] Done

