[@bs.config {jsx: 3}];

type props = {
  authenticityToken: string,
  communityId: string,
  communityPath: string,
  target: option(QuestionsEditor__Target.t),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    communityId: json |> field("communityId", string),
    communityPath: json |> field("communityPath", string),
    target:
      json
      |> field("target", nullable(QuestionsEditor__Target.decode))
      |> Js.Null.toOption,
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="questions-editor",
    ~attribute="data-json-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <QuestionsEditor
    authenticityToken={props.authenticityToken}
    communityId={props.communityId}
    communityPath={props.communityPath}
    target={props.target}
  />,
  "questions-editor",
);