<#
.SYNOPSIS
	This script is made to test Script Versions.

.DESCRIPTION
	This script check if there are a new version of this script.

.NOTES
	Version				: 1.0.0
	Date				: 2021-07-21
    Author				: Claus-Ole

    Revision History :
    					v1.0.0: 2021-07-21
							Initial release.


.LINK
	https://github.com/github-coo/PowerShell-Scripts

.EXAMPLE
	.\Test-Script-Version.ps1

	Description
	-----------
	Will test if this script is the most current version
	If not, a prompt to download the latest is presentet

.PARAMETER SkipUpdateCheck
	Boolean. Skips the automatic check for an Update. Courtesy of Pat: http://www.ucunleashed.com/3168
#>

[CmdletBinding(SupportsShouldProcess = $False)]
param(
	[parameter()]
	[switch] $SkipUpdateCheck
)

begin
{
	# Import modules
	# ScriptUpdateinfo
	try {
		$Module = (Join-Path $PSScriptRoot Get-ScriptUpdateinfo.psm1)
		Import-Module $Module 
		Write-Verbose -Message "Module $Module is loaded"		
	}
	catch {
		Write-Verbose -Message "Script is exiting. Module $Module could not be loaded"
		exit
	}

	# Parameters for function Get-UpdateInfo 
	$ScriptVersion = '1.0.0' 
	$ScriptName = 'Test-Script-Version.ps1'
	# End Parameters for function Get-UpdateInfo

	$Error.Clear() #Clear PowerShell's error variable
	$Global:Debug = $psboundparameters.debug.ispresent

	#--------------------------------
	# Start Functions ---------------
	#--------------------------------

	#--------------------------------
	# End Functions -----------------
	#--------------------------------


	if ($skipupdatecheck)
	{
		write-verbose -message 'Skipping update check'
	}
	else
	{
		write-progress -id 1 -Activity 'Initialising' -Status 'Performing update check' -PercentComplete (2)
		Get-ScriptUpdateInfo -ScriptName $ScriptName -ScriptVersion $ScriptVersion
		write-progress -id 1 -Activity 'Initialising' -Status 'Back from performing update check' -PercentComplete (2)
	}

	write-progress -id 1 -Activity 'Initialising' -Status 'Initialising' -PercentComplete (100)

} # End "Begin"

process
{

} # End "Process"

end
{

} # End "End"
