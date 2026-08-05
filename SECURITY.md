# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| latest (main) | ✅ |
| older releases | ❌ — please update via `Update.bat` |

## Reporting a Vulnerability

**Please do not open a public issue for security problems.**

Use GitHub's private *Security Advisories* feature on this repository
(**Security → Advisories → Report a vulnerability**) and we will respond as
quickly as possible.

## Notes for users

- Dashboard credentials are generated locally and stored only on YOUR machine
  in `dashboard-password.txt` (git-ignored). Never commit that file.
- The dashboard is exposed on your LAN only. Do **not** forward ports 53/80 to
  the internet — open DNS resolvers get abused for DDoS amplification.
- The wizard enables AdGuard Home's built-in malware/phishing protection and
  encrypted upstream DNS by default.
