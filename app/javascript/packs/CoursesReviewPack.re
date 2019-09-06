[@bs.config {jsx: 3}];

open CoursesReview__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("authenticityToken", string),
    json |> field("levels", list(Level.decode)),
    json |> field("pendingSubmissions", list(PendingSubmission.decode)),
    json |> field("users", list(User.decode)),
    json |> field("courseId", string),
  );

let (authenticityToken, levels, pendingSubmissions, users, courseId) =
  DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesReview__Root
    authenticityToken
    levels
    pendingSubmissions
    users
    courseId
  />,
  "react-root",
);
