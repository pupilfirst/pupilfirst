%%raw(`import "./Checkbox.css"`)

let input = (id, onChange, checked, disabled) => {
  <input className="checkbox__input" id type_="checkbox" onChange checked disabled={disabled} />
}

@react.component
let make = (~id, ~onChange, ~checked=false, ~label=?, ~disabled=false) =>
  <div>
    {switch label {
    | Some(element) =>
      <label className="checkbox__label flex items-center ltr:space-x-2" htmlFor=id>
        {input(id, onChange, checked, disabled)} <div className="text-sm flex-1 ms-2"> {element} </div>
      </label>

    | None =>
      <label className="checkbox__label flex items-center space-x-2" htmlFor=id>
        {input(id, onChange, checked, disabled)}
      </label>
    }}
  </div>
