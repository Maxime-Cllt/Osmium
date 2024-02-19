let compare_result image image_compresse =
    (* Fonction qui permet de créer une sesion interactive que l'on peut quitter avec la touche 'q' *)
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
    Jpeg.save "../images/image_compresse.jpeg" [] (Images.Rgb24 (Graphic_image.image_of graphe_image_compresse));
    interactive();; (* Création d'une session interactive pour voir les résultats *)

let assign_value r g b =
    let image_compresse = Array.make_matrix (Array.length r) (Array.length r.(0)) (Graphics.rgb 0 0 0) in
    let rec assign_aux i j =
        if (i >= (Array.length r)) then
            image_compresse
        else if (j >= (Array.length r.(0))) then
            assign_aux (i+1) 0
        else (
                image_compresse.(i).(j) <- Graphics.rgb r.(i).(j) g.(i).(j) b.(i).(j);
                assign_aux i (j+1)
        ) in assign_aux 0 0 ;;

let get_colors image =
    let nb_ligne, nb_colonne = (Array.length image), (Array.length image.(0)) in
    let array_image_red = Array.make_matrix nb_ligne nb_colonne 0 in
    let array_image_green = Array.make_matrix nb_ligne nb_colonne 0 in
    let array_image_blue = Array.make_matrix nb_ligne nb_colonne 0 in
    Array.iteri (fun i ligne -> Array.iteri (fun j pixel ->
        array_image_red.(i).(j) <- pixel lsr 16 land 0xff;
        array_image_green.(i).(j) <- pixel lsr 8 land 0xff;
        array_image_blue.(i).(j) <- pixel land 0xff;
    ) ligne) image;
    (array_image_red, array_image_green, array_image_blue);;
