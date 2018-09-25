start /wait Powershell.exe Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

powershell.exe choco install %~dp0browsers.config -y

powershell.exe choco install %~dp0frameworks.config -y

powershell.exe choco install %~dp0Tools.config -y

powershell.exe Set-ExecutionPolicy Bypass -Scope Process [Environment]::SetEnvironmentVariable("JETBRAINS_LICENSE_SERVER", "http://vwansys.chester.lan:27010", "Machine")