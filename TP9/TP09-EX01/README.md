# TP9 - Intégration S3 Sécurisée

## 1. Création du bucket S3

```terraform
resource "aws_s3_bucket" "nextcloud_sensitive" {
  bucket = "${local.name}-nextcloud-sensitive"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Owner = local.user
  }
}
```


## 2. Configuration IAM

```terraform
resource "aws_iam_role" "nextcloud_s3" {
  name = "${local.name}-nextcloud-s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  inline_policy {
    name = "s3_access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads"
          ]
          Resource = aws_s3_bucket.nextcloud_sensitive.arn
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
          Resource = "${aws_s3_bucket.nextcloud_sensitive.arn}/*"
        }
      ]
    })
  }
}
```


## 3. Profil d'instance EC2

```terraform
resource "aws_iam_instance_profile" "nextcloud_s3" {
  name = "${local.name}-nextcloud-s3"
  role = aws_iam_role.nextcloud_s3.name
}
```


## 4. Modification du Launch Template

```terraform
resource "aws_launch_template" "nextcloud" {
  # ... configuration existante ...
  iam_instance_profile {
    name = aws_iam_instance_profile.nextcloud_s3.name
  }
  # ... autres paramètres ...
}
```


## 5. Configuration Nextcloud

1. Dans l'interface d'administration Nextcloud :
    - Aller à "Paramètres" → "Stockage externe"
    - Ajouter un stockage de type "Amazon S3"
    - Renseigner :
        - Nom du bucket
        - Région AWS
        - Laisser les champs d'identification vides (utilisation IAM Role)

## 6. Bucket Policy

```terraform
resource "aws_s3_bucket_policy" "nextcloud_sensitive" {
  bucket = aws_s3_bucket.nextcloud_sensitive.id

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
        Resource = aws_s3_bucket.nextcloud_sensitive.arn
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
        Resource = "${aws_s3_bucket.nextcloud_sensitive.arn}/*"
      },
      {
        Sid    = "AllowEC2Access"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.nextcloud_s3.arn
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
          aws_s3_bucket.nextcloud_sensitive.arn,
          "${aws_s3_bucket.nextcloud_sensitive.arn}/*"
        ]
      }
    ]
  })
}
```


## Vérification des contraintes

| Contrainte | Respectée via |
| :-- | :-- |
| Haute disponibilité réseau | Subnets multi-AZ, NAT Gateway redondant |
| Nomenclature des ressources | Utilisation de `${local.name}` dans tous les noms |
| Authentification SSH | Clés SSH via AWS Key Pair |
| Accessibilité Bastion | Security Group restrictif + IP whitelist |
| Accessibilité instances Nextcloud | Seulement via ALB + Bastion |
| Sécurité EFS | Chiffrement au repos + Security Groups |
| Haute disponibilité EFS | Déploiement multi-AZ |
| Accessibilité base de données | Security Group restrictif + Authentification IAM |
| Haute disponibilité RDS | Configuration Multi-AZ |
| Élasticité application | ASG avec politiques de scaling |
| Authentification API AWS | IAM Roles + Pas de credentials en dur |
| Permissions S3 | Politique de bucket restrictive + IAM Role |

**Validation technique :**

```bash
# Test accès Terraform
aws s3 ls s3://${local.name}-nextcloud-sensitive --profile terraform-user # Doit réussir
aws s3 cp test.txt s3://${local.name}-nextcloud-sensitive/ --profile terraform-user # Doit échouer

# Test accès depuis instance Nextcloud
sudo -u www-data aws s3 cp /var/www/html/config/config.php s3://${local.name}-nextcloud-sensitive/ # Doit réussir
```

Cette configuration assure :

- Chiffrement AES-256 pour les données au repos
- Accès minimal via IAM Roles
- Auditabilité via CloudTrail
- Isolation réseau via VPC Endpoints (recommandé)
- Conformité au principe de moindre privilège

