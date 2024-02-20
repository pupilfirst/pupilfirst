type t = {
  title: string,
  feedback: option<string>,
}

let title = t => t.title
let feedback = t => t.feedback

let make = (~title, ~feedback) => {title: title, feedback: feedback}

let makeFromJs = data => data->Js.Array2.map(r => make(~title=r["title"], ~feedback=r["feedback"]))

let emptyTemplate = () => [
  make(~title="Yes", ~feedback=Some("Sample feedback for yes")),
  make(~title="No", ~feedback=Some("Sample feedback for no")),
]

let empty = () => make(~title="", ~feedback=None)

let replace = (checklist, t, index) =>
  checklist->Js.Array2.mapi((result, resultIndex) => resultIndex == index ? t : result)

let updateTitle = (checklist, title, t, index) =>
  checklist->replace(make(~title, ~feedback=t.feedback), index)

let updateFeedback = (resultItems, feedback, index) => {
  let optionalFeedback = feedback->Js.String.trim == "" ? None : Some(feedback)

  resultItems->replace(make(~title=resultItems[index].title, ~feedback=optionalFeedback), index)
}

let updateAdditionalFeedback = (resultItems, feedback, index) => {
  let additionalFeedback = feedback

  resultItems->replace(make(~title=resultItems[index].title, ~feedback=additionalFeedback), index)
}

let trim = t => {...t, title: t.title->String.trim}

let encode = t => {
  let title = list{("title", t.title->Json.Encode.string)}

  let feedback = switch t.feedback {
  | Some(f) => list{("feedback", f->Json.Encode.string)}
  | None => list{}
  }

  open Json.Encode
  object_(Belt.List.concat(title, feedback))
}
