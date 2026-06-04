(** Rendu graphique de la nuée via la bibliothèque [Graphics].

    La fenêtre doit avoir été ouverte avec [Graphics.open_graph]
    avant tout appel à ces fonctions. *)

val draw_bird : Bird.bird -> unit
(** [draw_bird b] dessine un oiseau à sa position courante :
    - un disque de rayon 3 px pour le corps
    - un segment de longueur proportionnelle à la vélocité (×8)
      indiquant la direction de déplacement.

    Les couleurs sont fixes : bleu foncé pour le corps, bleu clair
    pour le vecteur de direction. *)

val draw : Bird.bird list -> unit
(** [draw birds] efface l'écran puis dessine tous les oiseaux de [birds]
    via [draw_bird]. Doit être suivi de [Graphics.synchronize] dans la
    boucle principale (mode double-buffering). *)
