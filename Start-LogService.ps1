<#
.SYNOPSIS 
    This script sets up an HTTP listener to provide on-demand log retrieval via REST requests.

.DESCRIPTION
    The script starts an HTTP listener on http://localhost:8080/ and listens for incoming requests. When a request is received, 
    it checks if the requested URL path matches a predefined endpoint. 
    If the path matches, the script retrieves logs from a specified directory and sends them as a response. 
    If the path does not match, it responds with a 404 Not Found status code.

.PARAMETER LogDirectory
    Specifies the directory where log files are stored. The script retrieves logs from this directory in response to a valid request.

.EXAMPLE
    .\StartLogService.ps1 -LogDirectory "C:\ProgramData"
    
.NOTES
    Author: Jason Gebhart
    Date: November, 14, 2023
    Version: 1.0
#>
param (
    $LogDirectory = "C:\ProgramData"
)
Import-Module $PSScriptRoot\modules\LogHunter\LogHunter.psm1
# Start an HTTP listener
# https://learn.microsoft.com/en-us/dotnet/api/system.net.httplistener?view=net-7.0
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/") # define URI for listener
$listener.Start()
Write-Output -InputObject "Listening for requests on http://localhost:8080"

# Handle incoming requests
while ($listener.IsListening) {
    # The GetContext() method returns an instance of the listener context class.
    # This object contains information about the incoming HTTP request
    # and provides access to the HttpListenerRequest and HttpListenerResponse objects.
    $context = $listener.GetContext()
    # The listener.Request contains properties for the incoming request
    $request = $context.Request
    # The response is the web servers response to the requesting client.
    $response = $context.Response

    # Adding these headers allow the Console and Agent to talk when running on the same computer.
    # Allow requests from any origin
    $response.Headers.Add("Access-Control-Allow-Origin", "*")

    # Allow specific HTTP methods
    $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")

    # Allow specific HTTP headers
    $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, Authorization")

    # Parse query parameters
    # http://localhost:8080/logs?filename=example.log&filter=keyword&last=10
    $query = $request.Url.Query.TrimStart('?') -split '&'
    $queryParams = @{}
    # Build new hash with parameters
    foreach ($param in $query) {
        $key, $value = $param -split '='
        $queryParams[$key] = $value
    }
    switch ($request.Url.LocalPath) {
        '/logs' {
            Write-Output "request.Url.LocalPath: $($request.Url.LocalPath)"
            # Extract the log filename from the URL
            $LogFile = $queryParams['filename']

            # Check if log file is provided
            if (-not $LogFile) {
                $response.StatusCode = 400 # Bad Request
                $response.StatusDescription = "Bad Request: Log file name is missing."
                $response.Close()
                break
            }

            Write-output $LogFile
            # Create a parameter object
            $logParams = @{
                LogDirectory = $LogDirectory
                LogFile = $LogFile
            }

            if ($queryParams.ContainsKey('filter')) {
                Write-output "$($queryParams['filter'])"
                $logParams['filter'] = $queryParams['filter']
            }

            if ($queryParams.ContainsKey('last')) {
                Write-output "Last: $($queryParams['last'])"
                $logParams['Lines'] = $queryParams['last']
            }
   
            # Retrieve logs using the function
            $logs = Get-LocalLogContent @logParams

            # The OutputStream provides access to the outgoing Http Response 
            # The Write method of the OutputStream allows us to add data to the OutputStream
            # The write method takes these three parameters.
            # buffer = the data(in bytes) to write
            # 0 = any offset?
            # buffer.Length = total bytes to return
            $LogsInBytes = [System.Text.Encoding]::UTF8.GetBytes($logs)
            $response.OutputStream.Write($LogsInBytes, 0, $LogsInBytes.Length)
        }
        '/list' {
            Write-Output "request.Url.LocalPath: $($request.Url.LocalPath)"
            # Retrieve logs
            $list = Get-LocalLogFileList -LogDirectory "C:\ProgramData"
            $ListInBytes = [System.Text.Encoding]::UTF8.GetBytes($list)
            $response.OutputStream.Write($ListInBytes, 0, $ListInBytes.Length)
        }
        '/summary' {
            Write-Output "request.Url.LocalPath: $($request.Url.LocalPath)"
            # Retrieve totla number of logs found
            $summary = Get-LocalLogSummary -LogDirectory "C:\ProgramData"
            $SummaryBytes = [System.Text.Encoding]::UTF8.GetBytes($summary)
            $response.OutputStream.Write($SummaryBytes, 0, $SummaryBytes.Length)
        }
        default {
            $response.StatusCode = 404  # Not Found
        }
    }
    $response.Close()
}

# Stop the listener when done
$listener.Stop()