@echo off

rd /S /Q C:\ProgramData\Unity

rd /S /Q C:\Users\Default\AppData\Local\Unity

rd /S /Q C:\Users\Default\AppData\LocalLow\Unity

rd /S /Q C:\Users\Default\AppData\Roaming\Unity

rem delete in each users profile if the folder is there
cd /d "C:\Users"
for /d %%a in (*) do rd /s /q "C:\Users\%%a\AppData\Local\Unity" >nul 2>&1

for /d %%a in (*) do rd /s /q "C:\Users\%%a\AppData\LocalLow\Unity" >nul 2>&1

for /d %%a in (*) do rd /s /q "C:\Users\%%a\AppData\Roaming\Unity" >nul 2>&1

"C:\Program Files\Unity\Editor\Unity.exe" -quit -batchmode -serial E3-TTNR-GFJB-9KFE-QKWM-229W -username "tsp.imaging@chester.ac.uk" -password "Skynett800"