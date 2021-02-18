type errorMessage = string

type errorType =
  | Name(errorMessage)
  | Email(errorMessage)
  | Title(errorMessage)
  | TeamName(errorMessage)
  | Tags(errorMessage)
  | Affiliation(errorMessage)

type t = {
  rowNumber: int,
  errorType: errorType,
}

let nameError = (data, rowNumber) => {
  switch StudentsEditor__StudentCSVData.name(data) {
  | None => [{rowNumber: rowNumber, errorType: Name("empty name")}]
  | Some(name) => name == "" ? [{rowNumber: rowNumber, errorType: Name("empty name")}] : []
  }
}

let emailError = (data, rowNumber) => {
  switch StudentsEditor__StudentCSVData.email(data) {
  | None => [{rowNumber: rowNumber, errorType: Email("empty email")}]
  | Some(email) =>
    EmailUtils.isInvalid(false, email)
      ? [{rowNumber: rowNumber, errorType: Email("invalid email")}]
      : []
  }
}

let titleError = (data, rowNumber) => {
  switch StudentsEditor__StudentCSVData.title(data) {
  | None => []
  | Some(title) =>
    String.length(title) <= 250 ? [] : [{rowNumber: rowNumber, errorType: Title("title long")}]
  }
}

let affiliationError = (data, rowNumber) => {
  switch StudentsEditor__StudentCSVData.affiliation(data) {
  | None => []
  | Some(affiliation) =>
    String.length(affiliation) <= 250
      ? []
      : [{rowNumber: rowNumber, errorType: Affiliation("affiliation long")}]
  }
}

let teamNameError = (data, rowNumber) => {
  switch StudentsEditor__StudentCSVData.teamName(data) {
  | None => []
  | Some(teamName) =>
    String.length(teamName) <= 50
      ? []
      : [{rowNumber: rowNumber, errorType: TeamName("team name long")}]
  }
}

let tagsError = (data, rowNumber) => {
  switch StudentsEditor__StudentCSVData.tags(data) {
  | None => []
  | Some(tags) =>
    Js.String.split(",", tags)->Array.length <= 5
      ? []
      : [{rowNumber: rowNumber, errorType: Tags("tags more than 5")}]
  }
}

let parseError = studentCSVData => {
  studentCSVData
  |> Js.Array.mapi((data, index) =>
    ArrayUtils.flattenV2([
      nameError(data, index + 1),
      emailError(data, index + 1),
      titleError(data, index + 1),
      affiliationError(data, index + 1),
      teamNameError(data, index + 1),
      tagsError(data, index + 1),
    ])
  )
  |> ArrayUtils.flattenV2
}
