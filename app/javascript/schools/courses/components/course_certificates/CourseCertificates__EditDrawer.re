open CourseCertificates__Types;

let str = React.string;
let t = I18n.t(~scope="components.CourseCertificates__EditDrawer");

type state = {
  name: string,
  active: bool,
  margin: int,
  fontSize: int,
  nameOffsetTop: int,
  qrCorner: IssuedCertificate.qrCorner,
  qrScale: int,
  dirty: bool,
  saving: bool,
};

type action =
  | UpdateName(string)
  | UpdateActive(bool)
  | UpdateMargin(int)
  | UpdateFontSize(int)
  | UpdateNameOffsetTop(int)
  | UpdateQrCorner(IssuedCertificate.qrCorner)
  | UpdateQrScale(int)
  | BeginSaving
  | FinishSaving
  | FailSaving;

let computeInitialState = certificate => {
  name: Certificate.name(certificate),
  active: Certificate.active(certificate),
  margin: Certificate.margin(certificate),
  fontSize: Certificate.fontSize(certificate),
  nameOffsetTop: Certificate.nameOffsetTop(certificate),
  qrCorner: Certificate.qrCorner(certificate),
  qrScale: Certificate.qrScale(certificate),
  dirty: false,
  saving: false,
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateName(name) => {...state, name, dirty: true}
  | UpdateActive(active) => {...state, active, dirty: true}
  | UpdateMargin(margin) => {...state, margin, dirty: true}
  | UpdateFontSize(fontSize) => {...state, fontSize, dirty: true}
  | UpdateNameOffsetTop(nameOffsetTop) => {
      ...state,
      nameOffsetTop,
      dirty: true,
    }
  | UpdateQrCorner(qrCorner) => {...state, qrCorner, dirty: true}
  | UpdateQrScale(qrScale) => {...state, qrScale, dirty: true}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | FinishSaving => {...state, saving: false, dirty: false}
  };

let buttonTypeClass = (stateQrCorner, qrCorner) => {
  stateQrCorner == qrCorner ? "btn-primary" : "btn-default";
};

let activeButtonClasses = (stateActive, active) => {
  let baseClasses = "toggle-button__button";
  let additionalClasses =
    stateActive == active ? " toggle-button__button--active" : "";
  baseClasses ++ additionalClasses;
};

let isValidName = name => {
  let length = Js.String.trim(name)->Js.String.length;
  length >= 1 && length <= 30;
};

module UpdateCertificateMutation = [%graphql
  {|
  mutation UpdateCertificateMutation($id: ID!, $name: String!, $margin: Int!, $nameOffsetTop: Int!, $fontSize: Int!, $qrCorner: QrCorner!, $qrScale: Int!, $active: Boolean!) {
    updateCertificate(id: $id, name: $name, margin: $margin, nameOffsetTop: $nameOffsetTop, fontSize: $fontSize, qrCorner: $qrCorner, qrScale: $qrScale, active: $active) {
      success
    }
  }
  |}
];

let saveChanges = (certificate, updateCertificateCB, state, send, _event) => {
  send(BeginSaving);

  let name = Js.String.trim(state.name);
  let {margin, nameOffsetTop, fontSize, qrCorner, qrScale, active} = state;

  Js.log((margin, nameOffsetTop, fontSize, qrCorner, qrScale, active));

  UpdateCertificateMutation.make(
    ~id=Certificate.id(certificate),
    ~name,
    ~margin,
    ~nameOffsetTop,
    ~fontSize,
    ~qrCorner,
    ~qrScale,
    ~active,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
       if (result##updateCertificate##success) {
         Certificate.update(
           certificate,
           ~name,
           ~margin,
           ~nameOffsetTop,
           ~fontSize,
           ~qrCorner,
           ~qrScale,
           ~active,
         )
         ->updateCertificateCB;

         send(FinishSaving);
       } else {
         send(FailSaving);
       };

       Js.Promise.resolve();
     })
  |> Js.Promise.catch(error => {
       Js.log(error);
       send(FailSaving);
       Js.Promise.resolve();
     })
  |> ignore;
};

