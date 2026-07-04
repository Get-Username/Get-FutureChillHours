<#	
	.NOTES
	===========================================================================
	 Created on:	   	06/28/2026
	 Created by:   		trevorfreedland@gmail.com
	 File Version:     	0.0.2
	 Project Name:		Permasilience Climate Analysis
	 File Name:			Get-UtahChillHours.ps1
	===========================================================================
	.DESCRIPTION
		Calculates estimate chill hours from hourly recorded temps
#>

function Get-UtahChillHours {
	<#
	.PARAMETER csvFile
        Filepath to the input file.  Expects MRCC export with two cols: Date and Temperature (F)
	.EXAMPLE
		PS C:\> Get-UtahChillHours -csvFile ~/RICtemps.csv
	.DESCRIPTION
		The ranges for the Richardson Chill Unit Model aka the Utah model
			1 hour below 34.99°F 	=  0.0 chill unit
			1 hour 35.00 - 36.99°F 	=  0.5 chill unit
			1 hour 37.00 - 48.99°F 	=  1.0 chill unit
			1 hour 49.00 - 54.99°F 	=  0.5 chill unit
			1 hour 55.00 - 60.99°F 	=  0.0 chill unit
			1 hour 61.00 - 65.99°F 	= -0.5 chill unit
			1 hour >65.99°F 		= -1.0 chill unit

		citation: 
		https://www.researchgate.net/publication/284288130_A_model_for_estimating_the_completion_of_rest_for_'Redhaven'_and_'Elberta'_Peach_Trees
		Richardson, E. & Seeley, Schuyler & Walker, David. (1974). A Model for Estimating the Completion of Rest for ‘Redhaven’ and ‘Elberta’ Peach Trees
		1. HortScience. 9. 331-332. 10.21273/HORTSCI.9.4.331. 
	#>

	[CmdletBinding()]
	param(
		[Parameter(			
			HelpMessage = '.csv input file.')]
		[string]$csvFile,
		[Parameter(
			HelpMessage = 'Dir of .csv input files.')]
		[string]$csvDir,
		[Parameter(Mandatory = $true,
			HelpMessage = 'Path to where new csv output file should be saved.')]
		[ValidatePattern('\.csv$')]
		[string]$outFile
	)
	$csvFilesToProcess = Get-ChildItem $csvDir

	if ($csvFilesToProcess.count -eq 0) {
		try { $csvFilesToProcess = $csvFile }
		catch { Write-Output "Either csvFile or csvDir are required." }
	}

	foreach ($file in $csvFilesToProcess) {
		$csvData = Import-Csv $file 
		[Int16]$chillHours = 0
	
		foreach ($line in $csvData) {
			switch ($line.'Temperature (F)') {
				{ $_ -lt 34.99 } { break } # 0 points
				{ $_ -ge 35 -and $_ -lt 37 } { $chillHours += 0.5; break }
				{ $_ -ge 37 -and $_ -lt 49 } { $chillHours += 1.0; break }
				{ $_ -ge 49 -and $_ -lt 55 } { $chillHours += 0.5; break }
				{ $_ -ge 55 -and $_ -lt 61 } { break } # 0 points
				{ $_ -ge 61 -and $_ -lt 66 } { $chillHours += -0.5; break }
				{ $_ -gt 66 } { $chillHours += -1.0; break }
			}
		}
		Write-Output "Bleep bloop, the total chill hours found in $file is: $chillHours"
		if ($outFile) {
			if (-not (Test-Path $outFile)) {
				Add-Content -Path $outFile -Value '"filename","utah-chill-hours"'
			}
			Add-Content -Path $outFile -Value "$($file.Name),$chillHours"
		}
	}
} # End function Get-UtahChillHours

$csvDir = "./data/transformed-data"
$outFile = '~/Documents/Local-Projects/Get-ChillHours/data/output-data/RIC-30-Report.csv'
Get-UtahChillHours -csvDir $csvDir -outFile $outFile
