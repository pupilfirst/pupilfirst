open SchoolCustomize__Types

type action =
  | SetEditing(bool)
  | UpdateTitle(string)
  | UpdateUrl(string)
  | SetError(bool)
  | SetUpdating(bool)

type state = {
  title: string,
  url: string,
  editing: bool,
  error: bool,
  updating: bool,
}

let str = React.string

let inputClasses = "bg-white border border-gray-400 rounded py-2 px-3 focus:outline-none focus:ring-2 focus:ring-indigo-500 placeholder-gray-500"

let deleteIconClasses = deleting => deleting ? "fas fa-spinner fa-pulse" : "far fa-trash-alt"

module DestroySchoolLinkQuery = %graphql(`
  mutation DestroySchoolLinkMutation($id: ID!) {
    destroySchoolLink(id: $id) {
      success
    }
  }
  `)

module SortSchoolLinkQuery = %graphql(`
  mutation SortSchoolLinksMutation($id: ID!,$direction:MoveDirection!) {
    sortSchoolLinks(id:$id,direction:$direction) {
      links {
        id
        title
        url
        kind
        sortIndex
     }
    }
  }
  `)

let handleMoveLink = (~id, ~direction, ~dispatch, ~moveLinkCB) => {
  dispatch(SetUpdating(true))
  SortSchoolLinkQuery.make({id: id, direction: direction})
  |> Js.Promise.then_(response => {
    dispatch(SetUpdating(false))
    open Json.Decode
    let x = field("links", list(Customizations.decodeLink), response["sortSchoolLinks"])
    moveLinkCB(x)
    dispatch(SetEditing(false))
    Js.Promise.resolve()
  })
  |> ignore
  ()
}

let handleDelete = (deleting, disableDeleteCB, removeLinkCB, id, event) => {
  event |> ReactEvent.Mouse.preventDefault

  if deleting |> List.mem(id) {
    ()
  } else {
    disableDeleteCB(id)

    // send(SchoolLinks.DisableDelete(id))

    DestroySchoolLinkQuery.make({id: id})
    |> Js.Promise.then_(_response => {
      removeLinkCB(id)
      Js.Promise.resolve()
    })
    |> ignore
  }
}

module UpdateSchoolLinkQuery = %graphql(`
  mutation UpdateSchoolLinkMutation($id: ID!, $title: String, $url: String!) {
    updateSchoolLink(id: $id, title: $title, url: $url) {
     success
    }
  }
`)

let handleLinkEdit = (~dispatch, ~updateLinkCB, ~id, ~title: string, ~url) => {
  dispatch(SetUpdating(true))
  UpdateSchoolLinkQuery.make({id: id, title: Some(title), url: url})
  |> Js.Promise.then_(_ => {
    dispatch(SetUpdating(false))
    dispatch(SetEditing(false))
    updateLinkCB(id, title, url)
    Js.Promise.resolve()
  })
  |> ignore
  ()
}

let initialState = (title: string, url: string) => {
  {
    title: title,
    url: url,
    editing: false,
    error: false,
    updating: false,
  }
}

let reducer = (state, action) => {
  switch action {
  | SetEditing(editing) => {...state, editing: editing}
  | UpdateTitle(title) => {...state, title: title}
  | UpdateUrl(url) => {...state, url: url}
  | SetError(error) => {...state, error: error}
  | SetUpdating(updating) => {...state, updating: updating}
  }
}

