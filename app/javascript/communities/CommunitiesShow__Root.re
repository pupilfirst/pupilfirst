open CommunitiesShow__Types;

let str = React.string;

type loading =
  | NotLoading
  | Reloading
  | LoadingMore;

type filter = {
  topicCategory: option(TopicCategory.t),
  title: option(string),
  target: option(Target.t),
};

type state = {
  loading,
  topics: Topics.t,
  filterString: string,
  filter,
  totalTopicsCount: int,
};

type action =
  | SelectTopicCategory(TopicCategory.t)
  | DeselectTopicCategory
  | SetSearchString(string)
  | UnsetSearchString
  | UpdateFilterString(string)
  | LoadTopics(option(string), bool, array(Topic.t), int)
  | BeginLoadingMore
  | BeginReloading;

let reducer = (state, action) => {
  switch (action) {
  | SelectTopicCategory(topicCategory) => {
      ...state,
      filter: {
        ...state.filter,
        topicCategory: Some(topicCategory),
      },
      filterString: "",
    }
  | DeselectTopicCategory => {
      ...state,
      filter: {
        ...state.filter,
        topicCategory: None,
      },
    }
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
  | LoadTopics(endCursor, hasNextPage, newTopics, totalTopicsCount) =>
    let updatedTopics =
      switch (state.loading) {
      | LoadingMore =>
        newTopics |> Array.append(state.topics |> Topics.toArray)
      | Reloading => newTopics
      | NotLoading => newTopics
      };

    {
      ...state,
      topics:
        switch (hasNextPage, endCursor) {
        | (_, None)
        | (false, Some(_)) => FullyLoaded(updatedTopics)
        | (true, Some(cursor)) => PartiallyLoaded(updatedTopics, cursor)
        },
      loading: NotLoading,
      totalTopicsCount,
    };
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  };
};

module TopicsQuery = [%graphql
  {|
    query TopicsFromCommunitiesShowRootQuery($communityId: ID!, $topicCategoryId: ID,$targetId: ID, $search: String, $after: String) {
      communityTopics(communityId: $communityId, topicCategoryId: $topicCategoryId,targetId: $targetId, search: $search, first: 10, after: $after) {
        nodes {
          id
          lastActivityAt
          createdAt
          creatorName
          likesCount
          liveRepliesCount
          title
          topicCategoryId
        }
        pageInfo{
          endCursor,hasNextPage
        }
        totalCount
      }
    }
  |}
];

let getTopics = (send, communityId, cursor, filter) => {
  let topicCategoryId =
    filter.topicCategory |> OptionUtils.map(TopicCategory.id);

  let targetId = filter.target |> OptionUtils.map(Target.id);

  TopicsQuery.make(
    ~communityId,
    ~after=?cursor,
    ~topicCategoryId?,
    ~targetId?,
    ~search=?filter.title,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       let newTopics =
         switch (response##communityTopics##nodes) {
         | None => [||]
         | Some(topicsArray) => topicsArray |> Topic.makeArrayFromJs
         };

       send(
         LoadTopics(
           response##communityTopics##pageInfo##endCursor,
           response##communityTopics##pageInfo##hasNextPage,
           newTopics,
           response##communityTopics##totalCount,
         ),
       );

       Js.Promise.resolve();
     })
  |> ignore;
};

let reloadTopics = (communityId, state, send) => {
  send(BeginReloading);
  getTopics(send, communityId, None, state.filter);
};

let computeInitialState = target => {
  loading: NotLoading,
  topics: Unloaded,
  filterString: "",
  filter: {
    title: None,
    topicCategory: None,
    target,
  },
  totalTopicsCount: 0,
};

let categoryPillClass = category => {
  let color = TopicCategory.color(category);
  "bg-" ++ color ++ "-200 text-" ++ color ++ "-900";
};

