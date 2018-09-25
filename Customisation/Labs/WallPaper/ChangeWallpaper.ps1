takeown /f c:\windows\WEB\wallpaper\Windows\img0.jpg
takeown /f C:\Windows\Web\4K\Wallpaper\Windows\*.*
icacls c:\windows\WEB\wallpaper\Windows\img0.jpg /Grant ‘System:(F)’
icacls C:\Windows\Web\4K\Wallpaper\Windows\*.* /Grant ‘System:(F)’
Remove-Item c:\windows\WEB\wallpaper\Windows\img0.jpg
Remove-Item C:\Windows\Web\4K\Wallpaper\Windows\*.*
Copy-Item $PSScriptRoot\DefaultRes\img0.jpg c:\windows\WEB\wallpaper\Windows\img0.jpg
Copy-Item $PSScriptRoot\4K\img0.jpg C:\Windows\Web\4K\Wallpaper\Windows\img0.jpg
Copy-Item $PSScriptRoot\DefaultRes\lock.jpg c:\windows\WEB\Screen\lock.jpg
New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\ -Name Personalization -Value "Default Value" -Force
New-ItemProperty  -Path  HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name "LockScreenImage" -PropertyType "String" -Value 'c:\windows\WEB\Screen\lock.jpg'