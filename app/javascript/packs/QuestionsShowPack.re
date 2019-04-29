[@bs.config {jsx: 3}];
open QuestionsShow__Types;

type props = {
  authenticityToken: string,
  question: Question.t,
  answers: list(Answer.t),
  comments: list(Comment.t),
  userData: list(UserData.t),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    question: json |> field("questions", Question.decode),
    answers: json |> field("answers", list(Answer.decode)),
    comments: json |> field("comments", list(Comment.decode)),
    userData: json |> field("userData", list(UserData.decode)),
  };

let props = DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <QuestionsShow
    authenticityToken={props.authenticityToken}
    question={props.question}
    answers={props.answers}
    comments={props.comments}
    userData={props.userData}
  />,
  "react-root",
);