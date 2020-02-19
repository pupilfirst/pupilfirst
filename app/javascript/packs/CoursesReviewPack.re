open CoursesReview__Types;

let decodeProps = json =>
  Json.Decode.(
    json |> field("levels", array(Level.decode)),
    json |> field("pendingSubmissions", array(SubmissionInfo.decode)),
    json |> field("courseId", string),
    json |> field("currentCoach", Coach.decode),
  );

let (levels, pendingSubmissions, courseId, currentCoach) =
  DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesReview__Root levels pendingSubmissions courseId currentCoach />,
  "react-root",
);