let topicsList = (topicCategories, topics) => {
  topics |> ArrayUtils.isEmpty
    ? <div
        className="flex flex-col mx-auto bg-white p-6 justify-center items-center">
        <i className="fas fa-comments text-5xl text-gray-400" />
        <h4 className="mt-3 font-semibold">
          {"There's no discussion here yet." |> str}
        </h4>
      </div>
    : topics
      |> Array.map(topic =>
           <div className="border-b" ariaLabel={"Topic " ++ Topic.id(topic)}>
             <div
               className="flex items-center border border-transparent hover:bg-gray-100 hover:text-primary-500  hover:border-primary-400">
               <div className="flex-1 w-full">
                 <a
                   className="cursor-pointer no-underline flex flex-col p-4 md:p-6"
                   href={"/topics/" ++ Topic.id(topic)}>
                   <span className="block">
                     <span
                       className="community-question__title text-sm md:text-base font-semibold inline-block break-words leading-snug">
                       {Topic.title(topic) |> str}
                     </span>
                     <span className="block text-xs mt-1">
                       <span> {"Posted by " |> str} </span>
                       <span className="font-semibold">
                         {(
                            switch (Topic.creatorName(topic)) {
                            | Some(name) => name ++ " "
                            | None => "Unknown "
                            }
                          )
                          |> str}
                       </span>
                       <span className="hidden md:inline-block md:mr-2">
                         {"on "
                          ++ Topic.createdAt(topic)
                             ->DateFns.formatPreset(~year=true, ())
                          |> str}
                       </span>
                       <span
                         className="block md:inline-block mt-1 md:mt-0 md:px-2 bg-gray-100 md:border-l border-gray-400">
                         {switch (Topic.lastActivityAt(topic)) {
                          | Some(date) =>
                            <span>
                              <span className="hidden md:inline-block">
                                {"Last updated" |> str}
                              </span>
                              <i className="fas fa-history mr-1 md:hidden" />
                              {" "
                               ++ DateFns.formatDistanceToNowStrict(
                                    date,
                                    ~addSuffix=true,
                                    (),
                                  )
                               |> str}
                            </span>
                          | None => React.null
                          }}
                       </span>
                     </span>
                   </span>
                   <span className="flex flex-row mt-2">
                     <span
                       className="flex text-center items-center mr-2 px-2 py-1 bg-gray-200"
                       ariaLabel="Likes">
                       <i
                         className="far fa-thumbs-up text-xs text-gray-600 mr-1"
                       />
                       <p className="text-xs font-semibold">
                         {(Topic.likesCount(topic) |> string_of_int)
                          ++ " Likes"
                          |> str}
                       </p>
                     </span>
                     <span
                       className="flex justify-between text-center items-center mr-2 px-2 py-1 bg-gray-200"
                       ariaLabel="Replies">
                       <i
                         className="far fa-comment-dots text-xs text-gray-600 mr-1"
                       />
                       <p className="text-xs font-semibold">
                         {(Topic.liveRepliesCount(topic) |> string_of_int)
                          ++ " Replies"
                          |> str}
                       </p>
                     </span>
                     {switch (Topic.topicCategoryId(topic)) {
                      | Some(id) =>
                        let topicCategory =
                          topicCategories
                          |> ArrayUtils.unsafeFind(
                               c => TopicCategory.id(c) == id,
                               "Unable to find topic category with ID: " ++ id,
                             );
                        <span
                          className={
                            "text-center items-center mr-2 px-2 py-1 bg-gray-200 "
                            ++ categoryPillClass(topicCategory)
                          }
                          ariaLabel="Topic Category">
                          <p className="text-xs font-semibold">
                            {TopicCategory.name(topicCategory) |> str}
                          </p>
                        </span>;
                      | None => React.null
                      }}
                   </span>
                 </a>
               </div>
               <div className="w-1/5" />
             </div>
           </div>
         )
      |> React.array;
};

let topicsLoadedData = (totalTopicsCount, loadedTopicsCount) => {
  <div className="mt-4 bg-gray-200 text-gray-900 text-sm py-1 text-center">
    {"Showing "
     ++ string_of_int(loadedTopicsCount)
     ++ " of "
     ++ string_of_int(totalTopicsCount)
     ++ " topics"
     |> str}
  </div>;
};

module Selectable = {
  type t =
    | TopicCategory(TopicCategory.t)
    | Title(string);

  let label = t =>
    switch (t) {
    | TopicCategory(_category) => Some("Category")
    | Title(_) => Some("Topic Title")
    };

  let value = t =>
    switch (t) {
    | TopicCategory(category) => TopicCategory.name(category)
    | Title(search) => search
    };

  let searchString = t =>
    switch (t) {
    | TopicCategory(category) => "category " ++ TopicCategory.name(category)
    | Title(search) => search
    };

  let color = t => {
    switch (t) {
    | TopicCategory(category) => TopicCategory.color(category)
    | Title(_search) => "gray"
    };
  };
  let topicCategory = topicCategory => TopicCategory(topicCategory);
  let title = search => Title(search);
};

module Multiselect = MultiselectDropdown.Make(Selectable);

