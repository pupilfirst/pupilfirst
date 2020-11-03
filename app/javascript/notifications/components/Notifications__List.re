let str = React.string;

open Notifications__Types;

let t = I18n.t(~scope="components.Notifications__List");

type event = [ | `topic_created | `topic_edited];

let eventName = event => {
  switch (event) {
  | `topic_created => t("filter.events.topic_created_text")
  | `topic_edited => t("filter.events.topic_edited_text")
  };
};

type sortDirection = [ | `Ascending | `Descending];

type filter = {
  sortDirection,
  event: option(event),
  title: option(string),
  unread: option(bool),
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
  | SetShowUnread
  | ClearUnread
  | SetShowRead
  | SetEvent(event)
  | ClearEvent
  | UpdateSortDirection(sortDirection);

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
      filter: {
        ...state.filter,
        title: None,
      },
    }
  | UpdateFilterString(filterString) => {...state, filterString}
  | UpdateSortDirection(sortDirection) => {
      ...state,
      filter: {
        ...state.filter,
        sortDirection,
      },
    }
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
  | SetShowUnread => {
      ...state,
      filter: {
        ...state.filter,
        unread: Some(true),
      },
    }
  | ClearUnread => {
      ...state,
      filter: {
        ...state.filter,
        unread: None,
      },
    }
  | SetShowRead => {
      ...state,
      filter: {
        ...state.filter,
        unread: Some(false),
      },
    }
  | SetEvent(event) => {
      ...state,
      filter: {
        ...state.filter,
        event: Some(event),
      },
    }
  | ClearEvent => {
      ...state,
      filter: {
        ...state.filter,
        event: None,
      },
    }
  };
};

module NotificationsQuery = [%graphql
  {|
    query NotificationsFromNotificationsListQuery($search: String, $after: String, $event: NotificationEvent, $sortDirection: SortDirection!, $unread: Boolean) {
      notifications(event: $event, search: $search, sortDirection: $sortDirection, first: 10, after: $after, unread: $unread) {
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
    ~unread=?filter.unread,
    ~after=?cursor,
    ~search=?filter.title,
    ~event=?filter.event,
    ~sortDirection=filter.sortDirection,
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
    sortDirection: `Ascending,
    event: None,
    unread: None,
  },
  totalEntriesCount: 0,
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

let entriesList = entries => {
  entries |> ArrayUtils.isEmpty
    ? <div
        className="flex flex-col mx-auto bg-white rounded-md border p-6 justify-center items-center">
        <FaIcon classes="fas fa-comments text-5xl text-gray-400" />
        <h4 className="mt-3 text-base md:text-lg text-center font-semibold">
          {t("empty_notifications")->str}
        </h4>
      </div>
    : entries
      |> Js.Array.map(entry =>
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
                  | Some(actor) =>
                    avatar(User.avatarUrl(actor), User.name(actor))
                  | None => React.null
                  }}
               </div>
               <div>
                 <div> {str(Entry.message(entry))} </div>
                 <span className="block text-xs text-gray-800 pt-1">
                   <span className="hidden md:inline-block md:mr-2">
                     {"on "
                      ++ Entry.createdAt(entry)
                         ->DateFns.formatPreset(~year=true, ())
                      |> str}
                   </span>
                 </span>
                 <div className="flex justify-between mt-4">
                   <a
                     href={"/notifications/" ++ Entry.id(entry)}
                     className="inline-flex items-center font-semibold p-2 md:py-1 bg-gray-100 hover:bg-gray-300 border rounded text-xs flex-shrink-0">
                     <i className="fas fa-eye mr-2" />
                     {str("Visit")}
                   </a>
                   <button
                     className="inline-flex items-center font-semibold p-2 md:py-1 bg-gray-100 hover:bg-gray-300 border rounded text-xs flex-shrink-0">
                     <i className="fas fa-check mr-2" />
                     {str("Mark as Read")}
                   </button>
                 </div>
               </div>
             </div>
           </div>
         )
      |> React.array;
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
    | Unread(bool)
    | Title(string);

  let label = s =>
    switch (s) {
    | Event(_event) => Some(t("filter.event"))
    | Title(_) => Some(t("filter.title"))
    | Unread(_) => Some(t("filter.unread"))
    };

  let value = s =>
    switch (s) {
    | Event(event) => eventName(event)
    | Title(search) => search
    | Unread(unread) => unread ? t("filter.unread") : t("filter.read")
    };

  let searchString = s =>
    switch (s) {
    | Event(event) => t("filter.event") ++ " " ++ eventName(event)
    | Title(search) => search
    | Unread(_unread) => t("filter.unread") ++ " " ++ t("filter.read")
    };

  let color = t => {
    switch (t) {
    | Event(_event) => "blue"
    | Title(_search) => "gray"
    | Unread(unread) => unread ? "orange" : "green"
    };
  };

  let event = event => Event(event);
  let title = search => Title(search);
  let unread = unread => Unread(unread);
};

module Multiselect = MultiselectDropdown.Make(Selectable);

let unselected = state => {
  let eventFilters =
    Selectable.event->Array.map([|`topic_created, `topic_edited|]);

  let trimmedFilterString = state.filterString |> String.trim;
  let title =
    trimmedFilterString == ""
      ? [||] : [|Selectable.title(trimmedFilterString)|];

  let unread =
    state.filter.unread
    ->Belt.Option.mapWithDefault(
        [|Selectable.unread(true), Selectable.unread(false)|], u =>
        u ? [|Selectable.unread(false)|] : [|Selectable.unread(true)|]
      );

  eventFilters |> Js.Array.concat(title) |> Js.Array.concat(unread);
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

  let unread =
    state.filter.unread
    ->Belt.Option.mapWithDefault([||], u => [|Selectable.unread(u)|]);

  selectedEventFilters
  |> Js.Array.concat(selectedSearchString)
  |> Js.Array.concat(unread);
};

let onSelectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.Event(event) => send(SetEvent(event))
  | Title(title) => send(SetSearchString(title))
  | Unread(unread) => send(unread ? SetShowUnread : SetShowRead)
  };

let onDeselectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.Event(_e) => send(ClearEvent)
  | Title(_title) => send(UnsetSearchString)
  | Unread(_) => send(ClearUnread)
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
           <div className="space-y-2"> {entriesList(entries)} </div>
           <div className="text-center">
             {entriesLoadedData(
                state.totalEntriesCount,
                Array.length(entries),
              )}
           </div>
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
         <div>
           <div className="space-y-2"> {entriesList(entries)} </div>
           <div className="text-center">
             {entriesLoadedData(
                state.totalEntriesCount,
                Array.length(entries),
              )}
           </div>
         </div>
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
