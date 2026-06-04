open Graphics

let draw_bird (b : Bird.bird) =
  let x = int_of_float b.pos.x in
  let y = int_of_float b.pos.y in
  set_color (rgb 30 120 220);
  fill_circle x y 3;
  set_color (rgb 80 160 255);
  moveto x y;
  lineto
    (x + int_of_float (b.vel.x *. 8.))
    (y + int_of_float (b.vel.y *. 8.))

let draw birds =
  set_color black;
  clear_graph ();
  List.iter draw_bird birds
