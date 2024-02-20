open StudentActions__Type

let t = I18n.t(~scope="components.StudentActions__Root")
let str = React.string

type student = {
  name: string,
  issuedCertificates: array<IssuedCertificate.t>,
  droppedOutAt: option<Js.Date.t>,
}
module IssuedCertificateFragment = IssuedCertificate.Fragment

module Editor = {
  module DropoutStudentQuery = %graphql(`
   mutation DropoutStudentMutation($id: ID!) {
    dropoutStudent(id: $id){
      success
     }
   }
 `)

  module ReActivateStudentQuery = %graphql(`
   mutation ReActivateStudentMutation($id: ID!) {
    reActivateStudent(id: $id){
      success
     }
   }
 `)

  module RevokeCertificateQuery = %graphql(`
   mutation RevokeCertificateMutation($issuedCertificateId: ID!) {
    revokeIssuedCertificate(issuedCertificateId: $issuedCertificateId){
      revokedCertificate {
        ...IssuedCertificateFragment
      }
     }
   }
 `)

  module IssueCertificateQuery = %graphql(`
   mutation IssueCertificateQueryMutation($certificateId: ID!, $studentId: ID!) {
    issueCertificate(certificateId: $certificateId, studentId: $studentId){
      issuedCertificate {
        ...IssuedCertificateFragment
      }
     }
   }
 `)

  type state = {
    student: student,
    saving: bool,
    issuing: bool,
    revoking: bool,
    selectedCertificateId: string,
  }

  type actions =
    | UpdateRevokedCertificate(IssuedCertificate.t)
    | AddNewCertificate(IssuedCertificate.t)
    | DropOutStudent
    | ReActivateStudent
    | SetSaving
    | ClearSaving
    | SetIssuing
    | ClearIssuing
    | SetRevoking
    | ClearRevoking
    | UpdateSelectedCertificateId(string)

  let reducer = (state: state, action) =>
    switch action {
    | UpdateRevokedCertificate(certificate) => {
        ...state,
        revoking: false,
        student: {
          ...state.student,
          issuedCertificates: state.student.issuedCertificates->Js.Array2.map(ic =>
            IssuedCertificate.id(certificate) == IssuedCertificate.id(ic) ? certificate : ic
          ),
        },
      }
    | AddNewCertificate(certificate) => {
        ...state,
        issuing: false,
        student: {
          ...state.student,
          issuedCertificates: Js.Array.concat(state.student.issuedCertificates, [certificate]),
        },
      }
    | DropOutStudent => {
        ...state,
        saving: false,
        student: {
          ...state.student,
          droppedOutAt: Some(Js.Date.make()),
        },
      }
    | ReActivateStudent => {
        ...state,
        saving: false,
        student: {
          ...state.student,
          droppedOutAt: None,
        },
      }
    | SetSaving => {
        ...state,
        saving: true,
      }
    | ClearSaving => {
        ...state,
        saving: false,
      }
    | SetIssuing => {
        ...state,
        issuing: true,
      }
    | ClearIssuing => {
        ...state,
        issuing: false,
      }
    | SetRevoking => {
        ...state,
        revoking: true,
      }
    | ClearRevoking => {
        ...state,
        revoking: false,
      }
    | UpdateSelectedCertificateId(certificateId) => {
        ...state,
        selectedCertificateId: certificateId,
      }
    }

  let dropoutStudent = (id, send, event) => {
    ReactEvent.Mouse.preventDefault(event)
    send(SetSaving)

    DropoutStudentQuery.fetch({id: id})
    |> Js.Promise.then_((response: DropoutStudentQuery.t) => {
      response.dropoutStudent.success ? send(DropOutStudent) : send(ClearSaving)
      Js.Promise.resolve()
    })
    |> ignore
  }

