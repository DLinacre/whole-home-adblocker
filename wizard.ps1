<#
.SYNOPSIS
    Whole-Home Ad Blocker - interactive setup wizard for Windows.
.DESCRIPTION
    Installs AdGuard Home (in Docker) so every device on your network gets
    ad/tracker blocking with a live dashboard. Walks you through port,
    encrypted DNS providers, blocklist packs and your dashboard login.
    Run with -Update to pull the latest version without the questions.
.NOTES
    ASCII only: Windows PowerShell 5.1 misreads non-ASCII chars without a BOM.
#>
[CmdletBinding()]
param(
    [switch]$Update
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Root      = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfDir   = Join-Path $Root 'adguard\conf'
$WorkDir   = Join-Path $Root 'adguard\work'
$Template  = Join-Path $Root 'AdGuardHome.template.yaml'
$CredsFile = Join-Path $Root 'dashboard-password.txt'
$ConfigYml = Join-Path $ConfDir 'AdGuardHome.yaml'

# ---------------------------------------------------------------- UI helpers
function Write-Header([string]$Title) {
    Clear-Host
    Write-Host ''
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    Write-Host '          WHOLE-HOME AD BLOCKER  |  SETUP WIZARD' -ForegroundColor Cyan
    Write-Host '  ==========================================================' -ForegroundColor Cyan
    if ($Title) { Write-Host ''; Write-Host "  -- $Title " -ForegroundColor Yellow }
    Write-Host ''
}
function Write-Ok([string]$m)    { Write-Host "  [ OK ] $m" -ForegroundColor Green }
function Write-Info([string]$m)  { Write-Host "  [ .. ] $m" -ForegroundColor DarkCyan }
function Write-Warn([string]$m)  { Write-Host "  [ !! ] $m" -ForegroundColor Yellow }
function Write-Fail([string]$m)  { Write-Host "  [FAIL] $m" -ForegroundColor Red }
function Wait-Enter { [void](Read-Host '  Press Enter to continue') }

# ------------------------------------------------------------ Docker helpers
function Test-DockerInstalled { cmd /c 'docker --version >nul 2>&1'; return ($LASTEXITCODE -eq 0) }
function Test-DockerRunning   { cmd /c 'docker info >nul 2>&1';      return ($LASTEXITCODE -eq 0) }

function Install-Docker {
    Write-Info 'Docker Desktop not found - installing it for you (this can take a few minutes)...'
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Fail 'Could not find winget to auto-install Docker.'
        Write-Host '  Install Docker Desktop manually (free): https://www.docker.com/products/docker-desktop/'
        Write-Host '  Then restart this PC and run Install.bat again.'
        exit 1
    }
    winget install -e --id Docker.DockerDesktop --accept-source-agreements --accept-package-agreements
    Write-Ok 'Docker installed.'
    Write-Warn 'Please RESTART this PC, open "Docker Desktop" once so it finishes'
    Write-Warn 'setting up, then run Install.bat again.'
    exit 0
}

function Start-DockerIfNeeded {
    if (Test-DockerRunning) { return }
    Write-Info 'Starting Docker Desktop (first start can take a minute)...'
    $exe = 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
    if (Test-Path $exe) { Start-Process $exe }
    $t = 0
    while (-not (Test-DockerRunning)) {
        Start-Sleep -Seconds 5; $t += 5
        Write-Host "     waiting for Docker... ${t}s" -ForegroundColor DarkGray
        if ($t -ge 300) { Write-Fail 'Docker did not start within 5 minutes.'; exit 1 }
    }
}

# ----------------------------------------------------------------- utilities
function New-Password([int]$Len = 14) {
    $chars = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'.ToCharArray()
    return -join ($chars | Get-Random -Count $Len)
}

function Get-Bcrypt([string]$User, [string]$Pass) {
    $line = cmd /c "docker run --rm httpd:2.4-alpine htpasswd -nbB $User $Pass 2>nul"
    return ($line -split ':', 2)[1].Trim()
}

