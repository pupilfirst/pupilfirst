open StudentsEditor__Types;

module DropoutStudentQuery = [%graphql
  {|
   mutation DropoutStudentMutation($id: ID!) {
    dropoutStudent(id: $id){
      success
     }
   }
 |}
];

module RevokeCertificateQuery = [%graphql
  {|
   mutation RevokeCertificateMutation($issuedCertificateId: ID!) {
    revokeIssuedCertificate(issuedCertificateId: $issuedCertificateId){
      success
     }
   }
 |}
];

module IssueCertificateQuery = [%graphql
  {|
   mutation IssueCertificateQueryMutation($certificateId: ID!, $studentId: ID!) {
    issueCertificate(certificateId: $certificateId, studentId: $studentId){
      issuedCertificate {
        id
        serialNumber
      }
     }
   }
 |}
];

let dropoutStudent = (id, setSaving, reloadTeamsCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setSaving(_ => true);

  DropoutStudentQuery.make(~id, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##dropoutStudent##success
         ? reloadTeamsCB() : setSaving(_ => false);
       Js.Promise.resolve();
     })
  |> ignore;
};

let revokeIssuedCertificate =
    (
      issuedCertificate,
      setRevoking,
      updateStudentCertificationCB,
      student,
      currentUserName,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  setRevoking(_ => true);

  let issuedCertificateId =
    StudentsEditor__IssuedCertificate.id(issuedCertificate);

  RevokeCertificateQuery.make(~issuedCertificateId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##revokeIssuedCertificate##success
         ? {
           let updatedCertificate =
             issuedCertificate->StudentsEditor__IssuedCertificate.revoke(
               Some(currentUserName),
               Some(Js.Date.make()),
             );
           let updatedStudent =
             student->Student.updateCertificate(updatedCertificate);
           updateStudentCertificationCB(updatedStudent);
           setRevoking(_ => false);
         }
         : setRevoking(_ => false);
       Js.Promise.resolve();
     })
  |> ignore;
};

let issueNewCertificate =
    (
      setIssuing,
      certificateId,
      student,
      updateStudentCertificationCB,
      currentUserName,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  setIssuing(_ => true);

  let studentId = Student.id(student);

  IssueCertificateQuery.make(~certificateId, ~studentId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       let data = response##issueCertificate##issuedCertificate;
       switch (data) {
       | Some(data) =>
         let newCertifcate =
           StudentsEditor__IssuedCertificate.make(
             ~id=data##id,
             ~certificateId,
             ~serialNumber=data##serialNumber,
             ~revokedAt=None,
             ~revokedBy=None,
             ~issuedBy=currentUserName,
             ~createdAt=Js.Date.make(),
           );
         let updatedStudent =
           student->Student.addNewCertificate(newCertifcate);
         updateStudentCertificationCB(updatedStudent);
         setIssuing(_ => false);

       | None => setIssuing(_ => false)
       };
       Js.Promise.resolve();
     })
  |> ignore;
};

let str = ReasonReact.string;

let submitButtonIcons = saving => {
  saving ? "fas fa-spinner fa-spin" : "fa fa-exclamation-triangle";
};

let issueButtonIcons = issuing => {
  issuing ? "fas fa-spinner fa-spin" : "fas fa-certificate";
};

let certificateStatusPillColour = revokedAt => {
  switch (revokedAt) {
  | Some(_) => "bg-red-200 border-red-800"
  | None => "bg-green-200 border-green-800"
  };
};

