<#
.SYNOPSIS 
    This module handles the logic for retrieving logs and sending them as a response.

.DESCRIPTION
    These functions are invoked by the Start-LogService.ps1 script. 
    The functions retrieve logs from a specified directory and 
    then sends a response back to the requestor.

.EXAMPLE
    Get-LocalLogContent -LogDirectory "C:\ProgramData" -LogFile "example.log" -Filter "keyword" -Lines 10
    Get-LocalLogFileList -LogDirectory "C:\ProgramData"
    Get-LocalLogSummary -LogDirectory "C:\ProgramData"
#>
function Get-LocalLogContent {
    param (
        [parameter(Mandatory=$true)]
        $LogDirectory,
        [parameter(Mandatory=$true)]
        $LogFile,
        [parameter(Mandatory=$false)]
        $filter,
        [parameter(Mandatory=$false)]
        $lines 
    )
    # Get the list of log file names
    $LogFullName = Get-ChildItem -Path $LogDirectory -Filter $LogFile -File -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

    # Verify that a file was found
    if (Test-Path -Path $LogFullName) {
        if ($filter) {
            $result = Select-String -Path $LogFullName -Pattern $filter
        } else {
            # Retrieve and return the content of the log file
            $result = Get-Content -Path $LogFullName
        }
        if ($lines) {
            $result = $result | Select-Object -Last $lines | Sort-Object -Property LineNumber -Descending  | ConvertTo-Json
        } else {
            $result = $result | Sort-Object -Property LineNumber -Descending | ConvertTo-Json
        }
    } else {
        $result = 404
    }
    $result
}

function Get-LocalLogFileList {
    param (
        [string]$LogDirectory = "C:\ProgramData"
    )
    # Get the list of log file names
    $logFiles = Get-ChildItem -Path $LogDirectory -Filter *.log -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

    # Convert the list to a newline-separated string
    $logFileNames = $logFiles -join "`r`n"
    $logFileNames
}

function Get-LocalLogSummary {
    param (
        [string]$LogDirectory = "C:\ProgramData"
    )

    # Get the list of log file names
    $logFiles = Get-ChildItem -Path $LogDirectory -Filter *.log -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
    $logFiles.count
}
