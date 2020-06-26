type t = {
  name: string,
  email: string,
  confirmedAt: option(Js.Date.t),
  lastCheckedAt: option(Js.Date.t),
};

let name = t => t.name;
let email = t => t.email;

let decode = json => {
  Json.Decode.{
    name: json |> field("name", string),
    email: json |> field("email", string),
    confirmedAt: json |> optional(field("confirmedAt", DateFns.decodeISO)),
    lastCheckedAt:
      json |> optional(field("lastCheckedAt", DateFns.decodeISO)),
  };
};

let fromJsObject = js => {
  name: js##name,
  email: js##email,
  confirmedAt: js##confirmedAt->Belt.Option.map(DateFns.decodeISO),
  lastCheckedAt: js##lastCheckedAt->Belt.Option.map(DateFns.decodeISO),
};
