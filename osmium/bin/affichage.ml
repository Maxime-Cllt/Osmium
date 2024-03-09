
let assign_value r g b =
  let nb_lignes = Array.length r in
  let nb_colonnes = Array.length r.(0) in
  let image_compresse = Array.make_matrix nb_lignes nb_colonnes 0 in
  for i = 0 to nb_lignes - 1 do
    let ligne_r = r.(i) in
    let ligne_g = g.(i) in
    let ligne_b = b.(i) in
    for j = 0 to nb_colonnes - 1 do
      image_compresse.(i).(j) <- Graphics.rgb ligne_r.(j) ligne_g.(j) ligne_b.(j)
    done
  done;
  image_compresse


(* [get_colors image] retourne un triplet de matrices de taille (n, m) où n est le nombre de lignes et m le nombre de colonnes de l'image.
Chaque matrice contient les valeurs des composantes rouge, verte et bleue de chaque pixel de l'image. *)
let get_colors image =
  let nb_lignes = Array.length image in
  let nb_colonnes = Array.length image.(0) in
  let array_image_red = Array.make_matrix nb_lignes nb_colonnes 0 in
  let array_image_green = Array.make_matrix nb_lignes nb_colonnes 0 in
  let array_image_blue = Array.make_matrix nb_lignes nb_colonnes 0 in

  for i = 0 to nb_lignes - 1 do
    let ligne = image.(i) in
    let row_red = array_image_red.(i) in
    let row_green = array_image_green.(i) in
    let row_blue = array_image_blue.(i) in

    for j = 0 to nb_colonnes - 1 do
      let pixel = ligne.(j) in
      let red = pixel lsr 16 land 0xff in
      let green = pixel lsr 8 land 0xff in
      let blue = pixel land 0xff in

      row_red.(j) <- red;
      row_green.(j) <- green;
      row_blue.(j) <- blue;
    done
  done;
  array_image_red, array_image_green, array_image_blue

