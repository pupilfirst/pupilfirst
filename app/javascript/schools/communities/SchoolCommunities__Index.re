let str = React.string;

open SchoolCommunities__IndexTypes;

type editorAction =
  | ShowEditor(option(Community.t))
  | Hidden;

type state = {
  editorAction,
  communities: list(Community.t),
  showCategoryEditor: bool,
};

type action =
  | UpdateShowCategoryEditor(bool)
  | UpdateEditorAction(editorAction)
  | UpdateCommunities(list(Community.t))
  | SaveCommunityChanges(list(Community.t));

let reducer = (state, action) => {
  switch (action) {
  | UpdateShowCategoryEditor(showCategoryEditor) => {
      ...state,
      showCategoryEditor,
    }
  | UpdateEditorAction(editorAction) => {...state, editorAction}
  | UpdateCommunities(communities) => {...state, communities}
  | SaveCommunityChanges(communities) => {
      ...state,
      communities,
      editorAction: Hidden,
    }
  };
};

[@react.component]
let make = (~communities, ~courses) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {editorAction: Hidden, communities, showCategoryEditor: false},
    );

  let updateCommunitiesCB = community => {
    let communities = state.communities |> Community.updateList(community);

    send(SaveCommunityChanges(communities));
  };

  let addCommunityCB = community => {
    let communities = communities |> List.append([community]);
    send(SaveCommunityChanges(communities));
  };
  <div className="flex-1 flex flex-col overflow-y-scroll bg-gray-200">
    {switch (state.editorAction) {
     | Hidden => React.null
     | ShowEditor(community) =>
       let level = state.showCategoryEditor ? 1 : 0;
       <SchoolAdmin__EditorDrawer2
         level closeDrawerCB={() => send(UpdateEditorAction(Hidden))}>
         <SchoolCommunities__Editor
           courses
           community
           addCommunityCB
           showCategoryEditorCB={() => send(UpdateShowCategoryEditor(true))}
           categories={
             switch (community) {
             | Some(community) => Community.topicCategories(community)
             | None => [||]
             }
           }
           updateCommunitiesCB
         />
         {switch (community) {
          | Some(community) =>
            state.showCategoryEditor
              ? <SchoolAdmin__EditorDrawer2
                  closeIconClassName="fas fa-arrow-left"
                  closeDrawerCB={() => send(UpdateShowCategoryEditor(false))}>
                  <SchoolCommunities__CategoryManager community />
                </SchoolAdmin__EditorDrawer2>
              : React.null
          | None => React.null
          }}
       </SchoolAdmin__EditorDrawer2>;
     }}
    <div className="flex px-6 py-2 items-center justify-between">
      <button
        onClick={_ => send(UpdateEditorAction(ShowEditor(None)))}
        className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer">
        <i className="fas fa-plus-circle" />
        <h5 className="font-semibold ml-2"> {"Add New Community" |> str} </h5>
      </button>
    </div>
    <div className="px-6 pb-4 mt-5 flex flex-1">
      <div className="max-w-2xl w-full mx-auto relative">
        {state.communities
         |> List.map(community =>
              <div
                key={community |> Community.id}
                className="flex items-center shadow bg-white rounded-lg mb-4">
                <div
                  className="course-faculty__list-item flex w-full items-center">
                  <a
                    onClick={_event => {
                      ReactEvent.Mouse.preventDefault(_event);
                      send(
                        UpdateEditorAction(ShowEditor(Some(community))),
                      );
                    }}
                    className="course-faculty__list-item-details flex flex-1 items-center justify-between border border-transparent cursor-pointer rounded-l-lg hover:bg-gray-100 hover:text-primary-500 hover:border-primary-400">
                    <div className="flex w-full text-sm justify-between">
                      <span className="flex-1 font-semibold py-5 px-5">
                        {community |> Community.name |> str}
                      </span>
                      <span
                        className="ml-2 py-5 px-5 font-semibold text-gray-700 hover:text-primary-500">
                        <i className="fas fa-edit text-normal" />
                        <span className="ml-1"> {"Edit" |> str} </span>
                      </span>
                    </div>
                  </a>
                  <a
                    target="_blank"
                    href={"/communities/" ++ (community |> Community.id)}
                    className="text-sm flex items-center border-l text-gray-700 hover:bg-gray-100 hover:text-primary-500 font-semibold px-5 py-5">
                    <i className="fas fa-external-link-alt text-normal" />
                    <span className="ml-1"> {"View" |> str} </span>
                  </a>
                </div>
              </div>
            )
         |> Array.of_list
         |> ReasonReact.array}
      </div>
    </div>
  </div>;
};