let unselected = (topicCategories, state) => {
  let unselectedCategories =
    topicCategories
    |> Js.Array.filter(category =>
         state.filter.topicCategory
         |> OptionUtils.mapWithDefault(
              selectedCategory =>
                category->TopicCategory.id
                != selectedCategory->TopicCategory.id,
              true,
            )
       )
    |> Array.map(Selectable.topicCategory);

  let trimmedFilterString = state.filterString |> String.trim;

  let title =
    trimmedFilterString == ""
      ? [||] : [|Selectable.title(trimmedFilterString)|];

  unselectedCategories |> Array.append(title);
};

let selected = state => {
  let selectedCategory =
    state.filter.topicCategory
    |> OptionUtils.mapWithDefault(
         selectedCategory => [|Selectable.topicCategory(selectedCategory)|],
         [||],
       );

  let selectedSearchString =
    state.filter.title
    |> OptionUtils.mapWithDefault(
         title => {[|Selectable.title(title)|]},
         [||],
       );

  selectedCategory |> Array.append(selectedSearchString);
};

let onSelectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.TopicCategory(topicCategory) =>
    send(SelectTopicCategory(topicCategory))
  | Title(title) => send(SetSearchString(title))
  };

let onDeselectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.TopicCategory(_topicCategory) => send(DeselectTopicCategory)
  | Title(_title) => send(UnsetSearchString)
  };

let filterPlaceholder = state => {
  switch (state.filter.topicCategory, state.filter.title) {
  | (None, None) => "Filter by category, or search by topic title.."
  | _ => ""
  };
};

[@react.component]
let make = (~communityId, ~target, ~topicCategories) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, target, computeInitialState);

  React.useEffect1(
    () => {
      reloadTopics(communityId, state, send);
      None;
    },
    [|state.filter|],
  );
  <div className="flex-1 flex flex-col">
    {switch (target) {
     | Some(target) =>
       <div className="max-w-3xl w-full mt-5 mx-auto px-3 md:px-0">
         <div
           className="flex py-4 px-4 md:px-6 w-full bg-yellow-100 border border-dashed border-yellow-400 rounded justify-between items-center">
           <p className="w-3/5 md:w-4/5 font-semibold text-sm">
             {"Target: " ++ Target.title(target) |> str}
           </p>
           <a
             className="no-underline bg-yellow-100 border border-yellow-400 px-3 py-2 hover:bg-yellow-200 rounded-lg cursor-pointer text-xs font-semibold"
             href={"/communities/" ++ communityId}>
             {"Clear Filter" |> str}
           </a>
         </div>
       </div>
     | None => React.null
     }}
    <div className="px-3 md:px-6 pb-4 mt-5 flex flex-1">
      <div className="max-w-3xl w-full mx-auto relative">
        <div
          className="max-w-3xl mx-auto bg-gray-100 sticky md:static md:top-0">
          <Multiselect
            id="filter"
            unselected={unselected(topicCategories, state)}
            selected={selected(state)}
            onSelect={onSelectFilter(send)}
            onDeselect={onDeselectFilter(send)}
            value={state.filterString}
            onChange={filterString => send(UpdateFilterString(filterString))}
            placeholder={filterPlaceholder(state)}
          />
        </div>
        <div
          className="community-question__list-container shadow bg-white rounded-lg mb-4 mt-10">
          {switch (state.topics) {
           | Unloaded =>
             SkeletonLoading.multiple(
               ~count=10,
               ~element=SkeletonLoading.card(),
             )
           | PartiallyLoaded(topics, cursor) =>
             <div>
               {topicsList(topicCategories, topics)}
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
                      getTopics(
                        send,
                        communityId,
                        Some(cursor),
                        state.filter,
                      );
                    }}>
                    {"Load More..." |> str}
                  </button>
                | Reloading => React.null
                }}
             </div>
           | FullyLoaded(topics) => topicsList(topicCategories, topics)
           }}
        </div>
        {ReactUtils.nullIf(
           switch (state.topics) {
           | Unloaded => React.null
           | PartiallyLoaded(topics, _cursor) =>
             <div>
               {switch (state.loading) {
                | LoadingMore => React.null
                | NotLoading =>
                  topicsLoadedData(
                    state.totalTopicsCount,
                    Array.length(topics),
                  )
                | Reloading => React.null
                }}
             </div>
           | FullyLoaded(topics) =>
             topicsLoadedData(state.totalTopicsCount, Array.length(topics))
           },
           state.totalTopicsCount == 0,
         )}
      </div>
    </div>
  </div>;
};
