%%raw("import 'react-datepicker/dist/react-datepicker.css'")
%%raw("import './DatePicker.css'")

module JsComponent = {
  @module("react-datepicker") @react.component
  external make: (
    ~id: string=?,
    ~onChange: Js.Nullable.t<Js.Date.t> => unit,
    ~selected: Js.Date.t=?,
    ~wrapperClassName: string,
    ~className: string,
    ~placeholderText: string,
    ~dateFormat: string,
    ~isClearable: bool,
  ) => React.element = "default"
}

@react.component
let make = (~onChange, ~selected=?, ~id=?) =>
  <JsComponent
    wrapperClassName="w-full"
    className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
    placeholderText="YYYY-MM-DD"
    dateFormat="yyyy-MM-dd"
    isClearable=true
    ?id
    onChange={date => onChange(date->Js.Nullable.toOption)}
    ?selected
  />
