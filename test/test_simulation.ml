(** Tests unitaires pour le module {!Birds_lib.Simulation}. *)

open Birds_lib

let eps = 1e-6
let check_float = Alcotest.(check (float eps))

let mk ~id ~px ~py ~vx ~vy =
  Bird.make ~id ~pos:{ Vector.x = px; y = py } ~vel:{ Vector.x = vx; y = vy }

(** {1 Tests de neighbors} *)

let test_neighbors_excludes_self () =
  let b = mk ~id:0 ~px:0. ~py:0. ~vx:0. ~vy:0. in
  let ns = Simulation.neighbors 100. b [ b ] in
  Alcotest.(check int) "self exclu" 0 (List.length ns)

let test_neighbors_finds_close_birds () =
  let b1 = mk ~id:1 ~px:0. ~py:0. ~vx:0. ~vy:0. in
  let b2 = mk ~id:2 ~px:10. ~py:0. ~vx:0. ~vy:0. in
  let b3 = mk ~id:3 ~px:100. ~py:0. ~vx:0. ~vy:0. in
  let ns = Simulation.neighbors 50. b1 [ b1; b2; b3 ] in
  Alcotest.(check int) "b2 inclus, b3 exclu" 1 (List.length ns);
  Alcotest.(check int) "voisin trouvé = b2" 2 (List.hd ns).id

