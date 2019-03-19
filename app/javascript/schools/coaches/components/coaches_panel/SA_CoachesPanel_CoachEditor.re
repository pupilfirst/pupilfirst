open CoachesPanel__Types;

open SchoolAdmin__Utils;

exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

type state = {
  name: string,
  imageUrl: string,
  email: string,
  title: string,
  linkedinUrl: string,
  public: bool,
  connectLink: string,
  notifyForSubmission: bool,
  imageFileName: string,
  dirty: bool,
  saving: bool,
  hasNameError: bool,
  hasTitleError: bool,
  hasEmailError: bool,
  hasLinkedInUrlError: bool,
  hasConnectLinkError: bool
};

type action =
  | UpdateName(string, bool)
  | UpdateEmail(string, bool)
  | UpdateTitle(string, bool)
  | UpdateLinkedInUrl(string, bool)
  | UpdateConnectLink(string, bool)
  | UpdatePublic(bool)
  | UpdateNotifyForSubmission(bool)
  | UpdateImageFileName(string)
  | UpdateSaving;

let component = ReasonReact.reducerComponent("SA_CoachesPanel_CoachEditor");

let str = ReasonReact.string;

let updateName = (send, name) => {
  let hasError = name |> String.length < 2;
  send(UpdateName(name, hasError));
};

let updateEmail = (send, email) => {
  let regex = [%re {|/.+@.+\..+/i|}];
  let hasError = ! Js.Re.test(email, regex);
  send(UpdateEmail(email, hasError));
};

let updateTitle = (send, title) => {
  let hasError = title |> String.length < 2;
  send(UpdateTitle(title, hasError));
};

let updateLinkedInUrl = (send, linkedinUrl) => {
  let regex = [%re
    {|/^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/|}
  ];
  let hasError =
    linkedinUrl |> String.length < 1 ?
      false : ! Js.Re.test(linkedinUrl, regex);
  send(UpdateLinkedInUrl(linkedinUrl, hasError));
};

let updateConnectLink = (send, connectLink) => {
  let regex = [%re
    {|/^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/|}
  ];
  let hasError =
    connectLink |> String.length < 1 ?
      false : ! Js.Re.test(connectLink, regex);
  send(UpdateConnectLink(connectLink, hasError));
};

let booleanButtonClasses = bool =>
  bool ?
    "w-1/2 bg-grey hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none" :
    "w-1/2 bg-white hover:bg-grey text-grey-darkest text-sm font-semibold py-2 px-6 focus:outline-none";

let saveDisabled = state =>
  state.hasTitleError
  || state.hasNameError
  || state.hasEmailError
  || state.hasLinkedInUrlError
  || state.hasConnectLinkError
  || ! state.dirty
  || state.saving;

