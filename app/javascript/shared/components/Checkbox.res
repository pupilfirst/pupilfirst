%raw(`require("./Checkbox.css")`)

let input = (id, onChange, checked) => {
  <input className="checkbox__input" id type_="checkbox" onChange checked />
}

@react.component
let make = (~id, ~onChange, ~checked=false, ~label=?) =>
  <div className="relative">
    {switch label {
    | Some(element) =>
      <label className="checkbox__label flex items-center" htmlFor=id>
        {input(id, onChange, checked)} <div className="text-sm flex-1"> {element} </div>
      </label>

    | None =>
      <label className="checkbox__label flex items-center" htmlFor=id>
        {input(id, onChange, checked)}
      </label>
    }}
  </div>
