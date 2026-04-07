# Homelab learning path

A progressive guide to building a personal homelab — from zero to a fully self-hosted network with DNS filtering, remote access, personal cloud, and more. Designed to build skills in the right order so each project teaches something you'll need for the next.

---

## How to use this guide

Work through the phases in order. Each phase assumes you're comfortable with the previous one. Don't skip ahead to buying hardware until the phase notes say it's time — you can get further than you'd think on hardware you already own.

---

## Phase 0 — Linux foundations (start here, no new hardware needed)

**Goal:** Get comfortable with the Linux terminal before touching any real servers.

### WSL2 (Windows Subsystem for Linux)

Run a full Ubuntu terminal inside Windows 11. This is the best Linux sandbox you already have — zero cost, zero risk to your main PC.

- Install via: `wsl --install` in PowerShell (run as admin)
- Default distro: Ubuntu
- What to practice: navigating the filesystem (`cd`, `ls`, `pwd`), editing files (`nano`), installing packages (`apt install`)

### VirtualBox or VMware Workstation

Full virtual machines with their own isolated network. Practice breaking and restoring Linux without consequences.

- VirtualBox is free; VMware Workstation has a free personal tier
- Create an Ubuntu 24 LTS VM as your main practice environment
- Snapshot before experimenting — restore if you break something

### Core Linux skills to learn in Phase 0

These unlock everything that follows:

- Navigation: `cd`, `ls -la`, `pwd`, `mkdir`, `rm`, `cp`, `mv`
- File editing: `nano` (easy) then `vim` (powerful)
- Permissions: `chmod`, `chown`, understanding `rwx`
- Services: `systemctl start/stop/enable/status`
- Networking: `ip a`, `ping`, `curl`, `ssh`
- Package management: `apt update && apt upgrade`, `apt install`
- Viewing logs: `journalctl -f`, `tail -f /var/log/syslog`

**You're ready for Phase 1 when:** you can SSH into a machine, install a package, and start/stop a service without looking anything up.

---

## Phase 1 — First real homelab service (weeks 2–4)

**Goal:** Get your first always-on service running and understand how your home network actually works.

### DNS filtering with AdGuard Home

AdGuard Home sits on your local network and acts as the DNS resolver for all your devices. Your router tells every device "use this IP for DNS." Blocked domains (ads, trackers) get a dead response before they ever load.

**What you'll learn:** static IP addresses, router DHCP settings, running a Linux daemon, reading logs.

**Installation (Docker method — recommended):**

```yaml
# docker-compose.yml
services:
  adguardhome:
    image: adguard/adguardhome
    container_name: adguardhome
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3000:3000/tcp"
      - "80:80/tcp"
    volumes:
      - ./adguard/work:/opt/adguardhome/work
      - ./adguard/conf:/opt/adguardhome/conf
    restart: unless-stopped
```

**Router config:** Set your router's DHCP DNS server to the static IP of the machine running AdGuard. All devices on the network will automatically use it.

> **Note:** Pi-hole is the classic alternative. AdGuard Home is recommended for beginners — cleaner UI, built-in DoH/DoT support, no extra config needed.

### Hardware decision point

You can run Phase 1 services on:
- A spare PC or old laptop running Ubuntu (free)
- A Raspberry Pi 4 or 5 (~$60–80 + SD card + power supply)
- A VM on your main Windows PC (works but goes down when you restart)

**Recommendation:** Start on a VM. If you enjoy it, buy a Raspberry Pi 4 as a dedicated always-on device for DNS + dashboard.

### Local dashboard with Homepage or Homarr

A browser home page that links all your services with live status indicators. Also your first Docker container.

```yaml
# docker-compose.yml
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    ports:
      - "3001:3000"
    volumes:
      - ./homepage/config:/app/config
    restart: unless-stopped
```

Access at `http://your-server-ip:3001`

---

## Phase 2 — Docker, networking, and remote access (month 2)

**Goal:** Learn the tools that unlock 90% of homelab software and get access from outside your home.

