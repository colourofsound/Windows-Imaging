<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
	# LICENSE #
	PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows. 
	Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
.EXAMPLE
    Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK 
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	
	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'Epic'
	[string]$appName = 'Unreal Engine'
	[string]$appVersion = '4.20.2'
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '02/12/2017'
	[string]$appScriptAuthor = 'Chris Walker - tsp.imaging@chester.ac.uk'
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = ''
	[string]$installTitle = ''
	
	##* Do not modify section below
	#region DoNotModify
	
	## Variables: Exit Code
	[int32]$mainExitCode = 0
	
	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.7.0'
	[string]$deployAppScriptDate = '02/13/2018'
	[hashtable]$deployAppScriptParameters = $psBoundParameters
	
	## Variables: Environment
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
	
	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}
	
	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================
		
	If ($deploymentType -ine 'Uninstall') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

		## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
		#Show-InstallationWelcome -CloseApps 'iexplore' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
		## <Perform Pre-Installation tasks here>
		
        ## Uninstall Existing Epic Games Launcher
        If (Test-Path -Path 'C:\ProgramData\Microsoft\VisualStudio\Packages\UnrealEngineV1,version=1.0.1\packages\UnrealEngineV1\EpicGameLauncher.msi' -ErrorAction Continue){
        Execute-MSI -Action 'Uninstall' -Path 'C:\ProgramData\Microsoft\VisualStudio\Packages\UnrealEngineV1,version=1.0.1\packages\UnrealEngineV1\EpicGameLauncher.msi'
        }

        ## Uninstall Existing Epic Games Launcher PreReqs
         If (Test-Path -Path 'C:\ProgramData\Package Cache\{c6c5a357-c7ca-4a5f-9789-3bb1af579253}\LauncherPrereqSetup_x64.exe' -ErrorAction Continue){
        Execute-Process -Path 'C:\ProgramData\Package Cache\{c6c5a357-c7ca-4a5f-9789-3bb1af579253}\LauncherPrereqSetup_x64.exe' -Parameters '/uninstall /quiet' -Verbose
        }
        
        ## Uninstall Existing UE4 PreRegs
         If (Test-Path -Path 'C:\ProgramData\Package Cache\{F9EC45F9-074A-48BF-92E9-A8CADD56F693}v1.0.11.0\UE4PreregSetup_x64.msi' -ErrorAction Continue){
        Execute-MSI -Action 'Uninstall' -Path 'C:\ProgramData\Package Cache\{F9EC45F9-074A-48BF-92E9-A8CADD56F693}v1.0.11.0\UE4PreregSetup_x64.msi'
        }

        ## Delete Existing Unreal Engine

        Remove-Folder -Path 'C:\Program Files\Epic Games' -Verbose

        ## Delete Existing User Prefs

        Remove-Folder -Path 'C:\ProgramData\Epic' -Verbose

        Remove-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\EpicGames'

        Remove-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\EpicGames'

		
		##*===============================================
		##* INSTALLATION 
		##*===============================================
		[string]$installPhase = 'Installation'
		
		## Handle Zero-Config MSI Installations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) { $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } }
		}
		
		## <Perform Installation tasks here>
		
        #Execute-MSI -Action 'Install' -Path "$dirSupportFiles\UE4PrereqSetup_x64.msi" -Parameters '/qn'

        #Execute-Process -Path "$dirSupportFiles\LauncherPrereqSetup_x64.exe" -Parameters '/install /quiet /norestart'

        Execute-MSI -Action 'Install' -Path "$dirFiles\epicgameslauncher.msi" -Parameters '/qn'
		
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'
		
		## <Perform Post-Installation tasks here>

        Copy-File -Path "$dirSupportFiles\UE*.7z" -Destination "C:\Program Files\Epic Games\" -Recurse -Verbose

        Execute-Process -Path "C:\Program Files\7-Zip\7z.exe" -Parameters 'x "C:\Program Files\Epic Games\UE*.7z" -o"C:\Program Files\Epic Games\"'

        Copy-File -Path "$dirSupportFiles\Epic\*" -Destination "C:\ProgramData\Epic\" -Recurse -Verbose

        Copy-File -Path "$dirSupportFiles\Unreal Engine.lnk" -Destination "C:\Users\Default\Desktop"

        Copy-File -Path "$dirSupportFiles\Unreal Engine.lnk" -Destination "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\"

        Execute-Process -Path "C:\Windows\System32\icacls.exe" -Parameters '"C:\Program Files\Epic Games" /grant Users:(OI)(CI)F /T'

        Remove-File -Path "C:\Program Files\Epic Games\UE*.7z"

        Remove-File -Path "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Epic Games Launcher.lnk"
		
		## Display a message at the end of the install
		If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'Success! Time for a Biscuit.' -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'
		
		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
		## <Perform Pre-Uninstallation tasks here>
		
        
		
		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'
		
		## Handle Zero-Config MSI Uninstallations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}
		
		# <Perform Uninstallation tasks here>
		
        ## Uninstall Existing Epic Games Launcher
         If (Test-Path -Path 'C:\ProgramData\Microsoft\VisualStudio\Packages\UnrealEngineV1,version=1.0.1\packages\UnrealEngineV1\EpicGameLauncher.msi' -ErrorAction Continue){
        Execute-MSI -Action 'Uninstall' -Path 'C:\ProgramData\Microsoft\VisualStudio\Packages\UnrealEngineV1,version=1.0.1\packages\UnrealEngineV1\EpicGameLauncher.msi'
        }

        ## Uninstall Existing Epic Games Launcher PreReqs
         If (Test-Path -Path 'C:\ProgramData\Package Cache\{c6c5a357-c7ca-4a5f-9789-3bb1af579253}\LauncherPrereqSetup_x64.exe' -ErrorAction Continue){
        Execute-Process -Path 'C:\ProgramData\Package Cache\{c6c5a357-c7ca-4a5f-9789-3bb1af579253}\LauncherPrereqSetup_x64.exe' -Parameters '/uninstall /quiet' -Verbose 
        }
        
        ## Uninstall Existing UE4 PreRegs
         If (Test-Path -Path 'C:\ProgramData\Package Cache\{F9EC45F9-074A-48BF-92E9-A8CADD56F693}v1.0.11.0\UE4PreregSetup_x64.msi' -ErrorAction Continue){
        Execute-MSI -Action 'Uninstall' -Path 'C:\ProgramData\Package Cache\{F9EC45F9-074A-48BF-92E9-A8CADD56F693}v1.0.11.0\UE4PreregSetup_x64.msi'
        }

        ## Delete Existing Unreal Engine

        Remove-Folder -Path 'C:\Program Files\Epic Games' -Verbose

        ## Delete Existing User Prefs

        Remove-Folder -Path 'C:\ProgramData\Epic' -Verbose

        Remove-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\EpicGames'

        Remove-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\EpicGames'
		
		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'
		
		## <Perform Post-Uninstallation tasks here>
		
		
	}
	
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================
	
	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}