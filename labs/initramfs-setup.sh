#!/bin/bash
# Create the minimal initramfs skeleton in /tmp/initramfs. Needs no root.
set -e

IRD=/tmp/initramfs
mkdir -p $IRD/{bin,sbin,etc,proc,sys,dev,usr/bin}

# Device nodes need root to create with mknod. Instead we describe them in a
# list file, and the kernel build adds them to the initramfs image when it
# packs it (CONFIG_INITRAMFS_SOURCE in config-linux names both paths).
cat > /tmp/initramfs.devnodes <<'EOF'
# type  name          mode uid gid  dev-type major minor
nod     /dev/console  0600 0   0    c        5     1
nod     /dev/null     0666 0   0    c        1     3
EOF

# Minimal /init
cat > $IRD/init <<'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
echo "Userspace up; dropping to shell."

# Setting up for autoloading drivers if needed
# for f in /sys/bus/platform/devices/*/modalias ; do
#         [ -f "$f" ] && modprobe "$(cat "$f")" 2>/dev/null || true
# done

exec /bin/sh < /dev/console > /dev/console 2>&1
EOF
chmod +x $IRD/init

echo "initramfs skeleton ready in $IRD (device nodes listed in /tmp/initramfs.devnodes)"
