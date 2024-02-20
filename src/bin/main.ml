let image = "../images/femme_carre.jpeg" in (* carrée *)
(*let image = "../images/femme_paysage.jpeg" in (* paysage *)*)
(*let image = "../images/femme_portrait.jpeg" in (* portrait *)*)
(*let image = "../images/homme_carre.jpeg" in (* carrée *)*)
(*let image = "../images/homme_paysage.jpeg" in (* paysage *)*)
(*let image = "../images/homme_portrait.jpeg" in (* portrait *)*)
let taux_compression = 0.1 in
let array_image = Graphic_image.array_of_image (Jpeg.load image []) in

let (array_image_red, array_image_green, array_image_blue) = Affichage.get_colors array_image in
print_newline ();
Printf.printf "Compression matrice rouge\n";
let image_red_compresse = Compression.convert_array_float_to_int
    (Compression.make_compression
        (Compression.convert_array_int_to_float array_image_red) taux_compression true) in
Printf.printf "Compression matrice verte\n";
let image_green_compresse = Compression.convert_array_float_to_int
    (Compression.make_compression
        (Compression.convert_array_int_to_float array_image_green) taux_compression true) in
Printf.printf "Compression matrice bleu\n";
let image_blue_compresse = Compression.convert_array_float_to_int
    (Compression.make_compression
        (Compression.convert_array_int_to_float array_image_blue) taux_compression true) in
let image_compresse = Affichage.assign_value image_red_compresse image_green_compresse image_blue_compresse in

(* Résultat intermédiaire*)
(*
let image_compresse = Compression.convert_array_float_to_int
    (Compression.make_compression
        (Compression.convert_array_int_to_float array_image) taux_compression true) in
*)
Affichage.compare_result image image_compresse;;
