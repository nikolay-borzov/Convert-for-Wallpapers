function Handle-Processed
{
  [CmdletBinding()]
  Param
  (
    [ValidateSet("Ignore","Copy","Move")] 
    [String]$Strategy,

    [Parameter(Mandatory=$True)]
    [String]$FileFullName,

    [Parameter(Mandatory=$True)]
    [String]$Path
  )

  if($Strategy -eq "Copy")
  {
    Copy-Item -LiteralPath $FileFullName -Destination $Path -Force
  }
  elseif($Strategy -eq "Move")
  {
    Move-Item -LiteralPath $FileFullName -Destination $Path -Force
  }
}