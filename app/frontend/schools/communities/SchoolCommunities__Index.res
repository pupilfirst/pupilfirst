let str = React.string

let tr = I18n.t(~scope="components.SchoolCommunities__Index")
let ts = I18n.t(~scope="shared")

open SchoolCommunities__IndexTypes

type editorAction =
  | ShowEditor(option<Community.t>)
  | Hidden

type state = {
  editorAction: editorAction,
  communities: list<Community.t>,
  showCategoryEditor: bool,
  dirtyTopicCategoryIds: Belt.Set.String.t,
  newCategoryInputDirty: bool,
}

type action =
  | UpdateShowCategoryEditor(bool)
  | UpdateEditorAction(editorAction)
  | UpdateCommunities(list<Community.t>)
  | SaveCommunityChanges(list<Community.t>)
  | DeleteCategory(Community.t, string)
  | AddCategory(Community.t, Category.t)
  | UpdateCategory(Community.t, Category.t)
  | UpdateDirtyTopicCategoryIds(string, bool)
  | UpdateNewCategoryInputDirty(bool)

let reducer = (state, action) =>
  switch action {
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
  | DeleteCategory(community, categoryId) =>
    let updatedCommunity = Community.removeCategory(community, categoryId)

    {
      ...state,
      communities: state.communities |> List.map(c =>
        Community.id(c) == Community.id(community) ? updatedCommunity : c
      ),
      editorAction: ShowEditor(Some(updatedCommunity)),
    }

  | AddCategory(community, category) =>
    let updatedCommunity = Community.addCategory(community, category)

    {
      ...state,
      communities: state.communities |> List.map(c =>
        Community.id(c) == Community.id(community) ? updatedCommunity : c
      ),
      editorAction: ShowEditor(Some(updatedCommunity)),
    }

  | UpdateCategory(community, category) =>
    let updatedCommunity = Community.updateCategory(community, category)

    {
      ...state,
      communities: state.communities |> List.map(c =>
        Community.id(c) == Community.id(community) ? updatedCommunity : c
      ),
      editorAction: ShowEditor(Some(updatedCommunity)),
    }

  | UpdateDirtyTopicCategoryIds(id, dirty) => {
      ...state,
      dirtyTopicCategoryIds: dirty
        ? Belt.Set.String.add(state.dirtyTopicCategoryIds, id)
        : Belt.Set.String.remove(state.dirtyTopicCategoryIds, id),
    }
  | UpdateNewCategoryInputDirty(newCategoryInputDirty) => {
      ...state,
      newCategoryInputDirty,
    }
  }

let setDirtyCategory = (send, categoryId, dirty) =>
  switch categoryId {
  | Some(id) => send(UpdateDirtyTopicCategoryIds(id, dirty))
  | None => send(UpdateNewCategoryInputDirty(dirty))
  }

let categoryEditorDirty = state =>
  !Belt.Set.String.isEmpty(state.dirtyTopicCategoryIds) || state.newCategoryInputDirty

let handleCloseCategoryManager = (send, state) =>
  categoryEditorDirty(state)
    ? if {
        open Webapi.Dom
        window->Window.confirm(tr("unsaved_window_confirm"))
      } {
        send(UpdateShowCategoryEditor(false))
      } else {
        ()
      }
    : send(UpdateShowCategoryEditor(false))

