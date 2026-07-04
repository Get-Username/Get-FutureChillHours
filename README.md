The pwsh cmdlets are to: 

1. Format-MRCCData breaks the 30 year export into a separate chill hour season chunk files.  e.g. 15 Oct 1997 - 1 March 1998, 15 Oct 1998 - 1 March 1999, etc. and 

2. Get-UtahChillHours calculates the observed chill hours for each chunk-file using the Richardson Chill Hours Model aka the the Utah Model




The xlsx file is to: 

1. calculate Standard Deviation (SD) 

2. calculate Linear Regression Coefficient

3. extend projections, apply SD, Linear Regression Coefficient(s), and

4. generate line chart




LIMITATIONS:

1. Diversity of input files and formats not tested. 

2. xlsx functions can be fully automated

3. Get-FutureChillHours is the cmdlet in development that chains together the end to end process, including data vis generation. 
