
# Output type to be chosen for data layout.
enum EOutputType {
    
            CSV
            JSON
       
        }

# Custom class that implements and holds requested properties.
class UserProcess {
      
        [Int]$Id
        [String]$Name
        [String]$ProcessOwner
        [Double]$CPUTimeSec
        [Double]$MemoryUsageMb
        
        
        UserProcess([Int]$Id, [String]$Name, [String]$ProcessOwner, [Double]$CPUTimeSec, [Double]$MemoryUsageMb) {

          $this.Id = $Id
          $this.Name = $Name
          $this.ProcessOwner = $ProcessOwner
          $this.CPUTimeSec = $CPUTimeSec
          $this.MemoryUsageMb = $MemoryUsageMb

        }
      
      
}

# Custom cmdlet code to query the required data.
function Get-UserProcesses {

    
    
    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true)]
        [EOutputType]$OutputType,
        [Parameter(Mandatory=$false)]
        [String]$OutputPath = "C:\Reports"
    )

    begin {

    # Checking if optional parameters were passed.

        if ($OutputPath -eq "C:\Reports") {

            Write-Host "No destination folder selected..." -BackgroundColor Black -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            Write-Host "Choosing default destination folder: $OutputPath" -BackgroundColor Black -ForegroundColor Yellow
            Start-Sleep -Seconds 1

        }

        Start-Sleep -Seconds 1

        Write-Host "Checking if destination folder exists..." -BackgroundColor Black -ForegroundColor Yellow

        Start-Sleep -Seconds 1

        # Checking if the selected output path exists in the destination folder. Creating if it does not.

        If (-not (Test-Path $OutputPath)) {
                Write-Host "Destination folder: $OutputPath does not exist. Creating..." -BackgroundColor Black -ForegroundColor Yellow
                New-Item -Path $OutputPath -ItemType Directory -Force
        }

        Write-Host "Destination folder: $OutputPath exists. Proceeding with report generation..." -BackgroundColor Black -ForegroundColor Yellow

        Start-Sleep -Seconds 1

    }
        #$coresCount = (Get-CimInstance -ClassName Win32_ComputerSystem).NumberOfLogicalProcessors
    

    process {

    # Get actual info on running processes.
    
      $processes = Get-CimInstance -ClassName Win32_Process

      $processesTotal = @()

      $i = 0

      foreach ($process in $processes) {

        # Interpreting processes properties, collecting the required data and generating the report.

            Write-Progress -Activity "Generating system processes usage report..." -Status "Processed: $($i) of $($processes.Count) processes" -PercentComplete ($i / $processes.Count * 100)

            $cpuTimeSec = [Math]::Round(($process.KernelModeTime + $process.UserModeTime) / 10000000, 2)

            
            $memoryUsageMb = [Math]::Round($process.WorkingSetSize / 1MB, 2)

            $ownerInfo = ($process | Invoke-CimMethod -MethodName GetOwner -ErrorAction SilentlyContinue).User

            $userProcess = [UserProcess]::new($process.ProcessId, $process.Name, $ownerInfo, $cpuTimeSec, $memoryUsageMb)
            
            $processesTotal += $userProcess

            $i += 1
      
      }

      # Defining output file extension based on the specified output type.
      
      switch ($OutputType) {

            "JSON" {
            
                $processesTotal | ConvertTo-Json | Out-File -FilePath "$OutputPath\processesReport.json"

            }

            "CSV" {
            
                $processesTotal | Export-Csv -Path "$OutputPath\processesReport.csv"


            }

      }

    }

}
