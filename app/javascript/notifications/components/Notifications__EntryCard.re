let str = React.string;

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
  ++ " text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 object-cover";
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
      "bg-white cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:shadow-md border-l-3 py-4 px-2 "
      ++ (
        switch (Entry.readAt(entry)) {
        | Some(_readAt) => "border-gray-500"
        | None => "border-green-500"
        }
      )
    }
    key={Entry.id(entry)}
    ariaLabel={"Notification " ++ Entry.id(entry)}>
    <div className="flex">
      <div className="w-1/3 md:w-1/6 md:mr-0 mr-2">
        {switch (Entry.actor(entry)) {
         | Some(actor) => avatar(User.avatarUrl(actor), User.name(actor))
         | None => React.null
         }}
      </div>
      <div>
        <div> {str(Entry.message(entry))} </div>
        <span className="block text-xs text-gray-800 pt-1">
          <span className="hidden md:inline-block md:mr-2">
            {"on "
             ++ Entry.createdAt(entry)->DateFns.formatPreset(~year=true, ())
             |> str}
          </span>
        </span>
        <div className="flex justify-between mt-4">
          {ReactUtils.nullIf(
             <button
               disabled=saving
               onClick={markNotification(
                 Entry.id(entry),
                 setSaving,
                 markNotificationCB,
               )}
               className="inline-flex items-center font-semibold p-2 md:py-1 bg-gray-100 hover:bg-gray-300 border rounded text-xs flex-shrink-0">
               <i className="fas fa-check mr-2" />
               {str("Mark as Read")}
             </button>,
             Entry.readAt(entry)->Belt.Option.isSome,
           )}
          {ReactUtils.nullIf(
             <a
               href={"/notifications/" ++ Entry.id(entry)}
               className="inline-flex items-center font-semibold p-2 md:py-1 bg-gray-100 hover:bg-gray-300 border rounded text-xs flex-shrink-0">
               <i className="fas fa-eye mr-2" />
               {str("Visit")}
             </a>,
             Entry.notifiableId(entry)->Belt.Option.isNone,
           )}
        </div>
      </div>
    </div>
  </div>;
};
