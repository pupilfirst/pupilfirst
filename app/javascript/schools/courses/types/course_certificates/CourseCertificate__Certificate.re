type qrCorner =
  | Hidden
  | TopLeft
  | TopRight
  | BottomRight
  | BottomLeft;

type id = string;

type t = {
  id,
  imageUrl: string,
  margin: int,
  fontSize: int,
  nameOffsetTop: int,
  qrCorner,
  qrScale: int,
  active: bool,
  createdAt: Js.Date.t,
  updatedAt: Js.Date.t,
};

let id = t => t.id;
let imageUrl = t => t.imageUrl;
let margin = t => t.margin;
let nameOffsetTop = t => t.nameOffsetTop;
let fontSize = t => t.fontSize;
let qrCorner = t => t.qrCorner;
let qrScale = t => t.qrScale;
let active = t => t.active;
let createdAt = t => t.createdAt;
let updatedAt = t => t.updatedAt;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    imageUrl: json |> field("imageUrl", string),
    margin: json |> field("margin", int),
    fontSize: json |> field("fontSize", int),
    nameOffsetTop: json |> field("nameOffsetTop", int),
    qrCorner:
      json
      |> optional(field("qrCorner", string))
      |> OptionUtils.mapWithDefault(
           corner =>
             switch (corner) {
             | "TopLeft" => TopLeft
             | "TopRight" => TopRight
             | "BottomRight" => BottomRight
             | "BottomLeft" => BottomLeft
             | "Hidden" => Hidden
             | somethingElse =>
               Rollbar.warning(
                 "Encountered unknown value for qrCorder: "
                 ++ somethingElse
                 ++ " while decoding props.",
               );
               Hidden;
             },
           Hidden,
         ),
    qrScale: json |> field("qrScale", int),
    active: json |> field("active", bool),
    createdAt: json |> field("createdAt", DateFns.decodeISO),
    updatedAt: json |> field("updatedAt", DateFns.decodeISO),
  };
