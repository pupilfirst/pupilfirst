open TopicsShow__Types;

type props = {
  communityId: string,
  target: option(LinkedTarget.t),
};

let decodeProps = json =>
  Json.Decode.{
    communityId: json |> field("communityId", string),
    target: json |> optional(field("target", LinkedTarget.decode)),
  };

let props = DomUtils.parseJSONTag() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CommunitiesNewTopic__Root
    communityId={props.communityId}
    target={props.target}
  />,
  "react-root",
);
