#!/bin/bash
# Installer le client NFS
yum install -y nfs-utils

# Créer le répertoire de montage
mkdir -p /mnt/efs

# Monter l'EFS
mount -t nfs4 -o nfsvers=4.1 ${efs_dns_name}:/ /mnt/efs

# Ajouter à fstab pour un montage automatique
echo "${efs_dns_name}:/ /mnt/efs nfs4 defaults,_netdev 0 0" >> /etc/fstab