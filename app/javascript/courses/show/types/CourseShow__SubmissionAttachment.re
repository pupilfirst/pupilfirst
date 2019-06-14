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

let makeFile = (submissionId, id, title, url) => {
  submissionId,
  attachment: File(id, title, url),
};

let makeLink = (submissionId, url) => {submissionId, attachment: Link(url)};
