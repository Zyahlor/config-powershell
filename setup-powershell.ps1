<#
.SYNOPSIS
    Tu dong cai dat va cau hinh PowerShell chuyen nghiep theo phong cach devaslife (Takuya Matsuyama).
.DESCRIPTION
    Script nay thuc hien:
    1. Thiet lap ExecutionPolicy va TLS 1.2
    2. Kiem tra va cai dat CLI qua Winget (PowerShell 7, Oh My Posh, Git, fzf, Neovim)
    3. Cai dat PackageProvider NuGet & tin cay PSGallery
    4. Cai dat cac PowerShell Modules (posh-git, Terminal-Icons, PSReadLine, PSFzf, z)
    5. Trien khai theme devaslife (takuya.omp.json) & user_profile.ps1
    6. Cau hinh tu dong nap profile cho ca PowerShell 7 va Windows PowerShell 5.1
    7. Tinh chinh Windows Terminal (JetBrainsMono Nerd Font, Acrylic 90%, PowerShell 7 lam mac dinh)
#>

[CmdletBinding()]
param (
    [switch]$Force
)

# Thiet lap ma hoa console sang UTF-8
try {
    [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
} catch {}

$ErrorActionPreference = "Continue"

function Write-Step {
    param ([string]$Msg)
    Write-Host "`n[+] $Msg" -ForegroundColor Cyan
}

function Write-Success {
    param ([string]$Msg)
    Write-Host "    $([char]0x2714) $Msg" -ForegroundColor Green
}

function Write-Info {
    param ([string]$Msg)
    Write-Host "    [i] $Msg" -ForegroundColor Yellow
}

function Write-Err {
    param ([string]$Msg)
    Write-Host "    [x] $Msg" -ForegroundColor Red
}

Write-Host "=================================================================" -ForegroundColor Magenta
Write-Host "   SETUP POWERSHELL THEO PHONG CACH DEVASLIFE (WINDOWS 11)      " -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Magenta

# 1. Cau hinh ExecutionPolicy va TLS
Write-Step "1/7. Cau hinh ExecutionPolicy va TLS 1.2..."
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Success "Da thiet lap ExecutionPolicy (RemoteSigned) va TLS 1.2."
} catch {
    Write-Info "ExecutionPolicy hien tai dang duoc quan ly boi phien lam viec."
}

# 2. Kiem tra & cai dat CLI qua Winget
Write-Step "2/7. Kiem tra cac cong cu CLI (PowerShell 7, Oh My Posh, Git, fzf, Neovim)..."

$wingetApps = @(
    @{ Name = "PowerShell 7";       Id = "Microsoft.PowerShell";           Command = "pwsh" },
    @{ Name = "Oh My Posh";         Id = "JanDeDobbeleer.OhMyPosh";        Command = "oh-my-posh" },
    @{ Name = "Git for Windows";    Id = "Git.Git";                        Command = "git" },
    @{ Name = "fzf (Fuzzy Finder)"; Id = "junegunn.fzf";                   Command = "fzf" },
    @{ Name = "Neovim";             Id = "Neovim.Neovim";                  Command = "nvim" }
)

foreach ($app in $wingetApps) {
    if (Get-Command $app.Command -ErrorAction SilentlyContinue) {
        Write-Success "$($app.Name) da duoc cai dat."
    } else {
        Write-Info "Dang cai dat $($app.Name) qua winget..."
        try {
            winget install --id $app.Id --source winget --accept-package-agreements --accept-source-agreements --silent
            Write-Success "$($app.Name) da cai dat thanh cong."
        } catch {
            Write-Err "Khong the cai dat $($app.Name): $_"
        }
    }
}

# 3. Cai dat PackageProvider & tin cay PSGallery
Write-Step "3/7. Thiet lap PackageProvider NuGet va PSGallery..."
try {
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force -Scope CurrentUser | Out-Null
    }
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    Write-Success "PSGallery va NuGet da san sang."
} catch {
    Write-Err "Loi thiet lap PackageProvider: $_"
}

# 4. Cai dat cac PowerShell Modules
Write-Step "4/7. Cai dat cac PowerShell Module (posh-git, Terminal-Icons, PSReadLine, PSFzf, z)..."
$modules = @("posh-git", "Terminal-Icons", "PSReadLine", "PSFzf", "z")

foreach ($mod in $modules) {
    if (Get-Module -ListAvailable -Name $mod) {
        Write-Success "Module [$mod] da co san."
    } else {
        Write-Info "Dang tai va cai dat module [$mod]..."
        try {
            Install-Module -Name $mod -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck -ErrorAction Stop
            Write-Success "Da cai dat module [$mod]."
        } catch {
            Write-Err "Khong the cai dat module [$mod]: $_"
        }
    }
}

# 5. Trien khai Theme Oh My Posh va user_profile.ps1
Write-Step "5/7. Trien khai theme devaslife va user_profile.ps1..."
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = (Get-Location).Path }

$configDir = Join-Path $HOME ".config\powershell"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

