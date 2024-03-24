 let start = Unix.gettimeofday () in (* Temps d'exécution *)

 let image = "../documentation/images/gmk166x100.jpeg" in
(* let image = "../documentation/images/ws200x200.jpeg" in *)
(* let image = "../documentation/images/ngannou1000x500.jpg" in *)
(* let image = "../documentation/images/CL1600x1000.jpeg" in *)
(* let image = "../documentation/images/lh2560x1707.jpg" in *)

let file_name = Filename.chop_extension (Filename.basename image) in (* Nom du fichier sans l'extension *)
let taux_compression = 0.1 in

(* Ouverture de l'image *)
let type_array_array_image = Graphic_image.array_of_image (Jpeg.load image []) in

(* Récupération des 3 matrices de couleurs *)
let (array_image_red, array_image_green, array_image_blue) = Affichage.get_colors type_array_array_image in

(* Compression *)
 let compress_and_convert_color_matrix color_array message =
  Printf.printf "Compression de la matrice %s...\n" message;
  let float_array = Compression.convert_array_int_to_float color_array in
  let compressed_array = Compression.make_compression float_array taux_compression in
  Compression.convert_array_float_to_int compressed_array in

(* (* Compression des 3 matrices de couleurs en mono thread *) *)
(* let image_red_compresse = compress_and_convert_color_matrix array_image_red "rouge" in *)
(* let image_green_compresse = compress_and_convert_color_matrix array_image_green "vert" in *)
(* let image_blue_compresse = compress_and_convert_color_matrix array_image_blue "bleu" in *)

(* Compression des 3 matrices de couleurs en utilisant le multi-threading *)
let compress_color_matrix_with_thread color_array message =
  let compressed_array_ref = ref None in
  let compress_func () =
    compressed_array_ref := Some (compress_and_convert_color_matrix color_array message) in
  let thread = Thread.create compress_func () in
  thread, compressed_array_ref in (* Return :  le thread et la référence de la matrice compressée *)

let (thread_red, image_red_compresse) = compress_color_matrix_with_thread array_image_red "rouge" in
let (thread_green, image_green_compresse) = compress_color_matrix_with_thread array_image_green "vert" in
let (thread_blue, image_blue_compresse) = compress_color_matrix_with_thread array_image_blue "bleu" in

(* Attente de la fin des threads *)
Thread.join thread_red;
Thread.join thread_green;
Thread.join thread_blue;

(* Récupération des matrices compressées *)
let image_red_compresse = match !image_red_compresse with
  | Some x -> x
  | None -> failwith "Erreur lors de la compression de la matrice rouge" in
let image_green_compresse = match !image_green_compresse with
    | Some x -> x
    | None -> failwith "Erreur lors de la compression de la matrice verte" in
let image_blue_compresse = match !image_blue_compresse with
    | Some x -> x
    | None -> failwith "Erreur lors de la compression de la matrice bleue" in

(* Affichage de l'image originale *)
let image_compresse_array_array = Affichage.assign_value image_red_compresse image_green_compresse image_blue_compresse in
Printf.printf "Image originale : \027[34m[%dx%d]\027[0m,  Finale : \027[34m[%dx%d]\027[0m\n" (Array.length array_image_red) (Array.length array_image_red.(0)) (Array.length image_compresse_array_array) (Array.length image_compresse_array_array.(0));

(* Calcul du PSNR de l'image originale et de l'image compressée *)
let psnr original_image noisy_image max_value =
  let sum_squared_diff = ref 0. in
  let m = Array.length original_image in
  let n = Array.length original_image.(0) in
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
    let max_val_sq = max_value *. max_value in
    10. *. log10 (max_val_sq /. mse) in

let psnr_red = psnr array_image_red image_red_compresse 255. in
let psnr_green = psnr array_image_green image_green_compresse 255. in
let psnr_blue = psnr array_image_blue image_blue_compresse 255. in
let psnr_total = (psnr_red +. psnr_green +. psnr_blue) /. 3. in
Printf.printf "PSNR [r,v,b] : \027[34m[%.2f, %.2f, %.2f]\027[0m, Total : \027[34m%.2f\027[0m\n" psnr_red psnr_green psnr_blue psnr_total;

(* Sauvegarde de l'image compressé *)
Graphics.open_graph "";
let graphe_image_compresse = Graphics.make_image image_compresse_array_array in
let file_dest = Printf.sprintf "../documentation/compresse/osmium_%s_[psnr=%.2f,tx=%.1f].jpeg" file_name psnr_total taux_compression in
if (Sys.file_exists "../documentation/compresse") = false then Unix.mkdir "../documentation/compresse" 0o777; (* Création du dossier compresse s'il n'existe pas pour éviter les erreurs *)
Jpeg.save file_dest [] (Images.Rgb24 (Graphic_image.image_of graphe_image_compresse));
Printf.printf "Résultat : \027[31m%d octets\027[0m => \027[32m%d octets\027[0m (-%d o) pour un taux de compression de \027[34m%.1f\027[0m\n" (Unix.stat image).Unix.st_size (Unix.stat file_dest).Unix.st_size ((Unix.stat image).Unix.st_size - (Unix.stat file_dest).Unix.st_size) taux_compression;
Graphics.close_graph ();
Printf.printf "Temps d'exécution : \027[34m%.3f\027[0m secondes\n" (Unix.gettimeofday () -. start)