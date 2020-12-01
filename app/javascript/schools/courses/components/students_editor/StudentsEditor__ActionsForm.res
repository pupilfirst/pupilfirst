open StudentsEditor__Types

let t = I18n.t(~scope="components.StudentsEditor__ActionsForm")

module DropoutStudentQuery = %graphql(
  `
   mutation DropoutStudentMutation($id: ID!) {
    dropoutStudent(id: $id){
      success
     }
   }
 `
)

module RevokeCertificateQuery = %graphql(
  `
   mutation RevokeCertificateMutation($issuedCertificateId: ID!) {
    revokeIssuedCertificate(issuedCertificateId: $issuedCertificateId){
      success
     }
   }
 `
)

module IssueCertificateQuery = %graphql(
  `
   mutation IssueCertificateQueryMutation($certificateId: ID!, $studentId: ID!) {
    issueCertificate(certificateId: $certificateId, studentId: $studentId){
      issuedCertificate {
        id
        serialNumber
      }
     }
   }
 `
)

let dropoutStudent = (id, setSaving, reloadTeamsCB, event) => {
  event |> ReactEvent.Mouse.preventDefault
  setSaving(_ => true)

  DropoutStudentQuery.make(~id, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(response => {
    response["dropoutStudent"]["success"] ? reloadTeamsCB() : setSaving(_ => false)
    Js.Promise.resolve()
  }) |> ignore
}

let revokeIssuedCertificate = (
  issuedCertificate,
  setRevoking,
  updateStudentCertificationCB,
  student,
  currentUserName,
  _event,
) => WindowUtils.confirm(t("revoke_certificate_confirmation"), () => {
    setRevoking(_ => true)

    let issuedCertificateId = StudentsEditor__IssuedCertificate.id(issuedCertificate)

    RevokeCertificateQuery.make(~issuedCertificateId, ())
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(response => {
      response["revokeIssuedCertificate"]["success"]
        ? {
            let updatedCertificate =
              issuedCertificate->StudentsEditor__IssuedCertificate.revoke(
                Some(currentUserName),
                Some(Js.Date.make()),
              )
            let updatedStudent = student->Student.updateCertificate(updatedCertificate)
            updateStudentCertificationCB(updatedStudent)
            setRevoking(_ => false)
          }
        : setRevoking(_ => false)
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Js.log(error)
      setRevoking(_ => false)
      Js.Promise.resolve()
    })
    |> ignore
  })

let issueNewCertificate = (
  setIssuing,
  certificateId,
  student,
  updateStudentCertificationCB,
  currentUserName,
  event,
) => {
  event |> ReactEvent.Mouse.preventDefault
  setIssuing(_ => true)

  let studentId = Student.id(student)

  IssueCertificateQuery.make(~certificateId, ~studentId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    let data = response["issueCertificate"]["issuedCertificate"]
    switch data {
    | Some(data) =>
      let newCertifcate = StudentsEditor__IssuedCertificate.make(
        ~id=data["id"],
        ~certificateId,
        ~serialNumber=data["serialNumber"],
        ~revokedAt=None,
        ~revokedBy=None,
        ~issuedBy=currentUserName,
        ~createdAt=Js.Date.make(),
      )
      let updatedStudent = student->Student.addNewCertificate(newCertifcate)
      updateStudentCertificationCB(updatedStudent)
      setIssuing(_ => false)

    | None => setIssuing(_ => false)
    }
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    setIssuing(_ => false)
    Js.Promise.resolve()
  })
  |> ignore
}

let str = ReasonReact.string

let submitButtonIcons = saving => saving ? "fas fa-spinner fa-spin" : "fa fa-exclamation-triangle"

let issueButtonIcons = issuing => issuing ? "fas fa-spinner fa-spin" : "fas fa-certificate"

