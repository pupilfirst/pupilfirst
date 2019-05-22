type t = {
  id: string,
  userId: string,
  createdAt: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    userId: json |> field("userId", string),
    createdAt: json |> field("createdAt", string),
  };

let id = t => t.id;

let createdAt = t => t.createdAt;

let userId = t => t.userId;

let addAnswer = (answers, answer) =>
  answers |> List.rev |> List.append([answer]) |> List.rev;

let answerFromUser = (userId, answers) =>
  answers |> List.filter(answer => answer.userId == userId);

let create = (id, userId, createdAt) => {id, userId, createdAt};