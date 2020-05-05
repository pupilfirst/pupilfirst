[%bs.raw {|require("./VerifyCertificate__Root.css")|}];

[@bs.module "./images/graduate-icon.svg"]
external graduateIcon: string = "default";

let str = React.string;

type viewMode =
  | Screen
  | Print;

let printCertificate = (setViewMode, _event) => {
  setViewMode(_ => Print);
  Js.Global.setTimeout(() => Webapi.Dom.(window |> Window.print), 1000)
  |> ignore;
};

let heading = (currentUser, issuedCertificate) =>
  if (currentUser) {
    <span>
      {"Congratulations " |> str}
      <strong>
        {issuedCertificate |> IssuedCertificate.issuedTo |> str}
      </strong>
      {"!" |> str}
      <br />
      {"You've earned it." |> str}
    </span>;
  } else {
    issuedCertificate |> IssuedCertificate.serialNumber |> str;
  };

let handleCancelPrint = (setViewMode, _event) => setViewMode(_ => Screen);

[@react.component]
let make = (~issuedCertificate, ~verifyImageUrl, ~currentUser) => {
  let (viewMode, setViewMode) = React.useState(() => Screen);

  switch (viewMode) {
  | Screen =>
    <div className="container mx-auto px-3 max-w-5xl py-8">
      <div
        className="border border-gray-300 rounded-lg shadow-lg bg-white p-3 md:p-6 flex flex-col md:flex-row items-start md:items-center">
        <div className="text-center md:w-5/12 pr-0 md:pr-5">
          <img src=graduateIcon className="w-18 md:w-24 mx-auto" />
          <h3 className="font-semibold mt-1 md:mt-2">
            {heading(currentUser, issuedCertificate)}
          </h3>
          <div className="text-sm mt-4">
            <span> {"This certificate was issued to " |> str} </span>
            <strong>
              {issuedCertificate |> IssuedCertificate.issuedTo |> str}
            </strong>
            <span> {" on " |> str} </span>
            <strong>
              {issuedCertificate
               ->IssuedCertificate.issuedAt
               ->DateFns.formatPreset(~short=true, ~year=true, ())
               ->str}
            </strong>
            <span> {" for completing the course " |> str} </span>
            <strong>
              {issuedCertificate |> IssuedCertificate.courseName |> str}
            </strong>
            <span> {"." |> str} </span>
          </div>
          {currentUser
             ? <div className="mt-4 text-xs">
                 <code>
                   {"Serial No. " |> str}
                   {issuedCertificate |> IssuedCertificate.serialNumber |> str}
                 </code>
               </div>
             : React.null}
          <div className="mt-4">
            <button
              onClick={printCertificate(setViewMode)}
              className="btn btn-primary">
              <i className="fas fa-print" />
              <span className="ml-2"> {"Print, or save as PDF" |> str} </span>
            </button>
          </div>
        </div>
        <div
          className="md:w-7/12 mt-6 md:mt-0 rounded-lg overflow-hidden border-8 border-white shadow-lg">
          <IssuedCertificate__Root issuedCertificate verifyImageUrl />
        </div>
      </div>
    </div>
  | Print =>
    <div className="flex flex-col items-center">
      <button
        onClick={handleCancelPrint(setViewMode)}
        className="btn btn-secondary my-4 md:my-6 verify-certificate__cancel-button">
        <i className="fas fa-undo-alt" />
        <span className="ml-1"> {"Cancel and return" |> str} </span>
      </button>
      <IssuedCertificate__Root issuedCertificate verifyImageUrl />
    </div>
  };
};
