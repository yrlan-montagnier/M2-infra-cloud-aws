# TP3 - Exercice 2 - AWS CLI - Créer un bucket S3

## Contexte

Dans ce TP, nous allons voir comment utiliser la CLI d'AWS pour interagir avec les services AWS.

Notamment, nous allons voir comment créer un bucket S3.

## Objectifs
Créer un bucket S3 dans le compte AWS dédié à la formation en respectant certains critères.


## 1. Identifier la commande AWS CLI à utiliser

À l'aide de la documentation de la CLI d'AWS, identifier la commande à utiliser pour créer un bucket S3.

Cette commande devrait permettre de spécifier le nom du bucket et la région.

```
aws s3api create-bucket \
    --bucket amzn-s3-demo-bucket1$(uuidgen | tr -d - | tr '[:upper:]' '[:lower:]' ) \
    --region us-west-1 \
    --create-bucket-configuration LocationConstraint=us-west-1
```

## 2. Créer le bucket S3

Exécuter la commande identifiée pour créer le bucket S3 en spécifiant :

Le nom du bucket : `<username_aws>` (exemple: `fdupont`)
La région : `eu-north-1` (`Stockholm`)

```
users:~/environment $ aws s3api create-bucket \
>     --bucket ymontagnier$(uuidgen | tr -d - | tr '[:upper:]' '[:lower:]' ) \
>     --region eu-north-1 \
>     --create-bucket-configuration LocationConstraint=eu-north-1 \
>     --profile formation-infra-cloud

{
    "Location": "http://ymontagnier.s3.amazonaws.com/"
}
```

## 3. Ajouter un tag au bucket

À l'aide de la documentation de la CLI d'AWS, identifier la commande à utiliser pour taguer le bucket créé.

Il faudra ajouter un tag avec la clé `Owner` et la valeur `<username_aws>`.

```
users:~/environment $ aws s3api put-bucket-tagging --bucket ymontagnier --profile formation-infra-cloud --tagging 'TagSet=[{Key=Owner,Value=ymontagnier}]'
```

On vérifie avec : 
```
users:~/environment $ aws s3api get-bucket-tagging --bucket ymontagnier --profile formation-infra-cloud 
{
    "TagSet": [
        {
            "Key": "Owner",
            "Value": "ymontagnier"
        }
    ]
}
```

## 4. Supprimer le bucket

À l'aide de la documentation de la CLI d'AWS, identifier la commande à utiliser pour supprimer le bucket créé.

```
users:~/environment $ aws s3api delete-bucket --bucket ymontagnier --profile formation-infra-cloud --region eu-north-1
```

## 5. On liste les buckets pour vérifier
```
users:~/environment $ aws s3api list-buckets 
{
    "Buckets": [
        {
            "Name": "mberguella",
            "CreationDate": "2025-02-06T10:10:22+00:00"
        }
    ],
    "Owner": {
        "ID": "dce67c98d78035264db5532e5c4c05988a00c173a730653f5f4e10dc375e8252"
    },
    "Prefix": null
}
```
