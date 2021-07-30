<#
.SYNOPSIS
	This script is getting Skype for Business Online information.

.DESCRIPTION
	This script is getting Skype for Business Online information, about an existing User Principal Name
    Ether from from a file or directly as a parameter

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
	.\Check-UserSettings.ps1 -UserPrincipalName test@contoso.com

	Description
	-----------
	Will Connect to MsolService and MSTeams and show SfBO settings for user test@contoso.com
	
.PARAMETER UserPrincipalName
    String. UserPrincipalName of the user to get information from

.PARAMETER InputFile
    String. File name (and path if you wish) of the file.
	If specified, the InputFile must be a text file and the first line must be 'UserPrincipalName' followed by UPN's. One per line
    Example:
        UserPrincipalName
        user1@contoso.com
        user2@contoso.com

.PARAMETER SkipUpdateCheck
	Boolean. Skips the automatic check for an Update. Courtesy of Pat: http://www.ucunleashed.com/3168

.PARAMETER skipConnectMsolService
	Boolean. Skips connecting to MsolService
	
.PARAMETER skipConnectMicrosoftTeams
	Boolean. Skips connecting to MicrosoftTeams
	
#>

[CmdletBinding(SupportsShouldProcess = $false)]
param(
	[parameter(ParameterSetName="UserPrincipalName", Mandatory=$false, Position=0)]
    [Alias('u','upn')]
    [string]
    $UserPrincipalName,
    
	[parameter(ParameterSetName="InputFile", Mandatory=$false)]
    [Alias('i')]
    [string]
    $InputFile,
	
    [parameter(Mandatory=$false)]
    [switch] 
    $SkipUpdateCheck,

	[parameter(Mandatory=$false)]
    [switch] 
    $skipConnectMsolService,

	[parameter(Mandatory=$false)]
    [switch] 
    $skipConnectMicrosoftTeams
)

