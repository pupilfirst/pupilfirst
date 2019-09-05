[@bs.config {jsx: 3}];

open CoursesReview__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("authenticityToken", string),
    json |> field("levels", list(Level.decode)),
    json |> field("submissions", array(Submission.decode)),
    json |> field("users", list(User.decode)),
  );

let (authenticityToken, levels, submissions, users) =
  DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesReview__Root authenticityToken levels submissions users />,
  "react-root",
);
