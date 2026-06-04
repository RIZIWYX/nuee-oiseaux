open Birds_lib
open Graphics

(** {1 Configuration via arguments de ligne de commande} *)

type config = {
  seed : int option;
  n_birds : int;
  width : float;
  height : float;
}

let default_config =
  { seed = None; n_birds = 200; width = 800.; height = 600. }

let usage =
  "Usage: dune exec bin/main.exe -- [OPTIONS]\n\n\
   Options:\n\
  \  --seed N        Seed du générateur aléatoire (défaut: aléatoire)\n\
  \  --n-birds N     Nombre d'oiseaux dans la nuée (défaut: 200)\n\
  \  --width N       Largeur de la fenêtre en pixels (défaut: 800)\n\
  \  --height N      Hauteur de la fenêtre en pixels (défaut: 600)\n\
  \  -h, --help      Afficher cette aide\n\n\
   Contrôles:\n\
  \  Echap           Quitter la simulation"

let rec parse_args cfg = function
  | [] -> cfg
  | ("-h" | "--help") :: _ ->
      print_endline usage;
      exit 0
  | "--seed" :: n :: rest ->
      parse_args { cfg with seed = Some (int_of_string n) } rest
  | "--n-birds" :: n :: rest ->
      parse_args { cfg with n_birds = int_of_string n } rest
  | "--width" :: n :: rest ->
      parse_args { cfg with width = float_of_string n } rest
  | "--height" :: n :: rest ->
      parse_args { cfg with height = float_of_string n } rest
  | opt :: _ ->
      Printf.eprintf "Option inconnue ou valeur manquante : %s\n\n%s\n" opt usage;
      exit 1

let init_random = function
  | Some seed -> Random.init seed
  | None -> Random.self_init ()

(** {1 Boucle principale} *)

let main () =
  let args = Array.to_list Sys.argv |> List.tl in
  let cfg = parse_args default_config args in
  init_random cfg.seed;
  let geom =
    Printf.sprintf " %dx%d" (int_of_float cfg.width) (int_of_float cfg.height)
  in
  open_graph geom;
  set_window_title "Nuee d'oiseaux";
  auto_synchronize false;

  let env = Environment.make ~width:cfg.width ~height:cfg.height in
  let birds =
    List.init cfg.n_birds (fun i ->
        Bird.random_bird ~id:i cfg.width cfg.height)
  in

  let rec loop birds =
    if key_pressed () && Char.code (read_key ()) = 27 then ()
    else begin
      let birds = Simulation.update env birds in
      Render.draw birds;
      synchronize ();
      Unix.sleepf 0.016;
      loop birds
    end
  in
  loop birds

let () = main ()
