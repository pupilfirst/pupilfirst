[@bs.config {jsx: 3}];

let decodeProps = json =>
  Json.Decode.(
    json |> field("schoolName", string),
    json |> field("schoolLogoPath", string),
    json |> field("schoolIconPath", string),
    json |> field("courses", list(SchoolAdminNavbar__Course.decode)),
    json |> field("isCourseAuthor", bool),
    json |> field("reviewPath", nullable(string)) |> Js.Null.toOption,
  );

let (
  schoolName,
  schoolLogoPath,
  schoolIconPath,
  courses,
  isCourseAuthor,
  reviewPath,
) =
  DomUtils.parseJsonAttribute(~id="school-admin-navbar__root", ())
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolAdminNavbar__Root
    schoolName
    schoolLogoPath
    schoolIconPath
    courses
    isCourseAuthor
    reviewPath
  />,
  "school-admin-navbar__root",
);
