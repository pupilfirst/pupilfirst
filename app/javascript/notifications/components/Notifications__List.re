let str = React.string;

open Notifications__Types;

let t = I18n.t(~scope="components.Notifications__List");

type event = [ | `topic_created | `topic_edited];

type status = [ | `all | `unread | `read];

let eventName = event => {
  switch (event) {
  | `topic_created => t("filter.events.topic_created_text")
  | `topic_edited => t("filter.events.topic_edited_text")
  };
};

module MarkNotificationQuery = [%graphql
  {|
  mutation MarkNotificationMutation($notificationId: ID!) {
    markNotification(notificationId: $notificationId)  {
      success
    }
  }
|}
];

type filter = {
  event: option(event),
  title: option(string),
  status: option(status),
};

type state = {
  loading: Loading.t,
  entries: Entries.t,
  filterString: string,
  filter,
  totalEntriesCount: int,
};

type action =
  | SetSearchString(string)
  | UnsetSearchString
  | UpdateFilterString(string)
  | LoadNotifications(option(string), bool, array(Entry.t), int)
  | BeginLoadingMore
  | BeginReloading
  | ClearStatus
  | SetStatus(status)
  | SetEvent(event)
  | ClearEvent
  | MarkNotification(string);

let updateNotification = (id, notifications) => {
  notifications
  |> Js.Array.map(entry =>
       Entry.id(entry) == id ? Entry.markAsRead(entry) : entry
     );
};

let reducer = (state, action) => {
  switch (action) {
  | SetSearchString(string) => {
      ...state,
      filter: {
        ...state.filter,
        title: Some(string),
      },
      filterString: "",
    }
  | UnsetSearchString => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        title: None,
      },
    }
  | UpdateFilterString(filterString) => {...state, filterString}
  | LoadNotifications(endCursor, hasNextPage, newTopics, totalEntriesCount) =>
    let updatedTopics =
      switch (state.loading) {
      | LoadingMore =>
        newTopics |> Array.append(state.entries |> Entries.toArray)
      | Reloading => newTopics
      | NotLoading => newTopics
      };

    {
      ...state,
      entries:
        switch (hasNextPage, endCursor) {
        | (_, None)
        | (false, Some(_)) => FullyLoaded(updatedTopics)
        | (true, Some(cursor)) => PartiallyLoaded(updatedTopics, cursor)
        },
      loading: NotLoading,
      totalEntriesCount,
    };
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  | MarkNotification(id) => {
      ...state,
      entries:
        switch (state.entries) {
        | Unloaded => Unloaded
        | PartiallyLoaded(entries, cursor) =>
          PartiallyLoaded(updateNotification(id, entries), cursor)
        | FullyLoaded(entries) =>
          FullyLoaded(updateNotification(id, entries))
        },
    }
  | SetStatus(status) => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        status: Some(status),
      },
    }
  | ClearStatus => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        status: None,
      },
    }
  | SetEvent(event) => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        event: Some(event),
      },
    }
  | ClearEvent => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        event: None,
      },
    }
  };
};

module NotificationsQuery = [%graphql
  {|
    query NotificationsFromNotificationsListQuery($search: String, $after: String, $event: NotificationEvent, $status: NotificationStatus) {
      notifications(event: $event, search: $search, first: 10, after: $after, status: $status) {
        nodes {
          actor {
            id
            name
            title
            avatarUrl
          }
          createdAt
          event
          id
          message
          notifiableId
          notifiableType
          readAt
        }
        pageInfo{
          endCursor,hasNextPage
        }
        totalCount
      }
    }
  |}
];

let getEntries = (send, cursor, filter) => {
  NotificationsQuery.make(
    ~status=?filter.status,
    ~after=?cursor,
    ~search=?filter.title,
    ~event=?filter.event,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       let newNotifications =
         response##notifications##nodes
         |> Js.Array.map(topicData => Entry.makeFromJS(topicData));

       send(
         LoadNotifications(
           response##notifications##pageInfo##endCursor,
           response##notifications##pageInfo##hasNextPage,
           newNotifications,
           response##notifications##totalCount,
         ),
       );

       Js.Promise.resolve();
     })
  |> ignore;
};

let markNotification = (send, notificationId) => {
  send(MarkNotification(notificationId));
};

let reloadEntries = (state, send) => {
  send(BeginReloading);
  getEntries(send, None, state.filter);
};

let computeInitialState = () => {
  loading: NotLoading,
  entries: Unloaded,
  filterString: "",
  filter: {
    title: None,
    event: None,
    status: None,
  },
  totalEntriesCount: 0,
};

let entriesList = (caption, entries, send) => {
  <div>
    <div className="font-bold text-xl"> {str(caption)} </div>
    <div className="space-y-2 mt-2">
      {entries |> ArrayUtils.isEmpty
         ? <div
             className="flex flex-col mx-auto bg-white rounded-md border p-6 justify-center items-center">
             <FaIcon classes="fas fa-comments text-5xl text-gray-400" />
             <h4
               className="mt-3 text-base md:text-lg text-center font-semibold">
               {t("empty_notifications")->str}
             </h4>
           </div>
         : entries
           |> Js.Array.map(entry =>
                <Notifications__EntryCard
                  entry
                  markNotificationCB={markNotification(send)}
                />
              )
           |> React.array}
    </div>
  </div>;
};

let entriesLoadedData = (totoalNotificationsCount, loadedNotificaionsCount) => {
  <div
    className="inline-block mt-2 mx-auto bg-gray-200 text-gray-800 text-xs p-2 text-center rounded font-semibold">
    {(
       totoalNotificationsCount == loadedNotificaionsCount
         ? t(
             ~variables=[|
               (
                 "total_notifications",
                 string_of_int(totoalNotificationsCount),
               ),
             |],
             "notifications_fully_loaded_text",
           )
         : t(
             ~variables=[|
               (
                 "total_notifications",
                 string_of_int(totoalNotificationsCount),
               ),
               (
                 "loaded_notifications_count",
                 string_of_int(loadedNotificaionsCount),
               ),
             |],
             "notifications_partially_loaded_text",
           )
     )
     |> str}
  </div>;
};

module Selectable = {
  type t =
    | Event(event)
    | Status(status)
    | Title(string);

  let label = s =>
    switch (s) {
    | Event(_event) => Some(t("filter.label.event"))
    | Title(_) => Some(t("filter.label.title"))
    | Status(_) => Some(t("filter.label.status"))
    };

  let value = s =>
    switch (s) {
    | Event(event) => eventName(event)
    | Title(search) => search
    | Status(status) =>
      let key =
        switch (status) {
        | `all => "all"
        | `read => "read"
        | `unread => "unread"
        };

      t("filter.status." ++ key);
    };

  let searchString = s =>
    switch (s) {
    | Event(event) => t("filter.event") ++ " " ++ eventName(event)
    | Title(search) => search
    | Status(_unread) =>
      t("filter.status.read")
      ++ " "
      ++ t("filter.status.unread")
      ++ " "
      ++ t("filter.status.all")
    };

  let color = t => {
    switch (t) {
    | Event(_event) => "blue"
    | Title(_search) => "gray"
    | Status(status) =>
      switch (status) {
      | `all => "yellow"
      | `read => "green"
      | `unread => "orange"
      }
    };
  };

  let event = event => Event(event);
  let title = search => Title(search);
  let status = status => Status(status);
};

module Multiselect = MultiselectDropdown.Make(Selectable);

let unselected = state => {
  let eventFilters =
    Selectable.event->Array.map([|`topic_created, `topic_edited|]);

  let trimmedFilterString = state.filterString |> String.trim;
  let title =
    trimmedFilterString == ""
      ? [||] : [|Selectable.title(trimmedFilterString)|];

  let status =
    state.filter.status
    ->Belt.Option.mapWithDefault([|`all, `read, `unread|], u =>
        switch (u) {
        | `all => [|`read, `unread|]
        | `read => [|`all, `unread|]
        | `unread => [|`all, `read|]
        }
      )
    |> Array.map(s => Selectable.status(s));

  eventFilters |> Js.Array.concat(title) |> Js.Array.concat(status);
};

let selected = state => {
  let selectedEventFilters =
    state.filter.event
    ->Belt.Option.mapWithDefault([||], e => [|Selectable.event(e)|]);

  let selectedSearchString =
    state.filter.title
    |> OptionUtils.mapWithDefault(
         title => {[|Selectable.title(title)|]},
         [||],
       );

  let status =
    state.filter.status
    ->Belt.Option.mapWithDefault([||], u => [|Selectable.status(u)|]);

  selectedEventFilters
  |> Js.Array.concat(selectedSearchString)
  |> Js.Array.concat(status);
};

let onSelectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.Event(event) => send(SetEvent(event))
  | Title(title) => send(SetSearchString(title))
  | Status(s) => send(SetStatus(s))
  };

let onDeselectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.Event(_e) => send(ClearEvent)
  | Title(_title) => send(UnsetSearchString)
  | Status(_) => send(ClearStatus)
  };

let showEntries = (entries, state, send) => {
  let now = Js.Date.make();
  let entriesToday =
    Js.Array.filter(
      e =>
        Js.Date.toDateString(Entry.createdAt(e))
        == Js.Date.toDateString(now),
      entries,
    );
  let entriesEarlier =
    Js.Array.filter(
      e =>
        Js.Date.toDateString(Entry.createdAt(e))
        != Js.Date.toDateString(now),
      entries,
    );

  <div>
    {ReactUtils.nullIf(
       entriesList("Today", entriesToday, send),
       ArrayUtils.isEmpty(entriesToday),
     )}
    {ReactUtils.nullIf(
       entriesList("Earlier", entriesToday, send),
       ArrayUtils.isEmpty(entriesEarlier),
     )}
    <div className="text-center">
      {entriesLoadedData(state.totalEntriesCount, Array.length(entries))}
    </div>
  </div>;
};

[@react.component]
let make = () => {
  let (state, send) = React.useReducer(reducer, computeInitialState());

  React.useEffect1(
    () => {
      reloadEntries(state, send);
      None;
    },
    [|state.filter|],
  );

  <div>
    <div className="mt-4 px-6">
      <div className="font-bold text-2xl"> {str("Notification")} </div>
    </div>
    <div className="w-full sticky top-0 z-30 mt-2 px-6 bg-white py-2">
      <label
        className="block text-tiny font-semibold uppercase pl-px text-left">
        {t("filter.input_label")->str}
      </label>
      <Multiselect
        id="filter"
        unselected={unselected(state)}
        selected={selected(state)}
        onSelect={onSelectFilter(send)}
        onDeselect={onDeselectFilter(send)}
        value={state.filterString}
        onChange={filterString => send(UpdateFilterString(filterString))}
        placeholder={t("filter.input_placeholder")}
      />
    </div>
    <div id="entries" className="mt-4 px-6">
      {switch (state.entries) {
       | Unloaded =>
         SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())
       | PartiallyLoaded(entries, cursor) =>
         <div>
           {showEntries(entries, state, send)}
           {switch (state.loading) {
            | LoadingMore =>
              SkeletonLoading.multiple(
                ~count=3,
                ~element=SkeletonLoading.card(),
              )
            | NotLoading =>
              <button
                className="btn btn-primary-ghost cursor-pointer w-full mt-4"
                onClick={_ => {
                  send(BeginLoadingMore);
                  getEntries(send, Some(cursor), state.filter);
                }}>
                {t("button_load_more") |> str}
              </button>
            | Reloading => React.null
            }}
         </div>
       | FullyLoaded(entries) =>
         <div> {showEntries(entries, state, send)} </div>
       }}
    </div>
    {switch (state.entries) {
     | Unloaded => React.null

     | _ =>
       let loading =
         switch (state.loading) {
         | NotLoading => false
         | Reloading => true
         | LoadingMore => false
         };
       <LoadingSpinner loading />;
     }}
  </div>;
};
