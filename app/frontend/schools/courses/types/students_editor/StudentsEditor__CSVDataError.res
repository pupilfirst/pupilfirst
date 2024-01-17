type errorVariants =
  | InvalidFormat
  | InvalidCharacters

type errorType =
  | Name
  | Email
  | Title
  | TeamName
  | Tags
  | Affiliation

type error = {
  errorType: errorType,
  variant: errorVariants,
}

type t = {
  rowNumber: int,
  errors: array<error>,
}

let error = (errorType, variant) => {
  {errorType, variant}
}

let errorType = error => error.errorType
let errorVariant = error => error.variant

let rowNumber = t => t.rowNumber

let errors = t => t.errors

let containsInvalidUTF8Characters = (text: string) => {
  let regexp = Js.Re.fromString("[^\\x00-\\x7F\\u00C0-\\u00FF\\u0600-\\u06FF]+")
  let result = Js.Re.exec_(regexp, text)
  switch result {
  | Some(_) => true
  | None => false
  }
}

let nameError = data => {
  switch StudentsEditor__StudentCSVRow.name(data) {
  | None => []
  | Some(name) =>
    StringUtils.isPresent(name)
      ? containsInvalidUTF8Characters(name) ? [error(Name, InvalidCharacters)] : []
      : [error(Name, InvalidFormat)]
  }
}

let emailError = data => {
  switch StudentsEditor__StudentCSVRow.email(data) {
  | None => [error(Email, InvalidFormat)]
  | Some(email) =>
    EmailUtils.isInvalid(false, email)
      ? [error(Email, InvalidFormat)]
      : containsInvalidUTF8Characters(email)
      ? [error(Email, InvalidCharacters)]
      : []
  }
}

let titleError = data => {
  switch StudentsEditor__StudentCSVRow.title(data) {
  | None => []
  | Some(title) =>
    String.length(title) <= 250
      ? containsInvalidUTF8Characters(title) ? [error(Title, InvalidCharacters)] : []
      : [error(Title, InvalidFormat)]
  }
}

let affiliationError = data => {
  switch StudentsEditor__StudentCSVRow.affiliation(data) {
  | None => []
  | Some(affiliation) =>
    String.length(affiliation) <= 250
      ? containsInvalidUTF8Characters(affiliation) ? [error(Affiliation, InvalidCharacters)] : []
      : [error(Affiliation, InvalidFormat)]
  }
}

let teamNameError = data => {
  switch StudentsEditor__StudentCSVRow.teamName(data) {
  | None => []
  | Some(teamName) =>
    String.length(teamName) <= 50
      ? containsInvalidUTF8Characters(teamName) ? [error(TeamName, InvalidCharacters)] : []
      : [error(TeamName, InvalidFormat)]
  }
}

let tagsError = data => {
  switch StudentsEditor__StudentCSVRow.tags(data) {
  | None => []
  | Some(tagsList) => {
      let tags = Js.String.split(",", tagsList)
      let validTags = tags |> Js.Array.filter(tag => String.length(tag) <= 50)
      tags->Array.length <= 5 && validTags == tags
        ? containsInvalidUTF8Characters(tagsList) ? [error(Tags, InvalidCharacters)] : []
        : [error(Tags, InvalidFormat)]
    }
  }
}

let parseError = studentCSVRow => {
  studentCSVRow
  |> Js.Array.mapi((data, index) => {
    let errors = ArrayUtils.flattenV2([
      nameError(data),
      emailError(data),
      titleError(data),
      affiliationError(data),
      teamNameError(data),
      tagsError(data),
    ])
    errors |> ArrayUtils.isEmpty ? [] : [{rowNumber: index + 2, errors}]
  })
  |> ArrayUtils.flattenV2
}

let hasNameError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x.errorType {
    | Name => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasTitleError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x.errorType {
    | Title => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasEmailError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x.errorType {
    | Email => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasAffiliationError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x.errorType {
    | Affiliation => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasTeamNameError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x.errorType {
    | TeamName => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasTagsError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x.errorType {
    | Tags => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}