$themeSource = Join-Path $scriptDir "takuya.omp.json"
$themeDest = Join-Path $configDir "takuya.omp.json"

if (Test-Path $themeSource) {
    Copy-Item $themeSource -Destination $themeDest -Force
    Write-Success "Da sao chep takuya.omp.json vao $configDir."
} else {
    Write-Info "Dang tai takuya.omp.json tu GitHub..."
    curl.exe -sL https://raw.githubusercontent.com/craftzdog/dotfiles/master/.config/powershell/takuya.omp.json -o $themeDest
    Write-Success "Da tai theme takuya.omp.json thanh cong."
}

$profileSource = Join-Path $scriptDir "user_profile.ps1"
$profileDest = Join-Path $configDir "user_profile.ps1"

if (Test-Path $profileSource) {
    Copy-Item $profileSource -Destination $profileDest -Force
    Write-Success "Da sao chep user_profile.ps1 vao $configDir."
}

# 6. Cau hinh $PROFILE cho ca PowerShell 7 va Windows PowerShell 5.1
Write-Step "6/7. Cau hinh file $PROFILE tu dong nap profile..."
$profileLoaderContent = @'
# Load devaslife PowerShell configuration
$userProfile = Join-Path $HOME ".config\powershell\user_profile.ps1"
if (Test-Path $userProfile) {
    . $userProfile
}
'@

$profilePaths = @(
    (Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"),
    (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
)

foreach ($p in $profilePaths) {
    $parent = Split-Path $p -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Set-Content -Path $p -Value $profileLoaderContent -Encoding UTF8 -Force
    Write-Success "Da cap nhat profile: $p"
}

# 7. Tinh chinh Windows Terminal (Nerd Font, Acrylic mo, Do trong suot 90%)
Write-Step "7/7. Tinh chinh giao dien Windows Terminal..."
$wtSettingsPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)

$wtConfigured = $false
foreach ($wtPath in $wtSettingsPaths) {
    if (Test-Path $wtPath) {
        try {
            Copy-Item $wtPath "$wtPath.bak" -Force
            $wtJson = Get-Content $wtPath -Raw | ConvertFrom-Json

            # Cau hinh defaults
            if (-not $wtJson.profiles.defaults) {
                $wtJson.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{})
            }
            if (-not $wtJson.profiles.defaults.font) {
                $wtJson.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value ([PSCustomObject]@{})
            }
            $wtJson.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name "face" -Value "JetBrainsMono Nerd Font" -Force
            $wtJson.profiles.defaults | Add-Member -MemberType NoteProperty -Name "opacity" -Value 90 -Force
            $wtJson.profiles.defaults | Add-Member -MemberType NoteProperty -Name "useAcrylic" -Value $true -Force

            # Them profile PowerShell 7 neu chua co
            $pwshGuid = "{574e775e-4f2a-5b96-ac1e-a2962a402336}"
            $existing = $wtJson.profiles.list | Where-Object { $_.guid -eq $pwshGuid -or $_.commandline -like "*pwsh*" }
            if (-not $existing) {
                $pwshProfile = [PSCustomObject]@{
                    commandline = "pwsh.exe -NoLogo"
                    guid = $pwshGuid
                    hidden = $false
                    name = "PowerShell 7"
                }
                $wtJson.profiles.list = @($pwshProfile) + @($wtJson.profiles.list)
            }
            $wtJson.defaultProfile = $pwshGuid

            $wtJson | ConvertTo-Json -Depth 10 | Set-Content $wtPath -Encoding UTF8
            Write-Success "Da kich hoat JetBrainsMono Nerd Font, Acrylic (90%) va PowerShell 7 lam mac dinh trong Windows Terminal!"
            $wtConfigured = $true
            break
        } catch {
            Write-Err "Khong the tinh chinh Windows Terminal: $_"
        }
    }
}

if (-not $wtConfigured) {
    Write-Info "Khong tim thay settings.json cua Windows Terminal hoac da cau hinh truoc do."
}

Write-Host "`n=================================================================" -ForegroundColor Green
Write-Host "   SETUP HOAN TAT! KHOI DONG LAI WINDOWS TERMINAL DE TRAI NGHIEM!" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
Write-Host "Cac phim tat & tinh nang noi bat:" -ForegroundColor Cyan
Write-Host "  * Goi y lenh thong minh (History prediction): Go lenh va nhan [Right Arrow] de dien goi y." -ForegroundColor Gray
Write-Host "  * Tim kiem lich su mo (fzf): Nhan [Ctrl + R]" -ForegroundColor Gray
Write-Host "  * Tim kiem thu muc/file nhanh: Nhan [Ctrl + F]" -ForegroundColor Gray
Write-Host "  * Dieu huong thu muc nhanh: z <ten_thu_muc>" -ForegroundColor Gray
Write-Host "  * Xem file/thu muc co icon mau: ll hoac ls" -ForegroundColor Gray
Write-Host "  * Viet tat git: g status, g commit..." -ForegroundColor Gray
