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

let decode = json =>
  switch json {
  | JsonUtils.Object(dict) =>
    let issuedAt = JsonUtils.parseTimestamp(dict, "issuedAt", "IssuedCertificate.decode")

    let qrCorner = switch dict->Dict.get("qrCorner") {
    | Some("TopLeft") => #TopLeft
    | Some("TopRight") => #TopRight
    | Some("BottomRight") => #BottomRight
    | Some("BottomLeft") => #BottomLeft
    | Some("Hidden") => #Hidden
    | Some(String(somethingElse)) => {
        Debug.error(
          ~scope="IssuedCertificate.decode",
          "Encountered unknown value for qrCorder: " ++ somethingElse ++ " while decoding props.",
        )
        #Hidden
      }
    | None => #Hidden
    }

    make(
      ~serialNumber=dict->Dict.getUnsafe("serialNumber"),
      ~issuedTo=dict->Dict.getUnsafe("issuedTo"),
      ~profileName=dict->Dict.getUnsafe("profileName"),
      ~courseName=dict->Dict.getUnsafe("courseName"),
      ~imageUrl=dict->Dict.getUnsafe("imageUrl"),
      ~margin=dict->Dict.getUnsafe("margin"),
      ~fontSize=dict->Dict.getUnsafe("fontSize"),
      ~nameOffsetTop=dict->Dict.getUnsafe("nameOffsetTop"),
      ~qrScale=dict->Dict.getUnsafe("qrScale"),
      ~issuedAt,
      ~qrCorner,
    )
  | _ => raise(JsonUtils.DecodeError("Invalid JSON supplied to IssuedCertificate.decode"))
  }
