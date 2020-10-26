 function Migrate-VBRBackupCopyJob {
[CmdletBinding()]

param (
   [Parameter(ParameterSetName='SourceJob', Mandatory=$false,
              HelpMessage="Name of the source job that you want to migrate to immediate mode")]
   [Veeam.Backup.Core.CBackupJob[]]$SourceJob,
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
    foreach ($linkedJob in $source.LinkedJobIds) {
        $job = Get-VBRJob | where {$_.Id -eq $linkedJob}
        $linkedJobs += $job

    }
    $wanEnabled = $source.IsWanAcceleratorEnabled()
    $description = $source.Description
    $targetRepository = $source.FindTargetRepository()
    $migratedName = "$($source.Name)_migrated"
    if ($wanEnabled -eq $true -and $description -eq "") {
        $sourceWan = $source.FindSourceWanAccelerator()
        $targetWan = $source.FindTargetWanAccelerator()
        Add-VBRViBackupCopyJob -Name $migratedName -BackupJob $linkedJobs -SourceAccelerator $sourceWan -TargetAccelerator $targetWan -Repository $targetRepository -EnableImmediateCopy
        $migratedJob = Get-VBRJob -Name $migratedName
        $options = Get-VBRJobOptions -Job $source
        Set-VBRJobOptions -Job $migratedJob -Options $options
     }
    
    elseif ($wanEnabled -eq $false -and $description -ne "") {
        Add-VBRViBackupCopyJob -Name $migratedName -BackupJob $linkedJobs -Description $source.Description -DirectOperation -Repository $targetRepository -EnableImmediateCopy
        $migratedJob = Get-VBRJob -Name $migratedName
        $options = Get-VBRJobOptions -Job $source
        Set-VBRJobOptions -Job $migratedJob -Options $options
    
    }
    elseif ($wanEnabled -eq $true -and $description -ne "") {
        $sourceWan = $source.FindSourceWanAccelerator()
        $targetWan = $source.FindTargetWanAccelerator()
        Add-VBRViBackupCopyJob -Name $migratedName -BackupJob $linkedJobs -Description $source.Description -SourceAccelerator $sourceWan -TargetAccelerator $targetWan -Repository $targetRepository -EnableImmediateCopy
        $migratedJob = Get-VBRJob -Name $migratedName
        $options = Get-VBRJobOptions -Job $source
        Set-VBRJobOptions -Job $migratedJob -Options $options
    }
    else {
        Add-VBRViBackupCopyJob -Name $migratedName -BackupJob $linkedJobs -DirectOperation -Repository $targetRepository -EnableImmediateCopy
        $migratedJob = Get-VBRJob -Name $migratedName
        $options = Get-VBRJobOptions -Job $source
        Set-VBRJobOptions -Job $migratedJob -Options $options
     
    }
    }
   }
 }
catch {
 throw $_
 }

}  
