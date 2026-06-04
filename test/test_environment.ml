(** Tests unitaires pour le module {!Birds_lib.Environment}. *)

open Birds_lib

let eps = 1e-9
let check_float = Alcotest.(check (float eps))

let env = Environment.make ~width:800. ~height:600.

let bird_at pos = Bird.make ~id:0 ~pos ~vel:Vector.zero

(** {1 Tests de boundary_force} *)

let test_no_force_in_center () =
  let b = bird_at { Vector.x = 400.; y = 300. } in
  let f = Environment.boundary_force env b in
  check_float "centre fx = 0" 0. f.x;
  check_float "centre fy = 0" 0. f.y

let test_force_near_left_edge () =
  (* À 10 px du bord gauche, dans la zone marginale de 50 px *)
  let b = bird_at { Vector.x = 10.; y = 300. } in
  let f = Environment.boundary_force env b in
  check_float "bord gauche fx = +turn_factor" Environment.turn_factor f.x;
  check_float "bord gauche fy = 0" 0. f.y

let test_force_near_right_edge () =
  let b = bird_at { Vector.x = 790.; y = 300. } in
  let f = Environment.boundary_force env b in
  check_float "bord droit fx = -turn_factor" (-. Environment.turn_factor) f.x

let test_force_near_top_edge () =
  let b = bird_at { Vector.x = 400.; y = 590. } in
  let f = Environment.boundary_force env b in
  check_float "bord haut fy = -turn_factor" (-. Environment.turn_factor) f.y

let test_force_corner () =
  (* Coin haut-gauche : deux composantes non nulles *)
  let b = bird_at { Vector.x = 5.; y = 595. } in
  let f = Environment.boundary_force env b in
  check_float "coin fx" Environment.turn_factor f.x;
  check_float "coin fy" (-. Environment.turn_factor) f.y

(** {1 Tests de clamp} *)

let test_clamp_inside_is_identity () =
  let b = bird_at { Vector.x = 400.; y = 300. } in
  let b' = Environment.clamp env b in
  check_float "clamp inside x" 400. b'.pos.x;
  check_float "clamp inside y" 300. b'.pos.y

let test_clamp_x_too_low () =
  let b = bird_at { Vector.x = -10.; y = 300. } in
  let b' = Environment.clamp env b in
  check_float "clamp x trop bas -> 1" 1. b'.pos.x

let test_clamp_x_too_high () =
  let b = bird_at { Vector.x = 1000.; y = 300. } in
  let b' = Environment.clamp env b in
  check_float "clamp x trop haut -> width - 1" 799. b'.pos.x

let test_clamp_y_too_low () =
  let b = bird_at { Vector.x = 400.; y = -5. } in
  let b' = Environment.clamp env b in
  check_float "clamp y trop bas -> 1" 1. b'.pos.y

let test_clamp_y_too_high () =
  let b = bird_at { Vector.x = 400.; y = 700. } in
  let b' = Environment.clamp env b in
  check_float "clamp y trop haut -> height - 1" 599. b'.pos.y

let test_clamp_preserves_velocity () =
  let b =
    Bird.make ~id:5 ~pos:{ Vector.x = -10.; y = -10. }
      ~vel:{ Vector.x = 2.; y = 3. }
  in
  let b' = Environment.clamp env b in
  Alcotest.(check int) "id préservé" 5 b'.id;
  check_float "vel.x préservée" 2. b'.vel.x;
  check_float "vel.y préservée" 3. b'.vel.y

let tests =
  [
    ("pas de force au centre", `Quick, test_no_force_in_center);
    ("force près du bord gauche", `Quick, test_force_near_left_edge);
    ("force près du bord droit", `Quick, test_force_near_right_edge);
    ("force près du bord haut", `Quick, test_force_near_top_edge);
    ("force dans un coin", `Quick, test_force_corner);
    ("clamp à l'intérieur = identité", `Quick, test_clamp_inside_is_identity);
    ("clamp x trop bas", `Quick, test_clamp_x_too_low);
    ("clamp x trop haut", `Quick, test_clamp_x_too_high);
    ("clamp y trop bas", `Quick, test_clamp_y_too_low);
    ("clamp y trop haut", `Quick, test_clamp_y_too_high);
    ("clamp préserve la vélocité", `Quick, test_clamp_preserves_velocity);
  ]
