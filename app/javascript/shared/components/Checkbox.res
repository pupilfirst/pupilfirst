%raw(`require("./Checkbox.css")`)

let inputSVG = () => {
  <div>
    <svg width="11px" height="11px" viewBox="0 0 13 13">
      <polyline points="1.5 6 4.5 9 10.5 1" />
    </svg>
  </div>
}

let hiddenInput = (id, onChange, checked) => {
  <input
    className="absolute top-1 overflow-hidden focus:outline-none checkbox__input"
    id
    type_="checkbox"
    onChange
    checked
  />
}

@react.component
let make = (~id, ~onChange, ~checked=false, ~label=?) =>
  <div className="relative">
    {switch label {
    | Some(element) =>
      [
        {hiddenInput(id, onChange, checked)},
        <label className="checkbox__label flex items-center" htmlFor=id>
          {inputSVG()} <div className="text-sm flex-1"> {element} </div>
        </label>,
      ]->React.array
    | None =>
      <label className="checkbox__label flex items-center" htmlFor=id>
        {inputSVG()} {hiddenInput(id, onChange, checked)}
      </label>
    }}
  </div>
