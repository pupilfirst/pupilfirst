open CourseCertificates__Types

let str = React.string
let t = I18n.t(~scope="components.CourseCertificates__EditDrawer")

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
}

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
  | FailSaving

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
}

let reducer = (state, action) =>
  switch action {
  | UpdateName(name) => {...state, name: name, dirty: true}
  | UpdateActive(active) => {...state, active: active, dirty: true}
  | UpdateMargin(margin) => {...state, margin: margin, dirty: true}
  | UpdateFontSize(fontSize) => {...state, fontSize: fontSize, dirty: true}
  | UpdateNameOffsetTop(nameOffsetTop) => {
      ...state,
      nameOffsetTop: nameOffsetTop,
      dirty: true,
    }
  | UpdateQrCorner(qrCorner) => {...state, qrCorner: qrCorner, dirty: true}
  | UpdateQrScale(qrScale) => {...state, qrScale: qrScale, dirty: true}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | FinishSaving => {...state, saving: false, dirty: false}
  }

let buttonTypeClass = (stateQrCorner, qrCorner) =>
  stateQrCorner == qrCorner
    ? "border-primary-500 bg-primary-100 text-primary-600"
    : "border-gray-400 bg-gray-200 text-gray-800"

let activeButtonClasses = (stateActive, active) => {
  let baseClasses = "toggle-button__button"
  let additionalClasses = stateActive == active ? " toggle-button__button--active" : ""
  baseClasses ++ additionalClasses
}

