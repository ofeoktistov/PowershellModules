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
      Write-Host "Source job $($source.Name) is not a backup copy job with periodic mode" -ForegroundColor Red
      Start-Sleep -Seconds 2
      Continue
    }
    else {
    $migratedName = "$($source.Name)_migrated"
    $exists = Get-VBRJob -Name $migratedName
    if ($exists) {
     Write-Host "Job with the name $($source.Name) has already been migrated" -ForegroundColor Red
     Start-Sleep -Seconds 2
     Continue
    }

    $objects = Get-VBRJobObject -Job $source
    if ($objects) {
      Write-Host "The following includes backep up by $($source.Name) job are of unsupported type and won't be to the target job: " -ForegroundColor Yellow
      Start-Sleep -Seconds 2
      foreach ($object in $objects) {
         Write-Host $object.Name -ForegroundColor Yellow
         Start-Sleep -Seconds 2
      }
    }
    $linkedJobs = @()
    foreach ($linkedJob in $source.LinkedJobIds) {
        $job = Get-VBRJob | where {$_.Id -eq $linkedJob}
        $linkedJobs += $job

    }
    $wanEnabled = $source.IsWanAcceleratorEnabled()
    $description = $source.Description
    $targetRepository = $source.FindTargetRepository()
    if ($wanEnabled -eq $true -and $description -eq "") {
        $sourceWan = $source.FindSourceWanAccelerator()
        $targetWan = $source.FindTargetWanAccelerator()
        Add-VBRViBackupCopyJob -Name $migratedName -BackupJob $linkedJobs -SourceAccelerator $sourceWan -TargetAccelerator $targetWan -Repository $targetRepository -EnableImmediateCopy -ErrorAction Continue | Out-Null
        $migratedJob = Get-VBRJob -Name $migratedName
        $options = Get-VBRJobOptions -Job $source
        Set-VBRJobOptions -Job $migratedJob -Options $options
     }
    
    elseif ($wanEnabled -eq $false -and $description -ne "") {
        Add-VBRViBackupCopyJob -Name $migratedName -BackupJob $linkedJobs -Description $source.Description -DirectOperation -Repository $targetRepository -EnableImmediateCopy -ErrorAction Continue | Out-Null
        $migratedJob = Get-VBRJob -Name $migratedName | Out-Null
        $options = Get-VBRJobOptions -Job $source
        Set-VBRJobOptions -Job $migratedJob -Options $options
    
    }
    elseif ($wanEnabled -eq $true -and $description -ne "") {
        $sourceWan = $source.FindSourceWanAccelerator()
        $targetWan = $source.FindTargetWanAccelerator()
        Add-VBRViBackupCopyJob -Name $migratedName -BackupJob $linkedJobs -Description $source.Description -SourceAccelerator $sourceWan -TargetAccelerator $targetWan -Repository $targetRepository -EnableImmediateCopy -ErrorAction Continue | Out-Null
        $migratedJob = Get-VBRJob -Name $migratedName
        $options = Get-VBRJobOptions -Job $source
        Set-VBRJobOptions -Job $migratedJob -Options $options
    }
    else {
        Add-VBRViBackupCopyJob -Name $migratedName -BackupJob $linkedJobs -DirectOperation -Repository $targetRepository -EnableImmediateCopy -ErrorAction Continue | Out-Null
        $migratedJob = Get-VBRJob -Name $migratedName
        $options = Get-VBRJobOptions -Job $source
        Set-VBRJobOptions -Job $migratedJob -Options $options
     
    }
    }
  }
 }
catch {
 Write-Host $_ -ForegroundColor Red 
 Continue
 }

}  
