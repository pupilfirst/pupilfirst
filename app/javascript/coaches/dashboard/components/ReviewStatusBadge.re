[%bs.raw {|require("./ReviewStatusBadge.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("ReviewStatusBadge");

let containerClass = reviewResult =>
  (
    switch (reviewResult) {
    | TimelineEvent.Passed => "review-status-badge__container--verified"
    | Failed => "review-status-badge__container--not-accepted"
    }
  )
  ++ " review-status-badge__container";

let make = (~reviewResult, ~notAcceptedIconUrl, ~verifiedIconUrl, _children) => {
  ...component,
  render: _self =>
    <div className=(containerClass(reviewResult))>
      {
        let iconUrl =
          switch (reviewResult) {
          | TimelineEvent.Passed => verifiedIconUrl
          | Failed => notAcceptedIconUrl
          };
        <div className="review-status-badge__icon-container mx-auto mb-1">
          <img src=iconUrl />
        </div>;
      }
      (reviewResult |> TimelineEvent.resultAsString |> str)
    </div>,
};