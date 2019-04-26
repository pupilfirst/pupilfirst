[@bs.config {jsx: 3}];
open QuestionsShow__Types;

type props = {
  authenticityToken: string,
  questions: Question.t,
  answers: list(Answer.t),
  comments: list(Comment.t),
  userData: list(UserData.t),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    questions: json |> field("questions", Question.decode),
    answers: json |> field("answers", list(Answer.decode)),
    comments: json |> field("comments", list(Comment.decode)),
    userData: json |> field("userData", list(UserData.decode)),
  };

let props = DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <QuestionsShow authenticityToken={props.authenticityToken} />,
  "react-root",
);