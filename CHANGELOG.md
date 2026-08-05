# Changelog

All notable changes to this project will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-08-06

### Added
- 🧙 Interactive PowerShell **setup wizard** (`Install.bat` → `wizard.ps1`)
  - dashboard port, encrypted DNS provider, blocklist strength, password
  - automatic Docker Desktop detection & install via winget
  - automatic port-80 → 8080 fallback and port-53 conflict diagnosis
- Pre-seeded **AdGuard Home** config: AdGuard DNS filter, OISD Big,
  StevenBlack lists; encrypted DoH upstreams (Quad9 + Cloudflare);
  DNSSEC, optimistic cache, phishing/malware protection.
- Blocklist packs: **Balanced / Strict (+HaGeZi Pro++, 1Hosts Lite) / Minimal**,
  plus optional **AdGuard Family** filtering.
- One-click **Update.bat** and **Uninstall.bat**; idempotent re-installs that
  keep settings and stats.
- 🗓️ Optional **weekly automatic updates** via Windows Scheduled Task (wizard prompt).
- `.gitattributes` enforcing **CRLF line endings** for `.bat`/`.ps1` — cmd.exe-safe
  installs straight from GitHub ZIP downloads.
- Wizard syntax-verified with real PowerShell (`Parser::ParseFile`) and the
  config-generation engine unit-tested against the shipped template.
- `docs/ROUTERS.md` — whole-house rollout guide with UK ISP (Sky/BT/Virgin)
  workarounds and AdGuard Home DHCP takeover.
- Community health files: LICENSE (MIT), CONTRIBUTING, CODE_OF_CONDUCT,
  SECURITY, issue & PR templates.
- CI workflow: PSScriptAnalyzer + yamllint validation.
