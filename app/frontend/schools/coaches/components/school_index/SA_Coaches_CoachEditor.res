open CoachesSchoolIndex__Types

exception UnexpectedResponse(int)

let t = I18n.t(~scope="components.SA_Coaches_CoachEditor")
let ts = I18n.t(~scope="shared")

let apiErrorTitle = x =>
  switch x {
  | UnexpectedResponse(code) => code |> string_of_int
  | _ => "Something went wrong!"
  }

type state = {
  name: string,
  email: string,
  title: string,
  public: bool,
  exited: bool,
  connectLink: string,
  imageFileName: string,
  dirty: bool,
  saving: bool,
  hasNameError: bool,
  hasTitleError: bool,
  hasEmailError: bool,
  hasLinkedInUrlError: bool,
  hasConnectLinkError: bool,
  affiliation: string,
}

type action =
  | UpdateName(string, bool)
  | UpdateEmail(string, bool)
  | UpdateTitle(string, bool)
  | UpdateConnectLink(string, bool)
  | UpdatePublic(bool)
  | UpdateImageFileName(string)
  | MarkAsActive
  | MarkAsExited
  | UpdateAffiliation(string)
  | UpdateSaving

let reducer = (state, action) =>
  switch action {
  | UpdateName(name, hasNameError) => {
      ...state,
      name,
      hasNameError,
      dirty: true,
    }
  | UpdateTitle(title, hasTitleError) => {
      ...state,
      title,
      hasTitleError,
      dirty: true,
    }
  | UpdateEmail(email, hasEmailError) => {
      ...state,
      email,
      hasEmailError,
      dirty: true,
    }

  | UpdateConnectLink(connectLink, hasConnectLinkError) => {
      ...state,
      connectLink,
      hasConnectLinkError,
      dirty: true,
    }
  | UpdatePublic(public) => {...state, public, dirty: true}
  | UpdateSaving => {...state, saving: !state.saving}
  | UpdateImageFileName(imageFileName) => {
      ...state,
      imageFileName,
      dirty: true,
    }
  | MarkAsActive => {...state, exited: false, dirty: true}
  | MarkAsExited => {...state, exited: true, dirty: true}
  | UpdateAffiliation(affiliation) => {...state, affiliation, dirty: true}
  }

let str = React.string

let nameOrTitleInvalid = name => Js.String.trim(name) |> Js.String.length < 2

let updateName = (send, name) => send(UpdateName(name, name |> nameOrTitleInvalid))

let emailInvalid = email => email |> EmailUtils.isInvalid(false)

let updateEmail = (send, email) => send(UpdateEmail(email, email |> emailInvalid))

let updateTitle = (send, title) => send(UpdateTitle(title, title |> nameOrTitleInvalid))

let updateConnectLink = (send, connectLink) =>
  send(UpdateConnectLink(connectLink, connectLink |> UrlUtils.isInvalid(true)))

let booleanButtonClasses = selected => {
  let classes = "toggle-button__button"
  classes ++ (selected ? " toggle-button__button--active" : "")
}

let saveDisabled = state =>
  state.title |> nameOrTitleInvalid ||
    (state.name |> nameOrTitleInvalid ||
    (state.email |> emailInvalid ||
      (state.hasLinkedInUrlError ||
      (state.connectLink |> UrlUtils.isInvalid(true) || (!state.dirty || state.saving)))))

let computeInitialState = coach =>
  switch coach {
  | None => {
      name: "",
      email: "",
      title: "",
      public: false,
      connectLink: "",
      exited: false,
      dirty: false,
      saving: false,
      hasNameError: false,
      hasEmailError: false,
      hasTitleError: false,
      hasLinkedInUrlError: false,
      hasConnectLinkError: false,
      imageFileName: "",
      affiliation: "",
    }
  | Some(coach) => {
      name: coach->Coach.name,
      email: coach->Coach.email,
      title: coach->Coach.title,
      public: coach->Coach.public,
      connectLink: switch coach->Coach.connectLink {
      | Some(connectLink) => connectLink
      | None => ""
      },
      exited: coach->Coach.exited,
      dirty: false,
      saving: false,
      hasNameError: false,
      hasEmailError: false,
      hasTitleError: false,
      hasLinkedInUrlError: false,
      hasConnectLinkError: false,
      imageFileName: switch coach->Coach.imageFileName {
      | Some(imageFileName) => imageFileName
      | None => ""
      },
      affiliation: coach->Coach.affiliation->OptionUtils.toString,
    }
  }

