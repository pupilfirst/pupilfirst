let str = React.string

open CoursesCurriculum__Types

let tr = I18n.t(~scope="components.CoursesCurriculum__Discuss", ...)

let linkToCommunity = (communityId, targetId) =>
  "/communities/" ++ (communityId ++ ("?target_id=" ++ targetId))

let linkToNewPost = (communityId, targetId) =>
  "/communities/" ++ (communityId ++ ("/new_topic" ++ ("?target_id=" ++ targetId)))

let topicCard = topic => {
  let topicId = Community.topicId(topic)
  let topicLink = "/topics/" ++ topicId
  <div
    href=topicLink
    key=topicId
    className="flex justify-between items-center px-5 py-4 bg-white border-t">
    <span className="text-sm font-semibold"> {str(Community.topicTitle(topic))} </span>
    <a href=topicLink className="btn btn-primary-ghost btn-small"> {str("View")} </a>
  </div>
}

let handleEmpty = () =>
  <div className="flex flex-col justify-center items-center bg-white px-3 py-10">
    <i className="fa fa-comments text-5xl text-gray-600 mb-2 " />
    <div className="text-center">
      <h4 className="font-bold"> {str(tr("no_discussion"))} </h4>
      <p> {str(tr("use_community"))} </p>
    </div>
  </div>

let actionButtons = (community, targetId) => {
  let communityId = Community.id(community)
  let communityName = Community.name(community)

  <div className="flex">
    <a
      title={"Browse all topics about this target in the " ++ (communityName ++ " community")}
      href={linkToCommunity(communityId, targetId)}
      className="btn btn-default me-3">
      {str(tr("go_to"))}
    </a>
    <a
      title={"Create a topic in the " ++ (communityName ++ " community")}
      href={linkToNewPost(communityId, targetId)}
      className="btn btn-primary">
      {str(tr("create"))}
    </a>
  </div>
}

let communityTitle = community =>
  <h5 className="font-bold">
    {str(tr("topics_pre") ++ (Community.name(community) ++ tr("topics_post")))}
  </h5>

@react.component
let make = (~targetId, ~communities) => <div> {React.array(Js.Array.map(community => {
        let communityId = Community.id(community)
        <div key=communityId className="mt-12 bg-gray-50 px-6 py-4 rounded-lg">
          <div className="flex flex-col md:flex-row w-full justify-between pb-3 items-center">
            <div> {communityTitle(community)} </div>
            {actionButtons(community, targetId)}
          </div>
          <div className="justify-between rounded-lg overflow-hidden shadow">
            {switch Community.topics(community) {
            | [] => handleEmpty()
            | topics => React.array(Array.map(topic => topicCard(topic), topics))
            }}
          </div>
        </div>
      }, communities))} </div>
