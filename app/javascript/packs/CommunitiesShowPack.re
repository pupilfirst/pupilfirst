open CommunitiesShow__Types;

type props = {
  communityId: string,
  target: option(Target.t),
  topicCategories: array(TopicCategory.t),
};

let decodeProps = json =>
  Json.Decode.{
    communityId: json |> field("communityId", string),
    target: json |> optional(field("target", Target.decode)),
    topicCategories:
      json |> field("topicCategories", array(TopicCategory.decode)),
  };

let props = DomUtils.parseJSONTag() |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CommunitiesShow__Root
    communityId={props.communityId}
    target={props.target}
    topicCategories={props.topicCategories}
  />,
  "react-root",
);