let test_neighbors_strict_inequality () =
  (* À exactement [radius], le voisin n'est PAS inclus (< strict) *)
  let b1 = mk ~id:1 ~px:0. ~py:0. ~vx:0. ~vy:0. in
  let b2 = mk ~id:2 ~px:50. ~py:0. ~vx:0. ~vy:0. in
  let ns = Simulation.neighbors 50. b1 [ b1; b2 ] in
  Alcotest.(check int) "exactement à radius => exclu" 0 (List.length ns)

(** {1 Tests des règles individuelles} *)

let test_separation_isolated_bird () =
  (* Un oiseau seul : pas de force de séparation *)
  let b = mk ~id:0 ~px:400. ~py:300. ~vx:1. ~vy:0. in
  let f = Simulation.separation b [ b ] in
  check_float "sep isolé.x" 0. f.x;
  check_float "sep isolé.y" 0. f.y

let test_separation_pushes_away () =
  (* Deux oiseaux côte à côte : b1 doit être poussé vers la gauche (loin de b2) *)
  let b1 = mk ~id:1 ~px:100. ~py:100. ~vx:0. ~vy:0. in
  let b2 = mk ~id:2 ~px:110. ~py:100. ~vx:0. ~vy:0. in
  let f = Simulation.separation b1 [ b1; b2 ] in
  Alcotest.(check bool) "séparation pousse vers la gauche (fx < 0)" true (f.x < 0.);
  check_float "fy proche de 0" 0. f.y

let test_alignment_isolated_bird () =
  let b = mk ~id:0 ~px:400. ~py:300. ~vx:1. ~vy:0. in
  let f = Simulation.alignment b [ b ] in
  check_float "ali isolé.x" 0. f.x;
  check_float "ali isolé.y" 0. f.y

let test_alignment_matches_neighbors () =
  (* b1 va vers la droite, b2 va vers le haut : b1 doit être tiré vers le haut *)
  let b1 = mk ~id:1 ~px:100. ~py:100. ~vx:1. ~vy:0. in
  let b2 = mk ~id:2 ~px:120. ~py:100. ~vx:0. ~vy:1. in
  let f = Simulation.alignment b1 [ b1; b2 ] in
  Alcotest.(check bool) "alignement tire vers le haut (fy > 0)" true (f.y > 0.)

let test_cohesion_isolated_bird () =
  let b = mk ~id:0 ~px:400. ~py:300. ~vx:0. ~vy:0. in
  let f = Simulation.cohesion b [ b ] in
  check_float "coh isolé.x" 0. f.x;
  check_float "coh isolé.y" 0. f.y

let test_cohesion_pulls_toward_group () =
  (* b1 en (0,0), groupe à droite : b1 doit être tiré vers la droite *)
  let b1 = mk ~id:1 ~px:0. ~py:0. ~vx:0. ~vy:0. in
  let b2 = mk ~id:2 ~px:30. ~py:0. ~vx:0. ~vy:0. in
  let b3 = mk ~id:3 ~px:40. ~py:0. ~vx:0. ~vy:0. in
  let f = Simulation.cohesion b1 [ b1; b2; b3 ] in
  Alcotest.(check bool) "cohésion tire vers la droite (fx > 0)" true (f.x > 0.)

(** {1 Tests de update et invariants globaux} *)

let test_update_preserves_count () =
  let env = Environment.make ~width:800. ~height:600. in
  Random.init 42;
  let birds = List.init 50 (fun i -> Bird.random_bird ~id:i 800. 600.) in
  let birds' = Simulation.update env birds in
  Alcotest.(check int) "même nombre d'oiseaux" 50 (List.length birds')

let test_update_preserves_ids () =
  let env = Environment.make ~width:800. ~height:600. in
  Random.init 42;
  let birds = List.init 10 (fun i -> Bird.random_bird ~id:i 800. 600.) in
  let birds' = Simulation.update env birds in
  let ids = List.map (fun b -> b.Bird.id) birds' |> List.sort compare in
  let expected = [ 0; 1; 2; 3; 4; 5; 6; 7; 8; 9 ] in
  Alcotest.(check (list int)) "ids conservés" expected ids

let test_update_respects_max_speed () =
  let env = Environment.make ~width:800. ~height:600. in
  Random.init 7;
  let birds = List.init 30 (fun i -> Bird.random_bird ~id:i 800. 600.) in
  let birds' = Simulation.update env birds in
  List.iter
    (fun b ->
      let speed = Vector.norm b.Bird.vel in
      Alcotest.(check bool)
        (Printf.sprintf "vitesse <= max_speed (oiseau %d, v=%f)" b.id speed)
        true
        (speed <= Simulation.max_speed +. 1e-6))
    birds'

let test_update_keeps_birds_in_bounds () =
  let env = Environment.make ~width:800. ~height:600. in
  Random.init 99;
  let birds = List.init 20 (fun i -> Bird.random_bird ~id:i 800. 600.) in
  (* Fait tourner la simulation 10 pas et vérifie qu'aucun oiseau ne sort *)
  let final =
    let rec loop n bs = if n = 0 then bs else loop (n - 1) (Simulation.update env bs) in
    loop 10 birds
  in
  List.iter
    (fun b ->
      Alcotest.(check bool) "x dans [1, 799]" true (b.Bird.pos.x >= 1. && b.pos.x <= 799.);
      Alcotest.(check bool) "y dans [1, 599]" true (b.pos.y >= 1. && b.pos.y <= 599.))
    final

let tests =
  [
    ("neighbors exclut self", `Quick, test_neighbors_excludes_self);
    ("neighbors trouve les proches", `Quick, test_neighbors_finds_close_birds);
    ("neighbors inégalité stricte", `Quick, test_neighbors_strict_inequality);
    ("séparation : oiseau isolé", `Quick, test_separation_isolated_bird);
    ("séparation : pousse loin du voisin", `Quick, test_separation_pushes_away);
    ("alignement : oiseau isolé", `Quick, test_alignment_isolated_bird);
    ("alignement : suit les voisins", `Quick, test_alignment_matches_neighbors);
    ("cohésion : oiseau isolé", `Quick, test_cohesion_isolated_bird);
    ("cohésion : tire vers le groupe", `Quick, test_cohesion_pulls_toward_group);
    ("update : nombre conservé", `Quick, test_update_preserves_count);
    ("update : ids conservés", `Quick, test_update_preserves_ids);
    ("update : vitesse max respectée", `Quick, test_update_respects_max_speed);
    ("update : oiseaux dans la fenêtre", `Quick, test_update_keeps_birds_in_bounds);
  ]
