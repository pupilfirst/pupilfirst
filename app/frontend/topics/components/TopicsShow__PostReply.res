open TopicsShow__Types

let str = React.string
let t = I18n.t(~scope="components.TopicsShow__PostReply")
%%raw(`import "./TopicsShow__PostReply.css"`)

let avatarClasses = "w-6 h-6 md:w-8 md:h-8 text-xs border border-gray-300 rounded-full overflow-hidden shrink-0 object-cover"

let avatar = user => {
  let avatarUrl = Belt.Option.flatMap(user, User.avatarUrl)
  let name = user->Belt.Option.mapWithDefault("?", user => User.name(user))
  switch avatarUrl {
  | Some(avatarUrl) => <img className=avatarClasses src=avatarUrl />
  | None => <Avatar name className=avatarClasses />
  }
}

let navigateToPost = postId => {
  let elementId = "post-show-" ++ postId
  let element = Webapi.Dom.document -> Webapi.Dom.Document.getElementById(elementId)
  switch element {
  | Some(e) =>
    {
      Webapi.Dom.Element.scrollIntoView(e)
      e->Webapi.Dom.Element.setClassName("topics-show__highlighted-item")
    } |> ignore
  | None => Rollbar.error("Could not find the post to scroll to.")
  } |> ignore
}

@react.component
let make = (~post, ~users) => {
  let user = Post.user(users, post)
  let tip = <div className=""> {t("jump_reply") |> str} </div>
  <div
    className="topics-post-reply-show__replies flex flex-col border bg-gray-50 rounded-lg mb-2 p-2 md:p-4">
    <div className="flex justify-between">
      <div className="flex items-center">
        {avatar(user)}
        <span className="text-xs font-semibold ms-2">
          {user->Belt.Option.mapWithDefault("Unknown", user => User.name(user)) |> str}
        </span>
      </div>
      <Tooltip tip position=#Start>
        <div
          ariaLabel={t("navigate_post") ++ " " ++ Post.id(post)}
          onClick={_ => navigateToPost(post |> Post.id)}
          className="shrink-0 flex items-center justify-center w-7 h-7 rounded leading-tight border bg-gray-50 text-gray-600 cursor-pointer hover:bg-gray-300">
          <i className="fas fa-angle-double-down" />
        </div>
      </Tooltip>
    </div>
    <div className="text-sm ms-9">
      <MarkdownBlock
        markdown={post |> Post.body} className="leading-normal text-sm " profile=Markdown.Permissive
      />
    </div>
  </div>
}
