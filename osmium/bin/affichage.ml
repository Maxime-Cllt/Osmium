
(* [assign_value r g b] prend en argument trois matrices de taille (n, m) où n est le nombre de lignes et m le nombre de colonnes de l'image. *)
let assign_value r g b =
  let image_compresse = Array.make_matrix (Array.length r) (Array.length r.(0)) 0 in
  for i = 0 to Array.length r - 1 do
    for j = 0 to Array.length r.(0) - 1 do
      image_compresse.(i).(j) <- Graphics.rgb r.(i).(j) g.(i).(j) b.(i).(j)
    done
  done;
  image_compresse

(* [get_colors image] retourne un triplet de matrices de taille (n, m) où n est le nombre de lignes et m le nombre de colonnes de l'image.
Chaque matrice contient les valeurs des composantes rouge, verte et bleue de chaque pixel de l'image. *)

let get_colors image =
  let nb_ligne, nb_colonne = Array.length image, Array.length image.(0) in
  let array_image_red = Array.make_matrix nb_ligne nb_colonne 0 in
  let array_image_green = Array.make_matrix nb_ligne nb_colonne 0 in
  let array_image_blue = Array.make_matrix nb_ligne nb_colonne 0 in
  for i = 0 to nb_ligne - 1 do
    for j = 0 to nb_colonne - 1 do
      let pixel = image.(i).(j) in
      array_image_red.(i).(j) <- pixel lsr 16 land 0xff;
      array_image_green.(i).(j) <- pixel lsr 8 land 0xff;
      array_image_blue.(i).(j) <- pixel land 0xff
    done
  done;
  array_image_red, array_image_green, array_image_blue
