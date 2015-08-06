Invoke-MsBuild-PowerShell-Module
================================

Executes the MSDeploy.exe tool. Returns true if the deploy succeeded, false if the deploy failed, and null if we could not determine the deploy result. If using the PathThru switch, the process running MSDeploy is returned instead.
	
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


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/omids20m/invoke-msbuild-powershell-module/trend.png)](https://bitdeli.com/free "Bitdeli Badge")



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/omids20m/invoke-msdeploy-powershell-module/trend.png)](https://bitdeli.com/free "Bitdeli Badge")



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/omids20m/invoke-msdeploy-powershell-module/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

