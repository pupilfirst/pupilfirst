let addIcon: string = [%raw "require('../images/add-circle-icon.svg')"];
let deleteIcon: string = [%raw "require('../images/delete-icon.svg')"];
let downIcon: string = [%raw "require('../images/down-arrow-icon.svg')"];
let closeIcon: string = [%raw "require('../images/close-icon.svg')"];

type kind =
  | Add
  | Alert
  | Close
  | Delete
  | Down;

let resolveIcon = kind =>
  switch (kind) {
  | Add => addIcon
  | Alert => closeIcon
  | Close => closeIcon
  | Delete => deleteIcon
  | Down => downIcon
  };

let component = ReasonReact.statelessComponent("Icon");

let iconClasses = (size, _inverse, opacity) => {
  let sizeString = size |> string_of_int;
  let opacityString = opacity |> string_of_int;
  "h-" ++ sizeString ++ " w-" ++ sizeString ++ " opacity-" ++ opacityString;
};

let make = (~kind, ~size, ~inverse=false, ~opacity=100, _children) => {
  ...component,
  render: _self =>
    <img
      src={resolveIcon(kind)}
      className={iconClasses(size, inverse, opacity)}
    />,
};