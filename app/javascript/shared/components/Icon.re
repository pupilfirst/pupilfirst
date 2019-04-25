[%bs.raw {|require("./Icon.css")|}];

let plusCircleIcon: string = [%raw "require('../images/add-circle-icon.svg')"];
let deleteIcon: string = [%raw "require('../images/delete-icon.svg')"];
let downIcon: string = [%raw "require('../images/down-arrow-icon.svg')"];
let closeIcon: string = [%raw "require('../images/close-icon.svg')"];
let checkIcon: string = [%raw "require('../images/check-white-icon.svg')"];
let editIcon: string = [%raw "require('../images/edit-icon.svg')"];

type kind =
  | Alert
  | Check
  | Close
  | Delete
  | Down
  | Edit
  | PlusCircle;

let resolveIcon = kind =>
  switch (kind) {
  | Alert => closeIcon
  | Check => checkIcon
  | Close => closeIcon
  | Delete => deleteIcon
  | Down => downIcon
  | Edit => editIcon
  | PlusCircle => plusCircleIcon
  };

let component = ReasonReact.statelessComponent("Icon");

let iconClasses = (size, _inverse, opacity, rotate) => {
  let opacityString = opacity |> string_of_int;
  let classes = "w-" ++ size ++ " opacity-" ++ opacityString;
  rotate ? classes ++ " icon__rotate" : classes;
};

let make =
    (~kind, ~size, ~inverse=false, ~opacity=100, ~rotate=false, _children) => {
  ...component,
  render: _self =>
    <img
      src={resolveIcon(kind)}
      className={iconClasses(size, inverse, opacity, rotate)}
    />,
};