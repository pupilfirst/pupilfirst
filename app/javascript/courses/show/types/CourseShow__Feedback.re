type t = {
  facultyId: string,
  feedback: string,
};

let decode = json =>
  Json.Decode.{
    facultyId: json |> field("facultyId", string),
    feedback: json |> field("feedback", string),
  };