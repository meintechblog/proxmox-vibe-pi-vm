# Example config used in the blog/video prep

This is the exact profile used for the prepared VM:

- VM ID: `126`
- Name: `vibe-pi-x86`
- OS image: Ubuntu 24.04 cloud image (`noble-server-cloudimg-amd64.img`)
- CPU: `2` cores (`host`)
- RAM: `4096` MB
- Disk: `25G` (`local-lvm`, virtio-scsi)
- Network bridge: `vmbr0`
- Guest IP: `192.168.3.126/24`
- Gateway: `192.168.3.1`
- Cloud-init user: `joerg`
- Guest agent: enabled
- Console mode: `virtio` (noVNC friendly)

## Equivalent creation command

```bash
./scripts/create-vm.sh \
  --vmid 126 \
  --name vibe-pi-x86 \
  --ip-cidr 192.168.3.126/24 \
  --gateway 192.168.3.1 \
  --ci-user joerg \
  --ci-password 'CHANGE_ME_NOW'
```

