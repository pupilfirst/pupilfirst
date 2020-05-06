type qrCorner =
  | Hidden
  | TopLeft
  | TopRight
  | BottomRight
  | BottomLeft;

type t = {
  serialNumber: string,
  issuedTo: string,
  issuedAt: Js.Date.t,
  courseName: string,
  imageUrl: string,
  margin: int,
  fontSize: int,
  nameOffsetTop: int,
  qrCorner,
  qrScale: int,
};

let serialNumber = t => t.serialNumber;
let issuedTo = t => t.issuedTo;
let issuedAt = t => t.issuedAt;
let courseName = t => t.courseName;
let imageUrl = t => t.imageUrl;
let margin = t => t.margin;
let nameOffsetTop = t => t.nameOffsetTop;
let fontSize = t => t.fontSize;
let qrCorner = t => t.qrCorner;
let qrScale = t => t.qrScale;

let decode = json =>
  Json.Decode.{
    serialNumber: json |> field("serialNumber", string),
    issuedTo: json |> field("issuedTo", string),
    issuedAt: json |> field("issuedAt", DateFns.decodeISO),
    courseName: json |> field("courseName", string),
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
  };
