# TP5 - Exercice 1 - EFS/EIP/NAT Gateway

## Script setup_efs.sh :
```bash
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
```

## Logs user-data
> Tips : On peut récupérer les logs du script passé dans le user data sur l'instance NextCloud.
>
> Cela permet de vérifier la sortie du script, nottement le fais que la variable $EFS_DNS soit bien remplacée par la valeur correspondant à l'EFS qui doit être associé à l'instance.
```bash
ubuntu@ip-10-0-5-188:~$ sudo cat /var/lib/cloud/instance/user-data.txt
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nfs-common

# Définition du DNS de l'EFS 
# fs-0e84015b258fd4c10.efs.eu-north-1.amazonaws.com remplace la valeur par celle passée en argument dans le fichier ec2.tf
EFS_DNS="fs-0e84015b258fd4c10.efs.eu-north-1.amazonaws.com"

# Création du point de montage
sudo mkdir -p /mnt/efs

# Montage du système de fichiers
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_DNS:/ /mnt/efs

# Ajout à fstab pour persistance après redémarrage
echo "$EFS_DNS:/ /mnt/efs nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstabubuntu@ip-10-0-5-188:~$
```

## Configuration fichier SSH
![alt text](img/ssh_config.png)

## Logs cloud-init :
```bash
/var/log/cloud-init.log
/var/log/cloud-init-output.log
```

