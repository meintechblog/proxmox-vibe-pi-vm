#!/usr/bin/env bash
set -euo pipefail

# Defaults (small profile)
VMID=126
NAME="vibe-pi-x86"
STORAGE="local-lvm"
BRIDGE="vmbr0"
CORES=2
MEMORY=4096
DISK_GB=25
IP_CIDR="dhcp"
GATEWAY="192.168.1.1"
CI_USER="vibe"
CI_PASSWORD=""
SSHKEYS_FILE=""

IMAGE_DIR="/var/lib/vz/template/qcow"
IMAGE_NAME="noble-server-cloudimg-amd64.img"
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/${IMAGE_NAME}"

usage() {
  cat <<USAGE
Usage: $0 [options]

Options:
  --vmid <id>                 VM ID (default: ${VMID})
  --name <name>               VM name (default: ${NAME})
  --storage <storage>         Proxmox storage (default: ${STORAGE})
  --bridge <vmbrX>            Bridge (default: ${BRIDGE})
  --cores <n>                 vCPU cores (default: ${CORES})
  --memory <mb>               RAM in MB (default: ${MEMORY})
  --disk-gb <n>               Disk size GB (default: ${DISK_GB})
  --ip-cidr <ip/prefix>       Static IP CIDR (default: ${IP_CIDR})
  --gateway <ip>              Gateway (default: ${GATEWAY})
  --ci-user <user>            Cloud-init user (default: ${CI_USER})
  --ci-password <pw>          Cloud-init password (required)
  --sshkeys-file <path>       Optional authorized_keys file
  -h, --help                  Show help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vmid) VMID="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --storage) STORAGE="$2"; shift 2 ;;
    --bridge) BRIDGE="$2"; shift 2 ;;
    --cores) CORES="$2"; shift 2 ;;
    --memory) MEMORY="$2"; shift 2 ;;
    --disk-gb) DISK_GB="$2"; shift 2 ;;
    --ip-cidr) IP_CIDR="$2"; shift 2 ;;
    --gateway) GATEWAY="$2"; shift 2 ;;
    --ci-user) CI_USER="$2"; shift 2 ;;
    --ci-password) CI_PASSWORD="$2"; shift 2 ;;
    --sshkeys-file) SSHKEYS_FILE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$CI_PASSWORD" ]]; then
  echo "ERROR: --ci-password is required" >&2
  exit 1
fi

for cmd in qm pvesm wget; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing command: $cmd" >&2; exit 1; }
done

if qm status "$VMID" >/dev/null 2>&1; then
  echo "ERROR: VMID ${VMID} already exists" >&2
  exit 1
fi

mkdir -p "$IMAGE_DIR"
IMAGE_PATH="${IMAGE_DIR}/${IMAGE_NAME}"

if [[ ! -f "$IMAGE_PATH" ]]; then
  echo "Downloading cloud image: ${IMAGE_URL}"
  wget -O "$IMAGE_PATH" "$IMAGE_URL"
else
  echo "Using cached image: ${IMAGE_PATH}"
fi

echo "Creating VM ${VMID} (${NAME})"
qm create "$VMID" \
  --name "$NAME" \
  --ostype l26 \
  --cores "$CORES" \
  --sockets 1 \
  --cpu host \
  --memory "$MEMORY" \
  --scsihw virtio-scsi-single \
  --net0 "virtio,bridge=${BRIDGE}" \
  --agent enabled=1 \
  --serial0 socket \
  --vga virtio

qm importdisk "$VMID" "$IMAGE_PATH" "$STORAGE"
qm set "$VMID" --scsi0 "$STORAGE:vm-${VMID}-disk-0,ssd=1"
qm set "$VMID" --boot order=scsi0
qm set "$VMID" --ide2 "$STORAGE:cloudinit"
qm set "$VMID" --ipconfig0 "ip=${IP_CIDR},gw=${GATEWAY}"
qm set "$VMID" --ciuser "$CI_USER"
qm set "$VMID" --cipassword "$CI_PASSWORD"
qm resize "$VMID" scsi0 "${DISK_GB}G"

if [[ -n "$SSHKEYS_FILE" ]]; then
  if [[ ! -f "$SSHKEYS_FILE" ]]; then
    echo "ERROR: --sshkeys-file not found: $SSHKEYS_FILE" >&2
    exit 1
  fi
  qm set "$VMID" --sshkeys "$SSHKEYS_FILE"
fi

qm start "$VMID"

echo "Done."
echo "VMID: ${VMID}"
echo "Name: ${NAME}"
echo "IP:   ${IP_CIDR%/*}"
echo "User: ${CI_USER}"
