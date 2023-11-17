# Log Retrieval Service

This script sets up a .NET HTTP listener (System.Net.HttpListener) to provide on-demand log retrieval functionality via REST requests.

## Description

The script starts an HTTP listener on http://localhost:8080/ and listens for incoming requests. When a request is received, it checks if the requested URL path matches a predefined endpoint. If the path matches, the script retrieves log information from a specified directory (c:\ProgramData) and sends a response. If the path does not match, it responds with a `404 Not Found` status code.

## variables

- **LogDirectory**: Specifies the directory where the script will look for logs on the agent computer. The script retrieves logs from this directory in response to a valid request.


## Usage

1. Clone the repository.

2. Open a PowerShell session.

3. Navigate to the script directory.

4. Run the script:

```powershell
.\StartLogService.ps1
```

## Notes

- **Author**: Jason Gebhart
- **Date**: November 14, 2023
- **Version**: 1.0

### `/logs`

- Retrieves logs based on query parameters:
  - `filename`: Specifies the log file to retrieve.
  - `filter`: Filters results based on basic text/keyword matches.
  - `last`: Specifies the last n number of matching entries to retrieve within the log.

#### Example

```text
http://localhost:8080/logs?filename=chocolatey.log&filter=python&last=10 
```

### `/list`

- Retrieves a list of log files.

### `/summary`

- Retrieves the total number of logs found.

### Default

- Returns a `404 Not Found` status code for unrecognized endpoints.

## Dependencies

- PowerShell version supporting the .NET HTTPListener.

## Testing
The `tests` folder contains a PowerShell test script called `Get-LogEntries.Tests.ps1`. Run this script against an active Log Hunter Agent after changes are made.


```