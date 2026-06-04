(** Représentation d'un agent de la nuée.

    Un oiseau est un enregistrement immuable : toute mise à jour
    produit un nouvel oiseau sans modifier l'original. L'identifiant [id]
    permet de distinguer les oiseaux sans s'appuyer sur l'égalité physique. *)

type bird = {
  id : int;
  (** Identifiant unique, attribué à la création. *)
  pos : Vector.vector;
  (** Position courante de l'oiseau dans l'espace 2D. *)
  vel : Vector.vector;
  (** Vélocité courante : direction et vitesse du déplacement. *)
}

val make : id:int -> pos:Vector.vector -> vel:Vector.vector -> bird
(** [make ~id ~pos ~vel] construit un oiseau avec les paramètres donnés. *)

val random_bird : id:int -> float -> float -> bird
(** [random_bird ~id width height] crée un oiseau à position et vélocité
    aléatoires dans le rectangle [0, width] × [0, height].
    Requiert que [Random.self_init] ou [Random.init] ait été appelé au préalable. *)

val move : bird -> bird
(** [move b] retourne un nouvel oiseau dont la position est [b.pos + b.vel].
    La vélocité et l'identifiant restent inchangés. *)
