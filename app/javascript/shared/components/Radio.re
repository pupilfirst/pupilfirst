[%bs.raw {|require("./Radio.css")|}];

let str = React.string;

[@react.component]
let make = (~id, ~label, ~onChange, ~checked=false) => {
  <div>
    <input className="hidden radio-input" id type_="radio" onChange checked />
    <label className="radio-label flex items-center" htmlFor=id>
      <span>
        <svg width="10px" height="8px" viewBox="0 0 12 10">
          <polyline points="1.5 6 4.5 9 10.5 1" />
        </svg>
      </span>
      <span className="text-sm flex-1 font-semibold leading-loose">
        {label |> str}
      </span>
    </label>
  </div>;
};
