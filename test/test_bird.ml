(** Tests unitaires pour le module {!Birds_lib.Bird}. *)

open Birds_lib

let eps = 1e-9
let check_float = Alcotest.(check (float eps))

let test_make () =
  let b =
    Bird.make ~id:42 ~pos:{ Vector.x = 1.; y = 2. }
      ~vel:{ Vector.x = 0.5; y = -0.5 }
  in
  Alcotest.(check int) "id" 42 b.id;
  check_float "pos.x" 1. b.pos.x;
  check_float "pos.y" 2. b.pos.y;
  check_float "vel.x" 0.5 b.vel.x

let test_move () =
  let b =
    Bird.make ~id:0 ~pos:{ Vector.x = 10.; y = 20. }
      ~vel:{ Vector.x = 1.5; y = -2. }
  in
  let b' = Bird.move b in
  check_float "new pos.x" 11.5 b'.pos.x;
  check_float "new pos.y" 18. b'.pos.y;
  check_float "vel unchanged.x" 1.5 b'.vel.x;
  check_float "vel unchanged.y" (-.2.) b'.vel.y;
  Alcotest.(check int) "id préservé" 0 b'.id

let test_move_is_pure () =
  (* L'oiseau d'origine ne doit pas être modifié (immuabilité). *)
  let b =
    Bird.make ~id:1 ~pos:{ Vector.x = 0.; y = 0. } ~vel:{ Vector.x = 1.; y = 1. }
  in
  let _ = Bird.move b in
  check_float "original.pos.x intact" 0. b.pos.x;
  check_float "original.pos.y intact" 0. b.pos.y

let test_random_bird_in_bounds () =
  Random.init 42;
  let b = Bird.random_bird ~id:0 800. 600. in
  Alcotest.(check bool) "pos.x >= 0" true (b.pos.x >= 0.);
  Alcotest.(check bool) "pos.x < 800" true (b.pos.x < 800.);
  Alcotest.(check bool) "pos.y >= 0" true (b.pos.y >= 0.);
  Alcotest.(check bool) "pos.y < 600" true (b.pos.y < 600.);
  Alcotest.(check bool) "vel.x in [-1,1)" true (b.vel.x >= -1. && b.vel.x < 1.);
  Alcotest.(check bool) "vel.y in [-1,1)" true (b.vel.y >= -1. && b.vel.y < 1.)

let test_random_bird_reproducible_with_seed () =
  Random.init 12345;
  let b1 = Bird.random_bird ~id:0 800. 600. in
  Random.init 12345;
  let b2 = Bird.random_bird ~id:0 800. 600. in
  check_float "même seed => même pos.x" b1.pos.x b2.pos.x;
  check_float "même seed => même vel.y" b1.vel.y b2.vel.y

let tests =
  [
    ("make", `Quick, test_make);
    ("move", `Quick, test_move);
    ("move est pur (n'altère pas l'original)", `Quick, test_move_is_pure);
    ("random_bird dans les bornes", `Quick, test_random_bird_in_bounds);
    ("random_bird reproductible avec seed", `Quick, test_random_bird_reproducible_with_seed);
  ]
