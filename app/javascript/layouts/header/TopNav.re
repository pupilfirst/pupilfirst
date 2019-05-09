[@bs.config {jsx: 3}];

let str = React.string;

[@react.component]
let make = (~name) =>
  <div className="w-full flex mx-auto items-center justify-between border bg-white "> {name |> str} </div>;