begin {

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
	$ScriptName = 'Check-UserSettings.ps1'
	# End Parameters for function Get-UpdateInfo

	$Error.Clear() #Clear PowerShell's error variable
	$Global:Debug = $psboundparameters.debug.ispresent

	#If the user only provided a filename, add the script's path for an absolute reference:
	$ScriptPath = $MyInvocation.MyCommand.Path
	$Dir = Split-Path -Path $ScriptPath
	
	#--------------------------------
	# Start Functions ---------------
	#--------------------------------

	function Get-UserInfo
	{
		<#
		.SYNOPSIS
		Get SfB Online Information from the users in a file containing UserPrincipalName

		.DESCRIPTION
		Get SfB Online Information from the users in a file containing UserPrincipalName

		.NOTES
		Version					: 1.2 - See changelog at https://ucunleashed.com/3168 for fixes & changes introduced with each version
		Wish list				: Better error trapping
		Rights Required			: Teams-Admin
		Sched Task Required		: No
		Lync/Skype4B Version	: N/A
		Author/Copyright		: © Claus-Ole Olsen
		Email/Blog/Twitter		: coo@mail.dk  https://ocsstuff.blogspot.com/  @ClausOleOlsen
		Disclaimer				: You running this script/function means you will not blame the author(s) if this breaks your stuff. This script/function
								is provided AS IS without warranty of any kind. Author(s) disclaim all implied warranties including, without limitation,
								any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use
								or performance of the sample scripts and documentation remains with you. In no event shall author(s) be held liable for
								any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss
								of business information, or other pecuniary loss) arising out of the use of or inability to use the script or
								documentation. Neither this script/function, nor any part of it other than those parts that are explicitly copied from
								others, may be republished without author(s) express written permission. Author(s) retain the right to alter this
								disclaimer at any time. 
		  Assumptions			: ExecutionPolicy of AllSigned (recommended), RemoteSigned, or Unrestricted (not recommended)
		  Limitations			:
		  Known issues			:

		  .EXAMPLE
		  Get-UserInfo -InputFile 'C:\upns.txt'

		  Description
		  -----------
		  Runs function to get Skype For Business Online information.

		  .INPUTS
		  None. You cannot pipe objects to this script.
	  	#>
		param (
		[string] $InputFile
		)
		
		[array] $Users = Import-Csv -Path $InputFile
		$Max = $Users.Count
		
		foreach ($User in $Users)
		{
			$Percent = $Users.indexOf($User) * 100 / $Max
			Write-Verbose -message "Get SfB Online Info: $($User.UserPrincipalName)"
			write-progress -Activity "Performing check:" -Status "Get SfB Online Info" -CurrentOperation "User: $($User.UserPrincipalName)" -PercentComplete $Percent
		}
		write-progress -Activity "Performing check:" -Status "Performing check Done" -PercentComplete (100) -Completed
	}

	#--------------------------------
	# End Functions -----------------
	#--------------------------------

	# Check if a new version of this script exists.
	if ($skipupdatecheck)
	{
		write-verbose -message 'Skipping update check'
	}
	else
	{
		write-progress -Activity 'Initialising' -Status 'Performing update check' -PercentComplete (2)
		Get-ScriptUpdateInfo -ScriptName $ScriptName -ScriptVersion $ScriptVersion
		write-progress -Activity 'Initialising' -Status 'Back from performing update check' -PercentComplete (50)
	}
	write-progress -Activity 'Initialising' -Status 'Initialising Done' -PercentComplete (100) -Completed
	
	# Connect to MsolService?
	if ($skipConnectMsolService)
	{
		write-verbose -message 'Skipping connect to MsolService'
	}
	else
	{
		write-progress -Activity 'MsolService' -Status 'Connecting...' -PercentComplete (2)
		Connect-MsolService
		write-progress -Activity 'MsolService' -Status 'Connected to MsolService' -PercentComplete (50)
	}
	write-progress -Activity 'MsolService' -Status 'Connection Done' -PercentComplete (100) -Completed

	# Connect to MicrosoftTeams?
	if ($skipConnectMicrosoftTeams)
	{
		write-verbose -message 'Skipping connect to MicrosoftTeams'
	}
	else
	{
		write-progress -Activity 'MicrosoftTeams' -Status 'Connecting...' -PercentComplete (2)
		Connect-MicrosoftTeams
		write-progress -Activity 'MicrosoftTeams' -Status 'Connected to MicrosoftTeams' -PercentComplete (50)
	}
	write-progress -Activity 'MicrosoftTeams' -Status 'Connection Done' -PercentComplete (100) -Completed

} # End "Begin"

process {
	#Create parameters to function Get-UserInfo
	$Params = @{
		}
	# Use UserPrincipalName or InputFile parameter?
	If ([string]::IsNullOrEmpty($UserPrincipalName))
	{
		# Use InputFile
		Write-Verbose -Message "InputFile was used: $InputFile"
		if ([IO.Path]::IsPathRooted($InputFile))
		{
			#It's absolute. Safe to leave.
			$Params.Add("InputFile", $Inputfile)
		}
		else
		{
			#It's relative.
			$Params.Add("InputFile",[IO.Path]::GetFullPath((Join-Path -path $Dir -childpath $InputFile)))
		}
	}
	else
	{
		# Create Temp InputFile  and add UserPrincipalName from UserPrincipalName parameter
		Write-Verbose -Message "UserPrincipalName was used: $UserPrincipalName"
		$TempFile = New-TemporaryFile
		Write-Verbose -Message "Creating Tmp file $TempFile"
		"UserPrincipalName" | Out-File $TempFile.FullName
		$UserPrincipalName | Out-File $TempFile.FullName -Append
		
		$Params.Add("InputFile", $TempFile.FullName)
	}
	
	# Start getting user information
	Get-UserInfo @Params

} # End "Process"

end {

} # End "End"
