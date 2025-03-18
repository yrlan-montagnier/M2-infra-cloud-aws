# M5-infra-cloud-aws

Je travaille sur un projet AWS visant à déployer Nextcloud avec une architecture hautement disponible et évolutive, en utilisant un Auto Scaling Group (ASG).

L’objectif est d’assurer scalabilité, tolérance aux pannes et persistance des données en intégrant plusieurs services AWS.

L’infrastructure repose sur plusieurs composants :

## Réseau & Connectivité

* VPC : Un réseau privé avec des sous-réseaux publics et privés.
* Subnets :
  * 3 sous-réseaux publics pour les Load Balancers et le bastion host.
  * 3 sous-réseaux privés pour les instances Nextcloud et la base de données MySQL.
* Route Tables :
  * Une table de routage publique associée aux subnets publics avec une route vers l’Internet Gateway.
  * Plusieurs tables privées associées aux subnets privés, avec une route vers une NAT Gateway pour permettre aux instances Nextcloud d’accéder à Internet (mises à jour, téléchargement de paquets, etc.).
* Internet Gateway : Fournit un accès Internet aux ressources situées dans les sous-réseaux publics (notamment le bastion host).
* NAT Gateway : Placée dans un subnet public pour permettre aux instances privées (Nextcloud, RDS) d’accéder à Internet sans être exposées.

## Compute & Load Balancing

* Auto Scaling Group (ASG) : Déploie dynamiquement les instances Nextcloud à partir d’une AMI préconfigurée.
* Launch Template : Définit la configuration des instances EC2 de l’ASG, y compris l’AMI, les paramètres réseau et les politiques de démarrage.
* Application Load Balancer (ALB) :
  * Répartit la charge entre les instances Nextcloud dans différentes AZs.
  * Utilise un Target Group pour enregistrer dynamiquement les instances de l’ASG.

## Stockage & Base de Données

* RDS MySQL : Base de données relationnelle utilisée par Nextcloud, déployée en mode Multi-AZ pour la haute disponibilité.
* EFS (Elastic File System) : Fournit un stockage persistant et partagé entre les instances Nextcloud pour stocker les fichiers utilisateurs.

## Sécurité & Accès

* Bastion Host : Instance située dans un subnet public, permettant d’accéder en SSH aux instances privées via un Jump Host.
* Security Groups : Définissent les règles de connectivité entre les composants, notamment :
  * ALB → Instances Nextcloud (ports 80/443).
  * Instances Nextcloud → RDS MySQL (port 3306).
  * Instances Nextcloud → EFS (port NFS 2049).
  * Bastion Host → Instances privées (port 22 pour SSH).
* IAM Roles & Policies : Permissions attribuées aux instances EC2 et autres services pour l’accès aux ressources AWS nécessaires (S3, CloudWatch, etc.).

## DNS & Nom de Domaine

* Route 53 :
  * Enregistrement d’un nom de domaine pour Nextcloud.
  * Liaison du domaine avec l’ALB via un enregistrement CNAME ou A.

## Objectif final

* L’objectif est de garantir une infrastructure robuste, automatisée et scalable, permettant :
  * Une haute disponibilité via l’ASG et le Multi-AZ.
  * Une gestion optimisée des ressources grâce aux Scaling Policies.
  * Une persistence des données avec EFS et RDS MySQL.
  * Un accès sécurisé avec le bastion, les Security Groups et les IAM roles.
