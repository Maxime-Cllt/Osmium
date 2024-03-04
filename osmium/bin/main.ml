(* let image = "../documentation/images/femme_carre.jpeg" in (* carrée *) *)
 let image = "../documentation/images/gmk.jpeg" in
(*let image = "../documentation/images/femme_portrait.jpeg" in (* portrait *)*)
(*let image = "../documentation/images/homme_carre.jpeg" in (* carrée *)*)
(*let image = "../documentation/images/homme_paysage.jpeg" in (* paysage *)*)
(*let image = "../documentation/images/homme_portrait.jpeg" in (* portrait *)*)
let taux_compression = 0.9 in
let array_image = Graphic_image.array_of_image (Jpeg.load image []) in

let (array_image_red, array_image_green, array_image_blue) = Affichage.get_colors array_image in
print_newline ();
Printf.printf "Compression matrice rouge...\n";
let image_red_compresse = Compression.convert_array_float_to_int
    (Compression.make_compression
        (Compression.convert_array_int_to_float array_image_red) taux_compression true) in
Printf.printf "Compression matrice verte...\n";
let image_green_compresse = Compression.convert_array_float_to_int
    (Compression.make_compression
        (Compression.convert_array_int_to_float array_image_green) taux_compression true) in
Printf.printf "Compression matrice bleu...\n";
let image_blue_compresse = Compression.convert_array_float_to_int
    (Compression.make_compression
        (Compression.convert_array_int_to_float array_image_blue) taux_compression true) in



let image_compresse = Affichage.assign_value image_red_compresse image_green_compresse image_blue_compresse in
(* let process_2d_array arr = *)
(*  Array.iter (fun inner_arr -> Array.iter print_int inner_arr; print_newline ()) arr in *)
Printf.printf "Compression terminée.\n";
Printf.printf "Taille de l'image originale : %d\n" (Array.length array_image);
Printf.printf "Taille de l'image compressée : %d\n" (Array.length image_compresse);
Printf.printf "Taux de compression : %f\n" (float_of_int (Array.length image_compresse) /. float_of_int (Array.length array_image));
print_newline ();
let compare_result image image_compresse =
    (* Fonction qui permet de créer une session interactive que l'on peut quitter avec la touche 'q' *)
    Graphics.open_graph "";
    let rec interactive () =
        let event = Graphics.wait_next_event [Graphics.Key_pressed] in
        if event.key == 'q' then exit 0
        else (print_char event.key; print_newline ()); interactive () in

    (* Voir *)
    let graphe_image_compresse = Graphics.make_image image_compresse in
    let offset_x, offset_y = 50, 100 in
    (*let graphe_image_compresse = Graphics.make_image (Array.map (Array.map (fun pixel -> Graphics.rgb (pixel lsr 16 land 0xff) (pixel lsr 8 land 0xff) (pixel land 0xff))) image_compresse) in (* Création du tablean en l'image graphique avec le RGB, source d'erreur potentielle*)*)
    let array_image = Graphic_image.array_of_image (Jpeg.load image []) in (* Ouverture de l'image de base*)

    Graphics.draw_image (Graphics.make_image array_image) offset_x offset_y; (* Affichage de l'image de base *)
    Graphics.draw_image graphe_image_compresse ((Array.length array_image.(0))+offset_y) offset_y; (* Affichage de l'image compressée*)
    Jpeg.save "../documentation/compresse/image_compresse.jpeg" [] (Images.Rgb24 (Graphic_image.image_of graphe_image_compresse)) in

compare_result image image_compresse;;

(* process_2d_array image_compresse *)
(* let save_2d_array arr filename =
let oc = open_out filename in
  Array.iter (fun inner_arr ->
    Array.iter (fun x ->
      output_string oc (string_of_int x ^ " ")
    ) inner_arr;
    output_string oc "\n"
  ) arr;
  close_out oc in
  save_2d_array image_compresse "test.text"; *)


