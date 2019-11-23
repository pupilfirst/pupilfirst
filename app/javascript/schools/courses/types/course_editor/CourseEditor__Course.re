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
  image: option(image),
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

let image = t => t.image;

let imageUrl = image => image.url;
let filename = image => image.filename;

let sort = courses => courses |> List.sort((x, y) => x.id - y.id);

let updateList = (courses, course) => {
  let oldCourses = courses |> List.filter(c => c.id !== course.id);
  oldCourses |> List.rev |> List.append([course]) |> List.rev;
};

let makeImage = (url, filename) => {url, filename};

let makeImageFromJs = data => {
  switch (data) {
  | Some(image) => Some(makeImage(image##url, image##filename))
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
      ~image,
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
  image,
  featured,
};

let replaceImage = (image, t) => {...t, image};

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
    ~image=makeImageFromJs(rawCourse##image),
    ~featured=rawCourse##featured,
  );
};
