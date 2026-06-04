(lang dune 3.10)

(name birds)
(generate_opam_files true)

(source (uri git+https://github.com/aksil/nuee-oiseaux.git))
(license MIT)
(authors "Aksil")
(maintainers "Aksil")

(package
 (name birds)
 (synopsis "Simulation de nuée d'oiseaux (boids) en OCaml fonctionnel pur")
 (description "Implémentation du modèle boids de Craig Reynolds (1986) en OCaml strictement fonctionnel : pas d'état mutable, pas d'effets de bord non contrôlés, architecture modulaire avec signatures .mli documentées.")
 (depends
  (ocaml (>= 4.14))
  (dune (>= 3.10))
  graphics
  (alcotest :with-test)))
