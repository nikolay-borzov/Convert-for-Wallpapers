<# 
 .Synopsis
  Returns folder object by given folder name and path.

 .Description
  By given folder name and path determines whether folder exists. If not - creates new.
  Returns folder object

 .Parameter Name
  Folder name to create/return.

 .Parameter ParentFolder
  Path to folder parent.

 .Example
  # Creates and returns folder at C:\Temp\folder1.
  GetDestination "folder1" "C:\Temp"
#>
function Get-Destination 
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True)]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [string]$ParentFolder
    )

    $path = Join-Path $ParentFolder $Name
   
    if(Test-Path -LiteralPath $path -PathType container) 
    {
        Get-Item -LiteralPath $path
    } 
    else 
    {
        New-Item -Path $ParentFolder -Name $Name -ItemType Directory
    }
}