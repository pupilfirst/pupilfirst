let str = React.string

let t = I18n.t(~scope="components.SchoolAdmins__Editor")
let ts = I18n.ts

type editorAction =
  | ShowEditor(option<SchoolAdmin.t>)
  | Hidden

type state = {
  editorAction: editorAction,
  admins: array<SchoolAdmin.t>,
  deleting: bool,
}

module DeleteSchoolAdminQuery = %graphql(`
  mutation DeleteSchoolAdminMutation($id: ID!) {
    deleteSchoolAdmin(id: $id) {
      success
    }
  }
`)

let removeSchoolAdmin = (setState, admin, currentSchoolAdminId, event) => {
  event |> ReactEvent.Mouse.preventDefault

  if {
    open Webapi.Dom
    window->Window.confirm(
      t("remove_confirm_pre") ++
      " " ++
      ((admin |> SchoolAdmin.name) ++
      " " ++
      t("remove_confirm_post")),
    )
  } {
    setState(state => {...state, deleting: true})

    DeleteSchoolAdminQuery.make({id: SchoolAdmin.id(admin)})
    |> Js.Promise.then_(response => {
      if response["deleteSchoolAdmin"]["success"] {
        if (
          /*
           * If the school admin who was removed is the current user, redirect her to
           * the dashboard page. Otherwise, just remove the entry from the list.
           */
          admin |> SchoolAdmin.id == currentSchoolAdminId
        ) {
          DomUtils.redirect("/dashboard")
        } else {
          setState(state => {
            ...state,
            deleting: false,
            admins: state.admins |> Js.Array.filter(
              a => a |> SchoolAdmin.id != (admin |> SchoolAdmin.id),
            ),
          })
        }
      } else {
        setState(state => {...state, deleting: false})
      }
      response |> Js.Promise.resolve
    })
    |> ignore
  }
}

let renderAdmin = (currentSchoolAdminId, admin, admins, setState) =>
  <div
    key={(admin |> SchoolAdmin.id) ++ (admin |> SchoolAdmin.name)}
    className="flex w-1/2 shrink-0 mb-5 px-3">
    <div
      className="shadow bg-white rounded-lg flex w-full border border-transparent overflow-hidden hover:border-primary-400 hover:bg-gray-50 focus-within:outline-none focus-within:ring-2 focus-within:ring-inset focus-within:ring-focusColor-500">
      <button
        className="w-full cursor-pointer p-4 "
        onClick={_event => {
          ReactEvent.Mouse.preventDefault(_event)
          setState(state => {...state, editorAction: ShowEditor(Some(admin))})
        }}>
        <div className="flex">
          <span className="me-4 shrink-0">
            {switch admin |> SchoolAdmin.avatarUrl {
            | Some(avatarUrl) =>
              <img className="w-10 h-10 rounded-full object-cover" src=avatarUrl />
            | None => <Avatar name={admin |> SchoolAdmin.name} className="w-10 h-10 rounded-full" />
            }}
          </span>
          <div className="flex flex-col">
            <span className="text-black font-semibold text-sm">
              {admin |> SchoolAdmin.name |> str}
            </span>
            <span className="text-black font-normal text-xs">
              {admin |> SchoolAdmin.email |> str}
            </span>
          </div>
        </div>
      </button>
      {admins |> Array.length > 1
        ? <div
            className="w-10 text-sm course-faculty__list-item-remove text-gray-600 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-50 hover:text-red-600"
            title={ts("delete") ++ " " ++ (admin |> SchoolAdmin.name)}
            onClick={removeSchoolAdmin(setState, admin, currentSchoolAdminId)}>
            <i className="fas fa-trash-alt" />
          </div>
        : React.null}
    </div>
  </div>

let handleUpdate = (setState, admin) =>
  setState(state => {
    ...state,
    admins: state.admins |> SchoolAdmin.update(admin),
    editorAction: Hidden,
  })

@react.component
let make = (~currentSchoolAdminId, ~admins) => {
  let (state, setState) = React.useState(() => {
    editorAction: Hidden,
    admins,
    deleting: false,
  })

  <div className="flex min-h-full bg-gray-50">
    <div className="flex-1 flex flex-col">
      {switch state.editorAction {
      | Hidden => React.null
      | ShowEditor(admin) =>
        <SchoolAdmin__EditorDrawer
          closeDrawerCB={_ => setState(state => {...state, editorAction: Hidden})}>
          <SchoolAdmins__Form admin updateCB={handleUpdate(setState)} />
        </SchoolAdmin__EditorDrawer>
      }}
      <DisablingCover disabled=state.deleting message={ts("deleting") ++ "..."}>
        <div className="flex px-6 py-2 items-center justify-between">
          <button
            onClick={_ => setState(state => {...state, editorAction: ShowEditor(None)})}
            className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-primary-300 border-dashed hover:border-primary-300 focus:border-primary-300 focus:bg-gray-50 focus:text-primary-600 focus:shadow-lg p-6 rounded-lg mt-8 cursor-pointer">
            <i className="fas fa-plus-circle" />
            <h5 className="font-semibold ms-2"> {t("add_new_admin") |> str} </h5>
          </button>
        </div>
        <div className="px-6 pb-4 mt-5 flex">
          <div className="max-w-2xl w-full mx-auto">
            <div className="flex -mx-3 flex-wrap">
              {state.admins
              |> SchoolAdmin.sort
              |> Array.map(admin =>
                renderAdmin(currentSchoolAdminId, admin, state.admins, setState)
              )
              |> React.array}
            </div>
          </div>
        </div>
      </DisablingCover>
    </div>
  </div>
}
