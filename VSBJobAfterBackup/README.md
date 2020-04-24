# Start SureBackup Job after all Backup Jobs stopped

This cmdlet checks if any backup sessions are still running and starts SureBackup job if they are not.
If they are, it waits for the time specified and retries to run SureBackup for up to the count specified.

## Import
To import this cmdlet, `cd` to the directory where you keep `Start-VSBJobAfterBackup.ps1` and execute the following: \
\
`Import-Module .\Start-VSBJobAfterBackup.ps1`

## Parameters
`-Job` - An array of SureBackup jobs you want to start. *REQUIRED* \
`-Retries` - Retries count in case any backup sessions are still running. *OPTIONAL* \
`-WaitSec` - Time to sleep till the next retry in seconds. *OPTIONAL* \
\

## Syntax
`Start-VSBJobAfterBackup -Job <CSbJob[]> [-Retries <int>] [-WaitSec <int>]`

## Usage

`Start-VSBJobAfterBackup -Job $sbJob -Retries 5 -WaitSec 360`