let showIssuedCertificates =
    (
      student,
      certificates,
      revoking,
      setRevoking,
      updateStudentCB,
      currentUserName,
    ) => {
  let issuedCertificates =
    StudentsEditor__Student.issuedCertificates(student);
  issuedCertificates->ArrayUtils.isEmpty
    ? <p className="text-xs text-gray-800">
        "The student has currently no certificate issued for this course!"->str
      </p>
    : {
      <div className="flex flex-col">
        <label className="tracking-wide text-sm font-semibold mb-2">
          "Issued certificates:"->str
        </label>
        {issuedCertificates
         |> Js.Array.map(ic =>
              <div
                key={StudentsEditor__IssuedCertificate.id(ic)}
                className="flex flex-col mt-2 p-2 border rounded border-gray-400">
                <div className="flex justify-between">
                  <span className="text-sm font-semibold">
                    {StudentsEditor__IssuedCertificate.certificate(
                       ic,
                       certificates,
                     )
                     ->Certificate.name
                     ->str}
                  </span>
                  {let revokedAt =
                     StudentsEditor__IssuedCertificate.revokedAt(ic);
                   <div
                     className={
                       "w-16 p-1 text-xs leading-tight rounded text-center "
                       ++ certificateStatusPillColour(revokedAt)
                     }>
                     (
                       switch (revokedAt) {
                       | Some(_) => "Revoked"
                       | None => "Active"
                       }
                     )
                     ->str
                   </div>}
                </div>
                <div className="text-xs text-gray-700">
                  {StudentsEditor__IssuedCertificate.serialNumber(ic)->str}
                </div>
                <div className="flex justify-between mt-2 items-end">
                  <div className="flex flex-col">
                    <div>
                      <span className="font font-semibold text-xs">
                        "Issued on: "->str
                      </span>
                      <span className="text-xs">
                        {StudentsEditor__IssuedCertificate.createdAt(ic)
                         ->DateFns.format("MMMM d, yyyy")
                         ->str}
                      </span>
                    </div>
                    <div>
                      <span className="font font-semibold text-xs">
                        "Issued by: "->str
                      </span>
                      <span className="text-xs">
                        {StudentsEditor__IssuedCertificate.issuedBy(ic)->str}
                      </span>
                    </div>
                  </div>
                  {switch (StudentsEditor__IssuedCertificate.revokedAt(ic)) {
                   | Some(revokedAt) =>
                     <div className="flex flex-col">
                       <div>
                         <span className="font font-semibold text-xs">
                           "Revoked on: "->str
                         </span>
                         <span className="text-xs">
                           {revokedAt->DateFns.format("MMMM d, yyyy")->str}
                         </span>
                       </div>
                       <div>
                         <span className="font font-semibold text-xs">
                           "Revoked by: "->str
                         </span>
                         <span className="text-xs">
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
                       "Revoke Certificate"->str
                     </button>
                   }}
                </div>
              </div>
            )
         |> React.array}
      </div>;
    };
};

[@react.component]
let make =
    (
      ~student,
      ~reloadTeamsCB,
      ~certificates,
      ~updateStudentCertificationCB,
      ~currentUserName,
    ) => {
  let (saving, setSaving) = React.useState(() => false);

  let (issuing, setIssuing) = React.useState(() => false);

  let (revoking, setRevoking) = React.useState(() => false);

  let (selectedCertificateId, setSelectedCertificateId) =
    React.useState(() => "0");

  <div className="mt-5">
    <div className="mb-4" ariaLabel="Manage student certificates">
      <h5 className="mb-2"> "Course Certificates"->str </h5>
      {certificates |> ArrayUtils.isEmpty
         ? <p className="text-xs text-gray-800">
             "This course has currently no certificates to issue!"->str
           </p>
         : <div>
             {showIssuedCertificates(
                student,
                certificates,
                revoking,
                setRevoking,
                updateStudentCertificationCB,
                currentUserName,
              )}
             {<div className="flex flex-col mt-2">
                <label className="tracking-wide text-sm font-semibold mb-2">
                  "Issue new certificate:"->str
                </label>
                {Student.hasActiveCertificate(student)
                   ? <div
                       className="flex p-4 bg-yellow-100 text-yellow-900 border border-yellow-500 border-l-4 rounded-r-md mt-2">
                       "The student already has an active certificate issued for this course. Please revoke the current certificate to issue a new one."
                       ->React.string
                     </div>
                   : <div className="flex items-end mt-2">
                       <select
                         className="cursor-pointer appearance-none block w-full bg-white border border-gray-400 rounded h-10 py-2 px-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                         id="issue-certificate"
                         onChange={event => {
                           let selectedValue =
                             ReactEvent.Form.target(event)##value;
                           setSelectedCertificateId(_ => selectedValue);
                         }}
                         value=selectedCertificateId>
                         <option key="0" value="0">
                           {str("Select a certificate to issue")}
                         </option>
                         {certificates
                          |> Array.map(certificate =>
                               <option
                                 key={Certificate.id(certificate)}
                                 value={Certificate.id(certificate)}>
                                 {Certificate.name(certificate)->str}
                               </option>
                             )
                          |> React.array}
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
                         <span className="ml-2">
                           "Issue Certificate"->str
                         </span>
                       </button>
                     </div>}
              </div>}
           </div>}
    </div>
    <label
      className="tracking-wide text-xs font-semibold"
      htmlFor="access-ends-at-input">
      {"Has this student dropped out?" |> str}
    </label>
    <HelpIcon
      className="ml-2"
      link="https://docs.pupilfirst.com/#/students?id=student-actions">
      {"Marking a student as dropped out will remove all of their access to the course."
       |> str}
    </HelpIcon>
    <div className="mt-2">
      <button
        disabled=saving
        className="btn btn-danger btn-large"
        onClick={dropoutStudent(
          student |> Student.id,
          setSaving,
          reloadTeamsCB,
        )}>
        <FaIcon classes={submitButtonIcons(saving)} />
        <span className="ml-2"> {"Dropout Student" |> str} </span>
      </button>
    </div>
  </div>;
};
