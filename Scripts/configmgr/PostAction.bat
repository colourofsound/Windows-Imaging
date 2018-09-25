@echo off

:: SMSTSPostAction Script for Thornton ::

:: Reinstall Microsoft Access Database Engine

:: msiexec.exe /f  "C:\Program Files (x86)\MSECache\AceRedist\1033\AceRedist.msi"

:: Run Windows 10 Tweaks

powershell.exe -NoProfile -ExecutionPolicy Bypass -File %~dp0Win10Setup.ps1 -preset %~dp0tsppreset.txt

:: Set Power Profile to high performance ::

:: powercfg -s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

:: Configure Correct DPI ::

regedit.exe /s %~dp096_DPI.reg

:: Set Provisioning Mode to False ::

REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCM\CcmExec /v ProvisioningMode /t REG_SZ /d false /f

:: Clear 'SystemTasksExcludes' Reg Key ::

REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCM\CcmExec /v SystemTaskExcludes /t REG_SZ /d “” /f

:: Clear SCCM Client Cache ::

cscript.exe %~dp0ClearCache.vbs

:: UUID Fix ::

reg add "HKLM\SYSTEM\CurrentControlSet\Services\gpsvc" /v Type /t REG_DWORD /d 0x10 /f

:: Force Group Policy Update ::

gpupdate.exe /force

:: Create List of Installed Software ::

powershell.exe -command "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher | Sort-Object -Property DisplayName | Format-Table -AutoSize -Wrap > C:\DO_NOT_DELETE_LIS-Installed-Programs-List.txt"

:: Set GMT ::

tzutil /s "GMT Standard Time"

:: Perform SCCM Client Actions ::

cscript.exe %~dp0SCCMPerformActions.vbs

:: Apply Firewall Rules ::

:: cmd.exe /c netsh advfirewall import %~dp0ThorntonFirewall.wfw