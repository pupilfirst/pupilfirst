%bs.raw(`require("./Checkbox.css")`)

@react.component
let make = (~id, ~label, ~onChange, ~checked=false) =>
  <div className="relative">
    <input className="absolute top-1 w-0 h-0 overflow-hidden focus:outline-none checkbox__input" id type_="checkbox" onChange checked />
    <label className="checkbox__label flex items-center" htmlFor=id>
      <div>
        <svg width="11px" height="11px" viewBox="0 0 13 13">
          <polyline points="1.5 6 4.5 9 10.5 1" />
        </svg>
      </div>
      <div className="text-sm flex-1"> {label} </div>
    </label>
  </div>
