# ============================================================
# SECTION 1 — LOGGING FRAMEWORK
# ============================================================

# Create log directory
$logRoot = "D:\ServiceReset_25H2_Logs"

if (-not (Test-Path $logRoot))
{
    New-Item -ItemType Directory -Path $logRoot | Out-Null
}#end if block

# Timestamp for log filenames
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Human-readable log file
$logFileText = "$logRoot\HumanLog_$timestamp.log"

# Structured JSON forensic log file
$logFileJson = "$logRoot\StructuredLog_$timestamp.jsonl"

# ------------------------------------------------------------
# Write human-readable log entry
# ------------------------------------------------------------
function Write-HumanLog
{
    param(
        [string]$Message
    )

    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $entry = "$ts :: $Message"

    Add-Content -Path $logFileText -Value $entry
}#end function Write-HumanLog

# ------------------------------------------------------------
# Write nested JSON structured log entry
# ------------------------------------------------------------
function Write-JsonLog
{
    param(
        [string]$Level,
        [string]$Category,
        [string]$Operation,
        [string]$Message,
        [string]$Path = "",
        [string]$Code = "",
        [string]$ExceptionType = ""
    )

    $jsonObject = @{
        timestamp = (Get-Date).ToString("o")
        event = @{
            level = $Level
            category = $Category
            operation = $Operation
            path = $Path
            details = @{
                message = $Message
                code = $Code
                exceptionType = $ExceptionType
            }
        }
    }

    $jsonLine = $jsonObject | ConvertTo-Json -Depth 6 -Compress
    Add-Content -Path $logFileJson -Value $jsonLine
}#end function Write-JsonLog

# ------------------------------------------------------------
# Unified logging function (console + text + JSON)
# ------------------------------------------------------------
function Log
{
    param(
        [string]$Level,
        [string]$Category,
        [string]$Operation,
        [string]$Message,
        [string]$Path = "",
        [string]$Code = "",
        [string]$ExceptionType = ""
    )

    # Console color selection
    switch ($Level)
    {
        "INFO"     { $color = "White" }
        "SUCCESS"  { $color = "Green" }
        "WARN"     { $color = "Yellow" }
        "ERROR"    { $color = "Red" }
        "EXCEPTION"{ $color = "DarkRed" }
        default    { $color = "White" }
    }#end switch block

    # Console output
    Write-Host "$Level :: $Category :: $Operation :: $Message" -ForegroundColor $color
    Write-Host "Level: $Level" -ForegroundColor $color
    Write-Host "Category: $Category" -ForegroundColor $color
    Write-Host "Operation: $Operation" -ForegroundColor $color
    Write-Host "Message: $Message" -ForegroundColor $color    

    # Human-readable log
    Write-HumanLog "$Level :: $Category :: $Operation :: $Message"

    # JSON structured log
    Write-JsonLog `
        -Level $Level `
        -Category $Category `
        -Operation $Operation `
        -Message $Message `
        -Path $Path `
        -Code $Code `
        -ExceptionType $ExceptionType
}#end function Log

# ------------------------------------------------------------
# Section header
# ------------------------------------------------------------
Log "INFO" "Init" "LoggingFramework" "Logging framework initialized."
# end SECTION 1
