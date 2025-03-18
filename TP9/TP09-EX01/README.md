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