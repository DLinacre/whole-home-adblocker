# 🌐 Pointing your home at the ad blocker

After the wizard finishes, blocking works on the PC itself. To protect **every
device**, tell your network to use your PC for DNS. You need the address the
wizard showed you, e.g. `192.168.1.50`.

Pick **ONE** of the three options below.

---

## Option A — Router DNS *(try this first — 2 minutes)*

1. Open your router's admin page (usually `192.168.0.1` or `192.168.1.1`).
2. Find **Internet / DNS settings** (sometimes under "WAN" or "Connection").
3. Set **Primary DNS** to your PC's address. Leave secondary blank.
4. Save/reconnect. Every device is now protected. ✅

### 🇬🇧 UK providers — read this

Many ISP-supplied hubs **lock the DNS setting**:

| Provider | Can you change DNS on the hub? |
|---|---|
| Sky (Hub/Q) | ❌ No (use Option B) |
| BT (Smart Hub 2) | ❌ No (use Option B) |
| Virgin Media (Hub 3/4/5) | ❌ No (use Option B) |
| TalkTalk | ❌ Usually locked (use Option B) |
| Vodafone UK | ⚠️ Often locked |
| Plusnet | ✅ Usually yes |
| Own router (Asus, TP-Link, Netgear…) | ✅ Almost always yes |

---

## Option B — Let the ad blocker take over DHCP *(works on ANY router)*

Routers hand out network settings via "DHCP". Give that job to the ad blocker
and every device automatically uses it — even on locked-down ISP hubs.

1. **Router admin page** → find **DHCP server** → **turn it OFF** → save.
2. **Dashboard** (`http://localhost`) → **Settings → DHCP settings** →
   **Enable DHCP server** → let it pick your network interface → save.
3. Reconnect your devices (or just wait — devices renew within ~24h).

✅ Done — everything now uses the blocker automatically, including new devices.

---

## Option C — Only some devices (don't touch the router)

Change DNS on each device to your PC's address:

- **Windows:** Settings → Network & Internet → Wi-Fi → your network →
  *DNS server assignment* → Edit → Manual → IPv4 → enter the address.
- **iPhone/iPad:** Settings → Wi-Fi → ⓘ → Configure DNS → Manual → enter it.
- **Android:** Settings → Wi-Fi → your network → Advanced → IP settings →
  Static → DNS 1.

---

## ✅ Verify it's working

1. On your phone (on Wi-Fi), open the dashboard: `http://YOUR-PC-ADDRESS` —
   your phone's lookups should appear in the Query Log.
2. Or visit a known ad-heavy site and watch the **Blocked** counter climb.

## ⭐ Recommended extras

- **Reserve the PC's address** in your router ("DHCP reservation" /
  "address reservation") so it never changes.
- **Stop the PC sleeping:** Settings → System → Power → Sleep = *Never*.
- Docker Desktop → Settings → General → **"Start Docker Desktop when you
  sign in"** — so blocking survives restarts.
