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

let str = ReasonReact.string;

let submitButtonIcons = saving => {
  saving ? "fas fa-spinner fa-spin" : "fa fa-exclamation-triangle";
};

let certificateStatusPillColour = revokedAt => {
  switch (revokedAt) {
  | Some(_) => "bg-red-200 border-red-800"
  | None => "bg-green-200 border-green-800"
  };
};

let showIssuedCertificates = (student, certificates) => {
  let issuedCertificates =
    StudentsEditor__Student.issuedCertificates(student);
  issuedCertificates->ArrayUtils.isEmpty
    ? <p className="text-xs text-gray-800">
        "The student has currently no certificate issued for this course!"->str
      </p>
    : {
      issuedCertificates
      |> Js.Array.map(ic =>
           <div
             className="flex flex-col mb-2 p-2 border rounded border-gray-400">
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
                  <button className="btn btn-danger btn-small">
                    "Revoke"->str
                  </button>
                }}
             </div>
           </div>
         )
      |> React.array;
    };
};

[@react.component]
let make = (~student, ~reloadTeamsCB, ~certificates) => {
  let (saving, setSaving) = React.useState(() => false);

  <div className="mt-5">
    <div className="mb-4" ariaLabel="Manage student certificates">
      <h5 className="mb-2"> "Course Certificates"->str </h5>
      {certificates |> ArrayUtils.isEmpty
         ? <p className="text-xs text-gray-800">
             "This course has currently no certificates to issue!"->str
           </p>
         : showIssuedCertificates(student, certificates)}
      {Student.hasActiveCertificate(student)
         ? React.null
         : <div className="flex flex-col mt-2">
             <label className="tracking-wide text-xs font-semibold mb-2">
               "Issue new certificate:"->str
             </label>
             <div className="flex">
               <select
                 className="appearance-none h-10 block w-full text-gray-700 border rounded border-gray-400 py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
                 id="add-new-category"
                 placeholder="Select a certificate to issue"
                 value="asdas">
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
               <button className="btn btn-success ml-2 text-sm">
                 "Issue"->str
               </button>
             </div>
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
