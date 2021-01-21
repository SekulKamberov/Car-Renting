$count = 0

$arrayApis = @("http://34.68.44.212/", "http://34.68.44.212/cars", "http://34.68.44.212/cars/1")

do {
    $count++

    Write-Output "[$env:STAGE_NAME] Starting container [Attempt: $count]"

	for($i = 0; $i -lt $arrayApis.length; $i++){ 

		$testStart = Invoke-WebRequest -Uri $arrayApis[$i] -UseBasicParsing

		if ($testStart.statuscode -eq '200' -Or $testStart.statuscode -eq '401') {
		  $started = $true
		} 
		else {
		  Start-Sleep -Seconds 5
		}

	}

} until ($started -or ($count -eq 3))

if (!$started) {
    exit 1
}
