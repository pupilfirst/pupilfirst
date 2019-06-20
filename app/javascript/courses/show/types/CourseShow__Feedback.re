type t = {
  coachId: string,
  submissionId: string,
  feedback: string,
};

let coachId = t => t.coachId;
let submissionId = t => t.submissionId;
let feedback = t => t.feedback;

let decode = json =>
  Json.Decode.{
    coachId: json |> field("coachId", string),
    submissionId: json |> field("submissionId", string),
    feedback: json |> field("feedback", string),
  };