let qrVisiblityClasses = (qrCorner, visible) => {
  let selected = switch (qrCorner, visible) {
  | (#Hidden, true) => false
  | (#TopLeft | #TopRight | #BottomLeft | #BottomRight, true) => true
  | (#Hidden, false) => true
  | (#TopLeft | #TopRight | #BottomLeft | #BottomRight, false) => false
  }

  let baseClasses = "toggle-button__button"
  let additionalClasses = selected ? " toggle-button__button--active" : ""

  baseClasses ++ additionalClasses
}

let isValidName = name => {
  let length = Js.String.trim(name)->Js.String.length
  length >= 1 && length <= 30
}

module UpdateCertificateMutation = %graphql(
  `
  mutation UpdateCertificateMutation($id: ID!, $name: String!, $margin: Int!, $nameOffsetTop: Int!, $fontSize: Int!, $qrCorner: QrCorner!, $qrScale: Int!, $active: Boolean!) {
    updateCertificate(id: $id, name: $name, margin: $margin, nameOffsetTop: $nameOffsetTop, fontSize: $fontSize, qrCorner: $qrCorner, qrScale: $qrScale, active: $active) {
      success
    }
  }
  `
)

let saveChanges = (certificate, updateCertificateCB, state, send, _event) => {
  send(BeginSaving)

  let name = Js.String.trim(state.name)
  let {margin, nameOffsetTop, fontSize, qrCorner, qrScale, active} = state

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
    if result["updateCertificate"]["success"] {
      Certificate.update(
        certificate,
        ~name,
        ~margin,
        ~nameOffsetTop,
        ~fontSize,
        ~qrCorner,
        ~qrScale,
        ~active,
      )->updateCertificateCB

      send(FinishSaving)
    } else {
      send(FailSaving)
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let activateQrCode = (state, send, _event) =>
  switch state.qrCorner {
  | #Hidden => send(UpdateQrCorner(#TopRight))
  | #TopLeft
  | #TopRight
  | #BottomLeft
  | #BottomRight => ()
  }

@react.component
let make = (
  ~certificate,
  ~verifyImageUrl,
  ~closeDrawerCB,
  ~updateCertificateCB,
  ~canBeAutoIssued,
) => {
  let (state, send) = React.useReducerWithMapState(reducer, certificate, computeInitialState)

  let demoCertificate = IssuedCertificate.make(
    ~serialNumber="20201231-A1B2C3",
    ~issuedTo="Lillian Schowalter Runolfsdottir",
    ~profileName="Lillian Schowalter Runolfsdottir",
    ~issuedAt=Js.Date.make(),
    ~courseName="Test Course",
    ~imageUrl=Certificate.imageUrl(certificate),
    ~margin=state.margin,
    ~fontSize=state.fontSize,
    ~nameOffsetTop=state.nameOffsetTop,
    ~qrCorner=state.qrCorner,
    ~qrScale=state.qrScale,
  )

  let validName = isValidName(state.name)
  let issuedCount = Certificate.issuedCertificates(certificate)
  let saveButtonDisabled = state.saving || !(state.dirty && validName)

  <SchoolAdmin__EditorDrawer
    closeDrawerCB closeButtonTitle={t("close")} size=SchoolAdmin__EditorDrawer.Large>
    <div className="flex flex-col min-h-screen">
      <DisablingCover
        disabled=state.saving message="Saving changes..." containerClasses="bg-white flex-grow-0">
        <div className="bg-gray-100 pt-6 pb-4 border-b">
          <div className="max-w-4xl px-4 mx-auto">
            <h5 className="uppercase"> {t("edit_action")->str} </h5>
          </div>
        </div>
        <div className="max-w-4xl px-4 py-6 mx-auto">
          <h5 className="text-sm uppercase font-bold pb-1 border-b"> {str("Details")} </h5>
          <div className="mt-4">
            <label className="flex items-center tracking-wide text-sm font-semibold" htmlFor="name">
              <span> {t("name_label")->str} </span>
            </label>
            <div>
              <input
                className="appearance-none block text-sm w-full bg-white border border-gray-400 rounded px-4 py-2 my-2 leading-relaxed focus:outline-none focus:bg-white focus:border-gray-500"
                maxLength=30
                id="name"
                type_="text"
                placeholder={t("name_placeholder")}
                onChange={event => send(UpdateName(ReactEvent.Form.target(event)["value"]))}
                value=state.name
              />
              <School__InputGroupError message={t("name_error")} active={!validName} />
            </div>
          </div>
          <div className="mt-6" ariaLabel="auto_issue">
            <label className="tracking-wide text-sm font-semibold">
              {t("active_label")->str}
            </label>
            <HelpIcon
              className="ml-1"
              link="https://docs.pupilfirst.com/#/certificates?id=automatically-issuing-certificates">
              <span dangerouslySetInnerHTML={"__html": t("active_help")} />
            </HelpIcon>
            <div className="ml-4 inline-flex toggle-button__group flex-shrink-0">
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
            {!canBeAutoIssued
              ? <div
                  className="flex p-4 bg-yellow-100 text-yellow-900 border border-yellow-500 border-l-4 rounded-r-md mt-2">
                  <div className="w-6 h-6 text-yellow-500 flex-shrink-0">
                    <i className="fas fa-exclamation-triangle" />
                  </div>
                  <span className="ml-2"> {t("cannot_be_auto_issued_warning")->React.string} </span>
                </div>
              : React.null}
          </div>
          <h5 className="mt-6 text-sm uppercase font-bold pb-1 border-b"> {str("Design")} </h5>
          <div className="flex mt-4">
            <div className="w-3/5">
              <div className="rounded border-6 border-white shadow-md">
                <IssuedCertificate__Root issuedCertificate=demoCertificate verifyImageUrl />
              </div>
            </div>
            <div className="w-2/5 pl-5">
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
                  className="form-input__range"
                  type_="range"
                  name="margin"
                  min="0"
                  max="20"
                  value={string_of_int(state.margin)}
                  onChange={event =>
                    send(UpdateMargin(ReactEvent.Form.target(event)["value"]->int_of_string))}
                />
              </div>
              <div className="mt-4">
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="name_offset_top">
                    {t("name_offset_top_label")->str}
                  </label>
                </div>
                <input
                  id="name_offset_top"
                  className="form-input__range"
                  type_="range"
                  name="name_offset_top"
                  min="0"
                  max="95"
                  value={string_of_int(state.nameOffsetTop)}
                  onChange={event =>
                    send(
                      UpdateNameOffsetTop(ReactEvent.Form.target(event)["value"]->int_of_string),
                    )}
                />
              </div>
              <div className="mt-4">
                <div>
                  <label
                    className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                    htmlFor="font_size">
                    {t("font_size_label")->str}
                  </label>
                </div>
                <input
                  id="font_size"
                  className="form-input__range"
                  type_="range"
                  name="font_size"
                  min="75"
                  max="150"
                  value={string_of_int(state.fontSize)}
                  onChange={event =>
                    send(UpdateFontSize(ReactEvent.Form.target(event)["value"]->int_of_string))}
                />
              </div>
              <div className="mt-4" ariaLabel="add_qr_code">
                <label className="tracking-wide text-gray-900 text-xs font-semibold">
                  {t("qr_visibility_label")->str}
                </label>
                <HelpIcon
                  className="ml-1"
                  link="https://docs.pupilfirst.com/#/certificates?id=automatically-issuing-certificates">
                  <span
                    dangerouslySetInnerHTML={
                      "__html": t("qr_visibility_help"),
                    }
                  />
                </HelpIcon>
                <div className="ml-4 inline-flex toggle-button__group flex-shrink-0">
                  <button
                    className={qrVisiblityClasses(state.qrCorner, true)}
                    onClick={activateQrCode(state, send)}>
                    {str("Yes")}
                  </button>
                  <button
                    className={qrVisiblityClasses(state.qrCorner, false)}
                    onClick={_ => send(UpdateQrCorner(#Hidden))}>
                    {str("No")}
                  </button>
                </div>
              </div>
              {switch state.qrCorner {
              | #Hidden => React.null
              | #TopLeft
              | #TopRight
              | #BottomLeft
              | #BottomRight =>
                [
                  <div className="mt-4" key="position">
                    <div>
                      <label
                        className="inline-block tracking-wide text-gray-900 text-xs font-semibold">
                        {t("qr_position_label")->str}
                      </label>
                    </div>
                    <div className="flex mt-2">
                      <button
                        className={"w-1/2 mr-2 rounded border pt-3 px-3 pb-5 text-sm font-semibold focus:shadow-outline hover:bg-gray-300 hover:text-gray-900 " ++
                        buttonTypeClass(state.qrCorner, #TopLeft)}
                        onClick={_ => send(UpdateQrCorner(#TopLeft))}>
                        <div className="flex"> <Icon className="if i-qr-code-regular" /> </div>
                        {t("qr_top_left_label")->str}
                      </button>
                      <button
                        className={"w-1/2 rounded border pt-3 px-3 pb-5 text-sm font-semibold focus:shadow-outline hover:bg-gray-300 hover:text-gray-900 " ++
                        buttonTypeClass(state.qrCorner, #TopRight)}
                        onClick={_ => send(UpdateQrCorner(#TopRight))}>
                        <div className="flex justify-end">
                          <Icon className="if i-qr-code-regular" />
                        </div>
                        {t("qr_top_right_label")->str}
                      </button>
                    </div>
                    <div className="flex mt-2">
                      <button
                        className={"w-1/2 mr-2 rounded border pt-5 px-3 pb-3 text-sm font-semibold focus:shadow-outline hover:bg-gray-300 hover:text-gray-900 " ++
                        buttonTypeClass(state.qrCorner, #BottomLeft)}
                        onClick={_ => send(UpdateQrCorner(#BottomLeft))}>
                        {t("qr_bottom_left_label")->str}
                        <div className="flex"> <Icon className="if i-qr-code-regular" /> </div>
                      </button>
                      <button
                        className={"w-1/2 rounded border pt-5 px-3 pb-3 text-sm font-semibold focus:shadow-outline hover:bg-gray-300 hover:text-gray-900 " ++
                        buttonTypeClass(state.qrCorner, #BottomRight)}
                        onClick={_ => send(UpdateQrCorner(#BottomRight))}>
                        {t("qr_bottom_right_label")->str}
                        <div className="flex justify-end">
                          <Icon className="if i-qr-code-regular" />
                        </div>
                      </button>
                    </div>
                  </div>,
                  <div className="mt-4" key="scale">
                    <div>
                      <label
                        className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
                        htmlFor="qr_scale">
                        {t("qr_scale_label")->str}
                      </label>
                    </div>
                    <input
                      id="qr_scale"
                      className="form-input__range"
                      type_="range"
                      name="qr_scale"
                      min="50"
                      max="150"
                      value={string_of_int(state.qrScale)}
                      onChange={event =>
                        send(UpdateQrScale(ReactEvent.Form.target(event)["value"]->int_of_string))}
                    />
                  </div>,
                ] |> React.array
              }}
            </div>
          </div>
        </div>
      </DisablingCover>
      <div className="bg-gray-100 flex-grow">
        <div className="max-w-4xl px-4 py-6 mx-auto">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              {issuedCount > 0 && !saveButtonDisabled
                ? <div
                    className="inline-flex bg-orange-100 mr-2 p-2 rounded-r border border-l-4 border-orange-500 items-center">
                    <div className="text-orange-500 text-2xl">
                      <i className="fas fa-exclamation-triangle" />
                    </div>
                    <div
                      className="ml-2 text-xs font-semibold"
                      dangerouslySetInnerHTML={
                        "__html": t(~count=issuedCount, "update_issued_certificates_warning"),
                      }
                    />
                  </div>
                : React.null}
            </div>
            <div className="flex-shrink-0">
              <button
                onClick={saveChanges(certificate, updateCertificateCB, state, send)}
                disabled=saveButtonDisabled
                className="w-auto btn btn-success">
                <FaIcon classes={"fas " ++ (state.saving ? "fa-spinner fa-pulse" : "fa-check")} />
                <span className="ml-2"> {t(state.saving ? "saving" : "save_changes")->str} </span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </SchoolAdmin__EditorDrawer>
}
