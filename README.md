<h1 align="center">Osmium</h1>

<table>
  <tr>
      <td align="center">
        Original
    </td>
     <td align="center">
        Taux : 1.0
    </td>
      <td align="center">
        Taux : 0.5
    </td>
    </tr>
  <tr>
    <td>
       <img src="https://github.com/Maxime-Cllt/Osmium/blob/main/documentation/images/ia1200x800.jpeg" width="300" height="300" alt="Image original">
    </td>
    <td>
       <img src="https://github.com/Maxime-Cllt/Osmium/blob/main/documentation/compresse/osmium_ia1200x800_%5Bpsnr%3D51.37%2Ctx%3D1.00%5D.jpeg" width="300" height="300" alt="Image compressé">
    </td>
 <td>
       <img src="https://github.com/Maxime-Cllt/Osmium/blob/main/documentation/compresse/osmium_ia1200x800_%5Bpsnr%3D51.14%2Ctx%3D0.50%5D.jpeg" width="300" height="300" alt="Image compressé">
    </td>
    </tr>
    <tr>
    <td align="center">
        103.17 KB
    </td>
    <td align="center">
        60.96 KB
    </td>
    <td align="center">
        56.9 KB
    </td>
    </tr>
</table>

L'osmium est un élément chimique de symbole Os et de numéro atomique 76. C'est le plus dense des éléments naturels, avec
une densité de 22,59 g/cm³.
Le nom osmium est dérivé du mot grec osme, qui signifie "odeur", en référence à l'odeur désagréable de ses composés
volatils.
Le lien entre l'osmium et l'image est que l'osmium est un élément très dense, comme peuvent l'être les images non
compressées, c'est donc l'intérêt de ce projet de compresser ces images pour les rendre moins lourdes.

Ce projet vise à implémenter la méthode de compression d'images en utilisant la décomposition en valeurs singulières (
SVD) comme présentée par Hervé Abdi dans son article "Singular Value Decomposition (SVD) and Generalized Singular Value
Decomposition (GSVD)".

## Objectif

L'objectif principal de ce projet est de créer un programme en OCaml capable de compresser des fichiers d'images de
visage en utilisant la méthode SVD. La compression d'image basée sur la SVD est un moyen efficace de réduire la taille
des fichiers d'images tout en préservant les informations essentielles.

## Méthode

Nous utilisons la librairie OCamlgsl, qui est une interface avec la GNU Scientific Library (GSL), pour effectuer les
calculs nécessaires à la décomposition en valeurs singulières et à la compression des images.

## Compatibilité

<p align="center">
    <img src="https://img.shields.io/badge/OS-MacOS-informational?style=flat&logo=apple&logoColor=white&color=2bbc8a" alt="MacOS" />
    <img src="https://img.shields.io/badge/OS-Linux-informational?style=flat&logo=linux&logoColor=white&color=2bbc8a" alt="Linux" />
</p>

## Dépendances

Avant de pouvoir exécuter le programme, assurez-vous d'avoir installé les dépendances suivantes :

- <b>OCaml</b> : Langage de programmation fonctionnel
- <b>Opam</b> : Gestionnaire de paquets pour OCaml
- <b>OCamlgsl</b> : Interface OCaml pour la GNU Scientific Library
- <b>OCamlgraphics</b> : Interface OCaml pour la bibliothèque graphique X11
- <b>Camlimages</b> : Bibliothèque OCaml pour la manipulation d'images
- <b>Dune</b> : Outil de construction pour les projets OCaml

Vous pouvez installer OCaml en utilisant Opam, le gestionnaire de paquets pour OCaml.

```bash
opam install ocamlgsl|ocamlgraphics|camlimages|dune
```

## Exécution

Pour exécuter le programme, vous pouvez utiliser la commande suivante dans /osmium :

```bash
dune exec osmium <chemin_vers_image> <taux_de_compression>
```

Exemple :

```bash
dune exec osmium "/images/img.jpeg" 1.0
```

Et le fichier Makefile vous permet de compiler le programme en utilisant la commande suivante :

```bash
make
```

## Auteurs

<ul>
      <li>
        <a
          href="https://github.com/Maxime-Cllt"
        >
          <p>Maxime COLLIAT</p>
        </a>
      </li>
      <li>
        <a
          href="https://github.com/Sudo-Rahman"
        >
          <p>Rahman YILMAZ</p>
        </a>
      </li>
</ul>
