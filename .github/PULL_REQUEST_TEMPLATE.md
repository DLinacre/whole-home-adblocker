## What does this PR do?


## Why is it needed?


## Checklist
- [ ] `wizard.ps1` stays **ASCII-only** (PowerShell 5.1 compatibility)
- [ ] Installer stays **idempotent** — re-running never wipes user data
- [ ] Ran `Invoke-ScriptAnalyzer wizard.ps1` with no errors
- [ ] Ran `yamllint -c .yamllint.yml AdGuardHome.template.yaml docker-compose.yml`
- [ ] Updated README / docs if behaviour changed
