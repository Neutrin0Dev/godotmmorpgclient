Je me lance dans l'apprentissage du networking sur Godot avec ce projet de MMOTOOLKIT.
L'idée est d'apprendre la création de netcode et les systemes applicable pour le MMO

But du projet : 
Créé un ensemble d'outils pour la création de projet MMO :

- Systeme simple de connexion au serveur (juste cliquer sur un bouton)
- Movement synchroniser entre client et serveur via l'envoie de RPC (Le mouvement coté client sera une interpolation des positions calculé par le serveur)
(mouvement dans un premier temps sera géré par les inputs key, mais j'aimerais aussi ajouté le click move)
- Node modulaire pour spawn des monstres
- Gestions des mouvements des monstres comme les client, le serveur calcules les déplacements, le client reçoit les positions et applique une interpolation.
- Node PNJ modulaire, ou les dialogue ainsi que les quetes seront défini dans la node directement.

Cela me semble déja un bon petit projet pour me faire la main et apprendre :D
