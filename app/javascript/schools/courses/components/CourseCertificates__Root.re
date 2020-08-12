open CourseCertificates__Types;

let str = React.string;
let t = I18n.t(~scope="components.CourseCertificates__Root");

type drawer =
  | NewCertificate
  | EditCertificate(Certificate.t)
  | Closed;

type state = {
  name: string,
  imageFilename: option(string),
  drawer,
  saving: bool,
  deleting: bool,
  certificates: array(Certificate.t),
};

let computeInitialState = certificates => {
  name: "",
  imageFilename: None,
  drawer: Closed,
  saving: false,
  deleting: false,
  certificates,
};

type action =
  | OpenNewCertificateDrawer
  | OpenEditCertificateDrawer(Certificate.t)
  | UpdateName(string)
  | UpdateImageFilename(string)
  | RemoveFilename
  | CloseDrawer
  | BeginSaving
  | FinishCreating(array(Certificate.t))
  | UpdateCertificates(array(Certificate.t))
  | FailSaving
  | BeginDeleting
  | FinishDeleting(Certificate.t)
  | FailDeleting;

let reducer = (state, action) =>
  switch (action) {
  | OpenNewCertificateDrawer => {...state, drawer: NewCertificate}
  | OpenEditCertificateDrawer(certificate) => {
      ...state,
      drawer: EditCertificate(certificate),
    }
  | UpdateName(name) => {...state, name}
  | UpdateImageFilename(filename) => {
      ...state,
      imageFilename: Some(filename),
    }
  | RemoveFilename => {...state, imageFilename: None}
  | CloseDrawer => {...state, drawer: Closed}
  | BeginSaving => {...state, saving: true}
  | FinishCreating(certificates) => {
      ...state,
      saving: false,
      drawer: Closed,
      certificates,
      imageFilename: None,
    }
  | FailSaving => {...state, saving: false}
  | UpdateCertificates(certificates) => {...state, certificates}
  | BeginDeleting => {...state, deleting: true}
  | FinishDeleting(certificate) => {
      ...state,
      certificates:
        Js.Array.filter(
          c => Certificate.id(c) != Certificate.id(certificate),
          state.certificates,
        ),
      deleting: false,
    }
  | FailDeleting => {...state, deleting: false}
  };

let saveDisabled = state => {
  state.imageFilename == None || state.saving;
};

let submitForm = (course, send, event) => {
  ReactEvent.Form.preventDefault(event);
  send(BeginSaving);

  let formData =
    ReactEvent.Form.target(event)
    ->DomUtils.EventTarget.unsafeToElement
    ->DomUtils.FormData.create;

  let url = "/school/courses/" ++ Course.id(course) ++ "/certificates";

  Api.sendFormData(
    url,
    formData,
    json => {
      Notification.success(
        t("done_exclamation"),
        t("success_notification"),
      );

      let certificates =
        json
        |> Json.Decode.(field("certificates", array(Certificate.decode)));

      send(FinishCreating(certificates));
    },
    () => send(FailSaving),
  );
};

let imageInputText = imageFilename =>
  imageFilename->Belt.Option.getWithDefault(
    t("certificate_base_image_placeholder"),
  );

