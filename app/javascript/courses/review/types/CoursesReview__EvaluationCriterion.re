type t = {
  id: string,
  name: string,
};

let id = t => t.id;
let name = t => t.name;

let make = (~id, ~name) => {id, name};
