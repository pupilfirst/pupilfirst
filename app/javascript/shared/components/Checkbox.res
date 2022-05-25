%raw(`require("./Checkbox.css")`)

@react.component
let make = (~id, ~label, ~onChange, ~checked=false, ~disabled=false) =>
  <div>
    <input
      className="hidden checkbox__input" id type_="checkbox" onChange checked disabled={disabled}
    />
    <label className="checkbox__label flex items-center" htmlFor=id>
      <div>
        <svg width="11px" height="11px" viewBox="0 0 13 13">
          <polyline points="1.5 6 4.5 9 10.5 1" />
        </svg>
      </div>
      <div className="text-sm flex-1"> {label} </div>
    </label>
  </div>
