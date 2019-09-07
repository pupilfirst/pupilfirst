[@bs.config {jsx: 3}];

open CoursesReview__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("authenticityToken", string),
    json |> field("levels", list(Level.decode)),
    json |> field("submissions", list(Submission.decode)),
    json |> field("courseId", string),
  );

let (authenticityToken, levels, submissions, courseId) =
  DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesReview__Root authenticityToken levels submissions courseId />,
  "react-root",
);
