
(* [assign_value r g b] prend en argument trois matrices de taille (n, m) où n est le nombre de lignes et m le nombre de colonnes de l'image.
Chaque matrice contient les valeurs des composantes rouge, verte et bleue de chaque pixel de l'image.
La fonction retourne une matrice de taille (n, m) où n est le nombre de lignes et m le nombre de colonnes de l'image.
Chaque pixel de la matrice retournée contient les valeurs des composantes rouge, verte et bleue de chaque pixel de l'image. *)
let assign_value r g b =
  let nb_lignes = Array.length r in
  let nb_colonnes = Array.length r.(0) in
  let image_compresse = Array.make_matrix nb_lignes nb_colonnes 0 in (* On crée une matrice de taille (n, m) où n est le nombre de lignes et m le nombre de colonnes de l'image *)
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
  let array_image_rouge = Array.make_matrix nb_lignes nb_colonnes 0 in
  let array_image_verte = Array.make_matrix nb_lignes nb_colonnes 0 in
  let array_image_bleu = Array.make_matrix nb_lignes nb_colonnes 0 in

  for i = 0 to nb_lignes - 1 do (* On parcourt chaque ligne de l'image *)
    let ligne = image.(i) in
    let row_red = array_image_rouge.(i) in
    let row_green = array_image_verte.(i) in
    let row_blue = array_image_bleu.(i) in

    for j = 0 to nb_colonnes - 1 do (* On parcourt chaque pixel de la ligne *)
      let pixel = ligne.(j) in
      let red = pixel lsr 16 land 0xff in (* lsr = logical shift right, land = logical and, 0xff = 255 *)
      let green = pixel lsr 8 land 0xff in
      let blue = pixel land 0xff in (* land = logical and, 0xff = 255 *)

      row_red.(j) <- red; (* On remplit les matrices avec les valeurs des composantes rouge, verte et bleue de chaque pixel *)
      row_green.(j) <- green;
      row_blue.(j) <- blue;
    done
  done;
  array_image_rouge, array_image_verte, array_image_bleu (* On retourne les trois matrices *)


(* Calcul du PSNR de l'image originale et de l'image compressée *)
let psnr original_image noisy_image max_value =
  let sum_squared_diff = ref 0. in (* Initialisation de la somme des différences au carré *)
  let m = Array.length original_image in (* Nombre de lignes *)
  let n = Array.length original_image.(0) in (* Nombre de colonnes *)
  for i = 0 to m - 1 do
    for j = 0 to n - 1 do
      let diff = float_of_int (original_image.(i).(j) - noisy_image.(i).(j)) in (* Différence entre les 2 images *)
      sum_squared_diff := !sum_squared_diff +. (diff *. diff)  (* Somme des différences au carré *)
    done;
  done;
  let mse = !sum_squared_diff /. (float_of_int (m * n)) in (* Moyenne des erreurs au carré *)
  if mse = 0. then
    infinity (* Si mse = 0, PSNR est infini *)
  else
    let max_val_sq = max_value *. max_value in (* max^2 *)
    10. *. log10 (max_val_sq /. mse);; (* PSNR = 10 * log10(max^2 / mse) *)