function Get-LanIp {
    try {
        $idx = (Get-NetRoute -DestinationPrefix '0.0.0.0/0' |
                Sort-Object RouteMetric | Select-Object -First 1).ifIndex
        return (Get-NetIPAddress -InterfaceIndex $idx -AddressFamily IPv4 |
                Select-Object -First 1).IPAddress
    } catch { return 'YOUR-PC-IP' }
}

function New-DesktopShortcut([string]$Url) {
    try {
        $ws = New-Object -ComObject WScript.Shell
        $ln = $ws.CreateShortcut("$env:USERPROFILE\Desktop\Ad Blocker Dashboard.lnk")
        $ln.TargetPath = $Url
        $ln.Save()
    } catch { }  # cosmetic extra - never fatal
}

# ------------------------------------------------------------ config builder
function Set-YamlSection([string]$Yaml, [string]$Name, [string[]]$Entries) {
    $body = ($Entries | ForEach-Object { "    - $_" }) -join "`r`n"
    $pattern = "(?s)(?<=# __${Name}_START__\r?\n).*?(?=\r?\n\s{2}# __${Name}_END__)"
    $evaluator = [System.Text.RegularExpressions.MatchEvaluator] { param($m) $body }
    return [regex]::Replace($Yaml, $pattern, $evaluator)
}

function Get-FilterYaml([array]$Packs) {
    $id = 1741350000
    $lines = foreach ($f in $Packs) {
        $id++
        '  - enabled: true'
        "    url: $($f.Url)"
        "    name: $($f.Name)"
        "    id: $id"
    }
    return ($lines -join "`r`n")
}