let make =
    (
      ~schoolId,
      ~coach,
      ~closeFormCB,
      ~updateCoachCB,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  initialState: () =>
    switch (coach) {
    | None => {
        name: "",
        imageUrl: "",
        email: "",
        title: "",
        linkedinUrl: "",
        public: false,
        connectLink: "",
        notifyForSubmission: false,
        dirty: false,
        saving: false,
        hasNameError: false,
        hasEmailError: false,
        hasTitleError: false,
        hasLinkedInUrlError: false,
        hasConnectLinkError: false,
        imageFileName: ""
      }
    | Some(coach) => {
        name: coach |> Coach.name,
        imageUrl: coach |> Coach.imageUrl,
        email: coach |> Coach.email,
        title: coach |> Coach.title,
        linkedinUrl:
          switch (coach |> Coach.linkedinUrl) {
          | Some(linkedinUrl) => linkedinUrl
          | None => ""
          },
        public: coach |> Coach.public,
        connectLink:
          switch (coach |> Coach.connectLink) {
          | Some(connectLink) => connectLink
          | None => ""
          },
        notifyForSubmission: coach |> Coach.notifyForSubmission,
        dirty: false,
        saving: false,
        hasNameError: false,
        hasEmailError: false,
        hasTitleError: false,
        hasLinkedInUrlError: false,
        hasConnectLinkError: false,
        imageFileName:
          switch (coach |> Coach.imageFileName) {
          | Some(imageFileName) => imageFileName
          | None => ""
          },
      }
    },
  reducer: (action, state) =>
    switch (action) {
    | UpdateName(name, hasNameError) =>
      ReasonReact.Update({...state, name, hasNameError, dirty: true})
    | UpdateTitle(title, hasTitleError) =>
      ReasonReact.Update({...state, title, hasTitleError, dirty: true})
    | UpdateEmail(email, hasEmailError) =>
      ReasonReact.Update({...state, email, hasEmailError, dirty: true})
    | UpdateLinkedInUrl(linkedinUrl, hasLinkedInUrlError) =>
      ReasonReact.Update({
        ...state,
        linkedinUrl,
        hasLinkedInUrlError,
        dirty: true,
      })
    | UpdateConnectLink(connectLink, hasConnectLinkError) =>
      ReasonReact.Update({
        ...state,
        connectLink,
        hasConnectLinkError,
        dirty: true,
      })
    | UpdatePublic(public) =>
      ReasonReact.Update({...state, public, dirty: true})
    | UpdateNotifyForSubmission(notifyForSubmission) =>
      ReasonReact.Update({...state, notifyForSubmission, dirty: true})
    | UpdateSaving => ReasonReact.Update({...state, saving: ! state.saving})
    | UpdateImageFileName(imageFileName) => ReasonReact.Update({...state, imageFileName, dirty: true})
    },
  render: ({state, send}) => {
    let formId = "coach-create-form";
    let addCoach = json => {
      let id = json |> Json.Decode.(field("id", int));
      let imageUrl = json |> Json.Decode.(field("image_url", string));
      let newCoach = Coach.create(id, state.name, imageUrl, state.email, state.title, Some(state.linkedinUrl), state.public, Some(state.connectLink), state.notifyForSubmission, Some(state.imageFileName));
      switch (coach) {
        | Some(_) =>
          Notification.success("Success", "Coach updated successfully")
        | None => Notification.success("Success", "Coach created successfully")
        };
      updateCoachCB(newCoach);
      closeFormCB();
    }
    let avatarUploaderText = () =>
      switch (state.imageFileName) {
      | "" => "Upload an avatar"
      | _ => "Replace avatar: " ++ state.imageFileName
      }

    let handleResponseJSON = json => {
      let error =
        json
        |> Json.Decode.(field("error", nullable(string)))
        |> Js.Null.toOption;
      switch (error) {
      | Some(err) => Notification.error("Something went wrong!", err)
      | None => addCoach(json)
      };
    };
    let sendCoach = formData => {
      let endPoint =
        switch (coach) {
        | Some(coach) =>
          "/school/coaches/" ++ (coach |> Coach.id |> string_of_int)
        | None => "/school/coaches/"
        };
      let httpMethod =
        switch (coach) {
        | Some(coach) => Fetch.Patch
        | None => Fetch.Post
        };
      Js.Promise.(
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
             if (Fetch.Response.ok(response)
                 || Fetch.Response.status(response) == 422) {
               response |> Fetch.Response.json;
             } else {
               Js.Promise.reject(
                 UnexpectedResponse(response |> Fetch.Response.status),
               );
             }
           )
        |> then_(json => handleResponseJSON(json) |> resolve)
        |> catch(error =>
             (
               switch (error |> handleApiError) {
               | Some(code) =>
                 Notification.error(code |> string_of_int, "Please try again")
               | None =>
                 Notification.error(
                   "Something went wrong!",
                   "Please try again",
                 )
               }
             )
             |> resolve
           )
        |> ignore
      );
    };
    let submitForm = event => {
      ReactEvent.Form.preventDefault(event);
      send(UpdateSaving);
      let element = ReactDOMRe._getElementById(formId);
      switch (element) {
      | Some(element) => sendCoach(FormData.create(element))
      | None => ()
      };
    };
    <div className="blanket">
      <div className="drawer-right relative">
        <div className="drawer-right__close absolute">
          <button
            onClick=(_e => closeFormCB())
            className="flex items-center justify-center bg-white text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons"> ("close" |> str) </i>
          </button>
        </div>
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-md p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-grey-light pb-2 mb-4">
                  ("Coach Details" |> str)
                </h5>
                <form
                  key="xxx"
                  id=formId
                  onSubmit=(event => submitForm(event))>
                  <input
                    name="authenticity_token"
                    type_="hidden"
                    value=authenticityToken
                  />
                  <label
                    className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                    htmlFor="name">
                    ("Name" |> str)
                  </label>
                  <span> ("*" |> str) </span>
                  <input
                    className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                    id="name"
                    type_="text"
                    name="faculty[name]"
                    placeholder="Coach Name"
                    value={state.name}
                    onChange=(
                      event =>
                        updateName(
                          send,
                          ReactEvent.Form.target(event)##value,
                        )
                    )
                  />
                  (
                    state.hasNameError ?
                      <div className="drawer-right-form__error-msg">
                        ("not a valid name" |> str)
                      </div> :
                      ReasonReact.null
                  )
                  <label
                    className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                    htmlFor="email">
                    ("Email" |> str)
                  </label>
                  <span> ("*" |> str) </span>
                  <input
                    className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                    id="email"
                    type_="email"
                    name="faculty[email]"
                    placeholder="Coach email address"
                    value={state.email}
                    onChange=(
                      event =>
                        updateEmail(
                          send,
                          ReactEvent.Form.target(event)##value,
                        )
                    )
                  />
                  (
                    state.hasEmailError ?
                      <div className="drawer-right-form__error-msg">
                        ("not a valid email" |> str)
                      </div> :
                      ReasonReact.null
                  )
                  <label
                    className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                    htmlFor="title">
                    ("Title" |> str)
                  </label>
                  <span> ("*" |> str) </span>
                  <input
                    className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                    id="title"
                    type_="text"
                    name="faculty[title]"
                    placeholder="Coach Title/Expertise"
                    value={state.title}
                    onChange=(
                      event =>
                        updateTitle(
                          send,
                          ReactEvent.Form.target(event)##value,
                        )
                    )
                  />
                  (
                    state.hasTitleError ?
                      <div className="drawer-right-form__error-msg">
                        ("not a valid title" |> str)
                      </div> :
                      ReasonReact.null
                  )
                  <label
                    className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                    htmlFor="linkedIn">
                    ("LinkedIn" |> str)
                  </label>
                  <input
                    className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                    id="linkedIn"
                    type_="text"
                    name="faculty[linkedin_url]"
                    placeholder="LinkedIn Profile URL"
                    value={ state.linkedinUrl}
                    onChange=(
                      event =>
                        updateLinkedInUrl(
                          send,
                          ReactEvent.Form.target(event)##value,
                        )
                    )
                  />
                  (
                    state.hasLinkedInUrlError ?
                      <div className="drawer-right-form__error-msg">
                        ("not a valid URL" |> str)
                      </div> :
                      ReasonReact.null
                  )
                  <label
                    className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                    htmlFor="connectLink">
                    ("Connect Link" |> str)
                  </label>
                  <input
                    className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
                    id="connectLink"
                    type_="text"
                    name="faculty[connect_link]"
                    placeholder="Student connect request link for the coach"
                    value={state.connectLink}
                    onChange=(
                      event =>
                        updateConnectLink(
                          send,
                          ReactEvent.Form.target(event)##value,
                        )
                    )
                  />
                  (
                    state.hasConnectLinkError ?
                      <div className="drawer-right-form__error-msg">
                        ("not a valid URL" |> str)
                      </div> :
                      ReasonReact.null
                  )
                  <div className="flex items-center mb-6">
                    <label
                      className="block w-1/2 tracking-wide text-grey-darker text-xs font-semibold mr-6"
                      htmlFor="evaluated">
                      ("Should the faculty profile be public?" |> str)
                    </label>
                    <div
                      id="notification"
                      className="inline-flex w-1/2 rounded-lg overflow-hidden border">
                      <button
                        type_="submit"
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            send(UpdatePublic(true));
                          }
                        )
                        name="faculty[public]"
                        value="true"
                        className=(booleanButtonClasses(state.public))>
                        ("Yes" |> str)
                      </button>
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            send(UpdatePublic(false));
                          }
                        )
                        className=(booleanButtonClasses(! state.public))>
                        ("No" |> str)
                      </button>
                      <input
                        type_="hidden"
                        name="faculty[public]"
                        value={state.public |> string_of_bool}
                      />
                    </div>
                  </div>
                  <div className="flex items-center mb-6">
                    <label
                      className="w-1/2 block tracking-wide text-grey-darker text-xs font-semibold mr-6"
                      htmlFor="evaluated">
                      (
                        "Should the coach be notified of student submissions?"
                        |> str
                      )
                    </label>
                    <div
                      id="notification"
                      className="inline-flex w-1/2 rounded-lg overflow-hidden border">
                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            send(UpdateNotifyForSubmission(true));
                          }
                        )
                        name="faculty[notify_for_submission]"
                        className=(
                          booleanButtonClasses(state.notifyForSubmission)
                        )>
                        ("Yes" |> str)
                      </button>

                      <button
                        onClick=(
                          _event => {
                            ReactEvent.Mouse.preventDefault(_event);
                            send(UpdateNotifyForSubmission(false));
                          }
                        )
                        className=(
                          booleanButtonClasses(! state.notifyForSubmission)
                        )>
                        ("No" |> str)
                      </button>
                      <input
                        type_="hidden"
                        name="faculty[notify_for_submission]"
                        value={state.notifyForSubmission |> string_of_bool}
                      />
                    </div>
                  </div>
                  <label
                       className="block tracking-wide text-grey-darker text-xs font-semibold mb-2"
                       htmlFor="avatarUploader">
                       ("Avatar" |> str)
                     </label>
                     <div
                       className="input-file__container flex items-center relative mb-4">
                       <input
                         disabled={state.saving}
                         className="input-file__input cursor-pointer px-4"
                         name="faculty[image]"
                         type_="file"
                         id="file"
                         required=false
                         multiple=false
                         onChange={
                          event =>
                            send(
                              UpdateImageFileName(
                                ReactEvent.Form.target(event)##files[0]##name,
                              ),
                            )
                        }
                       />
                       <label
                         className="input-file__label flex px-4 items-center font-semibold rounded text-sm"
                         htmlFor="file">
                         <i className="material-icons mr-2 text-grey-dark">
                           ("file_upload" |> str)
                         </i>
                         <span className="truncate">
                           (avatarUploaderText() |> str)
                         </span>
                       </label>
                     </div>
                  <div className="flex max-w-md w-full px-6 pb-5 mx-auto">
                    (
                      switch (coach) {
                      | Some(coach) =>
                        <button
                          disabled=(saveDisabled(state))
                          className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 shadow rounded focus:outline-none mt-3">
                          ("Update Coach" |> str)
                        </button>
                      | None =>
                        <button
                          disabled=(saveDisabled(state))
                          className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 shadow rounded focus:outline-none mt-3">
                          ("Create Coach" |> str)
                        </button>
                      }
                    )
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>;
  },
};
