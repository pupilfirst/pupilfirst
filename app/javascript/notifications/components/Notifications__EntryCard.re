let str = React.string;
[%bs.raw {|require("./Notifications__EntryCard.css")|}];

open Notifications__Types;

let t = I18n.t(~scope="components.Notifications__List");

module MarkNotificationQuery = [%graphql
  {|
  mutation MarkNotificationMutation($notificationId: ID!) {
    markNotification(notificationId: $notificationId)  {
      success
    }
  }
|}
];
let markNotification = (notificationId, setSaving, markNotificationCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setSaving(_ => true);
  MarkNotificationQuery.make(~notificationId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##markNotification##success
         ? {
           setSaving(_ => false);
           markNotificationCB(notificationId);
         }
         : setSaving(_ => false);
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       setSaving(_ => false);
       Js.Promise.resolve();
     })
  |> ignore;
};

let avatarClasses = size => {
  let (defaultSize, mdSize) = size;
  "w-"
  ++ defaultSize
  ++ " h-"
  ++ defaultSize
  ++ " md:w-"
  ++ mdSize
  ++ " md:h-"
  ++ mdSize
  ++ " text-xs border border-white rounded-full overflow-hidden flex-shrink-0 object-cover";
};

let avatar = (~size=("10", "10"), avatarUrl, name) => {
  switch (avatarUrl) {
  | Some(avatarUrl) => <img className={avatarClasses(size)} src=avatarUrl />
  | None => <Avatar name className={avatarClasses(size)} />
  };
};

[@react.component]
let make = (~entry, ~markNotificationCB) => {
  let (saving, setSaving) = React.useState(() => false);

  <div
    className={
      "notifications__entry-card relative cursor-pointer py-5 px-4 lg:px-8 hover:bg-gray-200 focus:bg-gray-200 transition ease-in-out duration-150 "
      ++ (
        switch (Entry.readAt(entry)) {
        | Some(_readAt) => "border-gray-500"
        | None => "border-green-500"
        }
      )
    }
    key={Entry.id(entry)}
    ariaLabel={"Notification " ++ Entry.id(entry)}>
    <a
      href={"/notifications/" ++ Entry.id(entry)}
      className="flex justify-between hover:underline">
      <div className="flex-1 flex items-center relative">
        <div className="flex-shrink-0 inline-block relative">
          {switch (Entry.actor(entry)) {
           | Some(actor) => avatar(User.avatarUrl(actor), User.name(actor))
           | None => React.null
           }}
          <span
            className="notifications__entry-unread-dot absolute top-0 flex justify-center h-full items-center">
            <span
              className="block h-1 w-1 rounded-full shadow-solid bg-primary-400"
            />
          </span>
        </div>
        <div className="ml-4"> {str(Entry.message(entry))} </div>
      </div>
      <div className="flex-shrink-0">
        <span className="block text-xs text-gray-800 pt-1">
          <span className="hidden md:inline-block md:mr-2">
            {"on "
             ++ Entry.createdAt(entry)->DateFns.formatPreset(~year=true, ())
             |> str}
          </span>
        </span>
        <div
          className="opacity-0 notifications__entry-card-buttons absolute top-0 bottom-0 right-0 flex pl-4 pr-3 justify-between space-x-2 items-center transition ease-in-out duration-150">
          {ReactUtils.nullIf(
             <a
               href={"/notifications/" ++ Entry.id(entry)}
               className="inline-flex items-center font-semibold p-2 md:py-1 bg-white hover:bg-gray-300 border rounded text-xs flex-shrink-0">
               <i className="fas fa-eye mr-2 text-primary-500" />
               {str("Visit Link")}
             </a>,
             Entry.notifiableId(entry)->Belt.Option.isNone,
           )}
          {ReactUtils.nullIf(
             <button
               disabled=saving
               onClick={markNotification(
                 Entry.id(entry),
                 setSaving,
                 markNotificationCB,
               )}
               className="inline-flex items-center font-semibold p-2 md:py-1 bg-white hover:bg-gray-300 border rounded text-xs flex-shrink-0">
               <Icon className="if i-circle-regular mr-2 text-primary-500" />
               {str("Mark as Read")}
             </button>,
             Entry.readAt(entry)->Belt.Option.isSome,
           )}
        </div>
      </div>
    </a>
  </div>;
};
