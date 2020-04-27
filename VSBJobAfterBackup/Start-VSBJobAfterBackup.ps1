asnp VeeamPSSnapin
function Start-VSBJobAfterBackup {
[CmdletBinding()]
param(
    [Parameter(
        Position = 0,
        Mandatory = $true
    )]
    [Veeam.Backup.Core.SureBackup.CSbJob[]]$Job,
    [int]$retries,
    [int]$waitSec

)
$Count = 0
$success = $null

do {
    try {
       $sessions = Get-VBRBackupSession | where {$_.State -ne 'Stopped'}
       if ($sessions -eq $null) {
        $sbJobs = $Job
        foreach ($sbJob in $sbJobs) {
            write-host 'Starting '$sbJob
            Start-VSBJob -Job $sbJob
        }
        $success = $true
       }
       elseif ($sessions -ne $null) {
            write-host 'Some backup jobs are still running. Sleeping for'$waitSec 'seconds'
            Start-Sleep -Seconds $waitS
            $Count += 1
            write-host 'Retry '$Count
       }
}
catch {
    throw $_.Exception
}
}
until ($Count -eq $retries -or $Success)
} 
