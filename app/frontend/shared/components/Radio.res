%%raw(`import "./Radio.css"`)

let str = React.string

@react.component
let make = (~id, ~label, ~onChange, ~checked=false) =>
  <div className="relative">
    <input
      className="w-0 h-0 absolute radio-input focus:outline-none" id type_="radio" onChange checked
    />
    <label className="radio-label flex items-center" htmlFor=id>
      <span>
        <svg className="fill-white" width="14px" height="14px" viewBox="0 0 14 14">
          <circle cx="8" cy="8" r="3" />
        </svg>
      </span>
      <span className="text-sm flex-1 me-3 font-semibold leading-loose"> {label |> str} </span>
    </label>
  </div>
