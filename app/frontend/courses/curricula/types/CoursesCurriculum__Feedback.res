type id = string

type t = {
  id: id,
  coachId: option<string>,
  submissionId: string,
  feedback: string,
}

let id = t => t.id
let coachId = t => t.coachId
let submissionId = t => t.submissionId
let feedback = t => t.feedback

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    coachId: field("coachId", option(string), json),
    submissionId: field("submissionId", string, json),
    feedback: field("feedback", string, json),
  }
}