@react.component
let make = (~coach, ~closeFormCB, ~authenticityToken) => {
  let (state, send) = React.useReducerWithMapState(reducer, coach, computeInitialState)

  let formId = "coach-create-form"

  let avatarUploaderText = () =>
    switch state.imageFileName {
    | "" => t("upload_avatar")
    | _ => t("replace_avatar") ++ ": " ++ state.imageFileName
    }

  let handleResponseJSON = json => {
    let error =
      json
      |> {
        open Json.Decode
        field("error", nullable(string))
      }
      |> Js.Null.toOption

    switch error {
    | Some(err) =>
      send(UpdateSaving)
      Notification.error(ts("notifications.something_wrong"), err)
    | None => ()
    }
  }
  let sendCoach = formData => {
    let endPoint = switch coach {
    | Some(coach) => "/school/coaches/" ++ coach->Coach.id
    | None => "/school/coaches/"
    }
    let httpMethod = switch coach {
    | Some(_coach) => Fetch.Patch
    | None => Fetch.Post
    }
    open Js.Promise
    Fetch.fetchWithInit(
      endPoint,
      Fetch.RequestInit.make(
        ~method_=httpMethod,
        ~body=Fetch.BodyInit.makeWithFormData(formData),
        ~credentials=Fetch.SameOrigin,
        (),
      ),
    )
    |> then_(response =>
      if Fetch.Response.ok(response) || Fetch.Response.status(response) == 422 {
        DomUtils.reload()
        response |> Fetch.Response.json
      } else {
        Js.Promise.reject(UnexpectedResponse(response |> Fetch.Response.status))
      }
    )
    |> then_(json => handleResponseJSON(json) |> resolve)
    |> catch(error => {
      let title = PromiseUtils.errorToExn(error)->apiErrorTitle
      send(UpdateSaving)
      Notification.error(title, ts("notifications.try_again"))
      Js.Promise.resolve()
    })
    |> ignore
  }
  let submitForm = event => {
    ReactEvent.Form.preventDefault(event)
    send(UpdateSaving)
    let element = ReactDOM.querySelector("#" ++ formId)
    switch element {
    | Some(element) => sendCoach(DomUtils.FormData.create(element))
    | None => ()
    }
  }
  <div className="blanket">
    <div className="drawer-right">
      <div className="drawer-right__close absolute">
        <button
          ariaLabel="close"
          title="close"
          onClick={_e => closeFormCB()}
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-s-full rounded-e-none hover:text-gray-600 focus:outline-none focus:text-primary-500 mt-4">
          <i className="fas fa-times text-xl" />
        </button>
      </div>
      <div className="drawer-right-form w-full">
        <div className="w-full">
          <div className="mx-auto bg-white">
            <div className="max-w-2xl px-6 pt-5 mx-auto">
              <h5 className="uppercase text-center border-b border-gray-300 pb-2">
                {switch coach {
                | Some(coach) => coach->Coach.name
                | None => t("add_coach")
                }->str}
              </h5>
            </div>
            <form key="xxx" id=formId onSubmit={event => submitForm(event)}>
              <input name="authenticity_token" type_="hidden" value=authenticityToken />
              <div className="max-w-2xl px-6 pb-6 mx-auto">
                <div className="mt-5">
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="name">
                    {t("name")->str}
                  </label>
                  <span> {"*"->str} </span>
                  <input
                    autoFocus=true
                    className="appearance-none block w-full bg-white text-gray-800 border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
                    id="name"
                    type_="text"
                    name="faculty[name]"
                    placeholder={t("coach_name")}
                    value=state.name
                    onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
                  />
                  <School__InputGroupError
                    message={t("input_group_error")} active=state.hasNameError
                  />
                </div>
                {switch coach {
                | Some(_coach) => React.null
                | None =>
                  <div className="mt-5">
                    <label
                      className="inline-block tracking-wide text-xs font-semibold" htmlFor="email">
                      {t("email")->str}
                    </label>
                    <span> {"*"->str} </span>
                    <input
                      className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
                      id="email"
                      type_="email"
                      name="faculty[email]"
                      placeholder={t("coach_email")}
                      value=state.email
                      onChange={event => updateEmail(send, ReactEvent.Form.target(event)["value"])}
                    />
                    <School__InputGroupError
                      message={t("email_input_error")} active=state.hasEmailError
                    />
                  </div>
                }}
                <div className="mt-5">
                  <label
                    className="inline-block tracking-wide text-xs font-semibold" htmlFor="title">
                    {t("title")->str}
                  </label>
                  <span> {"*"->str} </span>
                  <input
                    className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
                    id="title"
                    type_="text"
                    name="faculty[title]"
                    placeholder={t("coach_title")}
                    value=state.title
                    onChange={event => updateTitle(send, ReactEvent.Form.target(event)["value"])}
                  />
                  <School__InputGroupError
                    message={t("coach_title_error")} active=state.hasTitleError
                  />
                </div>
                <div className="mt-5">
                  <label
                    className="inline-block tracking-wide text-xs font-semibold"
                    htmlFor="affiliation">
                    {t("affiliation")->str}
                  </label>
                  <input
                    value=state.affiliation
                    onChange={event =>
                      send(UpdateAffiliation(ReactEvent.Form.target(event)["value"]))}
                    className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
                    id="affiliation"
                    name="faculty[affiliation]"
                    type_="text"
                    placeholder={t("affiliation_placeholder")}
                  />
                </div>
                <div className="mt-5">
                  <label
                    className="inline-block tracking-wide text-xs font-semibold"
                    htmlFor="connectLink">
                    {t("connect_link")->str}
                  </label>
                  <input
                    className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
                    id="connectLink"
                    type_="text"
                    name="faculty[connect_link]"
                    placeholder={t("connect_link_placeholder")}
                    value=state.connectLink
                    onChange={event =>
                      updateConnectLink(send, ReactEvent.Form.target(event)["value"])}
                  />
                  <School__InputGroupError
                    message={t("connect_link_error")} active=state.hasConnectLinkError
                  />
                  <School__InputGroupError
                    warn=true
                    message={t("coach_profile_warn")}
                    active={StringUtils.isPresent(state.connectLink) &&
                    (!state.hasConnectLinkError &&
                    !state.public)}
                  />
                </div>
                <div className="mt-5" ariaLabel="public-profile-selector">
                  <div className="flex items-center shrink-0">
                    <label
                      className="block tracking-wide text-xs font-semibold me-3"
                      htmlFor="evaluated">
                      {t("coach_public_q")->str}
                    </label>
                    <div id="notification" className="flex shrink-0 overflow-hidden ">
                      <div>
                        <button
                          type_="submit"
                          onClick={_event => {
                            ReactEvent.Mouse.preventDefault(_event)
                            send(UpdatePublic(true))
                          }}
                          name="faculty[public]"
                          value="true"
                          className={booleanButtonClasses(state.public)}>
                          {ts("_yes")->str}
                        </button>
                        <button
                          onClick={_event => {
                            ReactEvent.Mouse.preventDefault(_event)
                            send(UpdatePublic(false))
                          }}
                          className={booleanButtonClasses(!state.public)}>
                          {ts("_no")->str}
                        </button>
                      </div>
                      <input
                        type_="hidden" name="faculty[public]" value={state.public |> string_of_bool}
                      />
                    </div>
                  </div>
                </div>
                <div className="mt-5">
                  <label
                    className="block tracking-wide text-xs font-semibold" htmlFor="avatarUploader">
                    {ts("avatar")->str}
                  </label>
                  <div
                    className="rounded focus-within:outline-none focus-within:ring-2 focus-within:ring-focusColor-500">
                    <input
                      disabled=state.saving
                      className="absolute w-0 h-0"
                      name="faculty[image]"
                      type_="file"
                      id="sa-coach-editor__file-input"
                      required=false
                      multiple=false
                      onChange={event =>
                        send(
                          UpdateImageFileName(ReactEvent.Form.target(event)["files"][0]["name"]),
                        )}
                    />
                    <label className="file-input-label mt-2" htmlFor="sa-coach-editor__file-input">
                      <i className="fas fa-upload me-2 text-primary-300 text-lg" />
                      <span className="truncate"> {avatarUploaderText()->str} </span>
                    </label>
                  </div>
                </div>
              </div>
              <div className="p-6 bg-white border-t border-gray-200">
                <div className="max-w-2xl px-6 mx-auto">
                  <div className="flex max-w-2xl w-full justify-between items-center mx-auto">
                    {switch coach {
                    | Some(_coach) =>
                      <div className="flex items-center shrink-0">
                        <label
                          className="block tracking-wide  text-xs font-semibold me-3"
                          htmlFor="evaluated">
                          {t("coach_status")->str}
                        </label>
                        <div id="exited" className="flex shrink-0 overflow-hidden">
                          <div>
                            <button
                              onClick={_event => {
                                ReactEvent.Mouse.preventDefault(_event)
                                send(MarkAsActive)
                              }}
                              name="faculty[exited]"
                              className={booleanButtonClasses(!state.exited)}>
                              {t("active")->str}
                            </button>
                            <button
                              onClick={_event => {
                                ReactEvent.Mouse.preventDefault(_event)
                                send(MarkAsExited)
                              }}
                              className={booleanButtonClasses(state.exited)}>
                              {t("exited")->str}
                            </button>
                          </div>
                          <input
                            type_="hidden"
                            name="faculty[exited]"
                            value={state.exited |> string_of_bool}
                          />
                        </div>
                      </div>
                    | None => React.null
                    }}
                    <button
                      disabled={saveDisabled(state)} className="w-auto btn btn-large btn-primary">
                      {switch coach {
                      | Some(_coach) => t("coach_update")
                      | None => t("coach_add")
                      }->str}
                    </button>
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
}
