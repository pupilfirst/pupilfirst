[%bs.raw {|require("./Radio.css")|}];

let str = React.string;

[@react.component]
let make = (~id, ~label, ~onChange, ~checked=false) => {
  <div>
    <input className="hidden radio-input" id type_="radio" onChange checked />
    <label className="radio-label flex items-center" htmlFor=id>
      <span>
        <svg width="10px" height="10px" viewBox="0 0 12 10">
          <circle cx="50" cy="50" r="40" stroke="black" />
        </svg>
      </span>
      <span className="text-sm flex-1 font-semibold leading-loose">
        {label |> str}
      </span>
    </label>
  </div>;
};