@react.component
let make = (
  ~id,
  ~title,
  ~url,
  ~deleting,
  ~disableDeleteCB,
  ~removeLinkCB,
  ~updateLinkCB,
  ~kind,
  ~index,
  ~total,
  ~moveLinkCB,
) => {
  let (localState, dispatch) = React.useReducer(reducer, initialState(title, url))

  <DisablingCover disabled=localState.updating message="Updating...">
    <div
      className={"flex justify-between items-center gap-8 bg-gray-50 text-xs text-gray-900 border rounded mt-2"}>
      <div className="flex items-center flex-1">
        {localState.editing
          ? <>
              {switch kind {
              | SchoolLinks.HeaderLink
              | FooterLink => <>
                  <input
                    value=localState.title
                    required=true
                    autoFocus=true
                    className=inputClasses
                    placeholder="A short title for a new link"
                    onChange={event => {
                      let value = ReactEvent.Form.target(event)["value"]
                      dispatch(UpdateTitle(value))
                    }}
                  />
                  <FaIcon classes="fas fa-link mx-2" />
                </>
              | SocialLink => React.null
              }}
              <div className="flex flex-col gap-1 flex-1">
                <input
                  value=localState.url
                  type_="url"
                  required=true
                  placeholder="Full URL, staring with https://"
                  className={inputClasses ++ " flex-1 invalid:ring-red-500"}
                  autoFocus={kind == SocialLink}
                  onChange={event => {
                    let value = ReactEvent.Form.target(event)["value"]
                    dispatch(SetError(value |> UrlUtils.isInvalid(false)))
                    dispatch(UpdateUrl(value))
                  }}
                />
                <School__InputGroupError active={localState.error} message="Invalid Url" />
              </div>
            </>
          : <div className="pl-3">
              {switch kind {
              | HeaderLink
              | FooterLink => <>
                  <span className="inline-block mr-2 font-semibold"> {title |> str} </span>
                  <PfIcon className="if i-link-regular if-fw mr-1" />
                  <code> {url |> str} </code>
                </>
              | SocialLink => <code> {url |> str} </code>
              }}
            </div>}
      </div>
      <div>
        {localState.editing
          ? <div>
              <button
                ariaLabel={"Cancel Editing " ++ title}
                title={"Cancel Editing " ++ title}
                onClick={e => {
                  dispatch(SetEditing(false))
                  dispatch(UpdateTitle(title))
                  dispatch(UpdateUrl(url))
                  dispatch(SetError(url |> UrlUtils.isInvalid(false)))
                }}
                className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500 ">
                <PfIcon className="if i-times-solid if-fw text-base" />
              </button>
              <button
                ariaLabel={"Update " ++ title}
                title={"Update " ++ title}
                disabled={localState.error}
                onClick={e =>
                  if !localState.error {
                    handleLinkEdit(
                      ~dispatch,
                      ~id,
                      ~updateLinkCB,
                      ~title=localState.title,
                      ~url=localState.url,
                    )
                  }}
                className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500">
                <FaIcon classes={"fas fa-check"} />
              </button>
            </div>
          : <div>
              <button
                ariaLabel={"Move Down " ++ title}
                title={"Move Down " ++ title}
                onClick={e => handleMoveLink(~id, ~direction=#Down, ~moveLinkCB, ~dispatch)}
                disabled={index == total - 1}
                className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500">
                <FaIcon classes="fas fa-arrow-down" />
              </button>
              <button
                ariaLabel={"Move up " ++ title}
                title={"Move up " ++ title}
                disabled={index == 0}
                onClick={e => handleMoveLink(~id, ~direction=#Up, ~moveLinkCB, ~dispatch)}
                className={"p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500"}>
                <FaIcon classes="fas fa-arrow-up" />
              </button>
              <button
                ariaLabel={"Edit " ++ title}
                title={"Edit " ++ title}
                onClick={e => dispatch(SetEditing(true))}
                className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500">
                <FaIcon classes="fas fa-edit" />
              </button>
              <button
                ariaLabel={"Delete " ++ title}
                title={"Delete " ++ title}
                onClick={handleDelete(deleting, disableDeleteCB, removeLinkCB, id)}
                className="p-3 hover:text-red-500 hover:bg-red-50 focus:bg-red-50 focus:text-red-500">
                <FaIcon classes={deleteIconClasses(deleting |> List.mem(id))} />
              </button>
            </div>}
      </div>
    </div>
  </DisablingCover>
}
