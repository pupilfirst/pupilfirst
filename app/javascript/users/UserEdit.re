[%bs.raw {|require("./UserEdit.css")|}];

let str = React.string;

[@react.component]
let make = (~userData) => {
  <div> {"User Edit Form" |> str} </div>;
};
