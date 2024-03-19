 let image = "../documentation/images/gmk166x100.jpeg" in
(* let image = "../documentation/images/ws200x200.jpeg" in *)
(* let image = "../documentation/images/ngannou1000x500.jpg" in *)
(* let image = "../documentation/images/CL1600x1000.jpeg" in *)
(* let image = "../documentation/images/lh2560x1707.jpg" in *)

let file_name = Filename.chop_extension (Filename.basename image) in (* Nom du fichier sans l'extension *)
let taux_compression = 0.1 in

(* Ouverture de l'image *)
let array_image = Graphic_image.array_of_image (Jpeg.load image []) in

(* Récupération des 3 matrices de couleurs *)
let (array_image_red, array_image_green, array_image_blue) = Affichage.get_colors array_image in

(* Compression *)
let compress_and_convert color_array message =
  Printf.printf "Compression de la matrice %s...\n" message;
  let float_array = Compression.convert_array_int_to_float color_array in
  let compressed_array = Compression.make_compression float_array taux_compression in
  Compression.convert_array_float_to_int compressed_array in

(* Compression des 3 matrices de couleurs *)
let image_red_compresse = compress_and_convert array_image_red "rouge" in
let image_green_compresse = compress_and_convert array_image_green "vert" in
let image_blue_compresse = compress_and_convert array_image_blue "bleu" in

(* Affichage de l'image originale *)
let image_compresse = Affichage.assign_value image_red_compresse image_green_compresse image_blue_compresse in
Printf.printf "Compression terminée.\n";
Printf.printf "Taille de l'image originale : %d\n" (Array.length array_image);
Printf.printf "Taille de l'image compressée : %d\n" (Array.length image_compresse);

(* Sauvegarde de l'image compressé *)
Graphics.open_graph "";
let graphe_image_compresse = Graphics.make_image image_compresse in
let file_dest = Printf.sprintf "../documentation/compresse/image_compresse_%s_%.2f.jpeg" file_name taux_compression in
Jpeg.save file_dest [] (Images.Rgb24 (Graphic_image.image_of graphe_image_compresse));
Graphics.close_graph ();