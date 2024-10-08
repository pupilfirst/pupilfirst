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
    switch (
      dict->Dict.get("serialNumber"),
      dict->Dict.get("issuedTo"),
      dict->Dict.get("profileName"),
      dict->Dict.get("courseName"),
      dict->Dict.get("imageUrl"),
      dict->Dict.get("margin"),
      dict->Dict.get("fontSize"),
      dict->Dict.get("nameOffsetTop"),
      dict->Dict.get("qrScale"),
      dict->Dict.get("issuedAt"),
      dict->Dict.get("qrCorner"),
    ) {
    | (
        Some(String(serialNumber)),
        Some(String(issuedTo)),
        Some(String(profileName)),
        Some(String(courseName)),
        Some(String(imageUrl)),
        Some(Number(margin)),
        Some(Number(fontSize)),
        Some(Number(nameOffsetTop)),
        Some(Number(qrScale)),
        Some(String(issuedAtString)),
        Some(String(qrCornerString)),
      ) => {
        let issuedAt = DateFns.parseISO(issuedAtString)

        let qrCorner = switch qrCornerString {
        | "TopLeft" => #TopLeft
        | "TopRight" => #TopRight
        | "BottomRight" => #BottomRight
        | "BottomLeft" => #BottomLeft
        | "Hidden" => #Hidden
        | somethingElse => {
            Debug.error(
              ~scope="IssuedCertificate.decode",
              "Encountered unknown value for qrCorner: " ++
              somethingElse ++ " while decoding props.",
            )
            #Hidden
          }
        }

        make(
          ~serialNumber,
          ~issuedTo,
          ~profileName,
          ~courseName,
          ~imageUrl,
          ~margin,
          ~fontSize,
          ~nameOffsetTop,
          ~qrScale,
          ~issuedAt,
          ~qrCorner,
        )
      }
    | _ => raise(JsonUtils.DecodeError("Failed to decode JSON in IssuedCertificate"))
    }
  }