  let reActivateStudent = (id, send, event) => {
    ReactEvent.Mouse.preventDefault(event)
    send(SetSaving)

    ReActivateStudentQuery.fetch({id: id})
    |> Js.Promise.then_((response: ReActivateStudentQuery.t) => {
      response.reActivateStudent.success ? send(ReActivateStudent) : send(ClearSaving)
      Js.Promise.resolve()
    })
    |> ignore
  }

  let revokeIssuedCertificate = (issuedCertificate, send, _event) =>
    WindowUtils.confirm(t("revoke_certificate_confirmation"), () => {
      send(SetRevoking)

      let issuedCertificateId = IssuedCertificate.id(issuedCertificate)

      RevokeCertificateQuery.fetch({issuedCertificateId: issuedCertificateId})
      |> Js.Promise.then_((response: RevokeCertificateQuery.t) => {
        let data = response.revokeIssuedCertificate.revokedCertificate
        switch data {
        | Some(data) => send(UpdateRevokedCertificate(IssuedCertificate.makeFromFragment(data)))
        | None => send(ClearRevoking)
        }
        Js.Promise.resolve()
      })
      |> Js.Promise.catch(error => {
        Js.log(error)
        send(ClearRevoking)
        Js.Promise.resolve()
      })
      |> ignore
    })

  let issueNewCertificate = (studentId, state, send, event) => {
    ReactEvent.Mouse.preventDefault(event)
    send(SetIssuing)

    IssueCertificateQuery.fetch({certificateId: state.selectedCertificateId, studentId})
    |> Js.Promise.then_((response: IssueCertificateQuery.t) => {
      let data = response.issueCertificate.issuedCertificate
      switch data {
      | Some(data) => send(AddNewCertificate(IssuedCertificate.makeFromFragment(data)))
      | None => send(ClearIssuing)
      }
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Js.log(error)
      send(ClearIssuing)
      Js.Promise.resolve()
    })
    |> ignore
  }

  let str = React.string

  let submitButtonIcons = saving => saving ? "fas fa-spinner fa-spin" : "fa fa-exclamation-triangle"

  let issueButtonIcons = issuing => issuing ? "fas fa-spinner fa-spin" : "fas fa-certificate"

  let showIssuedCertificates = (student, state, send) => {
    let issuedCertificates = student.issuedCertificates
    issuedCertificates->ArrayUtils.isEmpty
      ? <p className="text-xs text-gray-800"> {t("empty_issued_certificates_text")->str} </p>
      : <div className="flex flex-col">
          <label className="tracking-wide text-sm font-semibold mb-2">
            {t("issued_certificates_label")->str}
          </label>
          {issuedCertificates
          ->Js.Array2.map(ic =>
            <div
              ariaLabel={t("details_certificate") ++ " " ++ IssuedCertificate.id(ic)}
              key={IssuedCertificate.id(ic)}
              className="flex flex-col mt-2 p-2 border rounded border-gray-400">
              <div className="flex justify-between">
                <span className="text-sm font-semibold">
                  {IssuedCertificate.certificate(ic)->Certificate.name->str}
                </span>
                {ReactUtils.nullUnless(
                  <div
                    className="w-16 p-1 text-xs leading-tight rounded text-center bg-red-200 border-red-800">
                    {t("revoked_status_label")->str}
                  </div>,
                  IssuedCertificate.revokedAt(ic)->Belt.Option.isSome,
                )}
              </div>
              <div className="mt-2">
                <a
                  className="btn btn-small btn-primary-ghost"
                  href={"/c/" ++ IssuedCertificate.serialNumber(ic)}>
                  {IssuedCertificate.serialNumber(ic)->str}
                </a>
              </div>
              <div className="flex justify-between mt-2 items-end">
                <div className="flex flex-col">
                  <div>
                    <span className="font font-semibold text-xs">
                      {t("issued_date_label")->str}
                    </span>
                    <span className="text-xs ms-2">
                      {IssuedCertificate.createdAt(ic)->DateFns.format("MMMM d, yyyy")->str}
                    </span>
                  </div>
                  <div>
                    <span className="font font-semibold text-xs">
                      {t("issued_by_label")->str}
                    </span>
                    <span className="text-xs ms-2"> {IssuedCertificate.issuedBy(ic)->str} </span>
                  </div>
                </div>
                {switch IssuedCertificate.revokedAt(ic) {
                | Some(revokedAt) =>
                  <div className="flex flex-col">
                    <div>
                      <span className="font font-semibold text-xs">
                        {t("revoked_date_label")->str}
                      </span>
                      <span className="text-xs ms-2">
                        {revokedAt->DateFns.format("MMMM d, yyyy")->str}
                      </span>
                    </div>
                    <div>
                      <span className="font font-semibold text-xs">
                        {t("revoked_by_label")->str}
                      </span>
                      <span className="text-xs ms-2">
                        {IssuedCertificate.revokedBy(ic)
                        ->Belt.Option.mapWithDefault("Unknown", r => r)
                        ->str}
                      </span>
                    </div>
                  </div>
                | None =>
                  <button
                    disabled=state.revoking
                    onClick={revokeIssuedCertificate(ic, send)}
                    className="btn btn-danger btn-small">
                    {t("revoke_certificate_button")->str}
                  </button>
                }}
              </div>
            </div>
          )
          ->React.array}
        </div>
  }

