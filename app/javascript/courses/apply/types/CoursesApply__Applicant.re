type t = {
  email: string,
  token: string,
};

let decode = json =>
  Json.Decode.{
    email: json |> field("email", string),
    token: json |> field("token", string),
  };

let email = t => t.email;

let token = t => t.token;