$FilterPacks = @{
    '1' = @(
        @{ Name = 'AdGuard DNS filter';         Url = 'https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt' },
        @{ Name = 'OISD Big';                   Url = 'https://big.oisd.nl/' },
        @{ Name = 'StevenBlack Unified Hosts';  Url = 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts' }
    )
    '2' = @(
        @{ Name = 'AdGuard DNS filter';         Url = 'https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt' },
        @{ Name = 'OISD Big';                   Url = 'https://big.oisd.nl/' },
        @{ Name = 'StevenBlack Unified Hosts';  Url = 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts' },
        @{ Name = 'HaGeZi Pro++';               Url = 'https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.plus.txt' },
        @{ Name = '1Hosts Lite';                Url = 'https://cdn.jsdelivr.net/gh/badmojr/1Hosts@latest/Lite/adblock.txt' }
    )
    '3' = @(
        @{ Name = 'AdGuard DNS filter';         Url = 'https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt' }
    )
}

# =============================================================== WIZARD FLOW
$DashboardPort = 80
$Upstreams     = @('https://dns10.quad9.net/dns-query', 'https://cloudflare-dns.com/dns-query')
$Bootstraps    = @('9.9.9.10', '149.112.112.10')
$PackChoice    = '1'
$PlainPassword = ''
$Regenerate    = $true

if (-not $Update) {
    Write-Header 'Welcome'
    Write-Host '  This wizard turns THIS PC into an ad blocker for your whole home.' -ForegroundColor White
    Write-Host ''
    Write-Host '  It will:'
    Write-Host '    1. Check for Docker Desktop (install it if needed)'
    Write-Host '    2. Ask you 3 quick questions'
    Write-Host '    3. Install AdGuard Home with blocklists preloaded'
    Write-Host '    4. Hand you a live dashboard where you can watch ads die in real time'
    Write-Host ''
    Write-Host '  The PC must stay switched on for blocking to work.'
    Write-Host ''
    Wait-Enter

    # ---- Question 1: dashboard port
    Write-Header 'Question 1 of 3 - Dashboard port'
    Write-Host '  The dashboard (your HUD) is a website served by this PC.'
    Write-Host '  Port 80 means you just type  http://localhost  - keep it unless something'
    Write-Host '  else on this PC already runs a website.'
    Write-Host ''
    $p = Read-Host '  Dashboard port [80]'
    if ($p -and [int]::TryParse($p, [ref]($n = 0)) -and $n -ge 1 -and $n -le 65535) { $DashboardPort = $n }

    # ---- Question 2: DNS provider
    Write-Header 'Question 2 of 3 - Private DNS provider'
    Write-Host '  After ads are blocked, remaining lookups go to an encrypted "upstream"'
    Write-Host '  provider so your internet provider cannot snoop on them.'
    Write-Host ''
    Write-Host '    [1] Quad9 + Cloudflare  (recommended - private, fast)' -ForegroundColor Green
    Write-Host '    [2] Google              (very fast, less private)'
    Write-Host '    [3] AdGuard Family      (also blocks adult content on every device)'
    Write-Host ''
    $d = Read-Host '  Choose [1]'
    switch ($d) {
        '2' { $Upstreams = @('tls://8.8.8.8', 'tls://8.8.4.4'); $Bootstraps = @('8.8.8.8', '8.8.4.4') }
        '3' { $Upstreams = @('https://family.adguard-dns.com/dns-query'); $Bootstraps = @('9.9.9.10') }
    }

    # ---- Question 3: blocklist strength
    Write-Header 'Question 3 of 3 - Blocking strength'
    Write-Host '    [1] Balanced  (recommended - strong blocking, rare breakage)' -ForegroundColor Green
    Write-Host '    [2] Strict    (more blocking, may occasionally break a site)'
    Write-Host '    [3] Minimal   (light touch)'
    Write-Host ''
    $b = Read-Host '  Choose [1]'
    if ($FilterPacks.ContainsKey($b)) { $PackChoice = $b }

    # ---- Password
    Write-Header 'Dashboard login'
    $PlainPassword = Read-Host '  Type your own dashboard password, or press Enter to auto-generate a strong one'
    if ([string]::IsNullOrWhiteSpace($PlainPassword)) {
        $PlainPassword = New-Password
        Write-Ok "Generated password: $PlainPassword  (it will also be saved to dashboard-password.txt)"
    }
    Write-Host ''
    Write-Info 'Ready to install. Settings: port ' + $DashboardPort + ', ' + $FilterPacks[$PackChoice].Count + ' blocklists.'
    Wait-Enter
}

# ------------------------------------------------------------ existing setup
if (Test-Path $ConfigYml) {
    if ($Update) {
        $Regenerate = $false
    } else {
        Write-Header 'Existing installation found'
        $k = Read-Host '  Keep your current settings and password? [Y/n]'
        if ($k -notmatch '^[Nn]') { $Regenerate = $false; Write-Ok 'Keeping your settings.' }
        else { Write-Warn 'Settings will be regenerated (previous stats stay on disk).' }
        Wait-Enter
    }
}

# ------------------------------------------------------------------ install
Write-Header 'Installing'
Write-Info 'Step 1/5 - checking Docker Desktop...'
if (-not (Test-DockerInstalled)) { Install-Docker }
Start-DockerIfNeeded
Write-Ok 'Docker is running.'

Write-Info 'Step 2/5 - preparing folders...'
New-Item -ItemType Directory -Force -Path $ConfDir | Out-Null
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

if ($Regenerate) {
    Write-Info 'Step 3/5 - writing configuration (blocklists preloaded)...'
    if (-not $Update -and -not $PlainPassword) { $PlainPassword = New-Password }
    $hash = Get-Bcrypt -User 'admin' -Pass $PlainPassword
    $yaml = Get-Content $Template -Raw
    $yaml = $yaml.Replace('__USER__', 'admin').Replace('__HASH__', $hash)
    $yaml = $yaml.Replace('__FILTERS__', (Get-FilterYaml $FilterPacks[$PackChoice]))
    $yaml = Set-YamlSection -Yaml $yaml -Name 'UPSTREAMS' -Entries $Upstreams
    $yaml = Set-YamlSection -Yaml $yaml -Name 'BOOTSTRAP' -Entries $Bootstraps
    [System.IO.File]::WriteAllText($ConfigYml, $yaml)
    Write-Ok 'Configuration written.'
} else {
    Write-Info 'Step 3/5 - existing configuration kept.'
}

Write-Info 'Step 4/5 - downloading the latest AdGuard Home...'
docker pull adguard/adguardhome:latest | Out-Null

Write-Info 'Step 5/5 - starting the ad blocker...'
docker rm -f adguardhome 2>$null | Out-Null
$ports = @('-p', '53:53/tcp', '-p', '53:53/udp', '-p', "${DashboardPort}:80/tcp")
$volumes = @('-v', "${ConfDir}:/opt/adguardhome/conf", '-v', "${WorkDir}:/opt/adguardhome/work")
docker run -d --name adguardhome --restart unless-stopped @ports @volumes adguard/adguardhome:latest 2>$null | Out-Null
$running = cmd /c 'docker ps --format "{{.Names}}" 2>nul | findstr /x adguardhome >nul 2>&1 && echo yes'
if ($LASTEXITCODE -ne 0 -and $DashboardPort -ne 8080) {
    Write-Warn "Port $DashboardPort was busy - trying 8080 for the dashboard..."
    $DashboardPort = 8080
    $ports = @('-p', '53:53/tcp', '-p', '53:53/udp', '-p', "8080:80/tcp")
    docker run -d --name adguardhome --restart unless-stopped @ports @volumes adguard/adguardhome:latest 2>$null | Out-Null
    $running = cmd /c 'docker ps --format "{{.Names}}" 2>nul | findstr /x adguardhome >nul 2>&1 && echo yes'
}
if ($LASTEXITCODE -ne 0 -or $running -ne 'yes') {
    Write-Fail 'The ad blocker could not start.'
    Write-Host '  Port 53 is probably in use. Most common cause on Windows:'
    Write-Host '  the "Internet Connection Sharing" service.'
    Write-Host '  Fix: Win+R -> services.msc -> Internet Connection Sharing -> Stop,'
    Write-Host '  set Startup type to Disabled, then run Install.bat again.'
    exit 1
}
Write-Ok 'Ad blocker is live.'

# -------------------------------------------------------------------- finish
$portSuffix = if ($DashboardPort -eq 80) { '' } else { ":$DashboardPort" }
$lanIp      = Get-LanIp
$localUrl   = "http://localhost$portSuffix"
$lanUrl     = "http://$lanIp$portSuffix"

if ($Regenerate -and $PlainPassword) {
    @"
AdGuard Home - your dashboard login
=====================================

Dashboard on this PC:         $localUrl
Dashboard from other devices: $lanUrl

Username: admin
Password: $PlainPassword

Keep this file somewhere safe. You can change the password
in the dashboard under Settings -> General settings.
"@ | Set-Content -NoNewline $CredsFile
}
$savedPass = ''
if (Test-Path $CredsFile) {
    $m = Select-String -Path $CredsFile -Pattern '^Password:\s*(.+)$'
    if ($m) { $savedPass = $m.Matches[0].Groups[1].Value.Trim() }
}

New-DesktopShortcut $localUrl

Write-Header 'DONE - your whole-home ad blocker is live'
Write-Host "   Dashboard (HUD):    $localUrl" -ForegroundColor Green
Write-Host "   From other devices: $lanUrl"
Write-Host "   Username:           admin"
if ($savedPass) { Write-Host "   Password:           $savedPass  (also in dashboard-password.txt)" }
Write-Host ''
Write-Host "   This PC's network address:  $lanIp" -ForegroundColor Yellow
Write-Host '   >> Final step: point your router at this address so every device'
Write-Host '      is protected. Open docs\ROUTERS.md - it takes 2 minutes, with'
Write-Host '      a special workaround for Sky, BT and Virgin Media routers.'
Write-Host '  ==========================================================' -ForegroundColor Cyan
Write-Host ''
Start-Process $localUrl
if (-not $Update) { Wait-Enter }