  let initialState = student => {
    student,
    saving: false,
    revoking: false,
    issuing: false,
    selectedCertificateId: "0",
  }

  let hasLiveCertificate = student =>
    student.issuedCertificates
    ->Js.Array2.find(ic => IssuedCertificate.revokedAt(ic)->Belt.Option.isNone)
    ->Belt.Option.isSome

  @react.component
  let make = (~studentData, ~studentId, ~certificates) => {
    let (state, send) = React.useReducer(reducer, initialState(studentData))

    <div className="pt-5 pb-10">
      <div className="bg-gray-50 p-4" ariaLabel={t("manage_certificates")}>
        <h5> {t("certificates_label")->str} </h5>
        {certificates->ArrayUtils.isEmpty
          ? <p className="text-xs text-gray-800"> {t("empty_course_certificates_text")->str} </p>
          : <div>
              {showIssuedCertificates(state.student, state, send)}
              {ReactUtils.nullIf(
                <div className="flex flex-col mt-2">
                  <label className="tracking-wide text-sm font-semibold mb-2">
                    {t("new_certificate_label")->str}
                  </label>
                  <div className="flex items-end mt-2">
                    <select
                      className="cursor-pointer appearance-none block w-full bg-white border border-gray-400 rounded h-10 py-2 px-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                      id="issue-certificate"
                      onChange={event => {
                        let selectedValue = ReactEvent.Form.target(event)["value"]
                        send(UpdateSelectedCertificateId(selectedValue))
                      }}
                      value=state.selectedCertificateId>
                      <option key="0" value="0">
                        {t("select_certificate_input_label")->str}
                      </option>
                      {certificates
                      ->Js.Array2.map(certificate =>
                        <option
                          key={Certificate.id(certificate)} value={Certificate.id(certificate)}>
                          {
                            let name = Certificate.name(certificate)

                            (
                              Certificate.active(certificate)
                                ? name ++ (" (" ++ (t("active_label") ++ ")"))
                                : name
                            )->str
                          }
                        </option>
                      )
                      ->React.array}
                    </select>
                    <button
                      onClick={issueNewCertificate(studentId, state, send)}
                      disabled={state.issuing || state.selectedCertificateId == "0"}
                      className="btn btn-success ms-2 text-sm h-10">
                      <FaIcon classes={issueButtonIcons(state.issuing)} />
                      <span className="ms-2"> {t("issue_certificate_button")->str} </span>
                    </button>
                  </div>
                </div>,
                hasLiveCertificate(state.student),
              )}
            </div>}
      </div>
      <div className="p-4 bg-red-50 border-red-300 rounded mt-12">
        <label className="tracking-wide text-xs font-semibold" htmlFor="access-ends-at-input">
          {t("dropout_student.label")->str}
        </label>
        <HelpIcon className="ms-2" link={t("dropout_student.help_url")}>
          {t("dropout_student.help")->str}
        </HelpIcon>
        <div className="mt-2">
          {Belt.Option.isNone(state.student.droppedOutAt)
            ? <button
                disabled=state.saving
                className="btn btn-danger"
                onClick={dropoutStudent(studentId, send)}>
                <FaIcon classes={submitButtonIcons(state.saving)} />
                <span className="ms-2"> {t("dropout_student.button")->str} </span>
              </button>
            : <button
                disabled=state.saving
                className="btn btn-success"
                onClick={reActivateStudent(studentId, send)}>
                <FaIcon classes={submitButtonIcons(state.saving)} />
                <span className="ms-2"> {t("re_activate_student.button")->str} </span>
              </button>}
        </div>
      </div>
    </div>
  }
}

