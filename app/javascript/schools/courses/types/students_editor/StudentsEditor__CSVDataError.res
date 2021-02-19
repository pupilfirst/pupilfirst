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
  errors: array<errorType>,
}

let rowNumber = t => t.rowNumber

let errors = t => t.errors

let nameError = data => {
  switch StudentsEditor__StudentCSVData.name(data) {
  | None => [Name("empty name")]
  | Some(name) => name == "" ? [Name("empty name")] : []
  }
}

let emailError = data => {
  switch StudentsEditor__StudentCSVData.email(data) {
  | None => [Email("empty email")]
  | Some(email) => EmailUtils.isInvalid(false, email) ? [Email("invalid email")] : []
  }
}

let titleError = data => {
  switch StudentsEditor__StudentCSVData.title(data) {
  | None => []
  | Some(title) => String.length(title) <= 250 ? [] : [Title("title long")]
  }
}

let affiliationError = data => {
  switch StudentsEditor__StudentCSVData.affiliation(data) {
  | None => []
  | Some(affiliation) => String.length(affiliation) <= 250 ? [] : [Affiliation("affiliation long")]
  }
}

let teamNameError = data => {
  switch StudentsEditor__StudentCSVData.teamName(data) {
  | None => []
  | Some(teamName) => String.length(teamName) <= 50 ? [] : [TeamName("team name long")]
  }
}

let tagsError = data => {
  switch StudentsEditor__StudentCSVData.tags(data) {
  | None => []
  | Some(tags) => Js.String.split(",", tags)->Array.length <= 5 ? [] : [Tags("tags more than 5")]
  }
}

let parseError = studentCSVData => {
  studentCSVData |> Js.Array.mapi((data, index) => {
    let errors = ArrayUtils.flattenV2([
      nameError(data),
      emailError(data),
      titleError(data),
      affiliationError(data),
      teamNameError(data),
      tagsError(data),
    ])
    errors |> ArrayUtils.isEmpty ? [] : [{rowNumber: index + 1, errors: errors}]
  }) |> ArrayUtils.flattenV2
}

let hasNameError = t => {
  t.errors |> Js.Array.filter(x =>
    switch x {
    | Name(_) => true
    | _ => false
    }
  ) |> ArrayUtils.isNotEmpty
}

let hasTitleError = t => {
  t.errors |> Js.Array.filter(x =>
    switch x {
    | Title(_) => true
    | _ => false
    }
  ) |> ArrayUtils.isNotEmpty
}

let hasEmailError = t => {
  t.errors |> Js.Array.filter(x =>
    switch x {
    | Email(_) => true
    | _ => false
    }
  ) |> ArrayUtils.isNotEmpty
}

let hasAffiliationError = t => {
  t.errors |> Js.Array.filter(x =>
    switch x {
    | Affiliation(_) => true
    | _ => false
    }
  ) |> ArrayUtils.isNotEmpty
}

let hasTeamNameError = t => {
  t.errors |> Js.Array.filter(x =>
    switch x {
    | TeamName(_) => true
    | _ => false
    }
  ) |> ArrayUtils.isNotEmpty
}

let hasTagsError = t => {
  t.errors |> Js.Array.filter(x =>
    switch x {
    | Tags(_) => true
    | _ => false
    }
  ) |> ArrayUtils.isNotEmpty
}
