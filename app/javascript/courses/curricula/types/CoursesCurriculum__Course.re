type t = {
  id: string,
  endsAt: option(Js.Date.t),
  certificateSerialNumber: option(string),
};

let endsAt = t => t.endsAt;

let id = t => t.id;

let certificateSerialNumber = t => t.certificateSerialNumber;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    endsAt:
      (json |> optional(field("endsAt", string)))
      ->Belt.Option.map(DateFns2.parse),
    certificateSerialNumber:
      json |> optional(field("certificateSerialNumber", string)),
  };

let hasEnded = t =>
  t.endsAt->Belt.Option.mapWithDefault(false, DateFns2.isPast);
