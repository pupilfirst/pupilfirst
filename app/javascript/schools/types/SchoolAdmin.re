type t = {
  id: string,
  name: string,
  avatarUrl: string,
  email: string,
};

let name = t => t.name;

let avatarUrl = t => t.avatarUrl;

let id = t => t.id;

let email = t => t.email;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    email: json |> field("email", string),
    name: json |> field("name", string),
    avatarUrl: json |> field("avatarUrl", string),
  };

let create = (id, name, email, avatarUrl) => {id, name, email, avatarUrl};

let update = (admin, admins) =>
  admins |> List.filter(a => a.id != admin.id) |> List.append([admin]);

  let sort = l => {
    l |> List.sort((x, y) =>
      x.name < y.name ? -1 : 1
    );
  };
