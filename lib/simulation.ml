(* Paramètres boids *)
let perception_radius = 60.
let separation_radius = 20.
let max_speed = 3.
let max_force = 0.05

let sep_weight = 1.5
let align_weight = 1.0
let cohes_weight = 1.0

let neighbors radius (b : Bird.bird) (birds : Bird.bird list) : Bird.bird list =
  List.filter
    (fun (other : Bird.bird) ->
      other.id <> b.id && Vector.distance b.pos other.pos < radius)
    birds

let separation (b : Bird.bird) (birds : Bird.bird list) : Vector.vector =
  let close = neighbors separation_radius b birds in
  match close with
  | [] -> Vector.zero
  | close_birds ->
      let steer =
        List.fold_left
          (fun acc (other : Bird.bird) ->
            let diff = Vector.sub b.pos other.pos in
            let d = Vector.norm diff in
            let weighted =
              Vector.scale (1. /. (d +. 0.0001)) (Vector.normalize diff)
            in
            Vector.add acc weighted)
          Vector.zero close_birds
      in
      let n = float_of_int (List.length close_birds) in
      let avg = Vector.scale (1. /. n) steer in
      let desired = Vector.scale max_speed (Vector.normalize avg) in
      Vector.limit max_force (Vector.sub desired b.vel)

let alignment (b : Bird.bird) (birds : Bird.bird list) : Vector.vector =
  let ns = neighbors perception_radius b birds in
  match ns with
  | [] -> Vector.zero
  | neighbor_list ->
      let avg_vel =
        List.fold_left
          (fun acc (other : Bird.bird) -> Vector.add acc other.vel)
          Vector.zero neighbor_list
      in
      let n = float_of_int (List.length neighbor_list) in
      let avg = Vector.scale (1. /. n) avg_vel in
      let desired = Vector.scale max_speed (Vector.normalize avg) in
      Vector.limit max_force (Vector.sub desired b.vel)

let cohesion (b : Bird.bird) (birds : Bird.bird list) : Vector.vector =
  let ns = neighbors perception_radius b birds in
  match ns with
  | [] -> Vector.zero
  | neighbor_list ->
      let avg_pos =
        List.fold_left
          (fun acc (other : Bird.bird) -> Vector.add acc other.pos)
          Vector.zero neighbor_list
      in
      let n = float_of_int (List.length neighbor_list) in
      let center = Vector.scale (1. /. n) avg_pos in
      let desired =
        Vector.scale max_speed (Vector.normalize (Vector.sub center b.pos))
      in
      Vector.limit max_force (Vector.sub desired b.vel)

let update_bird env (birds : Bird.bird list) (b : Bird.bird) : Bird.bird =
  let sep = Vector.scale sep_weight (separation b birds) in
  let ali = Vector.scale align_weight (alignment b birds) in
  let coh = Vector.scale cohes_weight (cohesion b birds) in
  let bound = Environment.boundary_force env b in
  let accel = Vector.add bound (Vector.add sep (Vector.add ali coh)) in
  let new_vel = Vector.limit max_speed (Vector.add b.vel accel) in
  let b' = { b with vel = new_vel } in
  let b' = Bird.move b' in
  Environment.clamp env b'

let update env birds = List.map (update_bird env birds) birds