let showIssuedCertificates = (
  student,
  certificates,
  revoking,
  setRevoking,
  updateStudentCB,
  currentUserName,
) => {
  let issuedCertificates = StudentsEditor__Student.issuedCertificates(student)
  issuedCertificates->ArrayUtils.isEmpty
    ? <p className="text-xs text-gray-800"> {t("empty_issued_certificates_text")->str} </p>
    : <div className="flex flex-col">
        <label className="tracking-wide text-sm font-semibold mb-2">
          {t("issued_certificates_label")->str}
        </label>
        {issuedCertificates |> Js.Array.map(ic =>
          <div
            ariaLabel={"Details of issued certificate " ++ StudentsEditor__IssuedCertificate.id(ic)}
            key={StudentsEditor__IssuedCertificate.id(ic)}
            className="flex flex-col mt-2 p-2 border rounded border-gray-400">
            <div className="flex justify-between">
              <span className="text-sm font-semibold">
                {StudentsEditor__IssuedCertificate.certificate(ic, certificates)
                ->Certificate.name
                ->str}
              </span>
              {StudentsEditor__IssuedCertificate.revokedAt(ic)->Belt.Option.isSome
                |> ReactUtils.nullUnless(
                  <div
                    className="w-16 p-1 text-xs leading-tight rounded text-center bg-red-200 border-red-800">
                    {t("revoked_status_label")->str}
                  </div>,
                )}
            </div>
            <div className="text-xs text-gray-700">
              {StudentsEditor__IssuedCertificate.serialNumber(ic)->str}
            </div>
            <div className="flex justify-between mt-2 items-end">
              <div className="flex flex-col">
                <div>
                  <span className="font font-semibold text-xs">
                    {t("issued_date_label")->str}
                  </span>
                  <span className="text-xs ml-2">
                    {StudentsEditor__IssuedCertificate.createdAt(ic)
                    ->DateFns.format("MMMM d, yyyy")
                    ->str}
                  </span>
                </div>
                <div>
                  <span className="font font-semibold text-xs"> {t("issued_by_label")->str} </span>
                  <span className="text-xs ml-2">
                    {StudentsEditor__IssuedCertificate.issuedBy(ic)->str}
                  </span>
                </div>
              </div>
              {switch StudentsEditor__IssuedCertificate.revokedAt(ic) {
              | Some(revokedAt) =>
                <div className="flex flex-col">
                  <div>
                    <span className="font font-semibold text-xs">
                      {t("revoked_date_label")->str}
                    </span>
                    <span className="text-xs ml-2">
                      {revokedAt->DateFns.format("MMMM d, yyyy")->str}
                    </span>
                  </div>
                  <div>
                    <span className="font font-semibold text-xs">
                      {t("revoked_by_label")->str}
                    </span>
                    <span className="text-xs ml-2">
                      {StudentsEditor__IssuedCertificate.revokedBy(ic)
                      ->Belt.Option.mapWithDefault("Unknown", r => r)
                      ->str}
                    </span>
                  </div>
                </div>
              | None =>
                <button
                  disabled=revoking
                  onClick={revokeIssuedCertificate(
                    ic,
                    setRevoking,
                    updateStudentCB,
                    student,
                    currentUserName,
                  )}
                  className="btn btn-danger btn-small">
                  {t("revoke_certificate_button")->str}
                </button>
              }}
            </div>
          </div>
        ) |> React.array}
      </div>
}

@react.component
let make = (
  ~student,
  ~reloadTeamsCB,
  ~certificates,
  ~updateStudentCertificationCB,
  ~currentUserName,
) => {
  let (saving, setSaving) = React.useState(() => false)

  let (issuing, setIssuing) = React.useState(() => false)

  let (revoking, setRevoking) = React.useState(() => false)

  let (selectedCertificateId, setSelectedCertificateId) = React.useState(() => "0")

  <div className="mt-5">
    <div className="mb-4" ariaLabel="Manage student certificates">
      <h5 className="mb-2"> {t("certificates_label")->str} </h5>
      {certificates |> ArrayUtils.isEmpty
        ? <p className="text-xs text-gray-800"> {t("empty_course_certificates_text")->str} </p>
        : <div>
            {showIssuedCertificates(
              student,
              certificates,
              revoking,
              setRevoking,
              updateStudentCertificationCB,
              currentUserName,
            )}
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
                      setSelectedCertificateId(_ => selectedValue)
                    }}
                    value=selectedCertificateId>
                    <option key="0" value="0"> {t("select_certificate_input_label")->str} </option>
                    {certificates |> Array.map(certificate =>
                      <option key={Certificate.id(certificate)} value={Certificate.id(certificate)}>
                        {
                          let name = Certificate.name(certificate)
                          (
                            Certificate.active(certificate)
                              ? name ++ (" (" ++ (t("active_label") ++ ")"))
                              : name
                          )->str
                        }
                      </option>
                    ) |> React.array}
                  </select>
                  <button
                    onClick={issueNewCertificate(
                      setIssuing,
                      selectedCertificateId,
                      student,
                      updateStudentCertificationCB,
                      currentUserName,
                    )}
                    disabled={issuing || selectedCertificateId == "0"}
                    className="btn btn-success ml-2 text-sm h-10">
                    <FaIcon classes={issueButtonIcons(issuing)} />
                    <span className="ml-2"> {t("issue_certificate_button")->str} </span>
                  </button>
                </div>
              </div>,
              Student.hasLiveCertificate(student),
            )}
          </div>}
    </div>
    <label className="tracking-wide text-xs font-semibold" htmlFor="access-ends-at-input">
      {t("dropout_student_label")->str}
    </label>
    <HelpIcon className="ml-2" link="https://docs.pupilfirst.com/#/students?id=student-actions">
      {"Marking a student as dropped out will remove all of their access to the course." |> str}
    </HelpIcon>
    <div className="mt-2">
      <button
        disabled=saving
        className="btn btn-danger btn-large"
        onClick={dropoutStudent(student |> Student.id, setSaving, reloadTeamsCB)}>
        <FaIcon classes={submitButtonIcons(saving)} />
        <span className="ml-2"> {t("dropout_button")->str} </span>
      </button>
    </div>
  </div>
}
