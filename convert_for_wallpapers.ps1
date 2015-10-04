<# 
 .Synopsis
  Using ImageMagick resizes images inside -FolderPath.
  
 .Description
  Puts converted images inside "convert_result" subfolder.
  Allows to specify width deviation (the scipt would convert an image with width bigger than -Width) if you need a scrollable wallpaper.
  It does several checks:
  If ImageMagick for some reason cannot determine an image size script moves (depends on -SkipStrategy value) the image to "skipped/invalidDimension" folder.
  If an image smaller that "-Width x -Height" - to "skipped/small" folder.
  If an image aspect ration (width/height) is smaller -Width/-Height - to "skipped/lesserRaio" folder.
  If an image has bigger width deviation - to "skipped/biggerDeviation" folder.

 .Parameter FolderPath
  Path to a folder containing images to convert

 .Parameter Width
  Desired images width

 .Parameter Height
  Desired images height

 .Parameter Deviation
  Images width max allowed deviation (%) - converts images with width range [width, width + width % deviation].
  Specify if you want to get a scrollable wallpaper (e.g. for smartphones)

 .Parameter ShowProgress
  Whether the show progress indicator should be shown.

 .Parameter ImageMagickCovert
  Path to ImageMagick convert.exe (including convert.exe). By default it's equal to "%ProgramW6432%\ImageMagick\convert.exe"

 .Parameter SkipStrategy
  Determines whether skipped images must be ignored ("Ignore"), copied ("Copy") or moved ("Move")

 .Parameter MoveConverted
  Determines whether original images that were converted must be moved to "converted" subfolder


 .Example
  # Converts images with the exact aspect ratio - 720x1280
  convert_for_wallpapers.ps1 -FolderPath "C:\My Images" -Width 720 -Height 1280

 .Example
  # Converts images with variable width 720..1080x1280
  convert_for_wallpapers.ps1 -FolderPath "C:\My Images" -Width 720 -Height 1280 -Deviation 50

 .Example
  # Converts images with exact the same aspect ratio - 720x1280 and move skipped images to a subfolder
  convert_for_wallpapers.ps1 -FolderPath "C:\My Images" -Width 720 -Height 1280 -SkipStrategy "Move"

 .Example
  # Converts images with exact the same aspect ratio - 720x1280 and move original converted images to a subfolder
  convert_for_wallpapers.ps1 -FolderPath "C:\My Images" -Width 720 -Height 1280 -MoveConverted 1

  .Link
  https://github.com/nikolay-borzov/Convert-for-Wallpapers
#>
[CmdletBinding()]
Param
(
  [Parameter(Mandatory=$True)]
  [ValidateScript({Test-Path $_ -PathType 'Container'})]
  [string]$FolderPath,

  [Parameter(Mandatory=$True)]
  [Int]$Width,

  [Parameter(Mandatory=$True)]
  [Int]$Height,

  [Int]$Deviation = 0,

  [Bool]$ShowProgress = $True,

  [ValidateScript({Test-Path $_ -PathType 'Leaf'})] 
  [String]$ImageMagickCovert = "$env:ProgramW6432\ImageMagick\convert.exe",

  [ValidateSet("Ignore","Copy","Move")] 
  [String]$SkipStrategy = "Ignore",

  [Bool]$MoveConverted = $False
)

# add functions
. "$PSScriptRoot\GetDestination.ps1"
. "$PSScriptRoot\GetAspectRatio.ps1"

if($SkippedStrategy -ne "Ignore" -or $MoveConverted) 
{
  . "$PSScriptRoot\HandleProcessed.ps1"
}

$ratio = Get-AspectRatio $Width $Height
Write-Debug "ratio: $ratio"

$savePath = Get-Destination "convert_result" $FolderPath
Write-Debug "savePath: $savePath"

if($SkipStrategy -ne "Ignore") 
{
  $skippedPath = Join-Path $FolderPath "skipped"
  $invalidDimensionPath = Get-Destination "invalidDimension" $skippedPath
  $smallPath = Get-Destination "small" $skippedPath
  $lesserRaionPath = Get-Destination "lesserRaio" $skippedPath
  $biggerDeviationPath = Get-Destination "biggerDeviation" $skippedPath
}

if($MoveConverted)
{
  $convertedPath = Get-Destination "converted" $FolderPath
}

$maxSide = [math]::max($Width, $Height)
$convertSquare = "{0}x{1}>" -f $maxSide, $maxSide

Write-Debug "convertSquare: $convertSquare"

# add -Recurse to get files from subfolders
$fileNames = Get-ChildItem -Path $FolderPath\* -Include *.gif, *.jpg, *.png, *.jpeg | ?{ $_.PSIsContainer-eq $False } | % { $_.FullName }

$i = 0
$filesCount = $fileNames.Length
$convertedCount = 0

$invalidDimensionCount = 0
$smallCount = 0
$lesserRatioCount = 0
$biggerDeviationCount = 0

foreach($fullFileName in $fileNames) 
{
  if($ShowProgress) 
  {
    $i++
    [int]$percentProcessed = ($i / $filesCount)  * 100
    Write-Progress -Activity "Processing image ($i/$filesCount) at $FolderPath" -Status "$percentProcessed%" -PercentComplete ($percentProcessed)
  }

  Write-Debug "`n"
  Write-Debug "$fullFileName"

  $widthRaw = identify -format %w $fullFileName
  $heightRaw = identify -format %h $fullFileName

  $tWidth = $widthRaw -as [int]
  $tHeight = $heightRaw -as [int]

  # skip image which dimensions for some reason are bigger than int
  if($width -eq $Null -or $height -eq $Null)
  {
    $invalidDimensionCount++
    Process-Skipped $SkipStrategy $fullFileName $invalidDimensionPath
    continue
  }

  Write-Debug "tWidth: $tWidth" 
  Write-Debug "tHeight: $tHeight" 

  # skip small images
  if($tHeight -lt $Height)
  {
    $smallCount++
    Handle-Processed $SkipStrategy $fullFileName $smallPath
    continue
  }

  $tRation = Get-AspectRatio $tWidth $tHeight
  Write-Debug "tRation: $tRation"

  # skip images with lesser aspect ration
  if($tRation -lt $ratio)
  {
    $lesserRatioCount++
    Handle-Processed $SkipStrategy $fullFileName $lesserRaionPath
    continue
  }

  if($Deviation -gt 0) 
  {
    $tRatioWidth = $tHeight * $ratio
    Write-Debug "tRatioWidth: $tRatioWidth"

    $tDeviation = [math]::abs([math]::floor($tWidth * 100 / $tRatioWidth) - 100)
    Write-Debug "tDeviation: $tDeviation"

    if($tDeviation -gt $Deviation) 
    {
      $biggerDeviationCount++
      Handle-Processed $SkipStrategy $fullFileName $biggerDeviationPath
  
      continue
    }
  }

  $fileName = Split-Path $fullFileName -Leaf
  $saveName = Join-Path $savePath $fileName

  &"$ImageMagickCovert" "$fullFileName" -resize "$convertSquare" "$saveName"

  if($MoveConverted)
  {
    Handle-Processed "Move" $fullFileName $convertedPath
  }

  $convertedCount++
}

$message = "$FolderPath"
$message += "`n$convertedCount images converted"
$message += "`nSkipped:"
$message += "`n$smallCount small images"
$message += "`n$lesserRatioCount with lesser aspect ratio"
$message += "`n$biggerDeviationCount with bigger deviation`n"

Write-Host $message

# disabled in favor of PAUSE inside "Convert for Wallpapers.bat"
#Read-Host "Press enter key to exit"