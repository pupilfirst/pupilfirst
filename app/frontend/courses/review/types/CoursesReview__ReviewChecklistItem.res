type t = {
  title: string,
  results: array<CoursesReview__ReviewChecklistResult.t>,
}

let title = t => t.title
let results = t => t.results

let make = (~title, ~results) => {title: title, results: results}

let makeFromJs = data =>
  data->Js.Array2.map(rc =>
    make(~title=rc["title"], ~results=rc["result"]->CoursesReview__ReviewChecklistResult.makeFromJs)
  )

let empty = () => [make(~title="", ~results=[CoursesReview__ReviewChecklistResult.empty()])]

let emptyTemplate = () => [
  make(~title="Default checklist", ~results=CoursesReview__ReviewChecklistResult.emptyTemplate()),
]

let updateTitle = (title, t) => make(~title, ~results=t.results)

let updateChecklist = (results, t) => make(~title=t.title, ~results)

let replace = (t, itemIndex, results) =>
  results->Js.Array2.mapi((item, index) => index == itemIndex ? t : item)

let appendEmptyChecklistItem = t =>
  make(
    ~title=t.title,
    ~results=Js.Array2.concat(t.results, [CoursesReview__ReviewChecklistResult.empty()]),
  )

let moveResultItemUp = (index, t) =>
  make(~title=t.title, ~results=ArrayUtils.swapUp(index, t.results))
let moveResultItemDown = (index, t) =>
  make(~title=t.title, ~results=ArrayUtils.swapDown(index, t.results))

let deleteResultItem = (index, t) =>
  make(~title=t.title, ~results=t.results->Js.Array2.filteri((_el, i) => i != index))

let trim = t => {
  title: t.title->String.trim,
  results: t.results->Js.Array2.map(CoursesReview__ReviewChecklistResult.trim),
}

let encode = t => {
  open Json.Encode
  object_(list{
    ("title", string(t.title)),
    ("result", array(CoursesReview__ReviewChecklistResult.encode, t.results)),
  })
}

let encodeArray = checklist => {
  Json.Encode.array(encode, checklist)
}
