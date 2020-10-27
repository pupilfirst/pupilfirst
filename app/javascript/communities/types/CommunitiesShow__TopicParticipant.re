type t = {
  id: string,
  name: string,
  avatarUrl: option(string),
};

let id = t => t.id;
let name = t => t.name;
let avatarUrl = t => t.avatarUrl;

let make = (~id, ~name, ~avatarUrl) => {id, name, avatarUrl};

let makeFromJs = jsObject =>
  make(
    ~id=jsObject##id,
    ~name=jsObject##name,
    ~avatarUrl=jsObject##avatarUrl,
  );