### Docker and Docker Compose

Docker is the single most important skill in this guide. Almost every self-hosted app ships as a Docker container. Learn it and everything else becomes: copy a `docker-compose.yml`, run `docker compose up -d`, done.

**Key concepts to learn:**
- Images vs containers
- Volumes (persistent data)
- Networks (how containers talk to each other)
- Environment variables for configuration
- `docker compose up -d`, `down`, `logs`, `pull`

**Practice project:** Run Portainer (`docker run -d -p 9000:9000 portainer/portainer-ce`) — it gives you a web UI to manage all your containers visually.

### Remote access with Tailscale

Tailscale lets you access your home network from anywhere — your phone, work laptop, or a coffee shop. It's a VPN, but configured in minutes instead of hours.

- No port forwarding required
- Works through NAT automatically
- Free for personal use (up to 100 devices)
- Install on your home server and your phone/laptop — they appear as if on the same network

```bash
# Install on Linux server
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

> **Tailscale vs self-hosted Wireguard:** Tailscale is the right choice now. Once you understand networking well (Phase 3+), you can migrate to self-hosted Wireguard if you want full control and no third-party relay.

### Network segmentation with VLANs

Separate your devices into isolated network segments so your smart TV can't snoop on your laptop.

**Recommended segments:**
- `VLAN 10` — trusted devices (laptops, phones you control)
- `VLAN 20` — IoT devices (smart TVs, Alexa, smart bulbs)
- `VLAN 30` — servers/homelab
- `VLAN 40` — guest network

**What you need:**
- A router with VLAN support (Unifi, OPNsense, pfSense, or some consumer routers)
- A managed switch (~$30–60, e.g. TP-Link TL-SG108E)

> **Hardware to consider buying in Phase 2:** Managed network switch ($30–60). Router upgrade to support VLANs if your current router doesn't (Unifi Dream Machine, or OPNsense on a mini PC).

---

## Phase 3 — Storage, apps, and self-hosted services (months 3–4)

**Goal:** Replace cloud services with local ones and start hosting your own applications.

### Personal cloud with Nextcloud

Your family's private Google Drive / Dropbox replacement. File sync, photo backup, shared calendars, and contacts — all on hardware you own.

```yaml
services:
  nextcloud:
    image: nextcloud:latest
    container_name: nextcloud
    ports:
      - "8080:80"
    volumes:
      - nextcloud_data:/var/www/html
    environment:
      - MYSQL_HOST=db
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_PASSWORD=changeme
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: mariadb:10.6
    environment:
      - MYSQL_ROOT_PASSWORD=changeme
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_PASSWORD=changeme
    volumes:
      - db_data:/var/lib/mysql
    restart: unless-stopped

volumes:
  nextcloud_data:
  db_data:
```

> **Hardware to consider buying in Phase 3:** Extra hard drives for storage. Consider a NAS (Network Attached Storage) device like a Synology DS223 (~$300) or build one with TrueNAS on an old PC. Apply the 3-2-1 backup rule: 3 copies of data, on 2 different media types, with 1 offsite.

### Hosting your web apps locally

If you've built HTML/JS apps (e.g. with Claude), you can host them on your local server and access them from any device on your network.

**Simple static file server with Caddy:**

```yaml
services:
  caddy:
    image: caddy:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./sites:/srv
      - caddy_data:/data
    restart: unless-stopped

volumes:
  caddy_data:
