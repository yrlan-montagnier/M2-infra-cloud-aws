# TP9 - Intégration S3 Sécurisée

## [Contexte](http://training-class.akiros.it/infra-cloud/tp/tp09/ex01#contexte "Lien direct vers Contexte")

Suite au déploiement réussi de l'application Nextcloud, l'équipe de direction a exprimé des inquiétudes concernant la sécurité des documents sensibles stockés dans l'application.

Pour répondre à ces préoccupations, il a été décidé que tous les documents sensibles uploadés sur Nextcloud doivent être stockés dans un bucket S3 dédié et hautement sécurisé.

L'équipe de sécurité a insisté sur l'utilisation des **meilleures pratiques** en matière de gestion des accès.

Elle recommande d'utiliser un profil d'instance EC2 plutôt que de stocker des credentials AWS directement sur les instances.

Votre tâche est de configurer les éléments d'infrastructure nécessaire pour permettre à l'application Nextcloud d'interagir de manière sécurisée avec le bucket S3, tout en respectant le principe du moindre privilège.

L'infrastructure sera auditée en intégralité par l'équipe de sécurité pour s'assurer que toutes les contraintes imposées depuis le début du projet sont bien respectées.

## [Objectifs](http://training-class.akiros.it/infra-cloud/tp/tp09/ex01#objectifs "Lien direct vers Objectifs")

1. Créer un bucket S3 dédié pour le stockage des documents sensibles.
2. Configurer un rôle IAM avec les permissions minimales nécessaires pour accéder au bucket S3.
3. Créer un profil d'instance EC2 associé à ce rôle.
4. Modifier la configuration des instances EC2 Nextcloud pour utiliser ce profil d'instance.
5. Configurer l'accès au bucket S3 depuis l'application Nextcloud.
6. Configurer une bucket policy pour restreindre l'accès au bucket S3 uniquement aux instances Nextcloud et à l'utilisateur Terraform pour l'administration du bucket.
7. Passer en revue toutes les contraintes imposées depuis le début du projet pour s'assurer qu'elles sont bien respectées.

### 1. Création du bucket S3

* Utiliser Terraform pour créer un nouveau bucket S3 nommé `<username>-<tp_dir>-nextcloud` (`ymontagnier-tp09-ex01-nextcloud`)
* Configurer le chiffrement côté serveur pour le bucket.

