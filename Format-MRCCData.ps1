<#	
	.NOTES
	===========================================================================
	 Created on:	   	07/02/2026
	 Created by:   		trevorfreedland@gmail.com
	 File Version:     	0.0.1
	 Project Name:		Permasilience Climate Analysis
	 File Name:			Format-MRCCData.ps1
	===========================================================================
	.DESCRIPTION
		Calculates estimate chill hours from hourly recorded temps
#>

function Format-MRCCData {
	<#
	.PARAMETER inFile
        Filepath to the input file.  Expects MRCC (.csv) export with a minimum of two cols: Date and Temperature (F)
	.PARAMETER outPath
        Filepath to the output dir.
	.EXAMPLE
		PS C:\> Format-MRCCData -inFile ~/RICtemps.csv -outPath ~/TempsData 
	.DESCRIPTION
		Formats raw download from MRCC, to be used with Get-UtahChillHours
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = '.csv input file.',
			position = 0)]
		[string]$inFile,
		[Parameter(Mandatory = $true,
			position = 1)]
		[string]$outPath
	)

	$csvData = Import-Csv $inFile
	
	foreach ($line in $csvData) {
		$write = $false
		$doy = (Get-Date $line.Date).DayOfYear
		$year = (Get-Date $line.Date).Year

		if ($doy -ge 288) {
			$closeYear = $year + 1
			$outputPath = Join-Path $outPath "$year-$closeYear.csv"
			$write = $true
		}
		elseif ($doy -le 60) {
			$startYear = $year - 1
			$outputPath = Join-Path $outPath "$startYear-$year.csv"
			$write = $true
		}
		if ($write) {
			if (-not (Test-Path $outputPath)){
				Add-Content -Path $outputPath -Value '"date","Temperature (F)"'
			}
			Add-Content -Path $outputPath -Value "$($line.date),$($line.'Temperature (F)')"
		}
	}

	Write-Output "Bleep bloop, automation complete."
} # End function Format-MRCCData
