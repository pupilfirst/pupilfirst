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
    id: field("id", string, json),
    name: field("name", string, json),
    imageUrl: field("imageUrl", string, json),
    margin: field("margin", int, json),
    fontSize: field("fontSize", int, json),
    nameOffsetTop: field("nameOffsetTop", int, json),
    qrCorner: OptionUtils.mapWithDefault(corner =>
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
    , #Hidden, option(field("qrCorner", string), json)),
    qrScale: field("qrScale", int, json),
    active: field("active", bool, json),
    createdAt: field("createdAt", DateFns.decodeISO, json),
    updatedAt: field("updatedAt", DateFns.decodeISO, json),
    issuedCertificates: field("issuedCertificatesCount", int, json),
  }
}

let update = (t, ~name, ~margin, ~nameOffsetTop, ~fontSize, ~qrCorner, ~qrScale, ~active) => {
  ...t,
  name,
  margin,
  nameOffsetTop,
  fontSize,
  qrCorner,
  qrScale,
  active,
  updatedAt: Js.Date.make(),
}

let markInactive = t => {...t, active: false}
