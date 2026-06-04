(** Tests unitaires pour le module {!Birds_lib.Vector}. *)

open Birds_lib

let eps = 1e-9
let check_float = Alcotest.(check (float eps))

(** {1 Tests des opérations arithmétiques} *)

let test_zero () =
  check_float "zero.x" 0. Vector.zero.x;
  check_float "zero.y" 0. Vector.zero.y

let test_add () =
  let v1 = { Vector.x = 1.; y = 2. } in
  let v2 = { Vector.x = 3.; y = 4. } in
  let r = Vector.add v1 v2 in
  check_float "add.x" 4. r.x;
  check_float "add.y" 6. r.y

let test_add_zero_is_identity () =
  let v = { Vector.x = 7.5; y = -2.3 } in
  let r = Vector.add v Vector.zero in
  check_float "add zero x" v.x r.x;
  check_float "add zero y" v.y r.y

let test_sub () =
  let v1 = { Vector.x = 5.; y = 7. } in
  let v2 = { Vector.x = 2.; y = 3. } in
  let r = Vector.sub v1 v2 in
  check_float "sub.x" 3. r.x;
  check_float "sub.y" 4. r.y

let test_scale () =
  let v = { Vector.x = 2.; y = -3. } in
  let r = Vector.scale 2.5 v in
  check_float "scale.x" 5. r.x;
  check_float "scale.y" (-.7.5) r.y

let test_scale_by_zero () =
  let v = { Vector.x = 100.; y = -50. } in
  let r = Vector.scale 0. v in
  check_float "scale 0 x" 0. r.x;
  check_float "scale 0 y" 0. r.y

(** {1 Tests de la norme et de la normalisation} *)

let test_norm_unit_vector () = check_float "norm (1,0)" 1. (Vector.norm { x = 1.; y = 0. })

let test_norm_3_4_5 () =
  check_float "norm (3,4) = 5" 5. (Vector.norm { x = 3.; y = 4. })

let test_norm_zero () = check_float "norm zero" 0. (Vector.norm Vector.zero)

let test_normalize () =
  let v = { Vector.x = 3.; y = 4. } in
  let n = Vector.normalize v in
  check_float "normalize.x" 0.6 n.x;
  check_float "normalize.y" 0.8 n.y;
  check_float "normalize norm = 1" 1. (Vector.norm n)

let test_normalize_zero_is_safe () =
  (* Cas critique : ne doit PAS diviser par zéro *)
  let r = Vector.normalize Vector.zero in
  check_float "normalize zero.x" 0. r.x;
  check_float "normalize zero.y" 0. r.y

(** {1 Tests de la limitation} *)

let test_limit_below_max () =
  let v = { Vector.x = 1.; y = 0. } in
  let r = Vector.limit 5. v in
  check_float "limit below x" 1. r.x;
  check_float "limit below y" 0. r.y

let test_limit_above_max () =
  let v = { Vector.x = 6.; y = 8. } in (* norme = 10 *)
  let r = Vector.limit 5. v in
  check_float "limit norm" 5. (Vector.norm r);
  check_float "limit.x" 3. r.x;
  check_float "limit.y" 4. r.y

(** {1 Tests de la distance} *)

let test_distance_symmetric () =
  let v1 = { Vector.x = 1.; y = 2. } in
  let v2 = { Vector.x = 4.; y = 6. } in
  check_float "distance symétrique" (Vector.distance v1 v2) (Vector.distance v2 v1)

let test_distance_3_4_5 () =
  let v1 = Vector.zero in
  let v2 = { Vector.x = 3.; y = 4. } in
  check_float "distance (0,0)-(3,4) = 5" 5. (Vector.distance v1 v2)

let test_distance_self_is_zero () =
  let v = { Vector.x = 42.; y = -17. } in
  check_float "distance(v,v) = 0" 0. (Vector.distance v v)

let tests =
  [
    ("zero", `Quick, test_zero);
    ("add", `Quick, test_add);
    ("add zero = identité", `Quick, test_add_zero_is_identity);
    ("sub", `Quick, test_sub);
    ("scale", `Quick, test_scale);
    ("scale par 0", `Quick, test_scale_by_zero);
    ("norm vecteur unité", `Quick, test_norm_unit_vector);
    ("norm (3,4) = 5", `Quick, test_norm_3_4_5);
    ("norm zéro", `Quick, test_norm_zero);
    ("normalize", `Quick, test_normalize);
    ("normalize zéro = sûr", `Quick, test_normalize_zero_is_safe);
    ("limit en dessous du max", `Quick, test_limit_below_max);
    ("limit au-dessus du max", `Quick, test_limit_above_max);
    ("distance symétrique", `Quick, test_distance_symmetric);
    ("distance (0,0)-(3,4) = 5", `Quick, test_distance_3_4_5);
    ("distance(v,v) = 0", `Quick, test_distance_self_is_zero);
  ]
