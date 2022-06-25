type t = {
  id: string,
  name: string,
  avatarUrl: option<string>,
  userTags: array<string>,
  email: string,
  title: string,
  affiliation: option<string>,
  issuedCertificates: array<StudentActions__IssuedCertificate.t>,
}

let name = t => t.name

let avatarUrl = t => t.avatarUrl

let userTags = t => t.userTags

let id = t => t.id

let title = t => t.title

let affiliation = t => t.affiliation

let email = t => t.email

let issuedCertificates = t => t.issuedCertificates

let addNewCertificate = (t, certificate) => {
  ...t,
  issuedCertificates: Js.Array.concat(t.issuedCertificates, [certificate]),
}

let updateCertificate = (t, certificate) => {
  ...t,
  issuedCertificates: Js.Array.map(
    ic =>
      StudentActions__IssuedCertificate.id(certificate) == StudentActions__IssuedCertificate.id(ic)
        ? certificate
        : ic,
    t.issuedCertificates,
  ),
}

let hasLiveCertificate = t =>
  Js.Array.find(
    ic => StudentActions__IssuedCertificate.revokedAt(ic)->Belt.Option.isNone,
    t.issuedCertificates,
  )->Belt.Option.isSome

let updateInfo = (~name, ~title, ~affiliation, ~student) => {
  ...student,
  name: name,
  title: title,
  affiliation: affiliation,
}

let make = (
  ~id,
  ~name,
  ~avatarUrl,
  ~userTags,
  ~email,
  ~title,
  ~affiliation,
  ~issuedCertificates,
) => {
  id: id,
  name: name,
  avatarUrl: avatarUrl,
  userTags: userTags,
  email: email,
  title: title,
  affiliation: affiliation,
  issuedCertificates: issuedCertificates,
}

let makeFromJS = studentDetails =>
  make(
    ~id=studentDetails["id"],
    ~name=studentDetails["name"],
    ~avatarUrl=studentDetails["avatarUrl"],
    ~userTags=studentDetails["userTags"],
    ~email=studentDetails["email"],
    ~title=studentDetails["title"],
    ~affiliation=studentDetails["affiliation"],
    ~issuedCertificates=[],
  )

let update = (~name, ~title, ~affiliation, ~student) => {
  ...student,
  name: name,
  title: title,
  affiliation: affiliation,
}

let encode = (teamName, t) => {
  open Json.Encode
  object_(list{
    ("id", t.id |> string),
    ("name", t.name |> string),
    ("team_name", teamName |> string),
    ("email", t.email |> string),
    ("title", t.title |> string),
    ("affiliation", t.affiliation |> OptionUtils.toString |> string),
  })
}