type baseData = {
  student: student,
  courseId: string,
  certificates: array<Certificate.t>,
}

type state = Unloaded | Loading | Loaded(baseData) | Errored

module CertificateFragment = Certificate.Fragment

module StudentActionsDataQuery = %graphql(`
  query StudentActionsDataQuery($studentId: ID!) {
    student(studentId: $studentId) {
      user {
        name
      }
      droppedOutAt
      issuedCertificates{
        ...IssuedCertificateFragment
      }
      course {
        id
        certificates{
          ...CertificateFragment
        }
      }
    }
  }
  `)

let pageLinks = studentId => [
  School__PageHeader.makeLink(
    ~href={`/school/students/${studentId}/details`},
    ~title=t("pages.details"),
    ~icon="if i-edit-regular text-base font-bold",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/students/${studentId}/actions`,
    ~title=t("pages.actions"),
    ~icon="if i-cog-regular text-base font-bold",
    ~selected=true,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/students/${studentId}/standing`,
    ~title=t("pages.standing"),
    ~icon="if i-shield-regular text-base font-bold",
    ~selected=false,
  ),
]

let loadData = (studentId, setState, setCourseId) => {
  setState(_ => Loading)
  StudentActionsDataQuery.fetch(
    ~notifyOnNotFound=false,
    {
      studentId: studentId,
    },
  )
  |> Js.Promise.then_((response: StudentActionsDataQuery.t) => {
    setState(_ => Loaded({
      student: {
        name: response.student.user.name,
        droppedOutAt: response.student.droppedOutAt->Belt.Option.map(DateFns.decodeISO),
        issuedCertificates: response.student.issuedCertificates->Js.Array2.map(
          IssuedCertificate.makeFromFragment,
        ),
      },
      certificates: response.student.course.certificates->Js.Array2.map(
        Certificate.makeFromFragment,
      ),
      courseId: response.student.course.id,
    }))
    setCourseId(response.student.course.id)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    setState(_ => Errored)
    Js.Promise.resolve()
  })
  |> ignore
}

@react.component
let make = (~studentId) => {
  let (state, setState) = React.useState(() => Unloaded)
  let courseContext = React.useContext(SchoolRouter__CourseContext.context)

  React.useEffect1(() => {
    loadData(studentId, setState, courseContext.setCourseId)
    None
  }, [studentId])

  {
    switch state {
    | Unloaded
    | Loading =>
      SkeletonLoading.coursePage()
    | Loaded(baseData) =>
      <div>
        <School__PageHeader
          exitUrl={`/school/courses/${baseData.courseId}/students`}
          title={`${t("edit")} ${baseData.student.name}`}
          description={t("page_description")}
          links={pageLinks(studentId)}
        />
        <div className="bg-white">
          <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
            <Editor
              studentData={baseData.student}
              certificates={baseData.certificates}
              studentId={studentId}
            />
          </div>
        </div>
      </div>
    | Errored => <ErrorState />
    }
  }
}
