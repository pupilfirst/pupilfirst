type qrCorner = [#Hidden | #TopLeft | #TopRight | #BottomRight | #BottomLeft]

type id = string

type t = {
  id: id,
  name: string,
  imageUrl: string,
  margin: int,
  fontSize: int,
  nameOffsetTop: int,
  qrCorner: qrCorner,
  qrScale: int,
  active: bool,
  createdAt: Js.Date.t,
  updatedAt: Js.Date.t,
  issuedCertificates: int,
}

let id = t => t.id
let name = t => t.name
let imageUrl = t => t.imageUrl
let margin = t => t.margin
let nameOffsetTop = t => t.nameOffsetTop
let fontSize = t => t.fontSize
let qrCorner = t => t.qrCorner
let qrScale = t => t.qrScale
let active = t => t.active
let createdAt = t => t.createdAt
let updatedAt = t => t.updatedAt
let issuedCertificates = t => t.issuedCertificates

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    imageUrl: json |> field("imageUrl", string),
    margin: json |> field("margin", int),
    fontSize: json |> field("fontSize", int),
    nameOffsetTop: json |> field("nameOffsetTop", int),
    qrCorner: json |> optional(field("qrCorner", string)) |> OptionUtils.mapWithDefault(corner =>
      switch corner {
      | "TopLeft" => #TopLeft
      | "TopRight" => #TopRight
      | "BottomRight" => #BottomRight
      | "BottomLeft" => #BottomLeft
      | "Hidden" => #Hidden
      | somethingElse =>
        Rollbar.warning(
          "Encountered unknown value for qrCorder: " ++ (somethingElse ++ " while decoding props."),
        )
        #Hidden
      }
    , #Hidden),
    qrScale: json |> field("qrScale", int),
    active: json |> field("active", bool),
    createdAt: json |> field("createdAt", DateFns.decodeISO),
    updatedAt: json |> field("updatedAt", DateFns.decodeISO),
    issuedCertificates: json |> field("issuedCertificatesCount", int),
  }
}

let update = (t, ~name, ~margin, ~nameOffsetTop, ~fontSize, ~qrCorner, ~qrScale, ~active) => {
  ...t,
  name: name,
  margin: margin,
  nameOffsetTop: nameOffsetTop,
  fontSize: fontSize,
  qrCorner: qrCorner,
  qrScale: qrScale,
  active: active,
  updatedAt: Js.Date.make(),
}

let markInactive = t => {...t, active: false}
