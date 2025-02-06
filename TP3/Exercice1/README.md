# TP3 - Exercice 1

## Contexte
Dans ce TP, nous allons voir comment utiliser la CLI d'AWS pour interagir avec les services AWS.

Notamment, nous allons voir comment lister des ressources spécifiques et comment filtrer les résultats.

## Objectifs
- lister les utilisateurs IAM du compte AWS dédié à la formation.
- filtrer les résultats pour n'afficher que les utilisateurs dont le path est /users/ynov/.
- afficher uniquement une liste contenant le nom de chaque utilisateur uniquement.

## 1. Identifier la commande AWS CLI à utiliser

À l'aide de la documentation de la CLI d'AWS, identifier la commande à utiliser pour lister les utilisateurs IAM.

Cette commande devrait renvoyer une liste d'objets JSON représentant les utilisateurs IAM du compte AWS.

```
aws iam list-users
```
![alt text](./img/list-users.png)

## 2. Filtrer les résultats

À l'aide de la documentation de la CLI d'AWS, identifier comment filtrer (côté serveur) les résultats pour n'afficher que les utilisateurs dont le path est `/users/ynov/`.

Cette commande devrait renvoyer un résultat similaire à la commande précédente mais ne contenir que les utilisateurs dont le path est `/users/ynov/`.

```
aws iam list-users --path-prefix /users/ynov/

{
    "Users": [
        {
            "Path": "/users/ynov/",
            "UserName": "epeyrataud",
            "UserId": "AIDAR6SW7FM74MP5TLLY2",
            "Arn": "arn:aws:iam::134400125759:user/users/ynov/epeyrataud",
            "CreateDate": "2025-02-02T18:07:53+00:00",
            "PasswordLastUsed": "2025-02-06T08:58:08+00:00"
        },
        {
            "Path": "/users/ynov/",
            "UserName": "groux",
            "UserId": "AIDAR6SW7FM7WCAEZ2BEH",
            "Arn": "arn:aws:iam::134400125759:user/users/ynov/groux",
            "CreateDate": "2025-02-02T18:07:52+00:00",
            "PasswordLastUsed": "2025-02-06T08:59:38+00:00"
        },
        {
            "Path": "/users/ynov/",
            "UserName": "gwattel",
            "UserId": "AIDAR6SW7FM7USOUEPXKW",
            "Arn": "arn:aws:iam::134400125759:user/users/ynov/gwattel",
            "CreateDate": "2025-02-02T18:07:52+00:00",
            "PasswordLastUsed": "2025-02-06T08:25:53+00:00"
        },
[...]
```

## 3. Afficher uniquement les noms des utilisateurs

À l'aide de cette documentation de la CLI d'AWS, identifier comment afficher (filtrage côté client) uniquement les noms des utilisateurs dont le path est `/users/ynov/`.

```
users:~/environment $ aws iam list-users --query "Users[?Path=='/users/ynov/'].UserName" --output json --profile formation-infra-cloud                                                                               
[
    "epeyrataud",
    "groux",
    "gwattel",
    "iotamendi",
    "jbats",
    "jpaillusseau",
    "kschaffner",
    "lhusson",
    "mberguella",
    "mlegrand",
    "mtardio",
    "rmarchais",
    "rmartin",
    "sperrin",
    "tcurmi",
    "tfourcade",
    "tquesnoy",
    "ymontagnier"
]

```