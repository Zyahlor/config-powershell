# =====================================================================
# PowerShell Configuration inspired by devaslife (Takuya Matsuyama)
# =====================================================================

# 1. Console Encoding
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# 2. posh-git (Git prompt & auto-completion)
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

# 3. Oh My Posh (Prompt theme engine)
$omp_config = Join-Path $HOME ".config\powershell\takuya.omp.json"
if (-not (Test-Path $omp_config)) {
    $omp_config = "e:\setup\takuya.omp.json"
}
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path $omp_config) {
        oh-my-posh init pwsh --config $omp_config | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# 4. Terminal-Icons (Color icons for ls / dir)
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# 5. PSReadLine (Fish-like autosuggestion & history prediction)
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    try {
        Set-PSReadLineOption -EditMode Emacs -ErrorAction Stop
        Set-PSReadLineOption -BellStyle None -ErrorAction Stop
        Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar -ErrorAction Stop
        Set-PSReadLineOption -PredictionSource History -ErrorAction Stop
        Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction Stop
        Set-PSReadLineOption -Colors @{
            InlinePrediction = "$([char]0x1b)[38;5;242m"
        } -ErrorAction Stop
    } catch {}
}

# 6. PSFzf (Fuzzy Finder with Ctrl+F / Ctrl+R)
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    try {
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r' -ErrorAction Stop
    } catch {}
}

# 7. z (Directory Jumper)
if (Get-Module -ListAvailable -Name z) {
    Import-Module z
}

# 8. Environment & SSH
if (Test-Path "C:\Windows\system32\OpenSSH\ssh.exe") {
    $env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
}

# 9. Aliases (devaslife dotfiles)
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vim -Value nvim -ErrorAction SilentlyContinue
    Set-Alias -Name vi -Value nvim -ErrorAction SilentlyContinue
}
Set-Alias -Name ll -Value Get-ChildItem -ErrorAction SilentlyContinue
Set-Alias -Name g -Value git -ErrorAction SilentlyContinue
Set-Alias -Name grep -Value findstr -ErrorAction SilentlyContinue

# 10. Helper Utilities
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# 11. Custom Tab Completion (Khong tu dong chen .\ vao truoc ten file khi Tab hoan thanh doi so)
function TabExpansion2 {
    [CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
    param (
        [Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 0)]
        [string] $InputScript,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 1)]
        [int] $CursorColumn = $InputScript.Length,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
        [hashtable] $Options = $null
    )

    $completion = [System.Management.Automation.CommandCompletion]::CompleteInput($InputScript, $CursorColumn, $Options)

    if ($completion -and $completion.CompletionMatches) {
        $prefixBeforeReplacement = $InputScript.Substring(0, [Math]::Min($completion.ReplacementIndex, $InputScript.Length))
        $isFirstToken = [string]::IsNullOrWhiteSpace($prefixBeforeReplacement) -or ($prefixBeforeReplacement -match '[|;&]\s*$')

        $typedLength = $completion.ReplacementLength
        $typedWord = if ($typedLength -gt 0 -and ($completion.ReplacementIndex + $typedLength) -le $InputScript.Length) {
            $InputScript.Substring($completion.ReplacementIndex, $typedLength)
        } else {
            ''
        }
        $userTypedDotSlash = ($typedWord -match '^\.\\|^\./|^''(\.\\|\./)|^"(\.\\|\./)')

        $cleanedMatches = [System.Collections.Generic.List[System.Management.Automation.CompletionResult]]::new()
        foreach ($match in $completion.CompletionMatches) {
            $text = $match.CompletionText

            # Neu la tham so (khong phai lenh o dau dong) va nguoi dung khong chu dong go .\ hoac ./
            if (-not $isFirstToken -and -not $userTypedDotSlash) {
                if ($text -like "'.\*" -or $text -like "'./*") {
                    $text = "'" + $text.Substring(3)
                } elseif ($text -like "`".\*" -or $text -like "`"./*") {
                    $text = '"' + $text.Substring(3)
                } elseif ($text -like ".\*" -or $text -like "./*") {
                    $text = $text.Substring(2)
                }
                $cleanedMatches.Add([System.Management.Automation.CompletionResult]::new(
                    $text,
                    $match.ListItemText,
                    $match.ResultType,
                    $match.ToolTip
                ))
            } else {
                $cleanedMatches.Add($match)
            }
        }

        return [System.Management.Automation.CommandCompletion]::new(
            $cleanedMatches,
            $completion.CurrentMatchIndex,
            $completion.ReplacementIndex,
            $completion.ReplacementLength
        )
    }

    return $completion
}

