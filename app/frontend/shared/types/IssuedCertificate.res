type qrCorner = [#Hidden | #TopLeft | #TopRight | #BottomRight | #BottomLeft]

type t = {
  serialNumber: string,
  issuedTo: string,
  profileName: string,
  issuedAt: Js.Date.t,
  courseName: string,
  imageUrl: string,
  margin: int,
  fontSize: int,
  nameOffsetTop: int,
  qrCorner: qrCorner,
  qrScale: int,
}

let serialNumber = t => t.serialNumber
let issuedTo = t => t.issuedTo
let profileName = t => t.profileName
let issuedAt = t => t.issuedAt
let courseName = t => t.courseName
let imageUrl = t => t.imageUrl
let margin = t => t.margin
let nameOffsetTop = t => t.nameOffsetTop
let fontSize = t => t.fontSize
let qrCorner = t => t.qrCorner
let qrScale = t => t.qrScale

let make = (
  ~serialNumber,
  ~issuedTo,
  ~profileName,
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
  profileName,
  issuedAt,
  courseName,
  imageUrl,
  margin,
  fontSize,
  nameOffsetTop,
  qrCorner,
  qrScale,
}

module Decode = {
  open Json.Decode

  let decodeQrCorner = string->map(s => {
    switch s {
    | "TopLeft" => #TopLeft
    | "TopRight" => #TopRight
    | "BottomRight" => #BottomRight
    | "BottomLeft" => #BottomLeft
    | "Hidden" => #Hidden
    | somethingElse => {
        Debug.error(
          "IssuedCertificate.decode",
          "Encountered unknown value for qrCorner: " ++ somethingElse ++ " while decoding props.",
        )
        #Hidden
      }
    }
  })

  let issuedCertificate = object(field => {
    serialNumber: field.required("serialNumber", string),
    issuedTo: field.required("issuedTo", string),
    profileName: field.required("profileName", string),
    issuedAt: field.required("issuedAt", DateFns.Decode.iso),
    courseName: field.required("courseName", string),
    imageUrl: field.required("imageUrl", string),
    margin: field.required("margin", int),
    fontSize: field.required("fontSize", int),
    nameOffsetTop: field.required("nameOffsetTop", int),
    qrCorner: field.required("qrCorner", decodeQrCorner),
    qrScale: field.required("qrScale", int),
  })
}
