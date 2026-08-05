# Contributing

Thanks for helping make home ad-blocking easier for everyone! 🎉

## Ways to help

- 🐛 **Report bugs** — use the *Bug report* issue template.
- 💡 **Suggest features** — use the *Feature request* template.
- 📖 **Improve docs** — router screenshots and ISP-specific notes are gold.
- 🔧 **Code** — keep it simple; this project's whole point is beginner-friendliness.

## Pull requests

1. Fork the repo and create a branch: `git checkout -b my-change`.
2. Keep `wizard.ps1` **ASCII-only** (Windows PowerShell 5.1 misreads BOM-less
   UTF-8 with special characters).
3. Run CI locally if you can:
   - `Invoke-ScriptAnalyzer wizard.ps1`
   - `yamllint -c .yamllint.yml AdGuardHome.template.yaml docker-compose.yml`
4. Open the PR with a clear description of *what* and *why*.

## Principles

- **Defaults must work for non-technical users.** Every smart option stays optional.
- **Idempotent installs.** Re-running the installer must never destroy user data.
- **No secrets in the repo.** Generated passwords live only on the user's PC.
