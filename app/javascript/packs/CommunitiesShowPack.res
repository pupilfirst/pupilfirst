open CommunitiesShow__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("communityId", string),
    json |> optional(field("target", Target.decode)),
    json |> field("topicCategories", array(TopicCategory.decode)),
  )
}

let (communityId, target, topicCategories) = DomUtils.parseJSONTag() |> decodeProps

ReactDOMRe.renderToElementWithId(
  <CommunitiesShow__Root communityId target topicCategories />,
  "react-root",
)
