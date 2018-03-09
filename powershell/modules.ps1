$ModulesDir = Join-Path $PSScriptRoot "Modules"

$local_modules = @(
"ApplicationCompatibility"
)

$modules = @(
# "PowerShellGet"
# "AWSPowerShell" -- SLOW
# "CredentialManager"
# "dbatools" -- SLOW
# "OData"
# "OpenSSHUtils"
"Posh-Docker"
"Posh-Git"
# "Posh-SSH" - SLOW
"powershell-yaml"
"PSReadline"
)

foreach ($module in $local_modules) {
  Import-Module (Join-Path $ModulesDir $module)
}

foreach ($module in $modules) {
  if (Get-Module -ListAvailable -Name $module ) {
#    Write-Host "Module $module already exist"
#    Get-Date -Format HH:mm:ss.fff
    Import-Module -Name $module
  } else {
    PowerShellGet\Install-Module $module
    Write-Host "Module $module succesfully installed"
    Import-Module -Name $module
  }
}