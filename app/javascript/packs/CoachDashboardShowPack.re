open CoachDashboard__Types;

type props = {
  founders: list(Founder.t),
  teams: list(Team.t),
  timelineEvents: list(TimelineEvent.t),
  morePendingSubmissionsAfter: option(string),
  moreReviewedSubmissionsAfter: option(string),
  authenticityToken: string,
  emptyIconUrl: string,
  notAcceptedIconUrl: string,
  verifiedIconUrl: string,
  gradeLabels: list(GradeLabel.t),
  passGrade: int,
  courseId: int,
  coachName: string,
};

let decodeProps = json =>
  Json.Decode.{
    founders: json |> field("founders", list(Founder.decode)),
    teams: json |> field("teams", list(Team.decode)),
    timelineEvents:
      json |> field("timelineEvents", list(TimelineEvent.decode)),
    morePendingSubmissionsAfter:
      json
      |> field("morePendingSubmissionsAfter", nullable(string))
      |> Js.Null.toOption,
    moreReviewedSubmissionsAfter:
      json
      |> field("moreReviewedSubmissionsAfter", nullable(string))
      |> Js.Null.toOption,
    authenticityToken: json |> field("authenticityToken", string),
    emptyIconUrl: json |> field("emptyIconUrl", string),
    notAcceptedIconUrl: json |> field("notAcceptedIconUrl", string),
    verifiedIconUrl: json |> field("verifiedIconUrl", string),
    gradeLabels: json |> field("gradeLabels", list(GradeLabel.decode)),
    passGrade: json |> field("passGrade", int),
    courseId: json |> field("courseId", int),
    coachName: json |> field("coachName", string),
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="coaches-dashboard",
    ~attribute="data-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoachDashboard
    founders={props.founders}
    teams={props.teams}
    timelineEvents={props.timelineEvents}
    morePendingSubmissionsAfter={props.morePendingSubmissionsAfter}
    moreReviewedSubmissionsAfter={props.moreReviewedSubmissionsAfter}
    authenticityToken={props.authenticityToken}
    emptyIconUrl={props.emptyIconUrl}
    notAcceptedIconUrl={props.notAcceptedIconUrl}
    verifiedIconUrl={props.verifiedIconUrl}
    gradeLabels={props.gradeLabels}
    passGrade={props.passGrade}
    courseId={props.courseId}
    coachName={props.coachName}
  />,
  "coaches-dashboard",
);
