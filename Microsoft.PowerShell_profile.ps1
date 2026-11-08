#configs
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 100000
Set-PSReadLineOption -BellStyle None


#keybinds
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key PageUp -Function BeginningOfHistory
Set-PSReadLineKeyHandler -Key PageDown -Function EndOfHistory
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete


# ctrl d to close
Set-PSReadLineKeyHandler -Key Ctrl+d -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("exit")
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}


#window title
function Get-ShortPath {
  $PWD.ProviderPath -replace "^$([regex]::Escape($HOME))", "~"
}

Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
  $commandLine = $null
  $cursorPosition = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$commandLine, [ref]$cursorPosition)
  
  if ($commandLine.Trim()) {
    $firstLine = ($commandLine -split "`n")[0]
    $Host.UI.RawUI.WindowTitle = "$(Get-ShortPath) - $firstLine"
  }
  
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}


#reopen on previous pwd
$lastDirFile = Join-Path $HOME ".last_pwd"
if ($PWD.ProviderPath -eq $HOME -and (Test-Path $lastDirFile)) {
  $lastDir = Get-Content $lastDirFile -Raw
  if (Test-Path $lastDir) { Set-Location $lastDir }
}

#prompt
$hostName = [System.Net.Dns]::GetHostName()
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$promptChar = if ($isAdmin) { "#" } else { "%" }
$resetTerminal = "`e[0m"

function Format-Color([string]$text, [string]$hexColor) {
  $rgb = [Convert]::ToInt32($hexColor.TrimStart("#"), 16)
  "$($PSStyle.Foreground.FromRgb($rgb))$text$($PSStyle.Reset)"
}

#set actual prompt
function prompt {
  $exitCode = if ($?) { 0 } elseif ($LASTEXITCODE) { $LASTEXITCODE } else { 1 }

  $currentDir = $PWD.ProviderPath
  if ($PWD.Provider.Name -eq "FileSystem" -and $currentDir -ne $script:savedDir) {
    $script:savedDir = $currentDir
    Set-Content $lastDirFile $currentDir -NoNewline
  }

  $shortPath = Get-ShortPath
  $Host.UI.RawUI.WindowTitle = $shortPath

  #exit code
  $rightColumn = $Host.UI.RawUI.WindowSize.Width - "$exitCode".Length - 1
  Write-Host -NoNewline "$resetTerminal`e7`e[${rightColumn}G[$(Format-Color $exitCode "#C19C00")]`e8"

  "$(Format-Color $env:USERNAME "#FFA500")@$(Format-Color $hostName "#145a82") $($PSStyle.Bold)$(Format-Color $shortPath "#008662") $promptChar "
}


#autocd
$ExecutionContext.InvokeCommand.CommandNotFoundAction = {
  param($commandName, $eventArgs)
  if (Test-Path -LiteralPath $commandName -PathType Container) {
    $eventArgs.CommandScriptBlock = { Set-Location -LiteralPath $commandName }.GetNewClosure()
    $eventArgs.StopSearch = $true
  }
}


#aliases
$gitLs = "C:\Program Files\Git\usr\bin\ls.exe"
if (Test-Path Alias:ls) { Remove-Item Alias:ls -Force }
function ls { & $gitLs --color=auto @args }
function l { ls -lh @args }
function lsa { ls -lha @args }
function st { & "C:\Program Files\Sublime Text\sublime_text.exe" @args }


#zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

$wsl = "\\wsl.localhost\Ubuntu\home\$Env:UserName"
