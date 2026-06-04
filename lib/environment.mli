(** Environnement de simulation : dimensions de la fenêtre et
    contraintes spatiales appliquées aux oiseaux. *)

type environment = {
  width : float;
  (** Largeur de la fenêtre en pixels. *)
  height : float;
  (** Hauteur de la fenêtre en pixels. *)
}

val margin : float
(** Largeur de la zone marginale (en pixels) dans laquelle la force
    de rappel des bords s'applique. Valeur par défaut : [50.]. *)

val turn_factor : float
(** Amplitude de la force de rappel appliquée dans la zone marginale.
    Valeur par défaut : [0.3]. *)

val make : width:float -> height:float -> environment
(** [make ~width ~height] construit un environnement de simulation. *)

val boundary_force : environment -> Bird.bird -> Vector.vector
(** [boundary_force env b] calcule une force de rappel vers l'intérieur
    de la fenêtre lorsque [b] s'approche d'un bord.

    La force est non nulle uniquement dans la zone marginale de [margin] px :
    - bord gauche/droit : composante x de ±[turn_factor]
    - bord haut/bas    : composante y de ±[turn_factor]

    Cette force doit être ajoutée à l'accélération dans [Simulation.update_bird]
    avant la limitation de vitesse. *)

val clamp : environment -> Bird.bird -> Bird.bird
(** [clamp env b] retourne un oiseau dont la position est contrainte
    à l'intérieur de [\[1, env.width - 1\] × \[1, env.height - 1\]].

    Sert de filet de sécurité après [boundary_force] pour garantir
    qu'aucun oiseau ne sort de la fenêtre graphique. *)