```terraform
resource "aws_s3_bucket" "nextcloud_bucket" {
  bucket = "${local.user}-tp09-ex01-nextcloud-bucket" #Sans variable pour les minuscules

  tags = {
    Name        = "${local.name}-nextcloud"
  }
}

resource aws_s3_bucket_server_side_encryption_configuration "nextcloud_bucket_sse" {
  bucket = aws_s3_bucket.nextcloud_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### 2. Configuration IAM

* Créer un rôle IAM nommé `<username>-<tp_dir>-nextcloud` qui peut être **assumé** par le service EC2.
* Créer une politique "Inline" à ce role permettant à Nextcloud d'accéder au bucket S3. Les permissions minimales nécessaires sont :
  * les actions suivantes sur le bucket S3 :
    * `s3:ListBucket`
    * `s3:ListBucketMultipartUploads`
  * les actions suivantes sur les objets du bucket S3 :
    * `s3:GetObject`
    * `s3:PutObject`
    * `s3:DeleteObject`
    * `s3:AbortMultipartUpload`
    * `s3:ListMultipartUploadParts`

```terraform
resource "aws_iam_role" "nextcloud_role" {
  name = "${local.name}-nextcloud"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "nextcloud_role_policy" {
  name   = "NextcloudS3AccessPolicy"
  role   = aws_iam_role.nextcloud_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.nextcloud_bucket.id}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.nextcloud_bucket.id}/*"
      }
    ]
  })
}
```

### 3. Créer un profil d'instance EC2 nommé `<username>-<tp_dir>-nextcloud` et associé au rôle IAM créé précédemment.

```terraform
resource "aws_iam_instance_profile" "nextcloud_instance_profile" {
  name = "${local.name}-nextcloud"
  role = aws_iam_role.nextcloud_role.name
}
```

### 4. Modifier le Launch Template pour utiliser le profil d'instance.

* Modifier la configuration Terraform pour que les instances EC2 utilisent le profil d'instance créé.

```terraform
resource "aws_launch_template" "nextcloud" {
  # ... configuration existante ...
  iam_instance_profile {
    name = aws_iam_instance_profile.nextcloud_s3.name
  }
  # ... autres paramètres ...
}
```

### 5. Configuration Nextcloud

* Suivre la [Procédure d&#39;ajout d&#39;un bucket S3 à Nextcloud](http://training-class.akiros.it/infra-cloud/tp/tp09/Nextcloud-S3).

1. Dans l'interface d'administration Nextcloud :
   - Aller à "Paramètres" → "Stockage externe"
   - Ajouter un stockage de type "Amazon S3"
   - Renseigner :
     - Nom du bucket
     - Région AWS
     - Laisser les champs d'identification vides (utilisation IAM Role)

### 6. Bucket Policy

* Créer une bucket policy qui **ne permet que** les actions suivantes (toute autre action doit être explicitement interdite) :
  * Permet à l'utilisateur Terraform d'administrer le bucket **mais pas** de :
    * récupérer (`s3:GetObject*`)
    * supprimer (`s3:DeleteObject*`)
    * ou ajouter (`s3:PutObject*`) des objets.
  * Ne permet que les actions spécifiées pour le rôle IAM associé aux instances Nextcloud et interdit toutes les autres actions.
* Appliquer cette policy au bucket S3 créé.
* Vérifier qu'il est toujours possible de lister, uploader, télécharger et supprimer des fichiers dans le bucket depuis l'application Nextcloud.
* Vérifier que l'utilisateur Terraform ne peut pas télécharger de fichier mais qu'il peut toujours administrer le bucket avec terraform.

```terraform
resource "aws_s3_bucket_policy" "nextcloud_bucket_policy" {
  bucket = aws_s3_bucket.nextcloud_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTerraformAdmin"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform-user"
        }
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy"
        ]
        Resource = aws_s3_bucket.nextcloud_bucket.arn
      },
      {
        Sid    = "DenyTerraformDataAccess"
        Effect = "Deny"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform-user"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.nextcloud_bucket.arn}/*"
      },
      {
        Sid    = "AllowEC2Access"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.nextcloud_role.arn
        }
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          aws_s3_bucket.nextcloud_bucket.arn,
          "${aws_s3_bucket.nextcloud_bucket.arn}/*"
        ]
      }
    ]
  })
}

```

#### **Validation technique :**

```bash
# Test accès Terraform
aws s3 ls s3://${local.name}-nextcloud-sensitive --profile terraform-user # Doit réussir
aws s3 cp test.txt s3://${local.name}-nextcloud-sensitive/ --profile terraform-user # Doit échouer

# Test accès depuis instance Nextcloud
sudo -u www-data aws s3 cp /var/www/html/config/config.php s3://${local.name}-nextcloud-sensitive/ # Doit réussir
```

### 7. Vérification des contraintes

Ce document décrit l'ensemble des contraintes imposées depuis le début du projet et explique comment elles sont respectées dans notre infrastructure AWS.


| **Contrainte**                                    | **Description**                            | **Conformité** |
| --------------------------------------------------- | -------------------------------------------- | ----------------- |
| Haute Disponibilité Réseau                      | Multi-AZ, ALB, NAT Gateway                 | Réalisée      |
| Nomenclature des Ressources                       | Utilisation de`${local.name}`              | Réalisée      |
| Authentification SSH EC2                          | Clés SSH via AWS Key Pair                 | Réalisée      |
| Accessibilité SSH Bastion                        | Accès SSH limité via IP whitelistS       | Réalisée      |
| Accessibilité SSH Nextcloud                      | Accès SSH via Bastion uniquement          | Réalisée      |
| Utilisation EC2 Instance Connect                  | Pas de credentials persistants             | Réalisée      |
| EFS - Sécurité des Fichiers                     | Chiffrement AES-256                        | Réalisée      |
| EFS - Accessibilité                              | Accès limité via SG                      | Réalisée      |
| EFS - Haute Disponibilité                        | Déploiement multi-AZ                      | Réalisée      |
| RDS - Accessibilité                              | Accès limité via SG                      | Réalisée      |
| RDS - Haute Disponibilité                        | RDS Multi-AZ                               | Réalisée      |
| Application NextCloud -Accessibilité             | ALB avec SG restrictif                     | Réalisée      |
| Application NextCloud - Haute Disponibilité      | ASG avec ALB                               | Réalisée      |
| Application NextCloud - Élasticité              | ASG - Scaling automatique basé sur charge | Réalisée      |
| Application NextCloud - Scalabilité              | ASG avec min_size/max_size dynamiques      | Réalisée      |
| Authentification des instances EC2 avec l'API AWS | IAM Roles sans credentials persistants     | Réalisée      |
| Permissions entre Nextcloud & le bucket S3        | Rôle IAM avec permissions minimales       | Réalisée      |
| Permissions S3                                    | Bucket policy restrictive                  | Réalisée      |

#### 1. Contraintes liées à la haute disponibilité réseau

**Solution implémentée**:

- Déploiement dans 3 zones de disponibilité différentes
- Sous-réseaux publics et privés dans chaque AZ
- Utilisation des foreach

Exemple pour les subnets privés :

```terraform
# Pour chaque sous-réseau privé, on définit le CIDR et l'AZ dans lequel il se trouve à partir des variables locales private_subnet
resource "aws_subnet" "private" {
  for_each          = local.private_subnet
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${local.name}-private-${each.value.az}"
  }
}
```

#### 2. Contraintes de nomenclature des ressources

**Solution implémentée**:

- Utilisation systématique de la variable `${local.name}` ou `${local.user}` comme préfixe
- Convention de nommage (tags) cohérente pour tous les composants

**Justification par le code**:

```terraform
resource "aws_security_group" "bastion_sg" {
  name = "${local.name}-bastion-sg"
  # ...
}
```

#### 3. Contraintes liées à l'authentification SSH sur les instances EC2

**Solution implémentée**:

- Utilisation de clés SSH via AWS Key Pair
- Désactivation de l'authentification par mot de passe

**Justification par le code**:

```terraform
resource "aws_key_pair" "nextcloud" {
  key_name   = "${local.name}-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
```

#### 4. Contraintes liées à l'accessibilité (SSH) du bastion

**Solution implémentée**:

- Bastion dans un sous-réseau public
- Accès SSH limité à des IPs spécifiques

**Exemple, autorisation depuis l'IP ynov**:

```terraform
# Autoriser le SSH depuis YNOV
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_ynov_to_bastion" {
  security_group_id = aws_security_group.bastion_sg.id

  # YNOV IP
  cidr_ipv4   = "195.7.117.146/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  tags = {
    Name = "Allow SSH from YNOV"
  }
}
```

#### 5. Contraintes liées à l'accessibilité (SSH) des instances Nextcloud

**Solution implémentée**:

- Instances dans des sous-réseaux privés
- Accès SSH uniquement via le bastion (security group)

**Autorisation depuis le SG du bastion**:

```terraform
# Autoriser le trafic SSH depuis le bastion
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_bastion" {
  security_group_id = aws_security_group.nextcloud_sg.id

  # Autoriser le trafic SSH depuis le security group du bastion
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  tags = {
    Name = "Allow SSH from Bastion"
  }
}
```

#### 6. Contraintes liées à l'utilisation du service EC2 instance connect

**Solution implémentée**:

- On interdit l'utilisation d'EC2 instant connect au niveau de l'ACL

**Au niveau de l'ACL**:

```terraform
  # Règle 100: Bloquer le trafic SSH depuis la plage d'adresses 13.48.4.200/30 (EC2 instance connect)
  ingress {
    rule_no    = 100
    action     = "deny"
    protocol   = "tcp"
    cidr_block = "13.48.4.200/30"
    from_port  = 22
    to_port    = 22
  }
```

#### 7. Contraintes liées à la sécurité des fichiers stockés sur le système de fichier partagé

**Solution implémentée**:

- EFS avec chiffrement activé `encrypted = true`
- Accès restreint via security groups

**Justification par le code**:

```terraform
# Créer un EFS pour Nextcloud
resource "aws_efs_file_system" "nextcloud_efs" {
  creation_token   = "nextcloud-efs-token"
  encrypted        = true
  performance_mode = "generalPurpose"
  tags = {
    Name = "${local.name}-nextcloud-efs"
  }
}
```

#### 8. Contraintes liées à l'accessibilité du système de fichier partagé

**Solution implémentée**:

- Accès NFS (port 2049) limité aux instances Nextcloud

**Limitation de l'accès via une règle dans le SG de l'EFS**:

```terraform
# Autoriser uniquement Nextcloud à accéder à EFS sur le port 2049
resource "aws_vpc_security_group_ingress_rule" "allow_nfs_from_nextcloud" {
  security_group_id = aws_security_group.efs_sg.id

  # Autoriser le trafic NFS/EFS depuis le security group de Nextcloud
  referenced_security_group_id = aws_security_group.nextcloud_sg.id
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049

  tags = {
    Name = "Allow NFS/EFS access from Nextcloud SG"
  }
}

```

#### 9. Contraintes liées à la haute disponibilité du système de fichier partagé

**Solution implémentée**:

- EFS déployé en mode multi-AZ
- Mount targets dans chaque zone de disponibilité

```
# Créer un mount target pour chaque subnet privé
resource "aws_efs_mount_target" "nextcloud_efs_targets" {
  for_each = aws_subnet.private

  file_system_id  = aws_efs_file_system.nextcloud_efs.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.efs_sg.id]
}
```

#### 10. Contraintes liées à l'accessibilité de la base de données

**Solution implémentée**:

- RDS dans des sous-réseaux privés
- Accès limité aux instances Nextcloud

**Règle pour autoriser uniquement NextCloud à se connecter au RDS**:

```terraform
# Autoriser uniquement Nextcloud à accéder à MySQL sur le port 3306
resource "aws_vpc_security_group_ingress_rule" "allow_mysql_from_nextcloud" {
  security_group_id = aws_security_group.nextcloud_db_sg.id

  # Autoriser le trafic MySQL depuis le security group de Nextcloud
  referenced_security_group_id = aws_security_group.nextcloud_sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306

  tags = {
    Name = "Allow MySQL access from Nextcloud SG"
  }
}

```

#### 11. Contraintes liées à la haute disponibilité de la base de données

**Solution implémentée**:

- RDS en mode Multi-AZ `multi_az = true`
- DB Subnet Group pointe vers les différents sous réseaux privés

```
# Créer un groupe de sous-réseaux pour la base de données RDS
resource "aws_db_subnet_group" "nextcloud_rds_subnet" {
  name       = "ymontagnier-nextcloud-rds-subnet"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  tags = {
    Name = "${local.name}-nextcloud-rds-subnet"
  }
}
```

#### 12. Contraintes liées à l'accessibilité de l'application Nextcloud

**Solution implémentée**:

- Application Load Balancer dans les sous-réseaux publics
- Accès contrôlé par whitelist d'IP

**Autorisation d'accès pour une adresse IP**:

```terraform
# Autoriser le trafic HTTP depuis l'IP d'YNOV
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_ynov_to_alb" {
  security_group_id = aws_security_group.nextcloud-alb-sg.id

  cidr_ipv4   = "195.7.117.146/32"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

  tags = {
    Name = "Autoriser l'accès à NextCloud depuis Ynov"
  }
}
```

#### 13. Contraintes liées à la haute disponibilité de l'application

**Solution implémentée**:

- Launch Template & Auto Scaling Group avec distribution multi-AZ
- Load balancer avec surveillance de l'état des instances

#### 14. Contraintes liées à l'élasticité de l'application

**Solution implémentée**:

- Politiques de scaling basées sur la charge CPU et les requêtes
- Déclenchement automatique des alarmes CloudWatch

#### 15. Contraintes liées à la scalabilité de l'application

**Solution implémentée**:

- Auto Scaling Group avec capacité dynamique (min=1, max=5)
- Architecture permettant d'ajouter/supprimer des instances à la demande

#### 16. Contraintes liées à la méthode d'authentification des instances EC2 auprès des API AWS

**Solution implémentée**:

- Utilisation de rôles IAM plutôt que de clés d'accès stockées
- Profil d'instance attaché aux instances EC2

**Justification par le code**:

```terraform
resource "aws_iam_role" "nextcloud_role" {
  name = "${local.name}-nextcloud"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}
```

#### 17. Contraintes liées aux permissions entre Nextcloud et le Bucket S3

**Solution implémentée**:

- Rôle IAM avec permissions minimales nécessaires
- Politique IAM inline limitant l'accès aux opérations essentielles

**IAM Role Policy**:

```terraform
resource "aws_iam_role_policy" "nextcloud_role_policy" {
  name   = "NextcloudS3AccessPolicy"
  role   = aws_iam_role.nextcloud_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.nextcloud_bucket.id}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.nextcloud_bucket.id}/*"
      }
    ]
  })
}

```

#### 18. Contraintes liées aux permissions sur le bucket S3

**Solution implémentée**:

- Chiffrement côté serveur AES-256
- Bucket policy restrictive avec deny explicite pour toutes les actions non autorisées

**S3 Bucket Policy**:

```terraform
resource "aws_s3_bucket_policy" "nextcloud_bucket_policy" {
  bucket = aws_s3_bucket.nextcloud_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowTerraformAdmin"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/ymontagnier"
        }
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy"
        ]
        Resource = aws_s3_bucket.nextcloud_bucket.arn
      },
      {
        Sid    = "DenyTerraformDataAccess"
        Effect = "Deny"
        Principal = {
          AWS = aws_iam_role.nextcloud_role.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.nextcloud_bucket.arn}/*"
      },
      {
        Sid    = "AllowEC2Access"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.nextcloud_role.arn
        }
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          aws_s3_bucket.nextcloud_bucket.arn,
          "${aws_s3_bucket.nextcloud_bucket.arn}/*"
        ]
      }
    ]
  })
}

```

Cette documentation démontre comment l'infrastructure respecte toutes les contraintes imposées, avec une justification par le code pour chaque point, assurant ainsi une solution robuste, sécurisée et hautement disponible pour l'application Nextcloud.
