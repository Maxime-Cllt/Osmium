open Gsl;;

(* Ajoute autant de ligne que nécessaire pour avoir une matrice carrée quand la matrice est en mode portrait (nb_ligne<nb_colonne) *)
let add_padding_to_matrix matrix nb_row nb_column=
  let array_matrix = Matrix.to_arrays matrix in
  let padding = Array.make_matrix (nb_column - nb_row) nb_column 0. in
  Matrix.of_arrays (Array.append array_matrix padding) ;;

(* Convertit un tableau de float en tableau de int *)
let convert_array_float_to_int array_float =
  Array.map (Array.map int_of_float) array_float;;

(* Convertit un tableau de int en tableau de float *)
let convert_array_int_to_float array_int =
  Array.map (Array.map float_of_int) array_int;;


(* Initialisation des variables pour la SVD *)
let init_var array =
  let nb_row, nb_column = ((Array.length array), (Array.length array.(0))) in
  let padding = nb_row < nb_column in
  (* Padding dans le cas où l'image est en mode paysage (nb_ligne<nb_colonne)*)
  let matrix = if padding then add_padding_to_matrix (Matrix.of_arrays array) nb_row nb_column else Matrix.of_arrays array in
  let nb_row = fst (Matrix.dims matrix) in
  nb_row, nb_column, matrix, padding ;;

 (* Effectue la Svd de la matrice passée en argument et renvoie les matrices U S et V *)
let decomp_SVD matrice =
  let (_, nb_column) = Matrix.dims matrice in
  let v = Matrix.create ?init:(Some 0.) nb_column nb_column in (* NxN *) (* Les vecteurs propres sont stockés dans une matrice *)
  let s = Vector.create ?init:(Some 0.) nb_column in (* 1xN *) (* Les valeurs singulières sont stockées dans un vecteur *)
  let work = Vector.create ?init:(Some 0.) nb_column in (* 1xN *) (* Vecteur de travail *) (* ? init = Some 0. pour initialiser les matrices à 0 *)
  let vecMat_U = Vectmat.mat_convert (`M (Matrix.copy matrice)) in (* MxN *)
  let vecMat_V = Vectmat.mat_convert (`M v) in
  let vecMat_S = Vectmat.vec_convert (`V s) in
  let vecMat_work = Vectmat.vec_convert (`V work) in
  Linalg._SV_decomp ~a:vecMat_U ~v:vecMat_V ~s:vecMat_S ~work:vecMat_work; (* Décomposition SVD, renvoie U, S et V en utilisant GSL *)
  (Vectmat.to_arrays vecMat_U), (Vectmat.to_array vecMat_S), (Vectmat.to_arrays vecMat_V);; (* On convertit des matrices en tableaux *)


 (* Effectue la compression de la matrice en utilisant la SVD compressée *)
let compress_SVD arrays_U array_S arrays_V nb_row nb_column taux_compression =
  let nb_comp_column = int_of_float ((float_of_int (List.length (List.filter (fun x -> x <> 0. ) (Array.to_list array_S)))) *. taux_compression) in

  let vecMat_U_comp = Vectmat.mat_convert (`M (Matrix.of_arrays (Array.map (fun row -> Array.sub row 0 nb_comp_column) arrays_U))) in (* Compression de u en matrice de taille MxK*)
  let array_S_comp = Array.sub array_S 0 nb_comp_column in (* Compression du tableau des valeurs singulières *)
  let vecMat_S_comp_array = Matrix.to_arrays (Matrix.create ?init:(Some 0.) nb_comp_column nb_comp_column) in (* Conversion de s en matrice de taille KxK pour faire un produit matriciel *)
  Array.iteri (fun i valeur_singuliere -> vecMat_S_comp_array.(i).(i) <- valeur_singuliere) array_S_comp; (* assignation de valeur dans la diagonale *)
  let vecMat_S_comp = Vectmat.mat_convert (`M (Matrix.of_arrays vecMat_S_comp_array)) in

  let mat_VT_comp = Matrix.create nb_comp_column nb_column in (* Création de la matrice transposée KxN *)
  let mat_V_comp = Matrix.of_arrays (Array.map (fun row -> Array.sub row 0 nb_comp_column) arrays_V) in (* Compression en matrice de taille NxK *)
  Matrix.transpose mat_VT_comp mat_V_comp;
  let vecMat_VT_comp = Vectmat.mat_convert (`M mat_VT_comp) in

  let vecMat_inter = Vectmat.mat_convert (`M (Matrix.create ?init:(Some 0.) nb_row nb_comp_column)) in (* MxK *)
  let vecMat_res = Vectmat.mat_convert (`M (Matrix.create ?init:(Some 0.) nb_row nb_column)) in (* MxN *)

  let sum_all_SV = Array.fold_left (+.) 0. array_S in (* Somme de toutes les valeurs singulières *)
  let sum_comp_SV = Array.fold_left (+.) 0. array_S_comp in (* Somme des valeurs singulières compressées *)
  Printf.printf "Reconstruction de \027[34m%.4f\n\027[0m" (sum_comp_SV /. sum_all_SV);
  (vecMat_U_comp, vecMat_S_comp, vecMat_VT_comp, vecMat_inter, vecMat_res);;

(* Effectue le compression du tableau de taille MxN selon le compression_rate (un pourcentage du rang de la matrice)
Renvoie une matrie MxN de range K, qui est le résultat de la SVD compressée *)
let make_compression_of_matrice array_of_color taux_compression =

       (*  M        N     MxN/NxN  bool si on a ajouté du padding *)
  let (nb_row, nb_column, matrix, padded) = init_var array_of_color in
        (*  MxN       N       NxN *)
  let (arrays_u, array_s, arrays_v) = decomp_SVD matrix in
      (*     MxK          KxK            KxN             MxK           MxN  avec K le rang de la matrice renvoyée calculé avec le taux de compression*)
  let (vecMat_u_comp, vecMat_s_comp, vecMat_vT_comp, vecMat_inter, vecMat_res) = compress_SVD arrays_u array_s arrays_v nb_row nb_column taux_compression in

  Linalg.matmult ~a:vecMat_u_comp ~b:vecMat_s_comp vecMat_inter; (* MxK *) (* Multiplication de U et S compressé *)
  Linalg.matmult ~a:vecMat_inter ~b:vecMat_vT_comp vecMat_res; (* MxN *) (* Multiplication de la matrice intermédiaire et de V transposé compressé *)

  if padded then Array.sub (Vectmat.to_arrays vecMat_res) 0 (Array.length array_of_color) (* Renvoie la matrice compressée sans les lignes ajoutées pour le padding*)
  else Vectmat.to_arrays vecMat_res;; (* Renvoie la matrice compressée*)


(* [fusion_color_components r g b] prend en argument trois matrices de taille (NM) où n est le nombre de lignes et m le nombre de colonnes de l'image.
Chaque matrice contient les valeurs des composantes rouge, verte et bleue de chaque pixel de l'image.
La fonction retourne une matrice de taille (NM) où n est le nombre de lignes et m le nombre de colonnes de l'image.
Chaque pixel de la matrice retournée contient les valeurs des composantes rouge, verte et bleue de chaque pixel de l'image. *)
let fusion_color_components r g b =
  let nb_rows = Array.length r in
  let nb_columns = Array.length r.(0) in
  let combined_image = Array.make_matrix nb_rows nb_columns 0 in

  for i = 0 to nb_rows - 1 do
    let row_r = r.(i) in
    let row_g = g.(i) in
    let row_b = b.(i) in
    for j = 0 to nb_columns - 1 do
      combined_image.(i).(j) <- Graphics.rgb row_r.(j) row_g.(j) row_b.(j) (* Push des valeurs RGB dans le pixel *)
    done
  done;
  combined_image


(* [get_array_color image] retourne un triplet de matrices de taille (n, m) où n est le nombre de lignes et m le nombre de colonnes de l'image.
Chaque matrice contient les valeurs des composantes rouge, verte et bleue de chaque pixel de l'image. *)
let get_array_color image =
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
      let red = pixel lsr 16 land 0xff in (* On fait un décalage de 16 bits vers la droite pour obtenir la composante rouge *)
      let green = pixel lsr 8 land 0xff in
      let blue = pixel land 0xff in

      row_red.(j) <- red; (* On remplit les matrices avec les valeurs des composantes rouge, verte et bleue de chaque pixel *)
      row_green.(j) <- green;
      row_blue.(j) <- blue;
    done
  done;
  array_image_rouge, array_image_verte, array_image_bleu (* On retourne les trois matrices *)

(* Fonction principale qui prend en argument une matrice de couleur et un taux de compression et renvoie une matrice compressée *)
let compress_and_convert matrice_de_couleur taux_compression =
  let float_array = convert_array_int_to_float matrice_de_couleur in
  let compressed_array = make_compression_of_matrice float_array taux_compression in
  convert_array_float_to_int compressed_array ;;

(* Calcul du PSNR de l'image originale et de l'image compressée *)
let psnr original_image noisy_image max_value =
  let sum_squared_diff = ref 0. in (* Initialisation de la somme des différences au carré *)
  let m = Array.length original_image in (* Nb lignes *)
  let n = Array.length original_image.(0) in (* Nb colonnes *)

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