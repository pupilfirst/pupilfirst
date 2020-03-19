let str = React.string;

[@react.component]
let make = (~schoolId) => {
  <div className="border-gray-400" key=schoolId>
    {"Welcome to Payments" |> str}
  </div>;
};
