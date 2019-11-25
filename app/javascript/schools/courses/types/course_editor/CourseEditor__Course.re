type image = {
  url: string,
  filename: string,
};

type t = {
  id: int,
  name: string,
  description: string,
  endsAt: option(Js.Date.t),
  maxGrade: int,
  passGrade: int,
  gradesAndLabels: list(CourseEditor__GradesAndLabels.t),
  enableLeaderboard: bool,
  about: option(string),
  publicSignup: bool,
  thumbnail: option(image),
  cover: option(image),
  featured: bool,
};

let name = t => t.name;

let id = t => t.id;

let endsAt = t => t.endsAt;

let about = t => t.about;

let publicSignup = t => t.publicSignup;

let description = t => t.description;

let maxGrade = t => t.maxGrade;

let passGrade = t => t.passGrade;

let gradesAndLabels = t => t.gradesAndLabels;

let enableLeaderboard = t => t.enableLeaderboard;

let featured = t => t.featured;

let cover = t => t.cover;

let thumbnail = t => t.thumbnail;

let imageUrl = image => image.url;

let filename = image => image.filename;

let sort = courses => courses |> List.sort((x, y) => x.id - y.id);

let updateList = (courses, course) => {
  let oldCourses = courses |> List.filter(c => c.id !== course.id);
  oldCourses |> List.rev |> List.append([course]) |> List.rev;
};

let makeImage = (url, filename) => Some({url, filename});

let makeImageFromJs = data => {
  switch (data) {
  | Some(image) => makeImage(image##url, image##filename)
  | None => None
  };
};

let create =
    (
      ~id,
      ~name,
      ~description,
      ~endsAt,
      ~maxGrade,
      ~passGrade,
      ~gradesAndLabels,
      ~enableLeaderboard,
      ~about,
      ~publicSignup,
      ~cover,
      ~thumbnail,
      ~featured,
    ) => {
  id,
  name,
  description,
  endsAt,
  maxGrade,
  passGrade,
  gradesAndLabels,
  enableLeaderboard,
  about,
  publicSignup,
  cover,
  thumbnail,
  featured,
};

let replaceImages = (cover, thumbnail, t) => {...t, cover, thumbnail};

let makeFromJs = rawCourse => {
  let endsAt =
    switch (rawCourse##endsAt) {
    | Some(endsAt) =>
      Some(endsAt |> Json.Decode.string)
      |> OptionUtils.map(DateFns.parseString)
    | None => None
    };
  let gradesAndLabels =
    rawCourse##gradesAndLabels
    |> Array.map(gradesAndLabel =>
         CourseEditor__GradesAndLabels.create(
           gradesAndLabel##grade,
           gradesAndLabel##label,
         )
       )
    |> Array.to_list;
  create(
    ~id=rawCourse##id |> int_of_string,
    ~name=rawCourse##name,
    ~description=rawCourse##description,
    ~endsAt,
    ~maxGrade=rawCourse##maxGrade,
    ~passGrade=rawCourse##passGrade,
    ~gradesAndLabels,
    ~enableLeaderboard=rawCourse##enableLeaderboard,
    ~about=rawCourse##about,
    ~publicSignup=rawCourse##publicSignup,
    ~thumbnail=makeImageFromJs(rawCourse##thumbnail),
    ~cover=makeImageFromJs(rawCourse##cover),
    ~featured=rawCourse##featured,
  );
};