[@react.component]
let make =
    (~certificate, ~verifyImageUrl, ~closeDrawerCB, ~updateCertificateCB) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, certificate, computeInitialState);

  let demoCertificate =
    IssuedCertificate.make(
      ~serialNumber="20201231-A1B2C3",
      ~issuedTo="Rosalind Wilton Oberbrunner",
      ~issuedAt=Js.Date.make(),
      ~courseName="Test Course",
      ~imageUrl=Certificate.imageUrl(certificate),
      ~margin=state.margin,
      ~fontSize=state.fontSize,
      ~nameOffsetTop=state.nameOffsetTop,
      ~qrCorner=state.qrCorner,
      ~qrScale=state.qrScale,
    );

  let validName = isValidName(state.name);
  let issuedCount = Certificate.issuedCertificates(certificate);
  let saveButtonDisabled = state.saving || !(state.dirty && validName);

  <SchoolAdmin__EditorDrawer
    closeDrawerCB
    closeButtonTitle={t("cancel")}
    size=SchoolAdmin__EditorDrawer.Large>
    <div className="flex flex-col min-h-screen">
      <DisablingCover
        disabled={state.saving}
        message="Saving changes..."
        containerClasses="bg-white flex-grow-0">
        <div className="max-w-4xl px-6 pt-5 mx-auto">
          <h5 className="uppercase text-center border-b border-gray-400 pb-2">
            {t("edit_action")->str}
          </h5>
        </div>
        <div className="max-w-4xl px-6 py-6 mx-auto">
          <div>
            <label
              className="flex items-center tracking-wide text-sm font-semibold"
              htmlFor="title">
              <i className="fas fa-list text-base" />
              <span className="ml-2"> {str("Title")} </span>
            </label>
            <div className="ml-6">
              <input
                className="appearance-none block text-sm w-full bg-white border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:bg-white focus:border-gray-500"
                maxLength=30
                id="name"
                type_="text"
                placeholder="A short name for this certificate"
                onChange={event =>
                  send(UpdateName(ReactEvent.Form.target(event)##value))
                }
                value={state.name}
              />
              <School__InputGroupError
                message="Name can't be blank"
                active={!validName}
              />
            </div>
          </div>
          <div className="mt-4">
            <label
              className="tracking-wide text-sm font-semibold" htmlFor="active">
              <span className="mr-2">
                <i className="fas fa-list text-base" />
              </span>
              {str(
                 "Should students be automatically issued this certificate?",
               )}
            </label>
            <HelpIcon
              className="ml-1"
              link="https://docs.pupilfirst.com/#/certificates?id=automatically-issuing-certificates">
              <span>
                {str(
                   "While you can have multiple certificates, only one can be automatically issued; it will be issued when a student ",
                 )}
                <em> {str("completes")} </em>
                {str(" a course.")}
              </span>
            </HelpIcon>
            <div
              className="ml-6 inline-flex toggle-button__group flex-shrink-0 rounded-lg overflow-hidden"
              id="active">
              <button
                className={activeButtonClasses(state.active, true)}
                onClick={_ => send(UpdateActive(true))}>
                {str("Yes")}
              </button>
              <button
                className={activeButtonClasses(state.active, false)}
                onClick={_ => send(UpdateActive(false))}>
                {str("No")}
              </button>
            </div>
          </div>
          <h5 className="mt-4"> {str("Design")} </h5>
          <div className="flex mt-4">
            <div className="w-2/3">
              <IssuedCertificate__Root
                issuedCertificate=demoCertificate
                verifyImageUrl
              />
            </div>
            <div className="w-1/3 ml-4">
              <div>
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="margin">
                    {t("margin_label")->str}
                  </label>
                </div>
                <input
                  id="margin"
                  className="w-full mt-1"
                  type_="range"
                  name="margin"
                  min="0"
                  max="20"
                  value={string_of_int(state.margin)}
                  onChange={event =>
                    send(
                      UpdateMargin(
                        ReactEvent.Form.target(event)##value->int_of_string,
                      ),
                    )
                  }
                />
              </div>
              <div className="mt-2">
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="name_offset_top">
                    {t("name_offset_top_label")->str}
                  </label>
                </div>
                <input
                  id="name_offset_top"
                  className="w-full mt-1"
                  type_="range"
                  name="name_offset_top"
                  min="0"
                  max="95"
                  value={string_of_int(state.nameOffsetTop)}
                  onChange={event =>
                    send(
                      UpdateNameOffsetTop(
                        ReactEvent.Form.target(event)##value->int_of_string,
                      ),
                    )
                  }
                />
              </div>
              <div className="mt-2">
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="font_size">
                    {t("font_size_label")->str}
                  </label>
                </div>
                <input
                  id="font_size"
                  className="w-full mt-1"
                  type_="range"
                  name="font_size"
                  min="75"
                  max="150"
                  value={string_of_int(state.fontSize)}
                  onChange={event =>
                    send(
                      UpdateFontSize(
                        ReactEvent.Form.target(event)##value->int_of_string,
                      ),
                    )
                  }
                />
              </div>
              <div className="mt-2">
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="qr_visibility">
                    {t("qr_visibility_label")->str}
                  </label>
                </div>
                <button
                  className={
                    "block btn mt-1 w-full "
                    ++ buttonTypeClass(state.qrCorner, `Hidden)
                  }
                  onClick={_ => send(UpdateQrCorner(`Hidden))}>
                  {t("qr_hidden_label")->str}
                </button>
                <div className="flex mt-2">
                  <button
                    className={
                      "btn w-1/2 mr-1 "
                      ++ buttonTypeClass(state.qrCorner, `TopLeft)
                    }
                    onClick={_ => send(UpdateQrCorner(`TopLeft))}>
                    {t("qr_top_left_label")->str}
                  </button>
                  <button
                    className={
                      "btn w-1/2 ml-1 "
                      ++ buttonTypeClass(state.qrCorner, `TopRight)
                    }
                    onClick={_ => send(UpdateQrCorner(`TopRight))}>
                    {t("qr_top_right_label")->str}
                  </button>
                </div>
                <div className="flex mt-2">
                  <button
                    className={
                      "btn w-1/2 mr-1 "
                      ++ buttonTypeClass(state.qrCorner, `BottomLeft)
                    }
                    onClick={_ => send(UpdateQrCorner(`BottomLeft))}>
                    {t("qr_bottom_left_label")->str}
                  </button>
                  <button
                    className={
                      "btn w-1/2 ml-1 "
                      ++ buttonTypeClass(state.qrCorner, `BottomRight)
                    }
                    onClick={_ => send(UpdateQrCorner(`BottomRight))}>
                    {t("qr_bottom_right_label")->str}
                  </button>
                </div>
              </div>
              {switch (state.qrCorner) {
               | `Hidden => React.null
               | `TopLeft
               | `TopRight
               | `BottomLeft
               | `BottomRight =>
                 <div className="mt-2">
                   <div>
                     <label
                       className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                       htmlFor="qr_scale">
                       {t("qr_scale_label")->str}
                     </label>
                   </div>
                   <input
                     id="qr_scale"
                     className="w-full mt-1"
                     type_="range"
                     name="qr_scale"
                     min="50"
                     max="150"
                     value={string_of_int(state.qrScale)}
                     onChange={event =>
                       send(
                         UpdateQrScale(
                           ReactEvent.Form.target(event)##value
                           ->int_of_string,
                         ),
                       )
                     }
                   />
                 </div>
               }}
            </div>
          </div>
        </div>
      </DisablingCover>
      <div className="bg-gray-100 flex-grow">
        <div className="max-w-4xl p-6 mx-auto">
          <div className="flex items-center">
            <button
              onClick={saveChanges(
                certificate,
                updateCertificateCB,
                state,
                send,
              )}
              disabled=saveButtonDisabled
              className="w-auto btn btn-large btn-primary">
              <FaIcon
                classes={
                  "fas " ++ (state.saving ? "fa-spinner fa-pulse" : "fa-check")
                }
              />
              <span className="ml-2">
                {t(state.saving ? "saving" : "save_changes")->str}
              </span>
            </button>
            {issuedCount > 0 && !saveButtonDisabled
               ? <div className="flex items-center ml-4">
                   <div className="text-red-700 text-2xl">
                     <i className="fas fa-exclamation-triangle" />
                   </div>
                   <div
                     className="ml-2 text-xs font-semibold"
                     dangerouslySetInnerHTML={
                       "__html":
                         t(
                           ~count=issuedCount,
                           "update_issued_certificates_warning",
                         ),
                     }
                   />
                 </div>
               : React.null}
          </div>
        </div>
      </div>
    </div>
  </SchoolAdmin__EditorDrawer>;
};
