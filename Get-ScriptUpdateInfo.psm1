
	function Get-ScriptUpdateInfo
	{
	  <#
		.SYNOPSIS
			Queries an online XML source for version information to determine if a new version of the script is available.
			*** This version is customised by Claus-Ole Olsen. @ClausOleOlsen ***

		.DESCRIPTION
			Queries an online XML source for version information to determine if a new version of the script is available.

		.NOTES
			Version					: 1.2 - See changelog at https://ucunleashed.com/3168 for fixes & changes introduced with each version
			Wish list				: Better error trapping
			Rights Required			: N/A
			Sched Task Required		: No
			Lync/Skype4B Version	: N/A
			Author/Copyright		: © Pat Richard, Office Servers and Services (Skype for Business) MVP - All Rights Reserved
			Email/Blog/Twitter		: pat@innervation.com  https://ucunleashed.com  @patrichard
			Donations				: https://www.paypal.me/PatRichard
			Dedicated Post			: https://ucunleashed.com/3168
			Disclaimer				: You running this script/function means you will not blame the author(s) if this breaks your stuff. This script/function
									is provided AS IS without warranty of any kind. Author(s) disclaim all implied warranties including, without limitation,
									any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use
									or performance of the sample scripts and documentation remains with you. In no event shall author(s) be held liable for
									any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss
									of business information, or other pecuniary loss) arising out of the use of or inability to use the script or
									documentation. Neither this script/function, nor any part of it other than those parts that are explicitly copied from
									others, may be republished without author(s) express written permission. Author(s) retain the right to alter this
									disclaimer at any time. For the most up to date version of the disclaimer, see https://ucunleashed.com/code-disclaimer.
			Acknowledgements		: Reading XML files
									http://stackoverflow.com/questions/18509358/how-to-read-xml-in-powershell
									http://stackoverflow.com/questions/20433932/determine-xml-node-exists
			Assumptions			: ExecutionPolicy of AllSigned (recommended), RemoteSigned, or Unrestricted (not recommended)
			Limitations			:
			Known issues			:

		.EXAMPLE
		  	Get-ScriptUpdateInfo -ScriptName 'Test-Script.ps1' -ScriptVersion '1.0.0'

		  	Description
		  	-----------
		  	Runs function to check for updates to script called 'Test-Script.ps1', version 1.0.0

		.PARAMETER ScriptName
		  	String. Filename of the current script.

		.PARAMETER ScriptVersion
		  	String. Version of the current script.

	  #>
		[CmdletBinding()]
		param (
		[string] $ScriptName,
        [string] $ScriptVersion
		)

		# Parameters for function Get-ScriptUpdateInfo 
		[String] $ScriptVersionsURL = 'https://raw.githubusercontent.com/github-coo/PowerShell/master/PowerShell-Scripts-Versions/PowerShell-Script-Versions.xml'
		# End Parameters for function Get-ScriptUpdateInfo
        try
		{
			[bool] $HasInternetAccess = ([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet)
			if ($HasInternetAccess)
			{
				write-verbose -message 'Performing update check'
				# ------------------ TLS 1.2 fixup from https://github.com/chocolatey/choco/wiki/Installation#installing-with-restricted-tls
				$securityProtocolSettingsOriginal = [Net.ServicePointManager]::SecurityProtocol
				try {
				  # Set TLS 1.2 (3072). Use integers because the enumeration values for TLS 1.2 won't exist in .NET 4.0, even though they are
				  # addressable if .NET 4.5+ is installed (.NET 4.5 is an in-place upgrade).
				  [Net.ServicePointManager]::SecurityProtocol = 3072
				} catch {
				  write-verbose -message 'Unable to set PowerShell to use TLS 1.2 due to old .NET Framework installed.'
				}
				# ------------------ end TLS 1.2 fixup
				[xml] $xml = (New-Object -TypeName System.Net.WebClient).DownloadString($ScriptVersionsURL)
				[Net.ServicePointManager]::SecurityProtocol = $securityProtocolSettingsOriginal #Reinstate original SecurityProtocol settings
				$article  = select-XML -xml $xml -xpath ("//article[@title='{0}']" -f ($ScriptName))
				[string] $Ga = $article.node.version.trim()
				if ($article.node.changeLog)
				{
					[string] $changelog = 'This version includes: ' + $article.node.changeLog.trim() + "`n`n"
				}
				if ($Ga -gt $ScriptVersion)
				{
					$wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
					$updatePrompt = $wshell.Popup(("Version {0} is available.`n`n{1}Would you like to download it?" -f ($ga), ($changelog)),0,'New version available',68)
					if ($updatePrompt -eq 6)
					{
						Start-Process -FilePath $article.node.downloadUrl
						write-warning -message "Script is exiting. Please run the new version of the script after you've downloaded it."
						exit
					}
					else
					{
						write-verbose -message ('Upgrade to version {0} was declined' -f ($ga))
					}
				}
				elseif ($Ga -eq $ScriptVersion)
				{
					write-verbose -message ('Script version {0} is the latest released version' -f ($ScriptVersion))
				}
				else
				{
					write-verbose -message ('Script version {0} is newer than the latest released version {1}' -f ($ScriptVersion), ($ga))
				}
			}
			else
			{
			}

		} # end function Get-ScriptUpdateInfo
		catch
		{
			write-verbose -message 'Caught error in Get-ScriptUpdateInfo'
			if ($Global:Debug)
			{
				$Global:error | Format-List -Property * -Force #This dumps to screen as white for the time being. I haven't been able to get it to dump in red
			}
		}
	}
	Export-ModuleMember -Function Get-ScriptUpdateInfo