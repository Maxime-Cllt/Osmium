open Gsl;;

(* Convertit un tableau de float en tableau de int *)
let convert_array_float_to_int array_float =
  Array.map (Array.map int_of_float) array_float;;

(* Convertit un tableau de int en tableau de float *)
let convert_array_int_to_float array_int =
  Array.map (Array.map float_of_int) array_int;;

(* Effectue le compression du tableau de taille MxN selon le compression_rate (un pourcentage du rang de la matrice)
Renvoie une matrie MxN de range K, qui est le résultat de la SVD compressée *)
let make_compression array compression_rate =
    (* Ajoute autant de ligne que nécessaire pour avoir une matrice carrée *)
    let pad_matrix matrix nb_row nb_column=
        let array_matrix = Matrix.to_arrays matrix in
        let pad = Array.make_matrix (nb_column - nb_row) nb_column 0. in
        Matrix.of_arrays (Array.append array_matrix pad) in


    (* Initialisation des variables *)
    let init_var array =
        let nb_row, nb_column = ((Array.length array), (Array.length array.(0))) in
        let padding = nb_row < nb_column in
        (* Padding dans le cas où l'image est en mode paysage (nb_ligne<nb_colonne)*)
        let matrix = if padding then pad_matrix (Matrix.of_arrays array) nb_row nb_column else Matrix.of_arrays array in
        let nb_row = fst (Matrix.dims matrix) in
        nb_row, nb_column, matrix, padding in
    (* Effectue la Svd avec le librairie Gsl renvoie (Array(MxN), Array(N), Array(NxN)) *)

    let exec_svd matrix =
        let (_, nb_column) = Matrix.dims matrix in
        let v = Matrix.create ?init:(Some 0.) nb_column nb_column in (* NxN *)
        let s = Vector.create ?init:(Some 0.) nb_column in (* 1xN *)
        let work = Vector.create ?init:(Some 0.) nb_column in (* 1xN *)

        let vecMat_u = Vectmat.mat_convert (`M (Matrix.copy matrix)) in (* MxN *)
        let vecMat_v = Vectmat.mat_convert (`M v) in
        let vecMat_s = Vectmat.vec_convert (`V s) in
        let vecMat_work = Vectmat.vec_convert (`V work) in

        Linalg._SV_decomp ~a:vecMat_u ~v:vecMat_v ~s:vecMat_s ~work:vecMat_work; (* Renvoie la matrice v, pas la transposée*)
        (Vectmat.to_arrays vecMat_u), (Vectmat.to_array vecMat_s), (Vectmat.to_arrays vecMat_v) in


    (* Redéfinir taux de compression comme étant le pourcentage de valeur singulière à garder plutôt que le pourcentage de colonnes à garder*)
    let compress_svd arrays_u array_s arrays_v nb_row nb_column compression_rate =
        let nb_comp_column = int_of_float ((float_of_int (List.length (List.filter (fun x -> x <> 0. ) (Array.to_list array_s)))) *. compression_rate) in

        let vecMat_u_comp = Vectmat.mat_convert (`M (Matrix.of_arrays (Array.map (fun row -> Array.sub row 0 nb_comp_column) arrays_u))) in (* Compression de u en matrice de taille MxK*)

        let array_s_comp = Array.sub array_s 0 nb_comp_column in (* Compression du tableau des valeurs singulières *)
        let vecMat_s_comp_array = Matrix.to_arrays (Matrix.create ?init:(Some 0.) nb_comp_column nb_comp_column) in (* Conversion de s en matrice de taille KxK pour faire un produit matriciel *)
        Array.iteri (fun i valeur_singuliere -> vecMat_s_comp_array.(i).(i) <- valeur_singuliere) array_s_comp; (* assignation de valeur dans la diagonale *)
        let vecMat_s_comp = Vectmat.mat_convert (`M (Matrix.of_arrays vecMat_s_comp_array)) in

        let mat_vT_comp = Matrix.create nb_comp_column nb_column in (* Création de la matrice transposée KxN *)
        let mat_v_comp = Matrix.of_arrays (Array.map (fun row -> Array.sub row 0 nb_comp_column) arrays_v) in (* Compression en matrice de taille NxK *)
        Matrix.transpose mat_vT_comp mat_v_comp;
        let vecMat_vT_comp = Vectmat.mat_convert (`M mat_vT_comp) in

        let vecMat_inter = Vectmat.mat_convert (`M (Matrix.create ?init:(Some 0.) nb_row nb_comp_column)) in (* MxK *)
        let vecMat_res = Vectmat.mat_convert (`M (Matrix.create ?init:(Some 0.) nb_row nb_column)) in (* MxN *)

        let sum_all_SV = Array.fold_left (+.) 0. array_s in
        let sum_comp_SV = Array.fold_left (+.) 0. array_s_comp in
        let ratio = sum_comp_SV /. sum_all_SV in
        Printf.printf "La qualité de reconstruction est de \027[34m%.4f\n\027[0m" ratio;
(*        let non_zero_s = Array.of_list (List.filter (fun x -> x <> 0. ) (Array.to_list array_s)) in *)
        (vecMat_u_comp, vecMat_s_comp, vecMat_vT_comp, vecMat_inter, vecMat_res) in

        (*  M        N     MxN/NxN  bool *)
    let (nb_row, nb_column, matrix, padded) = init_var array in
        (*  MxN       N       NxN *)
    let (arrays_u, array_s, arrays_v) = exec_svd matrix in
        (*     MxK          KxK            KxN             MxK           MxN     avec K le rang de la matrice renvoyée, calculé avec le taux de compression*)
    let (vecMat_u_comp, vecMat_s_comp, vecMat_vT_comp, vecMat_inter, vecMat_res) = compress_svd arrays_u array_s arrays_v nb_row nb_column compression_rate in

    Linalg.matmult ~a:vecMat_u_comp ~b:vecMat_s_comp vecMat_inter; (* MxK *)
    Linalg.matmult ~a:vecMat_inter ~b:vecMat_vT_comp vecMat_res; (* MxN *)

    if padded then Array.sub (Vectmat.to_arrays vecMat_res) 0 (Array.length array) (* Renvoie la matrice compressée sans les lignes ajoutées pour le padding*)
    else Vectmat.to_arrays vecMat_res;; (* Renvoie la matrice compressée*)


(* Compression de la matrice de couleur *)
 let compress_and_convert_color_matrix color_array taux_compression =
  let float_array = convert_array_int_to_float color_array in
      let compressed_array = make_compression float_array taux_compression in
  convert_array_float_to_int compressed_array;;


  (* Compression des 3 matrices de couleurs en utilisant le multi-threading *)
  let compress_color_matrix_with_thread color_array taux_compression =
    let compressed_array_ref = ref None in
    let compress_func () =
      compressed_array_ref := Some (compress_and_convert_color_matrix color_array taux_compression) in
    let thread = Thread.create compress_func () in
    thread, compressed_array_ref;; (* Return :  le thread et la référence de la matrice compressée *)


(* [fusion_color_components r g b] prend en argument trois matrices de taille (n, m) où n est le nombre de lignes et m le nombre de colonnes de l'image.
Chaque matrice contient les valeurs des composantes rouge, verte et bleue de chaque pixel de l'image.
La fonction retourne une matrice de taille (n, m) où n est le nombre de lignes et m le nombre de colonnes de l'image.
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
      combined_image.(i).(j) <- Graphics.rgb row_r.(j) row_g.(j) row_b.(j)
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

