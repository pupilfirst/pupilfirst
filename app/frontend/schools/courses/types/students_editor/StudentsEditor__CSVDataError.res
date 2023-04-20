type errorType =
  | Name
  | Email
  | Title
  | TeamName
  | Tags
  | Affiliation

type t = {
  rowNumber: int,
  errors: array<errorType>,
}

let rowNumber = t => t.rowNumber

let errors = t => t.errors

let nameError = data => {
  switch StudentsEditor__StudentCSVRow.name(data) {
  | None => []
  | Some(name) => StringUtils.isPresent(name) ? [] : [Name]
  }
}

let emailError = data => {
  switch StudentsEditor__StudentCSVRow.email(data) {
  | None => [Email]
  | Some(email) => EmailUtils.isInvalid(false, email) ? [Email] : []
  }
}

let titleError = data => {
  switch StudentsEditor__StudentCSVRow.title(data) {
  | None => []
  | Some(title) => String.length(title) <= 250 ? [] : [Title]
  }
}

let affiliationError = data => {
  switch StudentsEditor__StudentCSVRow.affiliation(data) {
  | None => []
  | Some(affiliation) => String.length(affiliation) <= 250 ? [] : [Affiliation]
  }
}

let teamNameError = data => {
  switch StudentsEditor__StudentCSVRow.teamName(data) {
  | None => []
  | Some(teamName) => String.length(teamName) <= 50 ? [] : [TeamName]
  }
}

let tagsError = data => {
  switch StudentsEditor__StudentCSVRow.tags(data) {
  | None => []
  | Some(tagsList) => {
      let tags = Js.String.split(",", tagsList)
      let validTags = tags |> Js.Array.filter(tag => String.length(tag) <= 50)
      tags->Array.length <= 5 && validTags == tags ? [] : [Tags]
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
    | _ => false
    }
  )
  |> ArrayUtils.isNotEmpty
}
