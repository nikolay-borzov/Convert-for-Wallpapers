function Get-AspectRatio 
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$True)]
		[string]$Width,

		[Parameter(Mandatory=$True)]
		[int]$Height
	)

	return [decimal]($Width / $Height)
}
