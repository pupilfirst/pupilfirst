open SchoolCustomize__Types

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
  mutation SortSchoolLinksMutation($linkIds: [ID!]!,$kind:String!) {
    sortSchoolLinks(linkIds:$linkIds,kind:$kind) {
      success
    }
  }
  `)

let handleMoveLink = (
  ~id,
  ~direction,
  ~setUpdating,
  ~setIsEditingDisabled,
  ~kind: SchoolLinks.kind,
  ~links,
  ~moveLinkCB,
) => {
  let linkIds = links |> List.map(((id, _, _, _)) => id) |> Array.of_list

  let linkKind = switch kind {
  | SchoolLinks.HeaderLink => "header"
  | SchoolLinks.FooterLink => "footer"
  | SchoolLinks.SocialLink => "social"
  }

  setUpdating(_ => true)
  SortSchoolLinkQuery.make(~linkIds, ~kind=linkKind, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(_ => {
    setUpdating(_ => false)
    setIsEditingDisabled(_ => true)
    moveLinkCB(id, direction)
    Js.Promise.resolve()
  })
  |> ignore
  ()
}

let handleDelete = (state: SchoolLinks.state, send, removeLinkCB, id, event) => {
  event |> ReactEvent.Mouse.preventDefault

  if state.deleting |> List.mem(id) {
    ()
  } else {
    send(SchoolLinks.DisableDelete(id))

    DestroySchoolLinkQuery.make(~id, ())
    |> GraphqlQuery.sendQuery
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

let handleLinkEdit = (~setUpdating, ~setIsEditingDisabled, ~updateLinkCB, ~id, ~title, ~url) => {
  setUpdating(_ => true)
  UpdateSchoolLinkQuery.make(~id, ~title, ~url, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(_ => {
    setUpdating(_ => false)
    setIsEditingDisabled(_ => true)
    updateLinkCB(id, title, url)
    Js.Promise.resolve()
  })
  |> ignore
  ()
}

@react.component
let make = (
  ~id,
  ~title,
  ~url,
  ~state,
  ~send,
  ~removeLinkCB,
  ~updateLinkCB,
  ~kind: SchoolLinks.kind,
  ~index,
  ~total,
  ~links,
  ~moveLinkCB,
) => {
  let (isEditingDisabled, setIsEditingDisabled) = React.useState(_ => true)
  let (_title, setTitle) = React.useState(_ => title)
  let (_url, setUrl) = React.useState(_ => url)
  let (updating, setUpdating) = React.useState(_ => false)
  let (error, setError) = React.useState(_ => false)

  <DisablingCover disabled=updating message="Updating...">
    <div
      className={"flex justify-between items-center gap-8 bg-gray-100 text-xs text-gray-900 border rounded mt-2"}>
      <div className="flex items-center flex-1">
        {isEditingDisabled
          ? <div className="pl-3">
              {switch kind {
              | HeaderLink
              | FooterLink => <>
                  <span> {title |> str} </span>
                  <FaIcon classes="fas fa-link mx-2" />
                  <code> {url |> str} </code>
                </>
              | SocialLink => <code> {url |> str} </code>
              }}
            </div>
          : <>
              {switch kind {
              | HeaderLink
              | FooterLink => <>
                  <input
                    value=_title
                    required=true
                    autoFocus=true
                    className=inputClasses
                    placeholder="A short title for a new link"
                    onChange={event => {
                      let value = ReactEvent.Form.target(event)["value"]
                      setTitle(_ => value)
                    }}
                  />
                  <FaIcon classes="fas fa-link mx-2" />
                </>
              | SocialLink => React.null
              }}
              <div className="flex flex-col gap-1 flex-1">
                <input
                  value=_url
                  type_="url"
                  required=true
                  placeholder="Full URL, staring with https://"
                  className={inputClasses ++ " flex-1 invalid:ring-red-500"}
                  autoFocus={kind == SocialLink}
                  onChange={event => {
                    let value = ReactEvent.Form.target(event)["value"]
                    setError(_ => value |> UrlUtils.isInvalid(false))
                    setUrl(_ => value)
                  }}
                />
                <School__InputGroupError active={error} message="Invalid Url" />
              </div>
            </>}
      </div>
      <div>
        {isEditingDisabled
          ? <div>
              <button
                ariaLabel={"Edit " ++ title}
                title={"Edit " ++ url}
                onClick={e =>
                  handleMoveLink(
                    ~id,
                    ~direction=Customizations.Down,
                    ~kind,
                    ~moveLinkCB,
                    ~links,
                    ~setIsEditingDisabled,
                    ~setUpdating,
                  )}
                disabled={index == total - 1}
                className="p-3 hover:text-primary-500 focus:text-primary-500">
                <FaIcon classes="fas fa-arrow-down" />
              </button>
              <button
                ariaLabel={"Edit " ++ title}
                title={"Edit " ++ url}
                disabled={index == 0}
                onClick={e =>
                  handleMoveLink(
                    ~id,
                    ~direction=Customizations.Up,
                    ~kind,
                    ~moveLinkCB,
                    ~links,
                    ~setIsEditingDisabled,
                    ~setUpdating,
                  )}
                className={"p-3 hover:text-primary-500 focus:text-primary-500"}>
                <FaIcon classes="fas fa-arrow-up" />
              </button>
              <button
                ariaLabel={"Edit " ++ title}
                title={"Edit " ++ url}
                onClick={e => setIsEditingDisabled(_ => false)}
                className="p-3 hover:text-primary-500 focus:text-primary-500">
                <FaIcon classes="fas fa-edit" />
              </button>
              <button
                ariaLabel={"Delete " ++ title}
                title={"Delete " ++ url}
                onClick={handleDelete(state, send, removeLinkCB, id)}
                className="p-3 hover:text-red-500 focus:text-red-500">
                <FaIcon classes={deleteIconClasses(state.deleting |> List.mem(id))} />
              </button>
            </div>
          : <div>
              <button
                ariaLabel={"Cancel Editing " ++ title}
                title={"Cancel Editing " ++ url}
                onClick={e => {
                  setIsEditingDisabled(_ => true)
                  setTitle(_ => title)
                  setError(_ => url |> UrlUtils.isInvalid(false))
                  setUrl(_ => url)
                }}
                className="p-3 hover:text-primary-500 focus:text-primary-500">
                <FaIcon classes={"fas fa-times"} />
              </button>
              <button
                ariaLabel={"Update " ++ title}
                title={"Update " ++ url}
                disabled={error}
                onClick={e =>
                  if !error {
                    handleLinkEdit(
                      ~setUpdating,
                      ~setIsEditingDisabled,
                      ~id,
                      ~updateLinkCB,
                      ~title=_title,
                      ~url=_url,
                    )
                  }}
                className="p-3 hover:text-primary-500 focus:text-primary-500">
                <FaIcon classes={"fas fa-check"} />
              </button>
            </div>}
      </div>
    </div>
  </DisablingCover>
}
