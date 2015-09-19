# shortcut taget - C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe "D:\chintsu\Works\scripts\Convert-for-Wallpapers\convert_for_wallpapers.ps1" -Width 720 -Height 1280 -Deviation 70 -SkipStrategy "Move" -FolderPath

[CmdletBinding()]
Param
(
  [Parameter(Mandatory=$True)]
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

#$DebugPreference = "Continue"

#$ImageMagickCovert = "$env:ProgramW6432\ImageMagick\convert.exe"

#$Height = 1280
#$Width = 720

#$Deviation = 50

#$ShowProgress = $True

#$FolderPath = "C:\tmp"

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
  $invalidDimensionPath = Get-Destination "invalidDimensio" $skippedPath
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

# add -Recurse to get files from sub-folders
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
    Write-Progress -Activity "Processing image ($i/$filesCount)" -Status "$percentProcessed%" -PercentComplete ($percentProcessed)
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

$message = "$convertedCount images converted"
$message += "`nSkipped:"
$message += "`n$smallCount small images"
$message += "`n$lesserRatioCount with lesser aspect ratio"
$message += "`n$biggerDeviationCount with bigger deviation`n"

Write-Host $message

Read-Host "Press enter key to exit"