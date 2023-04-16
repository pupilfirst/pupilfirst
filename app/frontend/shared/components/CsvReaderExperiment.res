module RowData = {
  type t = StudentsEditor__StudentCSVData.t
}

let complete = (results, file) => {
  Js.log(results)
  Js.log(results["data"][0])
  Js.log(file)
}

module Parser = Papaparse.Make(RowData)

let parseAndShowResults = event => {
  let csvFile = ReactEvent.Form.target(event)["files"][0]
  let config = Parser.config(~header=true, ~complete, ())
  Parser.parseFile(csvFile, config)->ignore
}

@react.component
let make = () => {
  <div> <input type_="file" onChange=parseAndShowResults /> </div>
}
