#Requires -Version 1.0
function Invoke-MsDeploy
{
<#
	.PARAMETER MsDeployVerb
	Action to perform (required).

	.PARAMETER MsDeploySource
	The source object for the operation.

	.PARAMETER MsDeployDest
	 The destination object for the operation.

	.PARAMETER AllowUntrusted
	 AllowUntrusted Certificate.

	.PARAMETER MsDeployParameters
	 MsDeploy other parameters to prepend.

	.PARAMETER KeepMsDeployLogOnSuccessfulDeploy
	KeepMsDeployLogOnSuccessfulDeploy.
	
	.PARAMETER MsDeployLogDirectoryPath
	The directory path to write the MsDeploy log file to.
	Defaults to putting the log file in the users temp directory (e.g. C:\Users\[User Name]\AppData\Local\Temp).

	.PARAMETER AutoLaunchMsDeployLogOnFailure
	$AutoLaunchMsDeployLogOnFailure.

	.PARAMETER ShowOutputWindow
	If set, this switch will cause a command prompt window to be shown in order to view the progress of the MsDeploy.

	.PARAMETER ShowOutputWindowAndPromptForInputBeforeClosing
	If set, this switch will cause a command prompt window to be shown in order to view the progress of the MsDeploy, and it will remain open
	after the MsDeploy completes until the user presses a key on it.
	NOTE: If not using PassThru, the user will need to provide input before execution will return back to the calling script.

	.PARAMETER PassThru
	If not using PassThru, the user will need to provide input before execution will return back to the calling script.

	.PARAMETER $GetLogPath
	$GetLogPath.
	
	.NOTES
	Name:   Invoke-MsDeploy
	Author: Omid Shariati
	Author's Blog: http://OmidShariati.com
	Version: 1.1
#>
	[CmdletBinding(DefaultParameterSetName="Wait")]
	param
	(
		[parameter(Mandatory=$true)]
		[Alias("Verb")]
		[Alias("V")]
		[string] $MsDeployVerb,
	
		[parameter(Mandatory=$false)]
		[Alias("Source")]
		[Alias("S")]
		[string] $MsDeploySource,

		[parameter(Mandatory=$false)]
		[Alias("Dest")]
		[Alias("D")]
		[string] $MsDeployDest,

		[parameter(Mandatory=$false)]
		[Alias("AllowUntrusted")]
		[Alias("AU")]
		[switch] $AllowUntrust,
		
		[parameter(Mandatory=$false)]
		[Alias("Params")]
		[Alias("P")]
		[string] $MsDeployParameters,

		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[Alias("L")]
		[string] $DeployLogDirectoryPath = $env:Temp,

		[parameter(Mandatory=$false,ParameterSetName="Wait")]
		[ValidateNotNullOrEmpty()]
		[Alias("AutoLaunch")]
		[Alias("A")]
		[switch] $AutoLaunchDeployLogOnFailure,

		[parameter(Mandatory=$false,ParameterSetName="Wait")]
		[ValidateNotNullOrEmpty()]
		[Alias("Keep")]
		[Alias("K")]
		[switch] $KeepDeployLogOnSuccessfulDeploys,

		[parameter(Mandatory=$false)]
		[Alias("Show")]
		[switch] $ShowDeployWindow,

		[parameter(Mandatory=$false)]
		[Alias("Prompt")]
		[switch] $ShowDeployWindowAndPromptForInputBeforeClosing,

		[parameter(Mandatory=$false,ParameterSetName="PassThru")]
		[switch] $PassThru,

		[parameter(Mandatory=$false)]
		[Alias("Get")]
		[Alias("G")]
		[switch] $GetLogPath
	)

	BEGIN {
		Write-Host "Deploy Started....."
	}
	END {
		Write-Host "Deploy end"
	}
	PROCESS
	{
		# Turn on Strict Mode to help catch syntax-related errors.
		# 	This must come after a script's/function's param section.
		# 	Forces a function to be the first non-comment code to appear in a PowerShell Script/Module.
		Set-StrictMode -Version Latest

        # Default the ParameterSet variables that may not have been set depending on which parameter set is being used. This is required for PowerShell v2.0 compatibility.
        if (!(Test-Path Variable:Private:AutoLaunchDeployLogOnFailure)) { $AutoLaunchDeployLogOnFailure = $false }
        if (!(Test-Path Variable:Private:KeepDeployLogOnSuccessfulDeploys)) { $KeepDeployLogOnSuccessfulDeploys = $false }
        if (!(Test-Path Variable:Private:PassThru)) { $PassThru = $false }
		## If the keyword was supplied, place the log in the same folder as the solution/project being built.
		#if ($DeployLogDirectoryPath.Equals("PathDirectory", [System.StringComparison]::InvariantCultureIgnoreCase))
		#{
		#	$DeployLogDirectoryPath = [System.IO.Path]::GetDirectoryName($Path)
		#}
		# Local Variables.
		#$solutionFileName = (Get-ItemProperty -Path $Path).Name
		$deployLogFilePath = $DeployLogDirectoryPath + "\msdeploy.log"
		$windowStyle = if ($ShowDeployWindow -or $ShowDeployWindowAndPromptForInputBeforeClosing) { "Normal" } else { "Hidden" }
		$deployCrashed = $false;
		# If all we want is the path to the Log file that will be generated, return it.
		if ($GetLogPath)
		{
			return $deployLogFilePath
		}

		# Try Deploy.
		try
		{
			# Deploy the arguments to pass to MsDeploy.
			#$deployArguments = "$MsDeployParameters /fileLoggerParameters:LogFile=""$deployLogFilePath"""
			
			#######$deployArguments = "$MsDeployParameters > $deployLogFilePath"
	
			#if($MsDeployVerb -ne "")
			#{
			$deployArguments = " -verb:$MsDeployVerb"
			#}
			if($MsDeploySource -ne "")
			{
				$deployArguments += " -source:''$MsDeploySource''"
			}
			if($MsDeployDest -ne "")
			{
				$deployArguments += " -dest:''$MsDeployDest''"
			}
			if($AllowUntrust -ne "")
			{
				$deployArguments += " -AllowUntrusted"
			}
			if($MsDeployParameters -ne "")
			{
				$deployArguments += " $MsDeployParameters"
			}
			$deployArguments += " > $deployLogFilePath"

			# Get the path to the MsDeploy executable.
			$msDeployPath = Get-MsDeployPath
            $cmdArgumentsToRunMsDeploy = "/k "" ""$msDeployPath"" "


			# Append the MSDeploy arguments to pass into cmd.exe .
			$ShowDeployWindowAndPromptForInputBeforeClosing = $true
			$pauseForInput = if ($ShowDeployWindowAndPromptForInputBeforeClosing) { "Pause & " } else { "" }


			$cmdArgumentsToRunMsDeploy += "$deployArguments & $pauseForInput Exit"" "

			Write-Debug "Starting new cmd.exe process with arguments ""$cmdArgumentsToRunMsDeploy""."

			# Perform the Deploy.
			if ($PassThru)
			{
				return Start-Process cmd.exe -ArgumentList $cmdArgumentsToRunMsDeploy -WindowStyle $windowStyle -PassThru
			}
			else
			{
				$process = Start-Process cmd.exe -ArgumentList $cmdArgumentsToRunMsDeploy -WindowStyle $windowStyle -Wait -PassThru
				$processExitCode = $process.ExitCode
			}
		}
		catch
		{
			$deployCrashed = $true;
			$errorMessage = $_
			Write-Error ("Unexpect error occured while deploing : $errorMessage" );
		}

		# If the deploy crashed, return that the deploy didn't succeed.
		if ($deployCrashed)
		{
			return $false
		}

        # If we can't find the deploy's log file in order to inspect it, write a warning and return null.
        if (!(Test-Path -Path $deployLogFilePath))
        {
            Write-Warning "Cannot find the deploy log file at '$deployLogFilePath', so unable to determine if deploy succeeded or not."
            return $null
        }

		# Get if the deploy failed or not by looking at the log file.
		$deploySucceeded = (((Select-String $deployLogFilePath -Pattern "Error" -SimpleMatch) -eq $null) -and $processExitCode -eq 0)

		# If the deploy succeeded.
		if ($deploySucceeded)
		{
			# If we shouldn't keep the log around, delete it.
			if (!$KeepDeployLogOnSuccessfulDeploys)
			{
				#Remove-Item -Path $deployLogFilePath -Force
				Write-Host ".....Remove-Item -Path $deployLogFilePath -Force";
			}
		}
		# Else at least one of the projects failed to deploy.
		else
		{
			# Write the error message as a warning.
			Write-Warning "FAILED to Deploy. Please check the deploy log ""$deployLogFilePath"" for details." 
			Write-Warning (Get-Content $deployLogFilePath)

			# If we should show the deploy log automatically, open it with the default viewer.
			if($AutoLaunchDeployLogOnFailure)
			{
				Start-Process -verb "Open" $deployLogFilePath;
			}
		}

		#if ($deployCrashed)
		#{
		#	return $false
		#}
		
		# Return if the Deploy Succeeded or Failed.
		return $deploySucceeded
	}
}

function Get-MsDeployPath
{
	# Array of valid MsDeploy versions
	$versions = @("3", "2")

	# Loop through each version from largest to smallest.
	foreach ($version in $versions) 
	{
		WRITE-HOST $version
	
		# Try to find an instance of that particular version in the registry
		$regKey = "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy\${Version}"
		$itemProperty = Get-ItemProperty $RegKey -ErrorAction SilentlyContinue

		# If registry entry exsists, then get the msdeploy path and retrun 
		if ($itemProperty -ne $null -and $itemProperty.InstallPath -ne $null)
		{
			# Get the path from the registry entry, and return it if it exists.
			$msDeployPath = Join-Path $itemProperty.InstallPath "MsDeploy.exe"
			if (Test-Path $msDeployPath)
			{
				return $msDeployPath
			}
		}
	} 

	# Return that we were not able to find MsDeploy.exe.
	return $null
}
Export-ModuleMember -Function Invoke-MsDeploy