let selectFile = (send, event) => {
  let files = ReactEvent.Form.target(event)##files;

  // The user can cancel the selection, which will result in files being an empty array.
  if (ArrayUtils.isEmpty(files)) {
    send(RemoveFilename);
  } else {
    let file = Js.Array.unsafe_get(files, 0);
    send(UpdateImageFilename(file##name));
  };
};

let newCertificateDrawer = (course, state, send) =>
  <SchoolAdmin__EditorDrawer
    closeDrawerCB={() => send(CloseDrawer)} closeButtonTitle={t("cancel")}>
    <form onSubmit={submitForm(course, send)}>
      <input
        name="authenticity_token"
        type_="hidden"
        value={AuthenticityToken.fromHead()}
      />
      <div className="flex flex-col min-h-screen">
        <div className="bg-white flex-grow-0">
          <div className="max-w-2xl px-6 pt-5 mx-auto">
            <h5
              className="uppercase text-center border-b border-gray-400 pb-2">
              {t("create_action")->str}
            </h5>
          </div>
          <div className="max-w-2xl pt-6 px-6 mx-auto">
            <div className="max-w-2xl pb-6 mx-auto">
              <div className="mt-5">
                <label
                  className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                  htmlFor="name">
                  {t("name_label")->str}
                </label>
                <span className="text-xs">
                  {" (" ++ t("optional") ++ ")" |> str}
                </span>
                <input
                  className="appearance-none block w-full bg-white text-gray-800 border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                  id="name"
                  type_="text"
                  name="name"
                  placeholder={t("name_placeholder")}
                  value={state.name}
                  onChange={event =>
                    send(UpdateName(ReactEvent.Form.target(event)##value))
                  }
                />
              </div>
              <div className="mt-5">
                <label
                  className="block tracking-wide text-xs font-semibold"
                  htmlFor="certificate-file-input">
                  {t("certificate_base_image_label")->str}
                </label>
                <input
                  disabled={state.saving}
                  className="hidden"
                  name="image"
                  type_="file"
                  id="certificate-file-input"
                  required=false
                  multiple=false
                  onChange={selectFile(send)}
                />
                <label
                  className="file-input-label mt-2"
                  htmlFor="certificate-file-input">
                  <i className="fas fa-upload mr-2 text-gray-600 text-lg" />
                  <span className="truncate">
                    {imageInputText(state.imageFilename)->str}
                  </span>
                </label>
              </div>
            </div>
          </div>
        </div>
        <div className="bg-gray-100 flex-grow">
          <div className="max-w-2xl p-6 mx-auto">
            <button
              disabled={saveDisabled(state)}
              className="w-auto btn btn-large btn-primary">
              {t("create_action")->str}
            </button>
          </div>
        </div>
      </div>
    </form>
  </SchoolAdmin__EditorDrawer>;

let updateCertificate = (state, send, certificate) => {
  let newCertificates =
    Js.Array.map(
      c =>
        Certificate.id(c) == Certificate.id(certificate) ? certificate : c,
      state.certificates,
    );

  send(UpdateCertificates(newCertificates));
};

module DeleteCertificateMutation = [%graphql
  {|
  mutation DeleteCertificateMutation($id: ID!) {
    deleteCertificate(id: $id) {
      success
    }
  }
|}
];

let deleteCertificate = (certificate, send) => {
  send(BeginDeleting);

  DeleteCertificateMutation.make(~id=Certificate.id(certificate), ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
       if (result##deleteCertificate##success) {
         send(FinishDeleting(certificate));
       } else {
         send(FailDeleting);
       };

       Js.Promise.resolve();
     })
  |> Js.Promise.catch(error => {
       Js.log(error);
       send(FailDeleting);
       Js.Promise.resolve();
     })
  |> ignore;
};

[@react.component]
let make = (~course, ~certificates, ~verifyImageUrl) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, certificates, computeInitialState);

  <DisablingCover
    containerClasses="w-full" disabled={state.deleting} message="Deleting...">
    <div className="flex flex-1 h-screen overflow-y-scroll">
      {switch (state.drawer) {
       | NewCertificate => newCertificateDrawer(course, state, send)
       | EditCertificate(certificate) =>
         <CourseCertificates__Editor
           certificate
           verifyImageUrl
           closeDrawerCB={() => send(CloseDrawer)}
           updateCertificateCB={updateCertificate(state, send)}
         />
       | Closed => React.null
       }}
      <div className="flex-1 flex flex-col bg-gray-100">
        <div className="flex px-6 py-2 items-center justify-between">
          <button
            onClick={_ => {send(OpenNewCertificateDrawer)}}
            className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer">
            <i className="fas fa-plus-circle" />
            <h5 className="font-semibold ml-2">
              {t("create_action")->str}
            </h5>
          </button>
        </div>
        {state.certificates |> ArrayUtils.isEmpty
           ? <div
               className="flex justify-center bg-gray-100 border rounded p-3 italic mx-auto max-w-2xl w-full">
               {t("no_certificates")->str}
             </div>
           : <div className="px-6 pb-4 mt-5 flex flex-1 bg-gray-100">
               <div className="max-w-2xl w-full mx-auto relative">
                 <h4 className="mt-5 w-full"> {t("heading")->str} </h4>
                 <div className="flex mt-4 -mx-3 items-start flex-wrap">
                   {state.certificates
                    |> ArrayUtils.copyAndSort((x, y) =>
                         DateFns.differenceInSeconds(
                           y |> Certificate.updatedAt,
                           x |> Certificate.updatedAt,
                         )
                       )
                    |> Array.map(certificate => {
                         let editTitle =
                           t(
                             ~variables=[|
                               ("name", Certificate.name(certificate)),
                             |],
                             "edit_button_title",
                           );

                         <div
                           key={Certificate.id(certificate)}
                           ariaLabel={
                             "Certificate " ++ Certificate.id(certificate)
                           }
                           className="flex w-1/2 items-center mb-4 px-3">
                           <div
                             className="course-faculty__list-item shadow bg-white overflow-hidden rounded-lg flex flex-col w-full">
                             <div className="flex flex-1 justify-between">
                               <div className="pt-4 pb-3 px-4">
                                 <div className="text-sm">
                                   <p className="text-black font-semibold">
                                     {Certificate.name(certificate)->str}
                                   </p>
                                   <p
                                     className="text-gray-600 font-semibold text-xs mt-px">
                                     {t(
                                        ~count=
                                          Certificate.issuedCertificates(
                                            certificate,
                                          ),
                                        "issued_count",
                                      )
                                      ->str}
                                   </p>
                                 </div>
                                 {Certificate.active(certificate)
                                    ? <div
                                        className="flex flex-wrap text-gray-600 font-semibold text-xs mt-1">
                                        <span
                                          className="px-2 py-1 border rounded bg-secondary-100 text-primary-600 mt-1 mr-1">
                                          {t("auto_issue_tag")->str}
                                        </span>
                                      </div>
                                    : React.null}
                               </div>
                               <div className="flex">
                                 <a
                                   title=editTitle
                                   className="w-10 text-sm text-gray-700 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-200"
                                   onClick={_ =>
                                     send(
                                       OpenEditCertificateDrawer(certificate),
                                     )
                                   }>
                                   <i className="fas fa-edit" />
                                 </a>
                                 {if (Certificate.issuedCertificates(
                                        certificate,
                                      )
                                      == 0) {
                                    let title =
                                      t(
                                        ~variables=[|
                                          (
                                            "name",
                                            Certificate.name(certificate),
                                          ),
                                        |],
                                        "delete_button_title",
                                      );

                                    <a
                                      title
                                      className="w-10 text-sm text-gray-700 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-200"
                                      onClick={_event =>
                                        WindowUtils.confirm(
                                          "Are you sure you want to delete this certificate?",
                                          () =>
                                          deleteCertificate(certificate, send)
                                        )
                                      }>
                                      <i className="fas fa-trash-alt" />
                                    </a>;
                                  } else {
                                    React.null;
                                  }}
                               </div>
                             </div>
                           </div>
                         </div>;
                       })
                    |> React.array}
                 </div>
               </div>
             </div>}
      </div>
    </div>
  </DisablingCover>;
};
