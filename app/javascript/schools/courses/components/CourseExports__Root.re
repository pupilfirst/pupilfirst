[@bs.config {jsx: 3}];

let str = React.string;

[@react.component]
let make = (course, exports) => {
  course |> Js.log;
  exports |> Js.log;
  <div> {"I'm alive!" |> str} </div>;
};
