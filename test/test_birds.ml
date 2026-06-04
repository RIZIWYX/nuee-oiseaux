(** Point d'entrée des tests unitaires. *)

let () =
  Alcotest.run "Birds"
    [
      ("Vector", Test_vector.tests);
      ("Bird", Test_bird.tests);
      ("Environment", Test_environment.tests);
      ("Simulation", Test_simulation.tests);
    ]
