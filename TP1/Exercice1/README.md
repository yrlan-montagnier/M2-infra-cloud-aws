# TP01 - Exercice 1

## 1. Étude comparative

J'ai commencé par récupérer toutes les instances qui respectaient les contraintes (1 ou 2 vCPU, 2Gb de RAM, type : general purpose)

Puis j'ai fait un fichier Excel avec une page par région.

Enfin une feuille dans ce fichier excel qui condense les infos présentes dans les différentes pages (régions).

Avec un tri par coût horraire croissant, je trouve que l'instance **`tg4.small`** dans la région **`Stockholm`** est celle qui a le plus faible coût.

https://aws.amazon.com/fr/ec2/pricing/on-demand/

:file_folder: [Tableau_comparatif_coûts_AWS.xlsx](Tableau_comparatif_coûts_AWS.xlsx)

![image](https://github.com/user-attachments/assets/de62f4f6-ca37-4504-a27e-a1b206844a2e)

## 2. Déploiement de l'instance EC2

À l'aide du tableau comparatif que vous avez créé, déployer une instance EC2 qui respecte le cahier des charges et contraintes imposées.

Vous n'avez pas besoin de créer de clé SSH, vous pouvez utiliser EC2 Instance Connect pour vous connecter à votre instance.
Vous n'avez pas besoin de créer de groupe de sécurité, vous pouvez utiliser le groupe de sécurité par défaut.

## 3. Installation du serveur web
Une fois l'instance EC2 déployée :

S'y connecter via EC2 Instance Connect
Installer le serveur web

## 4. Accès au serveur web
Une fois le serveur web installé :

Identifier l'adresse IP (ou FQDN) publique de l'instance EC2.
Vérifier que la page par défaut du serveur web est accessible depuis un navigateur web.

![image](https://github.com/user-attachments/assets/c0aa50c4-ceb2-404d-ab7b-bcb93d915e95)

## 5. Récupération des informations
**Repérer les informations suivantes sur votre instance EC2 :**

* ID de l'instance (instance ID) :`i-06c7ba45d3943d153`
* Type d'instance (Instance type) : `t4g.small`
* ID de l'AMI (AMI ID) : `ami-001e33773aec8d45f`
* L'IP publique associée à l'instance (Public IPv4 address) : `13.50.225.142`
* Le FQDN public associé à l'instance (Public IPv4 DNS) : `ec2-13-50-225-142.eu-north-1.compute.amazonaws.com`
* L'IP privée associée à l'instance (Private IPv4 address) : `ip-172-31-4-137.eu-north-1.compute.internal`
* L'ID du VPC dans lequel est déployée l'instance (VPC ID) : `vpc-0424f1e027d7cfe2b`
* L'ID du sous-réseau dans lequel est déployée l'instance (Subnet ID) : `subnet-002fab227991c2b1c`
* L'AZ dans laquelle est déployée l'instance (Availability Zone) : `eu-north-1c`
* L'ID de l'interface réseau associée à l'instance (Network Interface ID) : `eni-08b51fe8d2891d1ba`
* L'ID du volume attaché à l'instance (EBS Volume ID) : `vol-08446c8a9a246bb33`
* La taille du volume attaché à l'instance (EBS Volume Size) : `8 GiB`

**Livrables :**
* Le tableau comparatif des types d'instances EC2 par région.
    * :file_folder: [Tableau_comparatif_coûts_AWS.xlsx](Tableau_comparatif_coûts_AWS.xlsx)
* Un fichier texte contenant les informations de l'instance EC2 déployée.
    * Voir ci-dessus (5. Récupération des informations)
* Une capture d'écran de la page d'accueil du serveur web qui inclut l'adresse IP (ou FQDN) publique de l'instance EC2.
    * Voir ci-dessus (4. Accès au serveur web)

**Critères de validation :**
* Le tableau est correctement formaté et contient des informations pertinentes (1 point).
* La région adéquate a été sélectionnée (1 point).
* Le type d'instance adéquat a été sélectionné (1 point).
* Le service apache2 a été installé et est accessible depuis internet (1 point).
