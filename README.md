<p align="center">
  <img src="assets/banner.png" alt="Whole-Home Ad Blocker" width="100%" />
</p>

<h1 align="center">🛡️ Whole-Home Ad Blocker</h1>

<p align="center">
  <b>One double-click turns any always-on Windows PC into an ad blocker for your entire house.</b><br/>
  Phones, TVs, consoles, laptops — every device, no apps to install anywhere.
</p>

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
  <img alt="Platform" src="https://img.shields.io/badge/platform-Windows%2010%20%2F%2011-blue">
  <img alt="Docker" src="https://img.shields.io/badge/powered%20by-Docker%20%2B%20AdGuard%20Home-2496ED">
  <img alt="Interface" src="https://img.shields.io/badge/setup-friendly%20wizard-brightgreen">
  <img alt="PRs Welcome" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg">
</p>

---

## ✨ Why this exists

Network-wide ad blocking (like Pi-hole or AdGuard Home) is amazing — but the setup
usually involves cryptic config files and DNS knowledge. This project wraps
**AdGuard Home in Docker** with a **friendly PowerShell setup wizard** so anyone
can do it in about 10 minutes:

- 🧙 **Interactive setup wizard** — plain-English questions, sane defaults, no YAML
- 🖥️ **Live dashboard (HUD)** — watch ads get blocked in real time, with graphs,
  a live query log, top-blocked lists and one-click block/unblock
- 🚫 **Blocklists preloaded** — AdGuard DNS filter, OISD Big and StevenBlack out
  of the box (auto-updating daily), with Strict/Minimal packs one choice away
- 🔒 **Encrypted DNS built in** — Quad9 + Cloudflare over DNS-over-HTTPS, so your
  ISP can't snoop on lookups; optional **Family mode** (adult-content blocking)
- 🔁 **One-click update & uninstall** — and re-running the installer never wipes
  your settings or statistics
- 🇬🇧 **UK-router friendly docs** — includes the workaround for Sky, BT and
  Virgin Media hubs that block custom DNS ([docs/ROUTERS.md](docs/ROUTERS.md))

## 🚀 Quick start

> You need an always-on **Windows 10/11** PC connected to your home network.

```text
1. Download this repo  (Code → Download ZIP, or  git clone ...)
2. Double-click        Install.bat
3. Answer 3 questions in the wizard, then write down the network address it shows
4. Point your router's DNS at that address  (2 minutes — see docs/ROUTERS.md)
```

That's it. The dashboard opens automatically; log in with `admin` and the
password from `dashboard-password.txt`.

Prefer zero interaction? `Install.bat` is idempotent — re-run it any time to
update. Power users can use `docker compose up -d` instead.

## 🧙 What the wizard asks

| Question | Options | Default |
|---|---|---|
| Dashboard port | any free port | `80` |
| Encrypted DNS provider | Quad9+Cloudflare · Google · **AdGuard Family** | Quad9+Cloudflare |
| Blocking strength | Balanced · Strict (+HaGeZi Pro++, 1Hosts) · Minimal | Balanced |
| Password | your own, or auto-generated | auto-generated |

## 🗂️ What's inside

| File | Purpose |
|---|---|
| `Install.bat` | ⭐ Double-click entry point → launches the setup wizard |
| `wizard.ps1` | The wizard / installer engine (`-Update` for silent updates) |
| `AdGuardHome.template.yaml` | Pre-seeded AdGuard Home config the wizard personalises |
| `Update.bat` / `Uninstall.bat` | One-click maintenance |
| `docker-compose.yml` | Optional power-user path |
| `docs/ROUTERS.md` | Step-by-step router guides, incl. UK ISP workarounds |

## 📊 The dashboard (your HUD)

- Total queries, **% blocked**, live graphs
- **Query log** — every request in real time (green = allowed, red = blocked)
- Per-device stats, top blocked domains, one-click allow/deny

## ❓ FAQ

- **A website broke!** → Dashboard → Query Log → find the red entry → **Unblock**.
- **Internet stops when the PC is off** → expected; the PC is your network's
  phonebook. Keep it awake: Settings → Power → Sleep = *Never*.
- **Forgot the password?** → Delete the `adguard` folder, re-run `Install.bat`.

## 🤝 Contributing

Issues and PRs are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
Security reports: [SECURITY.md](SECURITY.md).

## 📜 License

[MIT](LICENSE) — free for personal and commercial use. AdGuard Home itself is
GPLv3 (© AdGuard); this repository is just an installer around it.
