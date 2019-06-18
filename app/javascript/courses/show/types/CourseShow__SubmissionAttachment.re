exception UnexpectedSubmissionType(string);

type id = string;
type title = string;
type url = string;

type attachment =
  | File(id, title, url)
  | Link(url);

type t = {
  submissionId: id,
  attachment,
};

let submissionId = t => t.submissionId;
let attachment = t => t.attachment;

let decode = json => {
  let url = json |> Json.Decode.(field("url", string));

  Json.Decode.{
    submissionId: json |> field("submissionId", string),
    attachment:
      switch (json |> field("submissionType", string)) {
      | "link" => Link(url)
      | "file" =>
        let id = json |> field("id", string);
        let title = json |> field("title", string);
        File(id, title, url);
      | unknownSubmissionType =>
        raise(UnexpectedSubmissionType(unknownSubmissionType))
      },
  };
};

let make = (submissionId, attachment) => {submissionId, attachment};

let onlyAttachments = ts => ts |> List.map(t => t |> attachment);