@react.component
let make = (~communities, ~courses) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      editorAction: Hidden,
      communities,
      showCategoryEditor: false,
      dirtyTopicCategoryIds: Belt.Set.String.empty,
      newCategoryInputDirty: false,
    },
  )

  let updateCommunitiesCB = community => {
    let communities = state.communities |> Community.updateList(community)

    send(UpdateCommunities(communities))
  }

  let addCommunityCB = community => {
    let communities = state.communities |> List.append(list{community})
    send(SaveCommunityChanges(communities))
  }
  <div className="bg-gray-50 min-h-full">
    {switch state.editorAction {
    | Hidden => React.null
    | ShowEditor(community) =>
      let level = state.showCategoryEditor ? 1 : 0
      <SchoolAdmin__EditorDrawer2
        closeButtonTitle={tr("close_community_editor")}
        level
        closeDrawerCB={() => send(UpdateEditorAction(Hidden))}>
        <SchoolCommunities__Editor
          courses
          community
          addCommunityCB
          showCategoryEditorCB={() => send(UpdateShowCategoryEditor(true))}
          categories={switch community {
          | Some(community) => Community.topicCategories(community)
          | None => []
          }}
          updateCommunitiesCB
        />
        {switch community {
        | Some(community) =>
          state.showCategoryEditor
            ? <SchoolAdmin__EditorDrawer2
                closeButtonTitle={tr("close_category_editor")}
                closeIconClassName="fas fa-arrow-left"
                closeDrawerCB={() => handleCloseCategoryManager(send, state)}>
                <SchoolCommunities__CategoryManager
                  community
                  deleteCategoryCB={categoryId => send(DeleteCategory(community, categoryId))}
                  createCategoryCB={category => send(AddCategory(community, category))}
                  updateCategoryCB={category => send(UpdateCategory(community, category))}
                  setDirtyCB={(categoryId, dirty) => setDirtyCategory(send, categoryId, dirty)}
                />
              </SchoolAdmin__EditorDrawer2>
            : React.null
        | None => React.null
        }}
      </SchoolAdmin__EditorDrawer2>
    }}
    <div className="flex px-6 py-2 items-center justify-between">
      <button
        onClick={_ => send(UpdateEditorAction(ShowEditor(None)))}
        className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:text-primary-600 hover:shadow-lg border-2 border-primary-300 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer focus:outline-none focus:border-primary-300 focus:bg-gray-50 focus:text-primary-600 focus:shadow-lg">
        <i className="fas fa-plus-circle" />
        <h5 className="font-semibold ms-2"> {tr("add_new_community") |> str} </h5>
      </button>
    </div>
    <div className="px-6 pb-4 mt-5 flex flex-1">
      <div className="max-w-2xl w-full mx-auto relative">
        {state.communities
        |> List.map(community =>
          <div
            key={community |> Community.id}
            className="flex items-center shadow overflow-hidden bg-white rounded-lg mb-4 focus-within:ring-2 focus-within:ring-focusColor-500">
            <div className="course-faculty__list-item flex w-full items-center">
              <button
                ariaLabel={"Edit " ++ (community |> Community.name)}
                onClick={_event => {
                  ReactEvent.Mouse.preventDefault(_event)
                  send(UpdateEditorAction(ShowEditor(Some(community))))
                }}
                className="course-faculty__list-item-details flex flex-1 items-center justify-between border border-transparent cursor-pointer rounded-s-lg  hover:bg-gray-50 hover:text-primary-500 hover:border-primary-400 focus:bg-gray-50 focus:text-primary-500">
                <div className="flex w-full text-sm justify-between">
                  <span className="flex-1 font-semibold py-5 px-5">
                    {community |> Community.name |> str}
                  </span>
                  <span
                    className="ms-2 py-5 px-5 font-semibold text-gray-600 hover:text-primary-500">
                    <i className="fas fa-edit text-normal" />
                    <span className="ms-1"> {ts("edit") |> str} </span>
                  </span>
                </div>
              </button>
              <a
                target="_blank"
                href={"/communities/" ++ (community |> Community.id)}
                className="text-sm flex items-center border-s text-gray-600 hover:bg-gray-50 hover:text-primary-500 focus:outline-none focus:bg-gray-50 focus:text-primary-500 font-semibold px-5 py-5">
                <i className="fas fa-external-link-alt text-normal rtl:-rotate-90" />
                <span className="ms-1"> {ts("view") |> str} </span>
              </a>
            </div>
          </div>
        )
        |> Array.of_list
        |> React.array}
      </div>
    </div>
  </div>
}
