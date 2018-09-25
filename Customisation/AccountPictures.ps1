Remove-Item "C:\ProgramData\Microsoft\User Account Pictures\*.png"
Remove-Item "C:\ProgramData\Microsoft\User Account Pictures\*.bmp"
Copy-Item $PSScriptRoot\AccountPictures\*.* "C:\ProgramData\Microsoft\User Account Pictures"