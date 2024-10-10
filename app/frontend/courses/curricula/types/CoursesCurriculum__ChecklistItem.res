type file = {
  id: string,
  name: string,
}

type rec result =
  | Files(array<file>)
  | Link(string)
  | ShortText(string)
  | LongText(string)
  | MultiChoice(choices, allowMultiple, selected)
  | AudioRecord(file)

and choices = array<string>
and allowMultiple = bool
and selected = array<string>

type t = {
  title: string,
  optional: bool,
  result: result,
}

let title = t => t.title

let result = t => t.result

let optional = t => t.optional

let make = (~result, ~title, ~optional) => {result, title, optional}

let fromTargetChecklistItem = targetChecklist => Array.map(tc => {
    let title = TargetChecklistItem.title(tc)
    let optional = TargetChecklistItem.optional(tc)
    let result = switch TargetChecklistItem.kind(tc) {
    | Files => Files([])
    | Link => Link("")
    | ShortText => ShortText("")
    | LongText => LongText("")
    | MultiChoice(choices, allowMultiple) => MultiChoice(choices, allowMultiple, [])
    | AudioRecord => AudioRecord({id: "", name: ""})
    }
    make(~title, ~optional, ~result)
  }, targetChecklist)

let updateResultAtIndex = (index, result, checklist) => {
  Js.Array.mapi((c, i) => i == index ? {...c, result} : c, checklist)
}

let makeFile = (id, name) => {id, name}

let filename = file => file.name

let fileId = file => file.id

let fileIds = checklist => Array.flat(Js.Array.map(c =>
      switch c.result {
      | Files(files) => Js.Array.map(a => a.id, files)
      | AudioRecord(file) => [file.id]
      | _anyOtherResult => []
      }
    , checklist))

let kindAsString = t =>
  switch t.result {
  | Files(_) => "files"
  | Link(_) => "link"
  | ShortText(_) => "shortText"
  | LongText(_) => "longText"
  | MultiChoice(_, _, _) => "multiChoice"
  | AudioRecord(_) => "audio"
  }

let resultAsJson = t => {
  open Json.Encode
  switch t.result {
  | Files(files) => Js.Array.map(file => file.id, files)->stringArray
  | Link(t)
  | ShortText(t)
  | LongText(t) =>
    t->string
  | AudioRecord(file) => file.id->string
  | MultiChoice(_, _, selected) => selected->stringArray
  }
}

let validString = (s, maxLength) => {
  let length = Js.String.length(Js.String.trim(s))

  length >= 1 && length <= maxLength
}

let validShortText = s => validString(s, 250)

let validLongText = s => validString(s, 5000)

let validFiles = files => files != [] && Array.length(files) < 4

let validMultiChoice = (selected, choices) => {
  selected->ArrayUtils.isNotEmpty && selected->Js.Array2.every(s => choices->Js.Array2.includes(s))
}

let validResponse = (response, allowBlank) => {
  let optional = allowBlank ? response.optional : false

  switch (response.result, optional) {
  | (Files(files), false) => validFiles(files)
  | (Files(files), true) => ArrayUtils.isEmpty(files) || validFiles(files)
  | (Link(link), false) => UrlUtils.isValid(false, link)
  | (Link(link), true) => UrlUtils.isValid(true, link)
  | (ShortText(t), false) => validShortText(t)
  | (ShortText(t), true) => validShortText(t) || t == ""
  | (LongText(t), false) => validLongText(t)
  | (LongText(t), true) => validLongText(t) || t == ""
  | (MultiChoice(choices, _allowMultiple, selected), false) => validMultiChoice(selected, choices)
  | (MultiChoice(choices, _allowMultiple, selected), true) =>
    ArrayUtils.isEmpty(selected) || validMultiChoice(selected, choices)
  | (AudioRecord(_), true) => true
  | (AudioRecord(file), false) => file.id != ""
  }
}

let validChecklist = checklist =>
  ArrayUtils.isEmpty(Js.Array.filter(c => !c, Js.Array.map(c => validResponse(c, true), checklist)))

let validResponses = responses => Js.Array.filter(c => validResponse(c, false), responses)

let encode = t => {
  open Json.Encode
  object_(list{
    ("title", string(t.title)),
    ("kind", string(kindAsString(t))),
    ("status", string("noAnswer")),
    ("result", resultAsJson(t)),
  })
}

let encodeArray = checklist =>
  {
    open Json.Encode
    array(encode)
  }(validResponses(checklist))

let makeFiles = checklist =>
  Array.map(
    f => {
      let url = "/timeline_event_files/" ++ (f.id ++ "/download")
      SubmissionChecklistItem.makeFile(~name=f.name, ~id=f.id, ~url)
    },
    Array.flat(Js.Array.map(item =>
        switch item.result {
        | Files(files) => files
        | AudioRecord(file) => [file]
        | _nonFileItem => []
        }
      , checklist)),
  )
