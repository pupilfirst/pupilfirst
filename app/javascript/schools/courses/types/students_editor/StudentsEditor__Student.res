type t = {
  id: string,
  name: string,
  avatarUrl: option<string>,
  email: string,
  excludedFromLeaderboard: bool,
  title: string,
  affiliation: option<string>,
  issuedCertificates: array<StudentsEditor__IssuedCertificate.t>,
}

let name = t => t.name

let avatarUrl = t => t.avatarUrl

let id = t => t.id

let title = t => t.title

let affiliation = t => t.affiliation

let email = t => t.email

let excludedFromLeaderboard = t => t.excludedFromLeaderboard

let issuedCertificates = t => t.issuedCertificates

let addNewCertificate = (t, certificate) => {
  ...t,
  issuedCertificates: Js.Array.concat(t.issuedCertificates, [certificate]),
}

let updateCertificate = (t, certificate) => {
  ...t,
  issuedCertificates: Js.Array.map(
    ic =>
      StudentsEditor__IssuedCertificate.id(certificate) == StudentsEditor__IssuedCertificate.id(ic)
        ? certificate
        : ic,
    t.issuedCertificates,
  ),
}

let hasLiveCertificate = t =>
  Js.Array.find(
    ic => StudentsEditor__IssuedCertificate.revokedAt(ic)->Belt.Option.isNone,
    t.issuedCertificates,
  )->Belt.Option.isSome

let updateInfo = (~name, ~excludedFromLeaderboard, ~title, ~affiliation, ~student) => {
  ...student,
  name: name,
  excludedFromLeaderboard: excludedFromLeaderboard,
  title: title,
  affiliation: affiliation,
}

let make = (
  ~id,
  ~name,
  ~avatarUrl,
  ~email,
  ~excludedFromLeaderboard,
  ~title,
  ~affiliation,
  ~issuedCertificates,
) => {
  id: id,
  name: name,
  avatarUrl: avatarUrl,
  email: email,
  excludedFromLeaderboard: excludedFromLeaderboard,
  title: title,
  affiliation: affiliation,
  issuedCertificates: issuedCertificates,
}

let makeFromJS = studentDetails =>
  make(
    ~id=studentDetails["id"],
    ~name=studentDetails["name"],
    ~avatarUrl=studentDetails["avatarUrl"],
    ~email=studentDetails["email"],
    ~excludedFromLeaderboard=studentDetails["excludedFromLeaderboard"],
    ~title=studentDetails["title"],
    ~affiliation=studentDetails["affiliation"],
    ~issuedCertificates=studentDetails["issuedCertificates"] |> Js.Array.map(ic =>
      StudentsEditor__IssuedCertificate.makeFromJS(ic)
    ),
  )

let update = (~name, ~excludedFromLeaderboard, ~title, ~affiliation, ~student) => {
  ...student,
  name: name,
  excludedFromLeaderboard: excludedFromLeaderboard,
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
    ("excluded_from_leaderboard", t.excludedFromLeaderboard |> bool),
    ("title", t.title |> string),
    ("affiliation", t.affiliation |> OptionUtils.toString |> string),
  })
}
