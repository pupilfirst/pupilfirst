open CommunityDashboard__Types;

type props = {
  authenticityToken: string,
  questions: list(Question.t),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    questions: json |> field("questions", list(Question.decode)),
  };

let props = DomUtils.parseJsonAttribute() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CommunityDashboard
    authenticityToken={props.authenticityToken}
    questions={props.questions}
  />,
  "react-root",
);