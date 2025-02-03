# TP1 - Exercice3 - Report du déploiement

## Contexte
L'équipe de développement à qui était destinée le serveur web a du retard dans la livraison de l'application.
Par soucis d'économies, on vous demande de détruire les ressources qui ne sont pas gratuites.

Comme le projet est retardé mais pas annulé, il faudra recréer ces ressources ultérieurement, on vous demande donc également de rédiger une procédure de déploiement de l'instance EC2 pour faciliter son redéploiement en y incluant le temps nécessaire à sa réalisation.

## Objectifs
Vous devez supprimer vos ressources (à l'exception du "Resource Group") et créer une procédure de redéploiement.

La procédure devra contenir toutes les informations nécessaires à sa bonne réalisation, screenshot à l'appuie, ainsi que le temps nécessaire pour réaliser chaque action.

## Étapes des réalisations
### 1. Supprimer vos resources
* Supprimer l'instance EC2 (terminate)
* Attendre que l'instance soit dans l'état désiré (Instance state -> Terminated)
* Filtrer la vue du service EC2 pour afficher uniquement l'instance et prendre un screenshot.
* À l'aide de votre groupe de ressources, vérifier s'il reste des ressources à supprimer.
* Supprimer les ressources restantes le cas échéant.

* une capture d'écran de la vue filtrée du service EC2 qui montre que l'instance a été supprimée.
![image](https://github.com/user-attachments/assets/f0b0b957-adf6-4501-b250-e3f12b31f2b5)

### 2. Rédiger la procédure de redéploiement
Créer un fichier au format de votre choix (exportable en PDF) contenant la procédure de redéploiement de l'instance EC2.

Pour cette étape vous êtes libre de choisir le format de votre choix, cependant, le fichier doit contenir les éléments suivants :
* Les différentes étapes à suivre pour déployer l'instance EC2, installer Apache2 et vérifier que le serveur web est accessible.
* Les temps nécessaires pour réaliser chaque étape ainsi que le temps total pour réaliser la procédure intégralement.
* Les screenshots nécessaires à la compréhension de la procédure.
* Vous pouvez redéployer une instance EC2 pour vous aider à rédiger la procédure et/ou pour tester votre procédure mais n'oubliez pas de la supprimer une fois la procédure rédigée.

## Procédure de déploiement
### 1. Se rendre sur le service EC2
Chercher et se rendre dans le service "EC2"
![image](https://github.com/user-attachments/assets/ffb3381c-7aa4-473d-8931-2a5990237226)

### 2. Création de l'instance EC2

Cliquer sur "Launch Instance" pour accéder à la page de création d'une instance EC2 :
![image](https://github.com/user-attachments/assets/cbaa4239-43bf-45b1-a1e8-bd138a4cb770)

#### Sélection des tags
Remplir les tags "Name" et "Owner", en inscrivant la première lettre du prénom suivi du nom dans le champ valeur, en minuscule.

Exemple : Yrlan MONTAGNIER = `ymontagnier`

![image](https://github.com/user-attachments/assets/bcdc35c9-1394-4d4e-a981-26b1750dfd28)

#### Application and OS Images
On choisit un type d'OS et une architecture pour notre instance. On sélectione Ubuntu Server 24.04
Dans notre cas, nous utilisons l'**architecture Arm** qui permettra de sélectionner l'instance type `t4g.small`, qui est le type d'instance le moins cher lors de la prochaine étape.
![image](https://github.com/user-attachments/assets/e46c66ef-89dc-4df9-823c-fdb4285f15d1)

#### Instance Type
Sélectionner `t4g.small`
![image](https://github.com/user-attachments/assets/9611612c-a174-42da-ae50-b6fa130c5bfc)

#### Key Pair (SSH)
Laisser les options par défaut.
![image](https://github.com/user-attachments/assets/8a4ba80a-650f-468f-9b0a-92e83d540ce7)

#### Network Settings
Sélectionner `Select existing security group` --> Default
![image](https://github.com/user-attachments/assets/80845588-ba29-47c2-b427-4e44c5a57847)

#### Configure storage
Laisser les options par défaut.
![image](https://github.com/user-attachments/assets/e55c6c11-85f3-4026-9de5-dbb75e00e964)

#### Déployer l'instance
Cliquer sur le bouton "Launch Instance"
![image](https://github.com/user-attachments/assets/10ea70b2-1557-4b40-9c64-3b814e8d340e)

### 3. Connexion à l'instance EC2
Sélectionner l'instance dans la liste des instances
![image](https://github.com/user-attachments/assets/6a2ce7f3-910a-43f5-83d8-99371f8e3846)

Cliquer sur "Connect" sur la page qui s'ouvre

### 4. Déploiement du serveur web Apache2
```
sudo apt install apache2
```

### 5. Confirmer le fonctionnement
Récupérer l'adresse IP publique de l'instance EC2, c'est celle-ci qui permettra d'accéder au serveur web apache.
![image](https://github.com/user-attachments/assets/15d22ead-eb54-4b4f-a48a-72b18c62a5a1)

## Critères de validation
    
* l'instance EC2 initiale doit être supprimée (1 point).
* le fichier de procédure contient toutes les informations nécessaires à la réalisation de la procédure (1 point).
* le fichier de procédure contient les temps nécessaires pour réaliser chaque étape et le temps total (1 point).
* la procédure est claire, précise et facile à suivre (1 point).
* Toutes les resources créés ont été supprimées, à l'exception du Resource Group (1 point).
