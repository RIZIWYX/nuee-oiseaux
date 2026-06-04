type vector = { x : float; y : float }

let zero = { x = 0.; y = 0. }

let add v1 v2 = { x = v1.x +. v2.x; y = v1.y +. v2.y }

let sub v1 v2 = { x = v1.x -. v2.x; y = v1.y -. v2.y }

let scale k v = { x = k *. v.x; y = k *. v.y }

let norm v = sqrt ((v.x *. v.x) +. (v.y *. v.y))

let normalize v =
  let n = norm v in
  if n = 0. then v else scale (1. /. n) v

let limit max v =
  let n = norm v in
  if n > max then scale (max /. n) v else v

let distance v1 v2 = norm (sub v1 v2)
