type t = {
  id: string,
  name: string,
};

let id = t => t.id;
let name = t => t.name;

let make = (~id, ~name) => {id, name};

let decodeJs = data => {
  data |> Js.Array.map(ec => make(~id=ec##id, ~name=ec##name));
};
