[@bs.config {jsx: 3}]
let str = React.string;

let handleClick = (setUndoing, event) => {
  setUndoing(_v => true);
  Js.log("Clicked!");
  event |> ReactEvent.Mouse.preventDefault;
};

let buttonContents = undoing =>
  if (undoing) {
    <span>
      <i className="fa fa-spinner fa-pulse mr-2" />
      {"Undoing..." |> str}
    </span>;
  } else {
    <span> <i className="fa fa-undo mr-2" /> {"Undo" |> str} </span>;
  };

[@react.component]
let make = (~undoSubmissionCB, ~targetId) => {
  let (undoing, setUndoing) = React.useState(() => false);
  <button
    disabled=undoing
    className="btn btn-md btn-danger text-uppercase btn-timeline-builder"
    onClick={handleClick(setUndoing)}>
    {buttonContents(undoing)}
  </button>;
};