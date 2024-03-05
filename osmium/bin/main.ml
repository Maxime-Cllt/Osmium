 let image = "../documentation/images/gmk100.jpeg" in

let taux_compression = 0.50 in
let array_image = Graphic_image.array_of_image (Jpeg.load image []) in

let (array_image_red, array_image_green, array_image_blue) = Affichage.get_colors array_image in
print_newline ();

(* Compression *)
let compress_and_convert color_array =
  let float_array = Compression.convert_array_int_to_float color_array in
  let compressed_array = Compression.make_compression float_array taux_compression in
  Compression.convert_array_float_to_int compressed_array in

Printf.printf "Compression de la matrice rouge...\n";
let image_red_compresse = compress_and_convert array_image_red in
Printf.printf "Compression de la matrice verte...\n";
let image_green_compresse = compress_and_convert array_image_green in
Printf.printf "Compression de la matrice bleu...\n";
let image_blue_compresse = compress_and_convert array_image_blue in

let image_compresse = Affichage.assign_value image_red_compresse image_green_compresse image_blue_compresse in
Printf.printf "Compression terminée.\n";
Printf.printf "Taille de l'image originale : %d\n" (Array.length array_image);
Printf.printf "Taille de l'image compressée : %d\n" (Array.length image_compresse);
let compare_result image image_compresse =
    Graphics.open_graph "";
    (* Voir *)
    let graphe_image_compresse = Graphics.make_image image_compresse in
    let offset_x, offset_y = 50, 100 in
    let array_image = Graphic_image.array_of_image (Jpeg.load image []) in (* Ouverture de l'image de base*)
    Graphics.draw_image (Graphics.make_image array_image) offset_x offset_y; (* Affichage de l'image de base *)
    Graphics.draw_image graphe_image_compresse ((Array.length array_image.(0))+offset_y) offset_y; (* Affichage de l'image compressée*)
    Jpeg.save "../documentation/compresse/image_compresse.jpeg" [] (Images.Rgb24 (Graphic_image.image_of graphe_image_compresse)) in

compare_result image image_compresse;;