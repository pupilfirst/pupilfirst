%%raw(`import "./Notifications__EntryCard.css"`)

let str = React.string

open Notifications__Types

let t = I18n.t(~scope="components.Notifications__EntryCard")

module MarkNotificationQuery = %graphql(`
  mutation MarkNotificationMutation($notificationId: ID!) {
    markNotification(notificationId: $notificationId)  {
      success
    }
}
`)

let markNotification = (notificationId, setSaving, markNotificationCB, event) => {
  event |> ReactEvent.Mouse.preventDefault
  setSaving(_ => true)
  MarkNotificationQuery.fetch({notificationId: notificationId})
  |> Js.Promise.then_((response: MarkNotificationQuery.t) => {
    response.markNotification.success
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
  " text-xs border border-white rounded-full overflow-hidden shrink-0 object-cover")))))))
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
    className={"notifications__entry-card block relative py-5 px-4 lg:px-8 text-sm font-medium hover:bg-gray-50 focus-within:bg-gray-50 transition ease-in-out duration-150 " ++
    switch Entry.readAt(entry) {
    | Some(_readAt) => "notifications__entry-card--read text-gray-600"
    | None => "notifications__entry-card--unread"
    }}
    key={Entry.id(entry)}
    ariaLabel={"Notification " ++ Entry.id(entry)}>
    <div className="flex justify-between items-center">
      <div className="flex-1 flex items-center relative">
        <div className="shrink-0 inline-block relative">
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
          ? <a className="ms-4 outline-none" href={"/notifications/" ++ Entry.id(entry)}>
              {str(Entry.message(entry))}
            </a>
          : <div className="ms-4"> {str(Entry.message(entry))} </div>}
      </div>
      <div className="shrink-0">
        <span className="notifications__entry-card-time block text-xs text-gray-400">
          <span className="hidden md:inline-block md:ps-4">
            {Entry.createdAt(entry)->DateFns.format("HH:mm") |> str}
          </span>
        </span>
        <div
          className="opacity-0 notifications__entry-card-buttons absolute top-0 bottom-0 end-0 flex items-center ps-4 pe-4 md:pe-8 transition ease-in-out duration-150">
          {ReactUtils.nullIf(
            <Tooltip tip={str(t("mark_read"))} position=#Start>
              <button
                disabled=saving
                ariaLabel={t("mark_read")}
                title={t("mark_read")}
                onClick={markNotification(Entry.id(entry), setSaving, markNotificationCB)}
                className="flex justify-center items-center w-8 h-8 font-semibold p-2 md:py-1 border border-gray-300 rounded text-sm bg-white text-gray-600 hover:text-primary-500 hover:border-primary-400 hover:bg-gray-50 hover:shadow-md focus:outline-none focus:text-primary-500 focus:border-primary-400 focus:bg-gray-50 focus:shadow-md transition ease-in-out duration-150">
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
