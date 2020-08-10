type qrCorner = [
  | `Hidden
  | `TopLeft
  | `TopRight
  | `BottomRight
  | `BottomLeft
];

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

let make =
    (
      ~serialNumber,
      ~issuedTo,
      ~issuedAt,
      ~courseName,
      ~imageUrl,
      ~margin,
      ~fontSize,
      ~nameOffsetTop,
      ~qrCorner,
      ~qrScale,
    ) => {
  serialNumber,
  issuedTo,
  issuedAt,
  courseName,
  imageUrl,
  margin,
  fontSize,
  nameOffsetTop,
  qrCorner,
  qrScale,
};

let decode = json =>
  Json.Decode.(
    make(
      ~serialNumber=field("serialNumber", string, json),
      ~issuedTo=field("issuedTo", string, json),
      ~issuedAt=field("issuedAt", DateFns.decodeISO, json),
      ~courseName=field("courseName", string, json),
      ~imageUrl=field("imageUrl", string, json),
      ~margin=field("margin", int, json),
      ~fontSize=field("fontSize", int, json),
      ~nameOffsetTop=field("nameOffsetTop", int, json),
      ~qrCorner=
        optional(field("qrCorner", string), json)
        |> OptionUtils.mapWithDefault(
             corner =>
               switch (corner) {
               | "TopLeft" => `TopLeft
               | "TopRight" => `TopRight
               | "BottomRight" => `BottomRight
               | "BottomLeft" => `BottomLeft
               | "Hidden" => `Hidden
               | somethingElse =>
                 Rollbar.warning(
                   "Encountered unknown value for qrCorder: "
                   ++ somethingElse
                   ++ " while decoding props.",
                 );
                 `Hidden;
               },
             `Hidden,
           ),
      ~qrScale=field("qrScale", int, json),
    )
  );
