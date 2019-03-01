type t = {avatarUrl: string};

let avatarUrl = t => t.avatarUrl;

let decode = json => Json.Decode.{avatarUrl: json |> field("avatarUrl", string)};
