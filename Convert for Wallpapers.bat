echo off

for %%x in (%*) do (
	PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%CD%\convert_for_wallpapers.ps1' -FolderPath '%%x' -Width 720 -Height 1280 -Deviation 50 -SkipStrategy 'Move' -MoveConverted 1"
)

PAUSE