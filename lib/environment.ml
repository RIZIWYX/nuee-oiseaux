type environment = {
  width : float;
  height : float;
}

let margin = 50.
let turn_factor = 0.3

let make ~width ~height = { width; height }

let boundary_force env (b : Bird.bird) : Vector.vector =
  let fx =
    if b.pos.x < margin then turn_factor
    else if b.pos.x > env.width -. margin then -. turn_factor
    else 0.
  in
  let fy =
    if b.pos.y < margin then turn_factor
    else if b.pos.y > env.height -. margin then -. turn_factor
    else 0.
  in
  { x = fx; y = fy }

let clamp env (b : Bird.bird) : Bird.bird =
  let clamp_f lo hi v = if v < lo then lo else if v > hi then hi else v in
  let x = clamp_f 1. (env.width -. 1.) b.pos.x in
  let y = clamp_f 1. (env.height -. 1.) b.pos.y in
  { b with pos = { x; y } }
