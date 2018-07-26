[%bs.raw {|require("./ReviewStatusBadge.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("ReviewStatusBadge");

let containerClass = reviewedStatus =>
  (
    switch (reviewedStatus) {
    | TimelineEvent.Verified(_grade) => "review-status-badge__container--verified"
    | NotAccepted => "review-status-badge__container--not-accepted"
    | NeedsImprovement => "review-status-badge__container--needs-improvement"
    }
  )
  ++ " review-status-badge__container";

let faIcon = reviewedStatus =>
  (
    switch (reviewedStatus) {
    | TimelineEvent.Verified(_grade) => "fa-check"
    | NotAccepted => "fa-times"
    | NeedsImprovement => "fa-hourglass-half"
    }
  )
  ++ " fa mr-1";

let make = (~reviewedStatus, _children) => {
  ...component,
  render: _self =>
    <div className=(containerClass(reviewedStatus))>
      <div>
        <i className=(faIcon(reviewedStatus)) />
      </div>
      (
        TimelineEvent.Reviewed(reviewedStatus)
        |> TimelineEvent.statusString
        |> str
      )
      (
        switch (reviewedStatus) {
        | Verified(grade) =>
          <div className="review-status-badge__subtext">
            (
              "Grade: "
              ++ (grade |> TimelineEvent.gradeString |> String.capitalize)
              |> str
            )
          </div>
        | NotAccepted
        | NeedsImprovement => ReasonReact.null
        }
      )
    </div>,
};