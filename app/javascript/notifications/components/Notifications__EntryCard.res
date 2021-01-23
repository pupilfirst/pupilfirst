let str = React.string
%bs.raw(`require("./Notifications__EntryCard.css")`)

open Notifications__Types

let t = I18n.t(~scope="components.Notifications__List")

module MarkNotificationQuery = %graphql(
  `
  mutation MarkNotificationMutation($notificationId: ID!) {
    markNotification(notificationId: $notificationId)  {
      success
    }
  }
`
)

let markNotification = (notificationId, setSaving, markNotificationCB, event) => {
  event |> ReactEvent.Mouse.preventDefault
  setSaving(_ => true)
  MarkNotificationQuery.make(~notificationId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["markNotification"]["success"]
      ? {
          setSaving(_ => false)
          markNotificationCB(notificationId)
        }
      : setSaving(_ => false)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    setSaving(_ => false)
    Js.Promise.resolve()
  })
  |> ignore
}

let avatarClasses = size => {
  let (defaultSize, mdSize) = size
  "w-" ++
  (defaultSize ++
  (" h-" ++
  (defaultSize ++
  (" md:w-" ++
  (mdSize ++
  (" md:h-" ++
  (mdSize ++
  " text-xs border border-white rounded-full overflow-hidden flex-shrink-0 object-cover")))))))
}

let avatar = (~size=("10", "10"), avatarUrl, name) =>
  switch avatarUrl {
  | Some(avatarUrl) => <img className={avatarClasses(size)} src=avatarUrl />
  | None => <Avatar name className={avatarClasses(size)} />
  }

@react.component
let make = (~entry, ~markNotificationCB) => {
  let (saving, setSaving) = React.useState(() => false)

  <div
    className={"notifications__entry-card block relative py-5 px-4 lg:px-8 text-sm font-semibold hover:bg-gray-200 focus:bg-gray-200 transition ease-in-out duration-150 " ++
    switch Entry.readAt(entry) {
    | Some(_readAt) => "notifications__entry-card--read text-gray-700"
    | None => "notifications__entry-card--unread"
    }}
    key={Entry.id(entry)}
    ariaLabel={"Notification " ++ Entry.id(entry)}>
    <div className="flex justify-between items-center">
      <div className="flex-1 flex items-center relative">
        <div className="flex-shrink-0 inline-block relative">
          {switch Entry.actor(entry) {
          | Some(actor) => avatar(User.avatarUrl(actor), User.name(actor))
          | None => React.null
          }}
          {<span
            className="notifications__entry-unread-dot absolute top-0 flex justify-center h-full items-center">
            <span className="block h-1 w-1 rounded-full shadow-solid bg-primary-400" />
          </span>->ReactUtils.nullUnless(Entry.readAt(entry)->Belt.Option.isNone)}
        </div>
        {Entry.notifiableId(entry)->Belt.Option.isSome
          ? <a className="ml-4" href={"/notifications/" ++ Entry.id(entry)}>
              {str(Entry.message(entry))}
            </a>
          : <div className="ml-4"> {str(Entry.message(entry))} </div>}
      </div>
      <div className="flex-shrink-0">
        <span className="notifications__entry-card-time block text-xs text-gray-800">
          <span className="hidden md:inline-block md:pl-4">
            {Entry.createdAt(entry)->DateFns.format("HH:mm") |> str}
          </span>
        </span>
        <div
          className="opacity-0 notifications__entry-card-buttons absolute top-0 bottom-0 right-0 flex items-center pl-4 pr-4 md:pr-8 transition ease-in-out duration-150">
          {ReactUtils.nullIf(
            <Tooltip tip={str("Mark as Read")} position=#Left>
              <button
                disabled=saving
                title="Mark as Read"
                onClick={markNotification(Entry.id(entry), setSaving, markNotificationCB)}
                className="flex justify-center items-center w-8 h-8 font-semibold p-2 md:py-1 border border-gray-400 rounded text-sm bg-white text-gray-700 hover:text-primary-500 hover:border-primary-400 hover:bg-gray-200 hover:shadow-md transition ease-in-out duration-150">
                <Icon className="if i-check-solid" />
              </button>
            </Tooltip>,
            Entry.readAt(entry)->Belt.Option.isSome,
          )}
        </div>
      </div>
    </div>
  </div>
}
