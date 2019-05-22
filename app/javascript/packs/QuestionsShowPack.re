[@bs.config {jsx: 3}];
open QuestionsShow__Types;

type props = {
  authenticityToken: string,
  question: Question.t,
  answers: list(Answer.t),
  comments: list(Comment.t),
  userData: list(UserData.t),
  markdownVersions: list(MarkdownVersion.t),
  likes: list(Like.t),
  currentUserId: string,
  communityPath: string,
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    question: json |> field("questions", Question.decode),
    answers: json |> field("answers", list(Answer.decode)),
    comments: json |> field("comments", list(Comment.decode)),
    userData: json |> field("userData", list(UserData.decode)),
    markdownVersions:
      json |> field("markdownVersions", list(MarkdownVersion.decode)),
    likes: json |> field("likes", list(Like.decode)),
    currentUserId: json |> field("currentUserId", string),
    communityPath: json |> field("communityPath", string),
  };

let props = DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <QuestionsShow
    authenticityToken={props.authenticityToken}
    question={props.question}
    answers={props.answers}
    comments={props.comments}
    userData={props.userData}
    likes={props.likes}
    markdownVersions={props.markdownVersions}
    currentUserId={props.currentUserId}
    communityPath={props.communityPath}
  />,
  "react-root",
);