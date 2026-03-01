# Proxmox Vibe-Pi VM (x86, headless)

![CI](https://github.com/hulki-bot/proxmox-vibe-pi-vm/actions/workflows/ci.yml/badge.svg) ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg) ![Platform](https://img.shields.io/badge/Platform-Proxmox%20VE-blue)

A clean, reproducible setup for a **headless Linux VM on Proxmox** that feels close to a Raspberry-Pi-style terminal workflow — ideal for:

- VS Code Remote SSH
- AI-assisted coding (Codex, etc.)
- API/network projects (e.g. Ulanzi display integrations)

> ⚠️ Important: this is **not a real Raspberry Pi**. It is an **x86_64 VM**.

## What this project gives you

- One script to create a small, fast VM on Proxmox
- Opinionated defaults for coding/demo workflows
- Post-install dev bootstrap script
- Console mode helpers (noVNC-friendly)
- Documentation you can reference in a blog/video

---

## Default VM profile ("small")

- 2 vCPU (`host`)
- 4 GB RAM
- 25 GB disk (`virtio-scsi`)
- Ubuntu Server cloud image (x86_64)
- Static IP via cloud-init (configurable)
- User + password + optional SSH keys

---

## Quickstart

Run on your Proxmox host:

```bash
git clone https://github.com/hulki-bot/proxmox-vibe-pi-vm.git
cd proxmox-vibe-pi-vm

chmod +x scripts/*.sh

./scripts/create-vm.sh \
  --vmid 126 \
  --name vibe-pi-x86 \
  --ip-cidr 192.168.3.126/24 \
  --gateway 192.168.3.1 \
  --ci-user joerg \
  --ci-password 'CHANGE_ME_NOW'
```

After first boot:

```bash
ssh joerg@192.168.3.126
sudo ./scripts/postinstall-dev.sh
```

(If you cloned on your laptop: run `postinstall-dev.sh` manually inside the VM.)

---

## Is this equivalent to Raspberry Pi 4?

Short answer: **for many terminal/dev tasks yes; for hardware/arch-specific tasks no.**

| Topic | x86 Proxmox VM | Real Raspberry Pi 4 |
|---|---|---|
| Terminal workflow | ✅ | ✅ |
| SSH + VS Code Remote | ✅ | ✅ |
| Network/API integrations | ✅ | ✅ |
| ARM-only binaries | ⚠️ sometimes no | ✅ |
| GPIO/peripheral behavior | ❌ | ✅ |
| Pi-specific kernel/device behavior | ❌ | ✅ |

If your project is network/API + app logic, this VM is usually perfect for demos and development.

---

## Console behavior note

For Proxmox noVNC login screen, use VGA mode:

```bash
./scripts/set-console-mode.sh --vmid 126 --mode virtio
```

Serial mode is also available for pure headless setups.

---

## Repo structure

- `scripts/create-vm.sh` – create/provision VM
- `scripts/postinstall-dev.sh` – install common dev tooling inside VM
- `scripts/set-console-mode.sh` – switch `vga` between `virtio|std|serial`
- `docs/TROUBLESHOOTING.md` – fixes for common issues
- `docs/ARCHITECTURE.md` – x86 VM vs Raspberry Pi explanation
- `docs/EXAMPLE_CONFIG.md` – exact profile used in the blog/video prep
- `docs/BLOG_SNIPPET_DE.md` – ready-to-use text snippets for blog/video

---

## License

MIT
