open CourseCertificates__Types

let str = React.string
let t = I18n.t(~scope="components.CourseCertificates__Root")

type drawer =
  | NewCertificate
  | EditCertificate(Certificate.t)
  | Closed

type state = {
  drawer: drawer,
  deleting: bool,
  certificates: array<Certificate.t>,
}

let computeInitialState = certificates => {
  drawer: Closed,
  deleting: false,
  certificates: certificates,
}

type action =
  | OpenNewCertificateDrawer
  | OpenEditCertificateDrawer(Certificate.t)
  | CloseDrawer
  | UpdateCertificates(array<Certificate.t>)
  | FinishCreating(array<Certificate.t>)
  | BeginDeleting
  | FinishDeleting(Certificate.t)
  | FailDeleting

let reducer = (state, action) =>
  switch action {
  | OpenNewCertificateDrawer => {...state, drawer: NewCertificate}
  | OpenEditCertificateDrawer(certificate) => {
      ...state,
      drawer: EditCertificate(certificate),
    }

  | CloseDrawer => {...state, drawer: Closed}
  | UpdateCertificates(certificates) => {...state, certificates: certificates}
  | FinishCreating(certificates) => {...state, certificates: certificates, drawer: Closed}
  | BeginDeleting => {...state, deleting: true}
  | FinishDeleting(certificate) => {
      ...state,
      certificates: Js.Array.filter(
        c => Certificate.id(c) != Certificate.id(certificate),
        state.certificates,
      ),
      deleting: false,
    }
  | FailDeleting => {...state, deleting: false}
  }

let addCertificate = (state, send, certificate) => {
  let newCertificates = Js.Array.concat([certificate], state.certificates)
  send(FinishCreating(newCertificates))
}

let updateCertificate = (state, send, certificate) => {
  let newCertificates = Js.Array.map(c =>
    if Certificate.id(c) == Certificate.id(certificate) {
      certificate
    } else if Certificate.active(certificate) {
      Certificate.markInactive(c)
    } else {
      c
    }
  , state.certificates)

  send(UpdateCertificates(newCertificates))
}

module DeleteCertificateMutation = %graphql(
  `
  mutation DeleteCertificateMutation($id: ID!) {
    deleteCertificate(id: $id) {
      success
    }
  }
`
)

let deleteCertificate = (certificate, send) => {
  send(BeginDeleting)

  DeleteCertificateMutation.make(~id=Certificate.id(certificate), ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
    if result["deleteCertificate"]["success"] {
      send(FinishDeleting(certificate))
    } else {
      send(FailDeleting)
    }

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailDeleting)
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~course, ~certificates, ~verifyImageUrl, ~canBeAutoIssued) => {
  let (state, send) = React.useReducerWithMapState(reducer, certificates, computeInitialState)

  <DisablingCover containerClasses="w-full" disabled=state.deleting message="Deleting...">
    <div className="flex flex-1 h-screen overflow-y-scroll">
      {switch state.drawer {
      | NewCertificate =>
        <CourseCertificates__CreateDrawer
          course
          closeDrawerCB={() => send(CloseDrawer)}
          addCertificateCB={addCertificate(state, send)}
        />
      | EditCertificate(certificate) =>
        <CourseCertificates__EditDrawer
          certificate
          verifyImageUrl
          closeDrawerCB={() => send(CloseDrawer)}
          updateCertificateCB={updateCertificate(state, send)}
          canBeAutoIssued
        />
      | Closed => React.null
      }}
      <div className="flex-1 flex flex-col bg-gray-100">
        <div className="flex px-6 py-2 items-center justify-between">
          <button
            onClick={_ => send(OpenNewCertificateDrawer)}
            className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer">
            <i className="fas fa-plus-circle" />
            <h5 className="font-semibold ml-2"> {t("create_action")->str} </h5>
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
                    let editTitle = t(
                      ~variables=[("name", Certificate.name(certificate))],
                      "edit_button_title",
                    )

                    <div
                      key={Certificate.id(certificate)}
                      ariaLabel={"Certificate " ++ Certificate.id(certificate)}
                      className="flex w-1/2 items-center mb-4 px-3">
                      <div
                        className="shadow bg-white overflow-hidden rounded-lg flex flex-col w-full">
                        <div className="flex flex-1 justify-between">
                          <div className="pt-4 pb-3 px-4">
                            <div className="text-sm">
                              <p className="text-black font-semibold">
                                {Certificate.name(certificate)->str}
                              </p>
                              <p className="text-gray-600 font-semibold text-xs mt-px">
                                {t(
                                  ~count=Certificate.issuedCertificates(certificate),
                                  "issued_count",
                                )->str}
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
                              onClick={_ => send(OpenEditCertificateDrawer(certificate))}>
                              <i className="fas fa-edit" />
                            </a>
                            {if Certificate.issuedCertificates(certificate) == 0 {
                              let title = t(
                                ~variables=[("name", Certificate.name(certificate))],
                                "delete_button_title",
                              )

                              <a
                                title
                                className="w-10 text-sm text-gray-700 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-200"
                                onClick={_event =>
                                  WindowUtils.confirm(
                                    "Are you sure you want to delete this certificate?",
                                    () => deleteCertificate(certificate, send),
                                  )}>
                                <i className="fas fa-trash-alt" />
                              </a>
                            } else {
                              React.null
                            }}
                          </div>
                        </div>
                      </div>
                    </div>
                  })
                  |> React.array}
                </div>
              </div>
            </div>}
      </div>
    </div>
  </DisablingCover>
}
