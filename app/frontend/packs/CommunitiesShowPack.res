open CommunitiesShow__Types

let decodeProps = json => {
  open Json.Decode
  (
    json |> field("communityId", string),
    json |> optional(field("target", Target.decode)),
    json |> field("topicCategories", array(TopicCategory.decode)),
  )
}

Psj.match("communities#show", () => {
  let (communityId, target, topicCategories) = DomUtils.parseJSONTag() |> decodeProps

  switch ReactDOM.querySelector("#react-root") {
  | Some(root) =>
    ReactDOM.render(<CommunitiesShow__Root communityId target topicCategories />, root)
  | None => ()
  }
})
