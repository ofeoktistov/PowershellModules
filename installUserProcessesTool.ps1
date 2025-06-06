
# Variables to be used script-wide

$moduleName = "UserProcessesTool"
$functionName = "Get-UserProcesses"
$sourceLocation = Get-Location
$moduleRootPath = "C:\Program Files\WindowsPowershell\Modules\$moduleName"
$psd1Path = "$moduleRootPath\$moduleName.psd1"

# Testing if the root module directory exists. Creating it if it does not.

if (-not (Test-Path $moduleRootPath)) {

    New-Item -Path $moduleRootPath -ItemType Directory -Force
}

# Copying the tool module and installing it to the root Windows powershell module path.

Copy-Item -Path "$sourceLocation\UserProcessesTool.psm1" -Destination $moduleRootPath

New-ModuleManifest -Path $psd1Path -RootModule "$moduleName.psm1" -FunctionsToExport @($functionName) `
-CmdletsToExport @() -VariablesToExport @() -AliasesToExport @() -ModuleVersion "1.0.0" `
-Description "User Processes Tool"


# Importing module into the PS session.

Import-Module UserProcessesTool -Force 

if ((Test-Path $moduleRootPath) -and (Get-Module -Name "UserProcessesTool")) {
Write-Host "Module: $($moduleName) was successfully installed system-wide. You can now launch its cmdlets from any directory" -BackgroundColor Black -ForegroundColor Green
}


Start-Sleep -Seconds 50