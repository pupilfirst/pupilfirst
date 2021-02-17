type field =
  | Name(string)
  | Email(string)
  | Title(string)
  | TeamName(string)
  | Tags(string)
  | Affiliation(string)

type t = {
  rowNumber: int,
  field: field,
}

let nameError = (data, rowNumber) => {
  switch StudentsEditor__StudentCSVData.name(data) {
  | None => [{rowNumber: rowNumber, field: Name("empty name")}]
  | Some(name) => name == "" ? [{rowNumber: rowNumber, field: Name("empty name")}] : []
  }
}

let emailError = (data, rowNumber) => {
  switch StudentsEditor__StudentCSVData.email(data) {
  | None => [{rowNumber: rowNumber, field: Email("empty email")}]
  | Some(email) =>
    EmailUtils.isInvalid(false, email)
      ? [{rowNumber: rowNumber, field: Email("invalid email")}]
      : []
  }
}

let parseError = studentCSVData => {
  studentCSVData
  |> Js.Array.mapi((data, index) =>
    ArrayUtils.flattenV2([nameError(data, index + 1), emailError(data, index + 1)])
  )
  |> ArrayUtils.flattenV2
}
