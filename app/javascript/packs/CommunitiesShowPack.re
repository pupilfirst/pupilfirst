open CommunitiesShow__Types;

type props = {
  communityId: string,
  target: option(Target.t),
  topics: array(Topic.t),
};

let decodeProps = json =>
  Json.Decode.{
    communityId: json |> field("communityId", string),
    target: json |> optional(field("target", Target.decode)),
    topics: json |> field("topics", array(Topic.decode)),
  };

let props = DomUtils.parseJSONTag() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CommunitiesShow__Root
    topics={props.topics}
    target={props.target}
    showPrevPage=true
    showNextPage=true
  />,
  "react-root",
);
