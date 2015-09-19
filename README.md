# Convert for Wallpapers Powershell-ImageMagick script
Powershell script that allows to convert images to use as wallpapers.

##Parameters
**FolderPath** - Images source folder

**Width** - Desired wallpaper width

**Height*** - Desired wallpaper height

**Deviation** - % of the width by what result width could bigger. It's actuall only if you want to get scrollable wallpaper (for smartphones)

**ShowProgress** - Whether images processing progress bar should be shown

**ImageMagickCovert** - Path to ImageMagick convert tool (ex. `C\:Programm Files\ImageMagick\convert.exe`)

**SkipStrategy** - "Ignore", "Copy", "Move". What to do with images aren't fit the criteria. If "Copy" or "Move" is chosen `skipped` folder would be created

**MoveConverted** Whethet converted images should me moved into `converted` subfolder

