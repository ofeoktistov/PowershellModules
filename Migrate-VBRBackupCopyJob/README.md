# Migrate Backup Copy jobs from periodic to immediate mode

## Import
To import this cmdlet, `cd` to the directory where `Migrate-VBRBackupCopyJob.ps1` is kept and execute the following: \
\
`Import-Module .\Migrate-VBRBackupCopyJob.ps1`

## Parameters
`-SourceJob` - accepts backup copy job object array. *REQUIRED* \
`-ApplyToAll` - migrates all backup copy jobs to immediate mode. *REQUIRED* \

\

## Usage

To migrate specific backup copy jobs: \
```
$jobs = Get-VBRJob -Name 'Backup Copy Job *'
Migrate-VBRBackupCopyJob -SourceJob $jobs
```

To migrate all backup copy jobs: \
`Migrate-VBRBackupCopyJob -ApplyToAll`\
