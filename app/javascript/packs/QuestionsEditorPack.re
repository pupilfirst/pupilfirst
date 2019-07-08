[@bs.config {jsx: 3}];

type props = {
  authenticityToken: string,
  communityId: string,
  target: option(QuestionsEditor__Target.t),
};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
    communityId: json |> field("communityId", string),
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
    target={props.target}
  />,
  "questions-editor",
);
