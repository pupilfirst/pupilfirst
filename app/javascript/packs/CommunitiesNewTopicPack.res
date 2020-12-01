open TopicsShow__Types

type props = {
  communityId: string,
  target: option<LinkedTarget.t>,
  topicCategories: array<TopicCategory.t>,
}

let decodeProps = json => {
  open Json.Decode
  {
    communityId: json |> field("communityId", string),
    target: json |> optional(field("target", LinkedTarget.decode)),
    topicCategories: json |> field("topicCategories", array(TopicCategory.decode)),
  }
}

let props = DomUtils.parseJSONTag() |> decodeProps

ReactDOMRe.renderToElementWithId(
  <CommunitiesNewTopic__Root
    communityId=props.communityId target=props.target topicCategories=props.topicCategories
  />,
  "react-root",
)
