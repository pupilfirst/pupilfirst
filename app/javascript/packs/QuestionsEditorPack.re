[@bs.config {jsx: 3}];

type props = {
  communityId: string,
  target: option(QuestionsEditor__Target.t),
};

let decodeProps = json =>
  Json.Decode.{
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
  <QuestionsEditor communityId={props.communityId} target={props.target} />,
  "questions-editor",
);
