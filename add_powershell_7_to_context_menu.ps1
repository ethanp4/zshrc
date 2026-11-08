$menuKeys = @(
  "HKCU:\Software\Classes\Directory\Background\shell\pwsh"
  "HKCU:\Software\Classes\Directory\shell\pwsh"
)

if (Test-Path $menuKeys[0]) {
  Remove-Item $menuKeys -Recurse -ErrorAction Ignore
  "Removed Open in PowerShell 7"
} else {
  foreach ($keyPath in $menuKeys) {
    New-Item -Path "$keyPath\command" -Force | Out-Null
    Set-ItemProperty -Path $keyPath -Name "(default)" -Value "Open in PowerShell 7"
    Set-ItemProperty -Path $keyPath -Name "Icon" -Value (Join-Path (Split-Path $PROFILE) "pwsh.ico")
    Set-ItemProperty -Path "$keyPath\command" -Name "(default)" -Value 'wt.exe -d "%V."'
  }
  "Added Open in PowerShell 7"
}
