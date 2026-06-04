(** Vecteurs 2D immuables utilisés pour les positions et vélocités.

    Tous les vecteurs sont des records non-mutables : chaque opération
    retourne une nouvelle instance, garantissant l'absence d'effets de bord. *)

type vector = { x : float; y : float }

val zero : vector
(** Vecteur nul {{0., 0.}}, utile comme accumulateur initial. *)

val add : vector -> vector -> vector
(** [add v1 v2] retourne la somme composante par composante de [v1] et [v2]. *)

val sub : vector -> vector -> vector
(** [sub v1 v2] retourne la différence [v1 - v2] composante par composante. *)

val scale : float -> vector -> vector
(** [scale k v] multiplie chaque composante de [v] par le scalaire [k]. *)

val norm : vector -> float
(** [norm v] retourne la norme euclidienne de [v], soit [sqrt(x² + y²)]. *)

val normalize : vector -> vector
(** [normalize v] retourne un vecteur unitaire de même direction que [v].
    Retourne [v] inchangé si sa norme est nulle, pour éviter la division par zéro. *)

val limit : float -> vector -> vector
(** [limit max v] retourne [v] si sa norme est inférieure à [max],
    sinon retourne un vecteur de même direction mais de norme exactement [max]. *)

val distance : vector -> vector -> float
(** [distance v1 v2] retourne la distance euclidienne entre les points [v1] et [v2].
    Équivalent à [norm (sub v1 v2)]. *)
