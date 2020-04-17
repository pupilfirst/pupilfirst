type t = {
  id: string,
  endsAt: option(string),
  certificateSerialNumber: option(string),
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    endsAt: json |> field("endsAt", nullable(string)) |> Js.Null.toOption,
    certificateSerialNumber:
      json |> optional(field("certificateSerialNumber", string)),
  };

let endsAt = t => t.endsAt;
let id = t => t.id;
let certificateSerialNumber = t => t.certificateSerialNumber;

let hasEnded = t =>
  switch (t.endsAt) {
  | Some(date) => date |> DateFns.parseString |> DateFns.isPast
  | None => false
  };
