open SchoolCustomize__Types

let t = I18n.t(~scope="components.SchoolCustomize__LinkComponent")
let ts = I18n.t(~scope="shared")

type kind = HeaderLink | FooterLink | SocialLink

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
  MoveSchoolLinkQuery.fetch(
    ~notify=false,
    {
      id: id,
      direction: switch direction {
      | Up => #Up
      | Down => #Down
      },
    },
  )
  |> Js.Promise.then_(_ => {
    send(SetUpdating(false))
    moveLinkCB(id, kind, direction)
    send(SetEditing(false))
    Js.Promise.resolve()
  })
  |> ignore
}

let handleDelete = (deleting, disableDeleteCB, removeLinkCB, id, event) => {
  event->ReactEvent.Mouse.preventDefault

  if deleting->Js.Array2.includes(id) {
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
  UpdateSchoolLinkQuery.make({id: id, title: Some(title), url: url})
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

module LinkEditor = {
  @react.component
  let make = (~id, ~kind, ~send, ~state) => {
    <>
      {switch kind {
      | HeaderLink
      | FooterLink => <>
          <div className="flex flex-col gap-1 flex-1">
            <input
              value=state.title
              required=true
              autoFocus=true
              id={"link-title-" ++ id}
              className=inputClasses
              placeholder="A short title for a new link"
              onChange={event => {
                let value = ReactEvent.Form.target(event)["value"]
                send(UpdateTitle(value))
              }}
              maxLength=24
            />
            <School__InputGroupError
              active={!StringUtils.lengthBetween(~allowBlank=false, state.title, 1, 24)}
              message={t("invalid_title")}
            />
          </div>
          <div className="pt-2"> <FaIcon classes="fas fa-link mx-2" /> </div>
        </>
      | SocialLink => React.null
      }}
      <div className="flex flex-col gap-1 flex-1">
        <input
          value=state.url
          type_="url"
          id={"link-url-" ++ id}
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
        <School__InputGroupError active={state.error} message={t("invalid_url")} />
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

  let invalidTitle = !StringUtils.lengthBetween(~allowBlank=false, state.title, 1, 24)

  <DisablingCover disabled=state.updating message="Updating...">
    <Spread props={"data-school-link-id": id}>
      <div
        className={"flex justify-between items-center gap-8 bg-gray-50 text-xs text-gray-900 border rounded mt-2"}>
        <div className="flex items-start flex-1 p-2">
          {state.editing
            ? <LinkEditor state id kind send />
            : <div className="ps-3 ">
                {switch kind {
                | HeaderLink
                | FooterLink => <>
                    <span className="inline-block me-4 font-semibold"> {title->str} </span>
                    <PfIcon className="if i-link-regular if-fw me-1" />
                    <code className="bg-gray-200 px-1"> {url->str} </code>
                  </>
                | SocialLink => <code> {url->str} </code>
                }}
              </div>}
        </div>
        <div>
          {state.editing
            ? <div className="grid grid-cols-2">
                <button
                  ariaLabel={t("cancel_editing") ++ " " ++ title}
                  title={t("cancel_editing")}
                  onClick={e => {
                    send(SetEditing(false))
                    send(UpdateTitle(title))
                    send(UpdateUrl(url))
                    send(SetError(url |> UrlUtils.isInvalid(false)))
                  }}
                  className="p-3 text-center hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500 ">
                  <PfIcon className="if i-times-solid if-fw text-base" />
                </button>
                <button
                  ariaLabel={ts("update") ++ " " ++ url}
                  title={ts("update")}
                  disabled={state.error || (invalidTitle && kind != SocialLink)}
                  onClick={e =>
                    if !state.error || invalidTitle {
                      handleLinkEdit(~send, ~id, ~updateLinkCB, ~title=state.title, ~url=state.url)
                    }}
                  className="p-3 text-center hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500">
                  <FaIcon classes={"fas fa-check"} />
                </button>
              </div>
            : <div>
                <button
                  ariaLabel={t("move_down") ++ " " ++ url}
                  title={t("move_down")}
                  onClick={e => handleMoveLink(~id, ~kind, ~direction=Down, ~moveLinkCB, ~send)}
                  disabled={index == total - 1}
                  className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500">
                  <FaIcon classes="fas fa-arrow-down" />
                </button>
                <button
                  ariaLabel={t("move_up") ++ " " ++ url}
                  title={t("move_up")}
                  disabled={index == 0}
                  onClick={e => handleMoveLink(~id, ~kind, ~direction=Up, ~moveLinkCB, ~send)}
                  className={"p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500"}>
                  <FaIcon classes="fas fa-arrow-up" />
                </button>
                <button
                  ariaLabel={ts("edit") ++ " " ++ url}
                  title={ts("edit")}
                  onClick={e => send(SetEditing(true))}
                  className="p-3 hover:text-primary-500 hover:bg-primary-50 focus:bg-primary-50 focus:text-primary-500">
                  <FaIcon classes="fas fa-edit" />
                </button>
                <button
                  ariaLabel={ts("delete") ++ " " ++ url}
                  title={ts("delete")}
                  onClick={handleDelete(deleting, disableDeleteCB, removeLinkCB, id)}
                  className="p-3 hover:text-red-500 hover:bg-red-50 focus:bg-red-50 focus:text-red-500">
                  <FaIcon classes={deleteIconClasses(deleting->Js.Array2.includes(id))} />
                </button>
              </div>}
        </div>
      </div>
    </Spread>
  </DisablingCover>
}
