type t = {
  id: string,
  name: string,
  avatarUrl: option(string),
};

let id = t => t.id;
let name = t => t.name;
let avatarUrl = t => t.avatarUrl;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    avatarUrl: json |> optional(field("avatarUrl", string)),
  };

let findById = (id, proxies) =>
  proxies
  |> ArrayUtils.unsafeFind(
       proxy => proxy.id == id,
       "Unable to find a User with ID " ++ id,
     );

let make = (~id, ~name, ~avatarUrl) => {id, name, avatarUrl};

let makeFromJs = jsObject =>
  make(
    ~id=jsObject##id,
    ~name=jsObject##name,
    ~avatarUrl=jsObject##avatarUrl,
  );
