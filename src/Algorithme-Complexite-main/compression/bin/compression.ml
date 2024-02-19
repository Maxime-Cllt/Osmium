open Gsl;;

let convert_array_float_to_int array_float =
    Array.map (fun ligne -> Array.map int_of_float ligne) array_float;;

let convert_array_int_to_float array_int =
    Array.map (fun ligne -> Array.map float_of_int ligne) array_int;;

(* Effectue le compression du tableau de taille MxN selon le compression_rate (un pourcentage du rang de la matrice)
Renvoie une matrie MxN de range K, qui est le résultat de la SVD compressée *)
let make_compression array compression_rate verbose =
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
        let matrix = if padding then (pad_matrix (Matrix.of_arrays array) nb_row nb_column) else (Matrix.of_arrays array) in 
        let nb_row = (fst (Matrix.dims matrix)) in
        (nb_row, nb_column, matrix, padding) in
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


    (* Redéfénir taux de compression comme étant le pourcentage de valeur singulière à garder plutôt que le pourcentage de colonnes à garder*)
    let compress_svd arrays_u array_s arrays_v nb_row nb_column compression_rate verbose=
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

        if verbose then (   (* Optionnel pour avoir des informations supplémentaires sur la matrice en console *)
            let sum_all_SV = Array.fold_left (+.) 0. array_s in
            let sum_comp_SV = Array.fold_left (+.) 0. array_s_comp in
            let ratio = sum_comp_SV /. sum_all_SV in
            Printf.printf "La qualitée de reconstruction est de %.4f\n" ratio;
            let non_zero_s = Array.of_list (List.filter (fun x -> x <> 0. ) (Array.to_list array_s)) in
            Printf.printf "Taille de l'image = (%d, %d)\n" nb_row nb_column;
            Printf.printf "Rang de l'image = %d; Rang de la matrice compressée = %d\n" (Array.length non_zero_s) (Array.length (Vectmat.to_arrays vecMat_s_comp));
            print_newline ();
        );

        (vecMat_u_comp, vecMat_s_comp, vecMat_vT_comp, vecMat_inter, vecMat_res) in


    assert(compression_rate <= 1.);
        (*  M        N     MxN/NxN  bool *)
    let (nb_row, nb_column, matrix, padded) = init_var array in
        (*  MxN       N       NxN *)
    let (arrays_u, array_s, arrays_v) = exec_svd matrix in
        (*     MxK          KxK            KxN             MxK           MxN     avec K le rang de la matrice renvoyée, calculé avec le taux de compression*)
    let (vecMat_u_comp, vecMat_s_comp, vecMat_vT_comp, vecMat_inter, vecMat_res) = compress_svd arrays_u array_s arrays_v nb_row nb_column compression_rate verbose in

    Linalg.matmult ~a:vecMat_u_comp ~b:vecMat_s_comp vecMat_inter;
    Linalg.matmult ~a:vecMat_inter ~b:vecMat_vT_comp vecMat_res;

    (*if padded then (Vectmat.to_arrays vecMat_res) (* Pour vérifier que le padding n'a pas d'effet sur la SVD *)*)
    if padded then Array.sub (Vectmat.to_arrays vecMat_res) 0 (Array.length array) (* Retire les lignes qui ont été ajoutées*)
    else Vectmat.to_arrays vecMat_res;;
