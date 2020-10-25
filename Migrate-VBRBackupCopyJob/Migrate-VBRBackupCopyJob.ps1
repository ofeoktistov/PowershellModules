 function Migrate-VBRBackupCopyJob {
[CmdletBinding()]

param (
   [Parameter(ParameterSetName='SourceJob', Mandatory=$false,
              HelpMessage="Name of the source job that you want to migrate to immediate mode")]
   [Veeam.Backup.Core.CBackupJob]$SourceJob,
   [Parameter(ParameterSetName='ApplyToAll', Mandatory=$false,
              HelpMessage="Enable if you want to migrate all backup copy jobs to immediate mode")]
   [Switch]$ApplyToAll


)
try {
    if ($ApplyToAll) {
        $SourceJob = Get-VBRJob | where {$_.JobType -eq 'BackupSync'}
    }

foreach ($source in $SourceJob) {
    if ($source.JobType -ne 'BackupSync') {
      throw 'Source job is not backup copy job'
    }
    else {
    $linkedJobs = @()
    foreach ($linkedJob in $sourceJob.LinkedJobIds) {
        $job = $jobs | where {$_.Id -eq $linkedJob}
        $linkedJobs += $job

    }
    $targetRepository = $sourceJob.FindTargetRepository()
    $sourceWan = $sourceJob.FindSourceWanAccelerator()
    $targetWan = $sourceJob.FindTargetWanAccelerator()
    $migratedName = "$($sourceJob.Name)_migrated"
 
    Add-VBRViBackupCopyJob -Name $migratedName -Description $sourcejob.Description -BackupJob $linkedJobs -SourceAccelerator $sourceWan -TargetAccelerator $targetWan -Repository $targetRepository -EnableImmediateCopy
    $migratedJob = Get-VBRJob -Name $migratedName
    $options = Get-VBRJobOptions -Job $sourceJob
    Set-VBRJobOptions -Job $migratedJob -Options $options
  
}
}
}
catch {
 throw $_
}

} 
