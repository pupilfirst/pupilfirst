open SchoolCommunities__IndexTypes

let str = React.string

let ts = I18n.t(~scope="shared")
let tr = I18n.t(~scope="components.SchoolCommunities__CategoryEditor")

type state = {
  categoryName: string,
  saving: bool,
  deleting: bool,
}

type action =
  | UpdateCategoryName(string)
  | StartSaving
  | FinishSaving(string)
  | FailSaving
  | StartDeleting
  | FailDeleting

let reducer = (state, action) =>
  switch action {
  | UpdateCategoryName(categoryName) => {...state, categoryName}
  | StartSaving => {...state, saving: true}
  | FinishSaving(categoryName) => {...state, saving: false, categoryName}
  | FailSaving => {...state, saving: false}
  | StartDeleting => {...state, deleting: true}
  | FailDeleting => {...state, deleting: false}
  }

module CreateCategoryQuery = %graphql(`
  mutation CreateCategoryMutation($name: String!, $communityId: ID!) {
    createTopicCategory(name: $name, communityId: $communityId ) {
      id
    }
  }
`)

module DeleteCategoryQuery = %graphql(`
  mutation DeleteCategoryMutation($id: ID!) {
    deleteTopicCategory(id: $id ) {
      success
    }
  }
`)

module UpdateCategoryQuery = %graphql(`
  mutation UpdateCategoryMutation($name: String!, $id: ID!) {
    updateTopicCategory(id: $id, name: $name ) {
      success
    }
  }
`)

let makeDeleteCategoryQuery = (categoryId, deleteCategoryCB, send) => {
  send(StartDeleting)
  DeleteCategoryQuery.fetch({id: categoryId})
  |> Js.Promise.then_((response: DeleteCategoryQuery.t) => {
    response.deleteTopicCategory.success ? deleteCategoryCB(categoryId) : send(FailDeleting)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailDeleting)
    Notification.error(ts("notifications.unexpected_error"), ts("notifications.please_reload"))
    Js.Promise.resolve()
  })
  |> ignore
}

let deleteCategory = (category, deleteCategoryCB, send, event) => {
  ReactEvent.Mouse.preventDefault(event)

  let categoryId = Category.id(category)
  let topicsCount = Category.topicsCount(category)

  topicsCount > 0
    ? if {
        open Webapi.Dom
        window->Window.confirm(tr("topics_delete_confirm"))
      } {
        makeDeleteCategoryQuery(categoryId, deleteCategoryCB, send)
      } else {
        ()
      }
    : makeDeleteCategoryQuery(categoryId, deleteCategoryCB, send)
}

let updateCategory = (category, newName, updateCategoryCB, send, event) => {
  ReactEvent.Mouse.preventDefault(event)

  let trimmedName = String.trim(newName)

  send(StartSaving)

  let variables = UpdateCategoryQuery.makeVariables(
    ~id=Category.id(category),
    ~name=trimmedName,
    (),
  )

  UpdateCategoryQuery.fetch(variables)
  |> Js.Promise.then_((response: UpdateCategoryQuery.t) => {
    response.updateTopicCategory.success
      ? {
          updateCategoryCB(Category.updateName(newName, category))
          send(FinishSaving(newName))
        }
      : send(FailSaving)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    send(FailSaving)
    Js.log(error)
    Notification.error(ts("notifications.unexpected_error"), ts("notifications.please_reload"))
    Js.Promise.resolve()
  })
  |> ignore
}

let createCategory = (communityId, name, createCategoryCB, send, event) => {
  ReactEvent.Mouse.preventDefault(event)

  let trimmedName = String.trim(name)

  send(StartSaving)

  CreateCategoryQuery.fetch({communityId, name: trimmedName})
  |> Js.Promise.then_((response: CreateCategoryQuery.t) => {
    switch response.createTopicCategory.id {
    | Some(id) =>
      let newCategory = Category.make(~id, ~name, ~topicsCount=0)
      createCategoryCB(newCategory)
      send(FinishSaving(""))
    | None => send(FailSaving)
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Notification.error(ts("notifications.unexpected_error"), ts("notifications.please_reload"))
    Js.Promise.resolve()
  })
  |> ignore
}

let saveDisabled = (name, saving) => String.trim(name) == "" || saving

@react.component
let make = (
  ~category=?,
  ~communityId,
  ~deleteCategoryCB,
  ~createCategoryCB,
  ~updateCategoryCB,
  ~setDirtyCB,
) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      categoryName: switch category {
      | Some(category) => Category.name(category)
      | None => ""
      },
      saving: false,
      deleting: false,
    },
  )
  let dirty = switch category {
  | Some(category) => Category.name(category) != state.categoryName
  | None => String.trim(state.categoryName) != ""
  }

  React.useEffect1(() => {
    let categoryId = Belt.Option.flatMap(category, category => Some(Category.id(category)))
    setDirtyCB(categoryId, dirty)
    None
  }, [dirty])
  switch category {
  | Some(category) =>
    let categoryId = Category.id(category)
    let presentCategoryName = Category.name(category)
    let (backgroundColor, color) = Category.color(category)
    <div
      key=categoryId
      ariaLabel={tr("editor_category_alt") ++ categoryId}
      className="flex justify-between items-center bg-gray-50 border-gray-300 shadow rounded mt-3 px-2 py-1 topic-category-editor">
      <div className="flex-1 items-center me-2">
        <input
          id="category-name"
          onChange={event => {
            let newName = ReactEvent.Form.target(event)["value"]
            send(UpdateCategoryName(newName))
          }}
          value=state.categoryName
          className="text-sm me-1 font-semibold px-2 py-1 w-full outline-none"
        />
      </div>
      <div>
        {presentCategoryName == state.categoryName
          ? <span
              className="text-xs py-1 px-2 me-2"
              style={ReactDOM.Style.make(~backgroundColor, ~color, ())}>
              {tr(~count=Category.topicsCount(category), "topics")->str}
            </span>
          : <button
              title={tr("update_category")}
              disabled={saveDisabled(state.categoryName, state.saving)}
              onClick={updateCategory(category, state.categoryName, updateCategoryCB, send)}
              className="btn btn-success me-2 text-xs">
              {tr("update_category") |> str}
            </button>}
        <button
          title={tr("delete_category")}
          onClick={deleteCategory(category, deleteCategoryCB, send)}
          className="text-xs py-1 px-2 h-8 text-gray-600 hover:text-red-500 hover:bg-gray-50 focus:text-red-500 focus:bg-gray-50 border-s border-gray-300">
          <FaIcon classes={state.deleting ? "fas fa-spinner fa-spin" : "fas fa-trash-alt"} />
        </button>
      </div>
    </div>
  | None =>
    <div className="flex mt-2">
      <input
        autoFocus=true
        id="add-new-category"
        onChange={event => {
          let name = ReactEvent.Form.target(event)["value"]
          send(UpdateCategoryName(name))
        }}
        value=state.categoryName
        placeholder={tr("add_new_category")}
        className="appearance-none h-10 block w-full text-gray-600 border rounded border-gray-300 py-2 px-4 text-sm hover:bg-gray-50 focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
      />
      {
        let showButton = state.categoryName |> String.trim != ""
        showButton
          ? <button
              disabled={saveDisabled(state.categoryName, state.saving)}
              onClick={createCategory(communityId, state.categoryName, createCategoryCB, send)}
              className="btn btn-success ms-2 text-sm">
              {tr("save_category") |> str}
            </button>
          : React.null
      }
    </div>
  }
}
