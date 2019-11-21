type t = {
  id: string,
  name: string,
};

let make = (~id, ~name) => {id, name};

let makeFromJs = ecData => {
  ecData |> Js.Array.map(ec => make(~id=ec##id, ~name=ec##name));
};
