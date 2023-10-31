type errorType =
  | Name
  | InvalidName
  | Email
  | InvalidEmail
  | Title
  | InvalidTitle
  | TeamName
  | InvalidTeamName
  | Tags
  | InvalidTags
  | Affiliation
  | InvalidAffiliation

type t = {
  rowNumber: int,
  errors: array<errorType>,
}

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
    StringUtils.isPresent(name) ? containsInvalidUTF8Characters(name) ? [InvalidName] : [] : [Name]
  }
}

let emailError = data => {
  switch StudentsEditor__StudentCSVRow.email(data) {
  | None => [Email]
  | Some(email) =>
    EmailUtils.isInvalid(false, email)
      ? [Email]
      : containsInvalidUTF8Characters(email)
      ? [InvalidEmail]
      : []
  }
}

let titleError = data => {
  switch StudentsEditor__StudentCSVRow.title(data) {
  | None => []
  | Some(title) =>
    String.length(title) <= 250
      ? containsInvalidUTF8Characters(title) ? [InvalidTitle] : []
      : [Title]
  }
}

let affiliationError = data => {
  switch StudentsEditor__StudentCSVRow.affiliation(data) {
  | None => []
  | Some(affiliation) =>
    String.length(affiliation) <= 250
      ? containsInvalidUTF8Characters(affiliation) ? [InvalidAffiliation] : []
      : [Affiliation]
  }
}

let teamNameError = data => {
  switch StudentsEditor__StudentCSVRow.teamName(data) {
  | None => []
  | Some(teamName) =>
    String.length(teamName) <= 50
      ? containsInvalidUTF8Characters(teamName) ? [InvalidTeamName] : []
      : [TeamName]
  }
}

let tagsError = data => {
  switch StudentsEditor__StudentCSVRow.tags(data) {
  | None => []
  | Some(tagsList) => {
      let tags = Js.String.split(",", tagsList)
      let validTags = tags |> Js.Array.filter(tag => String.length(tag) <= 50)
      tags->Array.length <= 5 && validTags == tags
        ? containsInvalidUTF8Characters(tagsList) ? [InvalidTags] : []
        : [Tags]
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
    errors |> ArrayUtils.isEmpty ? [] : [{rowNumber: index + 2, errors: errors}]
  })
  |> ArrayUtils.flattenV2
}

let hasNameError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x {
    | Name => true
    | InvalidName => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasTitleError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x {
    | Title => true
    | InvalidTitle => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasEmailError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x {
    | Email => true
    | InvalidEmail => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasAffiliationError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x {
    | Affiliation => true
    | InvalidAffiliation => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasTeamNameError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x {
    | TeamName => true
    | InvalidTeamName => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}

let hasTagsError = t => {
  t.errors
  |> Js.Array.filter(x =>
    switch x {
    | Tags => true
    | InvalidTags => true
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}
