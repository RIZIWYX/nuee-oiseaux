type bird = {
  id : int;
  pos : Vector.vector;
  vel : Vector.vector;
}

let make ~id ~pos ~vel = { id; pos; vel }

let random_bird ~id width height =
  {
    id;
    pos = Vector.{ x = Random.float width; y = Random.float height };
    vel = Vector.{ x = Random.float 2. -. 1.; y = Random.float 2. -. 1. };
  }

let move b = { b with pos = Vector.add b.pos b.vel }
