for %%x in (%*) do (
	powershell.exe -STA -Command "D:\chintsu\Works\scripts\Convert-for-Wallpapers\convert_for_wallpapers.ps1 -FolderPath '%%x' -Width 720 -Height 1280 -Deviation 70"
)

PAUSE