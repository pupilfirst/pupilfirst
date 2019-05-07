[@bs.config {jsx: 3}];

let str = React.string;

[@react.component]
let make = (~name) =>
  <div
    className="mt-4 my-8 max-w-lg w-full flex mx-auto items-center justify-center relative shadow border bg-white rounded-lg">
    {name |> str}
  </div>;