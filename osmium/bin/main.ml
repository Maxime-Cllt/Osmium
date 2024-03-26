 let start = Unix.gettimeofday () in (* Temps d'exécution *)

 let image = "../documentation/images/gmk166x100.jpeg" in
(* let image = "../documentation/images/ws200x200.jpeg" in *)
(* let image = "../documentation/images/gg950x500.jpeg" in *)
(* let image = "../documentation/images/gg1000.jpeg" in *)
(* let image = "../documentation/images/CL1600x1000.jpeg" in *)
(* let image = "../documentation/images/lh2560x1707.jpg" in *)

let file_name = Filename.chop_extension (Filename.basename image) in (* Nom du fichier sans l'extension *)
let taux_compression = 0.01 in

(* Ouverture de l'image *)
let type_array_array_image = Graphic_image.array_of_image (Jpeg.load image []) in

(* Récupération des 3 matrices de couleurs *)
let (array_image_red, array_image_green, array_image_blue) = Osmium.get_array_color type_array_array_image in

(* (* Compression des 3 matrices de couleurs en mono thread *) *)
(* let image_red_compresse = Compressing.compress_and_convert_color_matrix array_image_red "rouge" in *)
(* let image_green_compresse = Compressing.compress_and_convert_color_matrix array_image_green "vert" in *)
(* let image_blue_compresse = Compressing.compress_and_convert_color_matrix array_image_blue "bleu" in *)

(* Compression des 3 matrices de couleurs en multi thread *)
let (thread_red, image_red_compresse) = Osmium.compress_color_matrix_with_thread array_image_red taux_compression "rouge" in
let (thread_green, image_green_compresse) = Osmium.compress_color_matrix_with_thread array_image_green taux_compression "vert" in
let (thread_blue, image_blue_compresse) = Osmium.compress_color_matrix_with_thread array_image_blue taux_compression "bleu" in

(* Attente de la fin des threads *)
Thread.join thread_red;
Thread.join thread_green;
Thread.join thread_blue;

(* Récupération des matrices compressées *)
let check_image image_compresse = match image_compresse with
  | Some x -> x
  | None -> failwith "Erreur lors de la compression de la matrice" in

let image_red_compresse = check_image !image_red_compresse in
let image_green_compresse = check_image !image_green_compresse in
let image_blue_compresse = check_image !image_blue_compresse in

(* Affichage de l'image originale *)
let image_compresse_array_array = Osmium.fusion_color_components image_red_compresse image_green_compresse image_blue_compresse in
Printf.printf "Image originale : \027[34m[%dx%d]\027[0m,  Finale : \027[34m[%dx%d]\027[0m\n" (Array.length array_image_red) (Array.length array_image_red.(0)) (Array.length image_compresse_array_array) (Array.length image_compresse_array_array.(0));

let psnr_red = Osmium.psnr array_image_red image_red_compresse 255. in
let psnr_green = Osmium.psnr array_image_green image_green_compresse 255. in
let psnr_blue = Osmium.psnr array_image_blue image_blue_compresse 255. in
let psnr_total = (psnr_red +. psnr_green +. psnr_blue) /. 3. in
Printf.printf "PSNR [r,v,b] :  [\027[31m%.2f\027[0m,\027[32m %.2f\027[0m, \027[34m%.2f\027[0m]\027[0m, Total : \027[34m%.2f\027[0m\n" psnr_red psnr_green psnr_blue psnr_total;

(* Sauvegarde de l'image compressé *)
Graphics.open_graph "";
let graphe_image_compresse = Graphics.make_image image_compresse_array_array in
let file_dest = Printf.sprintf "../documentation/compresse/osmium_%s_[psnr=%.2f,tx=%.2f].jpeg" file_name psnr_total taux_compression in
if (Sys.file_exists "../documentation/compresse") = false then Unix.mkdir "../documentation/compresse" 0o777; (* Création du dossier compresse s'il n'existe pas pour éviter les erreurs *)
Jpeg.save file_dest [] (Images.Rgb24 (Graphic_image.image_of graphe_image_compresse));
Printf.printf "Résultat : \027[31m%d octets\027[0m => \027[32m%d octets\027[0m (-%d o) pour un taux de compression de \027[34m%.2f\027[0m\n" (Unix.stat image).Unix.st_size (Unix.stat file_dest).Unix.st_size ((Unix.stat image).Unix.st_size - (Unix.stat file_dest).Unix.st_size) taux_compression;
Graphics.close_graph ();
Printf.printf "Temps d'exécution : \027[34m%.3f\027[0m secondes\n" (Unix.gettimeofday () -. start)