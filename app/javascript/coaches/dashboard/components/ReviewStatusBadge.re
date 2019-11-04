[%bs.raw {|require("./ReviewStatusBadge.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("ReviewStatusBadge");

let containerClass = passed =>
  (
    passed
      ? "review-status-badge__container--verified"
      : "review-status-badge__container--not-accepted"
  )
  ++ " review-status-badge__container p-3";

let make = (~passed, ~notAcceptedIconUrl, ~verifiedIconUrl, _children) => {
  ...component,
  render: _self => {
    let iconUrl = passed ? verifiedIconUrl : notAcceptedIconUrl;
    let result = passed ? "Passed" : "Failed";

    <div className={containerClass(passed)}>
      <div className="review-status-badge__icon-container mx-auto mb-1">
        <img src=iconUrl />
      </div>
      {result |> str}
    </div>;
  },
};
