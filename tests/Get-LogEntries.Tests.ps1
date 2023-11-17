# Retrieve the last 10 lines of the `chocolatey.log` file containing the keyword "error."
$chocolateyLog = Invoke-RestMethod -Uri "http://localhost:8080/logs?filename=chocolatey.log&filter=error&last=2"

$list = Invoke-RestMethod -Uri "http://localhost:8080/list"

# Retrieve a count of logs from the specified log directory.
$logcount = Invoke-RestMethod -Uri 'http://localhost:8080/summary'

# Retrieve logs for the log file named `events.log` without additional filters or limits.
$events = Invoke-RestMethod -Uri 'http://localhost:8080/logs?filename=events.log'

# Handle scenarios where an unrecognized endpoint returns a 404 Not Found status code.
try {
    Invoke-RestMethod -Uri 'http://localhost:8080/invalid' -ErrorAction Stop
    Write-Output "Request successful!"
} catch {
    if ($_.Exception.Status -eq 404) {
        $BadRoute = "The requested resource was not found (HTTP 404)."
    } else {
        $BadRoute = "An error occurred: $($_.Exception.Message)"
    }
}

# Handle scenarios where a required query parameter is missing, resulting in a 400 Bad Request.
try {
    Invoke-RestMethod -Uri 'http://localhost:8080/logs' -ErrorAction Stop
    Write-Output "Request successful!"
} catch {
    if ($_.Exception.Status -eq 400) {
        $MissingQueryCheck = "The required query parameter is missing (HTTP 400)."
    } else {
        $MissingQueryCheck = "An error occurred: $($_.Exception.Message)"
    }
}

Write-Output "Test the full query by reading the chocolatey.log, filter=error and last=2"
Write-Output $chocolateyLog 

Write-Output "Test the list logs function but only return the first 5 Logs"
Write-Output ($list -split("`r`n"))[0..4]

Write-Output "Test the count logs function"
Write-Output $logcount

Write-Output "Test scenario where the log filename is passed but no 'last' parameter was passed"
Write-Output $events[0]

Write-Output -inputobject "Test scenarios where an unrecognized endpoint is included in URL. returns a 404 Not Found status code." 
Write-Output $BadRoute 

Write-Output "Test for scenario when there is no Query in the URL"
Write-Output $MissingQueryCheck