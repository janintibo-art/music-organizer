# Music Organizer

Lecteur et organisateur de musique locale. Il lit **les étiquettes des
fichiers en premier**, ce qui compte pour une collection underground que
les bases en ligne ne connaissent pas.

Quatre onglets : **Morceaux**, **Albums**, **Artistes**, **Listes**, avec une
barre de lecture permanente au-dessus de la navigation.

## Lecture des étiquettes

Écrite en Dart, sans aucun module natif — c'est délibéré, les modules de
lecture d'étiquettes sont une cause classique d'échec de compilation.
Trois familles sont couvertes :

| Format | Étiquettes lues |
|---|---|
| MP3 | ID3v2.2, 2.3 et 2.4, pochette APIC comprise |
| FLAC | commentaires Vorbis, bloc PICTURE, durée exacte |
| OGG et Opus | commentaires Vorbis |
| M4A, AAC | atomes `ilst`, pochette `covr` comprise |

Quand un fichier n'a aucune étiquette, le **chemin prend le relais** :
`Artiste / Album / 03 - Titre.mp3` est reconnu, ainsi que les formes
`03 - Artiste - Titre` et `Artiste - Titre`.

## Pochettes

Trois sources, dans l'ordre : l'image intégrée au fichier, puis une image
posée dans le dossier — `cover`, `folder`, `front`, `pochette` —, puis rien.
Les pochettes extraites sont rangées **une par album** et non par morceau.

## Lecture en arrière-plan

La musique continue écran éteint, avec les commandes sur l'écran verrouillé
et dans la zone de notification. C'est ce que le lecteur vidéo ne savait pas
faire.

## Listes de lecture

Trois façons de les construire :

- **Parcourir les disques** — on navigue dans l'arborescence, on coche, et
  un bouton ajoute un dossier entier avec ses sous-dossiers. La sélection
  survit aux allers-retours.
- **Sélection multiple** dans l'onglet Morceaux, par appui long.
- **Import M3U**, pour reprendre des listes venues d'ailleurs.

L'export M3U écrit des chemins relatifs quand c'est possible, pour qu'une
clé USB reste lisible sur une autre machine.

Une liste retient des chemins. Un disque débranché ne la vide pas : les
morceaux introuvables sont signalés et conservés.

## Compiler

Pousser le dossier sur GitHub, l'onglet Actions fait le reste.

## Confidentialité

Rien ne sort de l'appareil. Aucune requête réseau n'est faite.
