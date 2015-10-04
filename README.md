# Convert for Wallpapers Powershell-ImageMagick script
Powershell script that allows to convert images to use as wallpapers.

```
NAME
    D:\chintsu\Works\scripts\Convert-for-Wallpapers\convert_for_wallpapers.ps1
    
SYNOPSIS
    Using ImageMagick resizes images inside -FolderPath.
    
    
SYNTAX
    D:\chintsu\Works\scripts\Convert-for-Wallpapers\convert_for_wallpapers.ps1 [-FolderPath] <String> [-Width] <Int32> [-Height] <Int32> [[-Deviation] <Int32>] [[-ShowProgress] <Boolean>] [
    [-ImageMagickCovert] <String>] [[-SkipStrategy] <String>] [[-MoveConverted] <Boolean>] [<CommonParameters>]
    
    
DESCRIPTION
    Puts converted images inside "convert_result" subfolder.
    Allows to specify width deviation (the scipt would convert an image with width bigger than -Width) if you need a scrollable wallpaper.
    It does several checks:
    If ImageMagick for some reason cannot determine an image size script moves (depends on -SkipStrategy value) the image to "skipped/invalidDimension" folder.
    If an image smaller that "-Width x -Height" - to "skipped/small" folder.
    If an image aspect ration (width/height) is smaller -Width/-Height - to "skipped/lesserRaio" folder.
    If an image has bigger width deviation - to "skipped/biggerDeviation" folder.
```

