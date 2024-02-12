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

// Validates the name, title, affiliation, and team name fields
let validateField = (field, allowBlank, maxLength, value) => {
  switch value {
  | None => []
  | Some(value) =>
    StringUtils.lengthBetween(~allowBlank, value, 1, maxLength)
      ? containsInvalidUTF8Characters(value) ? [error(field, InvalidCharacters)] : []
      : [error(field, InvalidFormat)]
  }
}

let nameError = data => validateField(Name, false, 250, StudentsEditor__StudentCSVRow.name(data))

let titleError = data => validateField(Title, true, 250, StudentsEditor__StudentCSVRow.title(data))

let affiliationError = data =>
  validateField(Affiliation, true, 250, StudentsEditor__StudentCSVRow.affiliation(data))

let teamNameError = data =>
  validateField(TeamName, true, 50, StudentsEditor__StudentCSVRow.teamName(data))

let emailAlreadyExists = (email, allEmails) => {
  Js.Array2.filter(allEmails, e => {
    switch e {
    | None => false
    | Some(e) => e == email
    }
  })->Js.Array2.length > 1
}

let emailError = (data, allEmails) => {
  switch StudentsEditor__StudentCSVRow.email(data) {
  | None => [error(Email, InvalidFormat)]
  | Some(email) =>
    EmailUtils.isInvalid(false, email)
      ? [error(Email, InvalidFormat)]
      : containsInvalidUTF8Characters(email)
      ? [error(Email, InvalidCharacters)]
      : emailAlreadyExists(email, allEmails)
      ? [error(Email, InvalidFormat)]
      : []
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

let parseError = studentCSVRows => {
  let allEmails = Js.Array2.map(studentCSVRows, StudentsEditor__StudentCSVRow.email)

  studentCSVRows
  |> Js.Array.mapi((data, index) => {
    let errors = ArrayUtils.flattenV2([
      nameError(data),
      emailError(data, allEmails),
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
