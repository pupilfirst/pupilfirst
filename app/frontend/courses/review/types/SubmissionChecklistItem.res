type file = {
  id: string,
  name: string,
  url: string,
}

type result =
  | ShortText(string)
  | LongText(string)
  | Link(string)
  | Files(array<file>)
  | MultiChoice(array<string>)
  | AudioRecord(file)

type status =
  | Passed
  | Failed
  | NoAnswer

type t = {
  title: string,
  result: result,
  status: status,
}

let title = t => t.title
let result = t => t.result
let status = t => t.status
let fileName = file => file.name
let fileUrl = file => file.url

let make = (~title, ~result, ~status) => {title: title, result: result, status: status}

let makeFile = (~name, ~url, ~id) => {name: name, url: url, id: id}

let makeFiles = data =>
  data |> Js.Array.map(a => makeFile(~url=a["url"], ~name=a["title"], ~id=a["id"]))

let findAudioFile = (files, id) => {
  ArrayUtils.unsafeFind(file => file.id == id, "Unable to find file with ID: " ++ id, files)
}

let findFiles = (files, ids) => {
  Js.Array.filter(file => Js.Array.includes(file.id, ids), files)
}

let makeResult = (json, kind, files) => {
  open Json.Decode

  switch kind {
  | "shortText" => ShortText(json |> field("result", string))
  | "longText" => LongText(json |> field("result", string))
  | "audio" => AudioRecord(findAudioFile(files, json |> field("result", string)))
  | "link" => Link(json |> field("result", string))
  | "multiChoice" => MultiChoice(json |> field("result", array(string)))
  | "files" => Files(findFiles(files, json |> field("result", array(string))))
  | randomKind =>
    Rollbar.error(
      "Unkown kind: " ++ (randomKind ++ "recived in CurriculumEditor__TargetChecklistItem"),
    )
    ShortText("Error")
  }
}

let makeStatus = data =>
  switch data {
  | "noAnswer" => NoAnswer
  | "passed" => Passed
  | "failed" => Failed
  | unkownStatus =>
    Rollbar.error(
      "Unkown status:" ++ (unkownStatus ++ "recived in CourseReview__SubmissionChecklist"),
    )
    NoAnswer
  }

let decodeFile = json => {
  open Json.Decode
  {
    name: json |> field("name", string),
    url: json |> field("url", string),
    id: json |> field("id", string),
  }
}

let decode = (files, json) => {
  open Json.Decode
  {
    result: makeResult(json, field("kind", string, json), files),
    status: makeStatus(field("status", string, json)),
    title: field("title", string, json),
  }
}

let updateStatus = (checklist, index, status) =>
  checklist |> Array.mapi((i, t) =>
    i == index ? make(~title=t.title, ~result=t.result, ~status) : t
  )

let makeNoAnswer = (index, checklist) => updateStatus(checklist, index, NoAnswer)

let makeFailed = (index, checklist) => updateStatus(checklist, index, Failed)

let makePassed = (index, checklist) => updateStatus(checklist, index, Passed)

let encodeKind = t =>
  switch t.result {
  | ShortText(_) => "shortText"
  | LongText(_) => "longText"
  | Link(_) => "link"
  | Files(_) => "files"
  | MultiChoice(_) => "multiChoice"
  | AudioRecord(_) => "audio"
  }

let encodeResult = t => {
  open Json.Encode
  switch t.result {
  | ShortText(t)
  | LongText(t)
  | Link(t) =>
    string(t)
  | MultiChoice(t) => stringArray(t)
  | AudioRecord(file) => string(file.id)
  | Files(files) => stringArray(Js.Array.map(file => file.id, files))
  }
}

let encodeStatus = t =>
  switch t.status {
  | NoAnswer => "noAnswer"
  | Passed => "passed"
  | Failed => "failed"
  }

let encode = t => {
  open Json.Encode
  object_(list{
    ("title", t.title |> string),
    ("kind", encodeKind(t) |> string),
    ("status", encodeStatus(t) |> string),
    ("result", encodeResult(t)),
  })
}

let encodeArray = checklist =>
  checklist |> {
    open Json.Encode
    array(encode)
  }
