<h1 align="center">Osmium</h1>

<div align="center">
<table>
  <tr>
    <td>
        Original
    </td>
    <td>
        Taux : 1.0
    </td>
    <td>
        Taux : 0.5
    </td>
    </tr>
  <tr>
    <td>
       <img src="https://github.com/Maxime-Cllt/Osmium/blob/main/documentation/images/ia1200x800.jpeg" width="100" height="100" alt="Image original">
    </td>
    <td>
       <img src="https://github.com/Maxime-Cllt/Osmium/blob/main/documentation/images/ia1200x800.jpeg" width="100" height="100" alt="Image compressé">
    </td>
 <td>
       <img src="https://github.com/Maxime-Cllt/Osmium/blob/main/documentation/images/ia1200x800.jpeg" width="100" height="100" alt="Image compressé">
    </td>
    </tr>
    <tr>
    <td>
        103.17 KB
    </td>
    <td>
        60.96 KB
    </td>
    <td>
        56.9 KB
    </td>
    </tr>
</table>
</div>

Ce projet vise à implémenter la méthode de compression d'images en utilisant la décomposition en valeurs singulières (
SVD) comme présentée par Hervé Abdi dans son article "Singular Value Decomposition (SVD) and Generalized Singular Value
Decomposition (GSVD)".

## Objectif

L'objectif principal de ce projet est de créer un programme en OCaml capable de compresser des fichiers d'images de
visage en utilisant la méthode SVD. La compression d'image basée sur la SVD est un moyen efficace de réduire la taille
des fichiers d'images tout en préservant les informations essentielles.

## Méthode

Nous utiliserons la librairie OCamlgsl, qui est une interface avec la GNU Scientific Library (GSL), pour effectuer les
calculs nécessaires à la décomposition en valeurs singulières et à la compression des images.

## Dépendances

Avant de pouvoir exécuter le programme, assurez-vous d'avoir installé les dépendances suivantes :

- oCaml
- opam
- gsl
- graphics
- camlimages
- dune

Vous pouvez installer OCaml en utilisant Opam, le gestionnaire de paquets pour OCaml. Pour installer OCamlgsl, vous
pouvez utiliser Opam également :

```bash
opam install ocamlgsl
```

Pour installer la librairie camlimages, vous pouvez utiliser la commande suivante :

```bash
opam install camlimages
```

## Exécution

Pour exécuter le programme, vous pouvez utiliser la commande suivante dans /src :

```bash
dune exec osmium
```

Ou bien dans /src :

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
