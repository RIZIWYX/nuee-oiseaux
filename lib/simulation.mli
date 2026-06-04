(** Moteur de simulation : calcul des règles boids et mise à jour
    de la nuée à chaque pas de temps.

    Les trois règles sont appliquées simultanément à partir de l'état
    courant de la liste — chaque oiseau observe ses voisins tels qu'ils
    étaient au début du pas, pas après leur propre mise à jour. *)

(** {1 Paramètres de simulation} *)

val perception_radius : float
(** Rayon de perception (en pixels) pour alignement et cohésion. Défaut : [60.]. *)

val separation_radius : float
(** Rayon dans lequel la séparation s'applique. Défaut : [20.]. *)

val max_speed : float
(** Vitesse maximale d'un oiseau (norme du vecteur vélocité). Défaut : [3.]. *)

val max_force : float
(** Amplitude maximale d'une force de virage. Défaut : [0.05]. *)

val sep_weight : float
val align_weight : float
val cohes_weight : float

(** {1 Règles individuelles (exposées pour les tests)} *)

val neighbors : float -> Bird.bird -> Bird.bird list -> Bird.bird list
(** [neighbors radius b birds] retourne les oiseaux de [birds] (autres que [b])
    situés à moins de [radius] de la position de [b]. La comparaison se fait
    sur l'identifiant [id], pas sur l'égalité physique. *)

val separation : Bird.bird -> Bird.bird list -> Vector.vector
(** Force de séparation appliquée à [b] face à ses voisins proches. *)

val alignment : Bird.bird -> Bird.bird list -> Vector.vector
(** Force d'alignement avec la vélocité moyenne des voisins. *)

val cohesion : Bird.bird -> Bird.bird list -> Vector.vector
(** Force de cohésion vers le centre de masse des voisins. *)

(** {1 Mise à jour de la nuée} *)

val update_bird :
  Environment.environment -> Bird.bird list -> Bird.bird -> Bird.bird
(** [update_bird env birds b] retourne le nouvel état de l'oiseau [b]
    après application des trois règles, des bords, et du clamp. *)

val update : Environment.environment -> Bird.bird list -> Bird.bird list
(** [update env birds] retourne une nouvelle liste d'oiseaux après
    application des règles boids et des contraintes de l'environnement.
    Complexité : O(n²) en nombre d'oiseaux. *)