```

```
# Caddyfile
myapp.local {
    root * /srv/myapp
    file_server
}
```

Caddy also acts as a **reverse proxy** — it lets you access multiple services by name (e.g. `adguard.home`, `nextcloud.home`) instead of remembering port numbers.

### Making your web apps work on mobile (PWA)

Your HTML apps can be installed on phones as Progressive Web Apps — no app store, no native code needed.

Add a `manifest.json` to your app:

```json
{
  "name": "My App",
  "short_name": "App",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

Link it in your HTML `<head>`:
```html
<link rel="manifest" href="/manifest.json">
```

Users can then tap "Add to Home Screen" in their mobile browser to install it like a native app.

### Personal CRM

**Monica** — purpose-built for personal relationships. Tracks contacts, life events, reminders, notes from conversations. Best if you want to manage friendships and family, not pipelines.

**Twenty** — modern open-source CRM. Polished UI, custom fields, good for professional contacts and networking.

Both run in Docker. Choose Monica for personal/social, Twenty for professional.

---

## Phase 4 — Advanced infrastructure (month 5+)

**Goal:** Level up to proper virtualisation and explore the broader homelab ecosystem.

### Proxmox VE

Proxmox is a bare-metal hypervisor — install it instead of an OS on a dedicated machine, then run multiple VMs and containers inside it. It's what most serious homelabs graduate to.

- Run your Docker host as a VM inside Proxmox
- Run OPNsense as a VM for your router/firewall
- Snapshot and restore entire machines in seconds
- Free to use (paid support subscription optional)

> **Hardware to consider buying in Phase 4:** A dedicated mini PC or server for Proxmox. Good options: Beelink EQ12 or S12 Pro (N100 chip, ~$150–200), a used enterprise server (HP ProLiant DL360), or a NUC-style device.

### Other services worth exploring

| Service | What it does | Replaces |
|---|---|---|
| Immich | Photo backup with AI search | Google Photos |
| Jellyfin | Media server — stream your own movies/TV | Plex / Netflix |
| Vaultwarden | Password manager server | 1Password / Bitwarden cloud |
| Gitea | Private Git repositories | GitHub |
| Uptime Kuma | Service monitoring & alerts | UptimeRobot |
| Home Assistant | Smart home hub | Google Home / Alexa |
| Mealie | Recipe manager | Paprika |
| Stirling PDF | PDF tools | Adobe Acrobat |

---

## Hardware buying guide

| When | What | Why | Approx. cost |
|---|---|---|---|
| Phase 1 | Raspberry Pi 4 (4GB) + SD card + PSU | Always-on DNS + dashboard | ~$80 |
| Phase 2 | Managed switch (TP-Link TL-SG108E) | VLAN segmentation | ~$30–40 |
| Phase 2 | VLAN-capable router (optional upgrade) | Network segmentation | $100–300 |
| Phase 3 | Extra hard drives (2–4TB) | Local storage for Nextcloud | ~$60–100 each |
| Phase 3 | NAS device (optional) | Redundant storage | ~$300+ |
| Phase 4 | Mini PC / dedicated server | Run Proxmox, multiple VMs | ~$150–300 |

**Rule of thumb:** Don't buy hardware until you've run the service in a VM and confirmed you actually use it. Many people buy a NAS before confirming they'll maintain Nextcloud — start on a spare drive first.

---

## Ongoing questions to revisit

Ask yourself these at the end of each phase:

- **Backups:** Is my data backed up? Apply the 3-2-1 rule — 3 copies, 2 different media, 1 offsite.
- **Exposure:** Am I exposing anything to the internet that shouldn't be? (Never expose services directly — use Tailscale instead of open ports.)
- **Resilience:** What happens if this service goes down overnight? Does my family notice?
- **Documentation:** Could I rebuild this from scratch using my own notes? Keep a simple log of what you installed and why.
- **Updates:** Are my containers getting security updates? Set a monthly "update day."

---

## Quick reference: key tools

| Tool | Purpose | Phase |
|---|---|---|
| WSL2 | Linux terminal on Windows | 0 |
| VirtualBox | Full Linux VMs for practice | 0 |
| AdGuard Home | DNS filtering, network-wide ad blocking | 1 |
| Docker + Compose | Container runtime — runs almost everything | 2 |
| Portainer | Web UI for managing Docker | 2 |
| Tailscale | Remote access VPN | 2 |
| Caddy | Reverse proxy + web server | 3 |
| Nextcloud | Personal cloud storage | 3 |
| Monica / Twenty | Personal CRM | 3 |
| Proxmox | Bare-metal hypervisor | 4 |

---

*Last updated: April 2026*
