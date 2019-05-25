type t = {
  id: string,
  description: string,
  creatorId: string,
  editorId: option(string),
  createdAt: string,
  archived: bool,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    description: json |> field("description", string),
    creatorId: json |> field("creatorId", string),
    editorId:
      json |> field("editorId", nullable(string)) |> Js.Null.toOption,
    createdAt: json |> field("createdAt", string),
    archived: json |> field("archived", bool),
  };

let id = t => t.id;

let description = t => t.description;

let createdAt = t => t.createdAt;

let creatorId = t => t.creatorId;

let editorId = t => t.editorId;

let addAnswer = (answers, answer) =>
  answers |> List.rev |> List.append([answer]) |> List.rev;

let updateAnswer = (answers, newAnswer) =>
  answers |> List.map(answer => answer.id == newAnswer.id ? newAnswer : answer);

let answerFromUser = (userId, answers) =>
  answers |> List.filter(answer => answer.creatorId == userId);

let archived = t => t.archived;

let create = (id, description, creatorId, editorId, createdAt, archived) => {
  id,
  description,
  creatorId,
  editorId,
  createdAt,
  archived,
};