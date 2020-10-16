type t = {
  id: string,
  name: string,
  avatarUrl: option(string),
  email: string,
  excludedFromLeaderboard: bool,
  title: string,
  affiliation: option(string),
  issuedCertificates: array(StudentsEditor__IssuedCertificate.t),
};

let name = t => t.name;

let avatarUrl = t => t.avatarUrl;

let id = t => t.id;

let title = t => t.title;

let affiliation = t => t.affiliation;

let email = t => t.email;

let excludedFromLeaderboard = t => t.excludedFromLeaderboard;

let issuedCertificates = t => t.issuedCertificates;

let updateInfo =
    (~name, ~excludedFromLeaderboard, ~title, ~affiliation, ~student) => {
  ...student,
  name,
  excludedFromLeaderboard,
  title,
  affiliation,
};

let make =
    (
      ~id,
      ~name,
      ~avatarUrl,
      ~email,
      ~excludedFromLeaderboard,
      ~title,
      ~affiliation,
      ~issuedCertificates,
    ) => {
  id,
  name,
  avatarUrl,
  email,
  excludedFromLeaderboard,
  title,
  affiliation,
  issuedCertificates,
};

let makeFromJS = studentDetails => {
  make(
    ~id=studentDetails##id,
    ~name=studentDetails##name,
    ~avatarUrl=studentDetails##avatarUrl,
    ~email=studentDetails##email,
    ~excludedFromLeaderboard=studentDetails##excludedFromLeaderboard,
    ~title=studentDetails##title,
    ~affiliation=studentDetails##affiliation,
    ~issuedCertificates=
      studentDetails##issuedCertificates
      |> Js.Array.map(ic => StudentsEditor__IssuedCertificate.makeFromJS(ic)),
  );
};

let update = (~name, ~excludedFromLeaderboard, ~title, ~affiliation, ~student) => {
  {...student, name, excludedFromLeaderboard, title, affiliation};
};

let encode = (teamName, t) =>
  Json.Encode.(
    object_([
      ("id", t.id |> string),
      ("name", t.name |> string),
      ("team_name", teamName |> string),
      ("email", t.email |> string),
      ("excluded_from_leaderboard", t.excludedFromLeaderboard |> bool),
      ("title", t.title |> string),
      ("affiliation", t.affiliation |> OptionUtils.toString |> string),
    ])
  );
