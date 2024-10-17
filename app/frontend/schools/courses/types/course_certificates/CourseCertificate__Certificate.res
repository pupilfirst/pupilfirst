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

module Decode = {
  open Json.Decode

  let qrCorner = string->map(s =>
    switch s {
    | "TopLeft" => #TopLeft
    | "TopRight" => #TopRight
    | "BottomRight" => #BottomRight
    | "BottomLeft" => #BottomLeft
    | "Hidden" => #Hidden
    | somethingElse => {
        Debug.Error(
          "CourseCertificate__Certificate.Decode",
          `Encountered unknown value for qrCorner: ${somethingElse}`,
        )
        #Hidden
      }
    }
  )

  let certificate = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    imageUrl: field.required("imageUrl", string),
    margin: field.required("margin", int),
    fontSize: field.required("fontSize", int),
    nameOffsetTop: field.required("nameOffsetTop", int),
    qrCorner: field.required("qrCorner", qrCorner),
    qrScale: field.required("qrScale", int),
    active: field.required("active", bool),
    createdAt: field.required("createdAt", DateFns.decodeISO),
    updatedAt: field.required("updatedAt", DateFns.decodeISO),
    issuedCertificates: field.required("issuedCertificatesCount", int),
  })
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
