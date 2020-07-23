type t = {
  id,
  createdAt: Js.Date.t,
}
and id = string;

let id = t => t.id;
let createdAt = t => t.createdAt;
