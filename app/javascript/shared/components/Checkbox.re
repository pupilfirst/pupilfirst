[@bs.config {jsx: 3}];
[%bs.raw {|require("./Checkbox.css")|}];

let str = React.string;

[@react.component]
let make = (~id, ~label) => {
  <div>
    <input className="hidden checkbox-input" id type_="checkbox" />
    <label className="checkbox-label" htmlFor=id>
      <span>
        <svg width="12px" height="10px" viewBox="0 0 12 10">
          <polyline points="1.5 6 4.5 9 10.5 1" />
        </svg>
      </span>
      <span className="text-sm"> {label |> str} </span>
    </label>
  </div>;
};
