exception UnexpectedSubmissionType(string);

type submissionType =
  | File
  | Url;

type t = {
  submissionType,
  title: string,
  url: string,
};

let decode = json =>
  Json.Decode.{
    submissionType:
      switch (json |> field("submissionType", string)) {
      | "file" => File
      | "url" => Url
      | unknownSubmissionType =>
        raise(UnexpectedSubmissionType(unknownSubmissionType))
      },
    title: json |> field("title", string),
    url: json |> field("url", string),
  };