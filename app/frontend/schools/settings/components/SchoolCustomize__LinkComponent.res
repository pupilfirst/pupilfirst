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

module MoveSchoolLinkQuery = %graphql(`
  mutation MoveSchoolLinkMutation($id: ID!,$direction: MoveDirection!) {
    moveSchoolLink(id:$id,direction:$direction) {
      success
    }
  }
  `)

let handleMoveLink = (~id, ~kind, ~direction: Customizations.direction, ~send, ~moveLinkCB) => {
  send(SetUpdating(true))
  MoveSchoolLinkQuery.make({
    id,
    direction: switch direction {
    | Up => #Up
    | Down => #Down
    },
  })
  |> Js.Promise.then_(_ => {
    send(SetUpdating(false))
    moveLinkCB(id, kind, direction)
    send(SetEditing(false))
    Js.Promise.resolve()
  })
  |> ignore
}

let handleDelete = (deleting, disableDeleteCB, removeLinkCB, id, event) => {
  event |> ReactEvent.Mouse.preventDefault

  if deleting |> List.mem(id) {
    ()
  } else {
    disableDeleteCB(id)
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

let handleLinkEdit = (~send, ~updateLinkCB, ~id, ~title: string, ~url) => {
  send(SetUpdating(true))
  UpdateSchoolLinkQuery.make({id, title: Some(title), url})
  |> Js.Promise.then_(_ => {
    send(SetUpdating(false))
    send(SetEditing(false))
    updateLinkCB(id, title, url)
    Js.Promise.resolve()
  })
  |> ignore
  ()
}

let initialState = (title: string, url: string) => {
  {
    title,
    url,
    editing: false,
    error: false,
    updating: false,
  }
}

let reducer = (state, action) => {
  switch action {
  | SetEditing(editing) => {...state, editing}
  | UpdateTitle(title) => {...state, title}
  | UpdateUrl(url) => {...state, url}
  | SetError(error) => {...state, error}
  | SetUpdating(updating) => {...state, updating}
  }
}

module LinkEditor = {
  @react.component
  let make = (~originalUrl, ~kind, ~send, ~state) => {
    <>
      {switch kind {
      | SchoolLinks.HeaderLink
      | FooterLink =>
        <>
          <input
            value=state.title
            required=true
            autoFocus=true
            id={"link-title-" ++ originalUrl}
            className=inputClasses
            placeholder="A short title for a new link"
            onChange={event => {
              let value = ReactEvent.Form.target(event)["value"]
              send(UpdateTitle(value))
            }}
          />
          <FaIcon classes="fas fa-link mx-2" />
        </>
      | SocialLink => React.null
      }}
      <div className="flex flex-col gap-1 flex-1">
        <input
          value=state.url
          type_="url"
          id={"link-url-" ++ originalUrl}
          required=true
          placeholder="Full URL, staring with https://"
          className={inputClasses ++ " flex-1 invalid:ring-red-500"}
          autoFocus={kind == SocialLink}
          onChange={event => {
            let value = ReactEvent.Form.target(event)["value"]
            send(SetError(value |> UrlUtils.isInvalid(false)))
            send(UpdateUrl(value))
          }}
        />
        <School__InputGroupError active={state.error} message="Invalid Url" />
      </div>
    </>
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
  let (state, send) = React.useReducer(reducer, initialState(title, url))

  <DisablingCover disabled=state.updating message="Updating...">
    <div
      className={"flex justify-between items-center gap-8 bg-gray-50 text-xs text-gray-900 border rounded mt-2"}>
      <div className="flex items-center flex-1">
        {state.editing
          ? <LinkEditor state originalUrl=url kind send />
          : <div className="pl-3">
              {switch kind {
              | HeaderLink
              | FooterLink =>
                <>
                  <span className="inline-block mr-2 font-semibold"> {title |> str} </span>
                  <PfIcon className="if i-link-regular if-fw mr-1" />
                  <code> {url |> str} </code>
                </>
              | SocialLink => <code> {url |> str} </code>
              }}
            </div>}
      </div>
      <div>
        {state.editing
          ? <div>
              <button
                ariaLabel={"Cancel Editing " ++ title}
                title={"Cancel Editing " ++ title}
                onClick={e => {
                  send(SetEditing(false))
                  send(UpdateTitle(title))
                  send(UpdateUrl(url))
                  send(SetError(url |> UrlUtils.isInvalid(false)))
                }}
                className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500 ">
                <PfIcon className="if i-times-solid if-fw text-base" />
              </button>
              <button
                ariaLabel={"Update " ++ url}
                title={"Update " ++ url}
                disabled={state.error}
                onClick={e =>
                  if !state.error {
                    handleLinkEdit(~send, ~id, ~updateLinkCB, ~title=state.title, ~url=state.url)
                  }}
                className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500">
                <FaIcon classes={"fas fa-check"} />
              </button>
            </div>
          : <div>
              <button
                ariaLabel={"Move Down " ++ url}
                title={"Move Down " ++ url}
                onClick={e => handleMoveLink(~id, ~kind, ~direction=Down, ~moveLinkCB, ~send)}
                disabled={index == total - 1}
                className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500">
                <FaIcon classes="fas fa-arrow-down" />
              </button>
              <button
                ariaLabel={"Move Up " ++ url}
                title={"Move Up " ++ url}
                disabled={index == 0}
                onClick={e => handleMoveLink(~id, ~kind, ~direction=Up, ~moveLinkCB, ~send)}
                className={"p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500"}>
                <FaIcon classes="fas fa-arrow-up" />
              </button>
              <button
                ariaLabel={"Edit " ++ url}
                title={"Edit " ++ url}
                onClick={e => send(SetEditing(true))}
                className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500">
                <FaIcon classes="fas fa-edit" />
              </button>
              <button
                ariaLabel={"Delete " ++ url}
                title={"Delete " ++ url}
                onClick={handleDelete(deleting, disableDeleteCB, removeLinkCB, id)}
                className="p-3 hover:text-red-500 hover:bg-red-50 focus:bg-red-50 focus:text-red-500">
                <FaIcon classes={deleteIconClasses(deleting |> List.mem(id))} />
              </button>
            </div>}
      </div>
    </div>
  </DisablingCover>
}
