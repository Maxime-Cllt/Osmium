try
  let _ = Sys.argv.(1) in
  let _ = Sys.argv.(2) in
  ()
with
| Invalid_argument _ -> Printf.printf "\027[31mErreur lors de la saisie des arguments\027[0m\n"; exit 1
| Failure _ -> Printf.printf "\027[31mErreur lors de la conversion de la chaine de caractère en entier\027[0m\n"; exit 1;;

let start_chrono = Unix.gettimeofday () in (* Temps d'exécution -> départ *)

let image = Sys.argv.(1) in
let taux_compression = float_of_string Sys.argv.(2) in

let file_name = Filename.chop_extension (Filename.basename image) in (* Nom du fichier sans l'extension *)
let type_array_array_image = Graphic_image.array_of_image (Jpeg.load image []) in (* Ouverture de l'image *)
let (array_image_red, array_image_green, array_image_blue) = Osmium.get_array_color type_array_array_image in (* Récupération des 3 matrices de couleurs *)

(* Compression et conversion des matrices de couleurs *)
let image_red_compresse = Osmium.compress_and_convert array_image_red taux_compression in
let image_green_compresse = Osmium.compress_and_convert array_image_green taux_compression in
let image_blue_compresse = Osmium.compress_and_convert array_image_blue taux_compression in

(* Affichage de l'image originale *)
let image_compresse_array_array = Osmium.fusion_color_components image_red_compresse image_green_compresse image_blue_compresse in
Printf.printf "Originale : \027[34m[%dx%d]\027[0m,  Finale : \027[34m[%dx%d]\027[0m\n" (Array.length array_image_red) (Array.length array_image_red.(0)) (Array.length image_compresse_array_array) (Array.length image_compresse_array_array.(0));

let psnr_red = Osmium.psnr array_image_red image_red_compresse 255.0 in
let psnr_green = Osmium.psnr array_image_green image_green_compresse 255.0 in
let psnr_blue = Osmium.psnr array_image_blue image_blue_compresse 255.0 in
let psnr_total = (psnr_red +. psnr_green +. psnr_blue) /. 3.0 in
Printf.printf "PSNR [r,v,b] :  [\027[31m%.2f\027[0m,\027[32m %.2f\027[0m, \027[34m%.2f\027[0m]\027[0m, Total : \027[34m%.2f\027[0m\n" psnr_red psnr_green psnr_blue psnr_total;

(* Sauvegarde de l'image compressé *)
Graphics.open_graph "";
let graphe_image_compresse = Graphics.make_image image_compresse_array_array in
let file_dest = Printf.sprintf "../documentation/compresse/osmium_%s_[psnr=%.2f,tx=%.2f].jpeg" file_name psnr_total taux_compression in
if (Sys.file_exists "../documentation/compresse") = false then Unix.mkdir "../documentation/compresse" 0o777;
Jpeg.save file_dest [] (Images.Rgb24 (Graphic_image.image_of graphe_image_compresse));
Graphics.close_graph ();
Printf.printf "Résultat : \027[31m%d octets\027[0m => \027[32m%d octets\027[0m (-%d o) pour un taux de compression de \027[34m%.2f\027[0m\n" (Unix.stat image).Unix.st_size (Unix.stat file_dest).Unix.st_size ((Unix.stat image).Unix.st_size - (Unix.stat file_dest).Unix.st_size) taux_compression;
Printf.printf "Fichier sauvegardé sous le nom : \027[34m%s\027[0m\n" file_dest;
Printf.printf "Temps d'exécution : \027[34m%.3f\027[0m secondes\n" (Unix.gettimeofday () -. start_chrono)