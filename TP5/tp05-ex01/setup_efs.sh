#!/bin/bash
sudo apt-get update
sudo apt-get install -y nfs-common

# Définition du DNS de l'EFS 
# ${efs_dns} remplace la valeur par celle passée en argument dans le fichier ec2.tf
EFS_DNS="${efs_dns}"

# Création du point de montage
sudo mkdir -p /mnt/efs

# Montage du système de fichiers
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_DNS:/ /mnt/efs

# Ajout à fstab pour persistance après redémarrage
echo "$EFS_DNS:/ /mnt/efs nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab