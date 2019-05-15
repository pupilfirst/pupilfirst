[@bs.config {jsx: 3}];
let str = React.string;

[@react.component]
let make = (~authenticityToken) =>
  <div className="border-2">
    <p> {"This is the student course header. " |> str} </p>
    <p>
      {
        "The header has received authenticityToken: "
        ++ authenticityToken
        |> str
      }
    </p>
  </div>;