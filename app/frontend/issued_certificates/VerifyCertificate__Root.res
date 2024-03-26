@module("./images/graduate-icon.svg") external graduateIcon: string = "default"

let str = React.string
let t = I18n.t(~scope="components.VerifyCertificate__Root")

type viewMode =
  | Screen
  | Print

let printCertificate = (setViewMode, _event) => {
  setViewMode(_ => Print)
  Js.Global.setTimeout(() => {
    open Webapi.Dom
    window |> Window.print
  }, 1000) |> ignore
}

let heading = (currentUser, issuedCertificate) =>
  if currentUser {
    <span
      dangerouslySetInnerHTML={DOMPurify.sanitizedHTMLOpt(
        t(~variables=[("name", IssuedCertificate.profileName(issuedCertificate))], "heading"),
        DOMPurify.makeOptions(~allowedTags=["strong", "br"], ()),
      )}
    />
  } else {
    IssuedCertificate.serialNumber(issuedCertificate)->str
  }

let handleCancelPrint = (setViewMode, _event) => setViewMode(_ => Screen)

let issuedToName = issuedCertificate => {
  let issuedTo = IssuedCertificate.issuedTo(issuedCertificate)
  let profileName = IssuedCertificate.profileName(issuedCertificate)

  if issuedTo == profileName {
    profileName
  } else {
    "<a href=\"#name-change-notice\" className=\"text-blue-500 hover:text-blue-600\">" ++
    profileName ++ "<i className=\"ms-1 fas fa-exclamation-circle\" /></a>"
  }
}

@react.component
let make = (~issuedCertificate, ~verifyImageUrl, ~currentUser) => {
  let (viewMode, setViewMode) = React.useState(() => Screen)

  switch viewMode {
  | Screen =>
    <div className="container mt-16 mx-auto px-3 max-w-5xl py-8">
      <div
        className="border border-gray-300 rounded-lg bg-gray-50 p-3 md:p-6 flex flex-col md:flex-row items-start md:items-center">
        <div className="text-center md:w-5/12 pe-0  md:pe-5">
          <img src=graduateIcon className="w-18 md:w-24 mx-auto" />
          <h3 className="font-semibold mt-1 md:mt-2">
            {heading(currentUser, issuedCertificate)}
          </h3>
          <div
            className="text-sm mt-4"
            dangerouslySetInnerHTML={DOMPurify.sanitizedHTMLOpt(
              t(
                ~variables=[
                  ("name", issuedToName(issuedCertificate)),
                  (
                    "issue_date",
                    issuedCertificate
                    ->IssuedCertificate.issuedAt
                    ->DateFns.formatPreset(~short=true, ~year=true, ()),
                  ),
                  ("course_name", IssuedCertificate.courseName(issuedCertificate)),
                ],
                "description",
              ),
              DOMPurify.makeOptions(~allowedTags=["strong"], ()),
            )}
          />
          {ReactUtils.nullUnless(
            <div className="mt-4 text-xs">
              <code>
                {t(
                  ~variables=[("serial", IssuedCertificate.serialNumber(issuedCertificate))],
                  "serial_number",
                )->str}
              </code>
            </div>,
            currentUser,
          )}
          <div className="mt-4">
            <button onClick={printCertificate(setViewMode)} className="btn btn-primary">
              <i className="fas fa-print" />
              <span className="ms-2"> {t("print_or_save")->str} </span>
            </button>
          </div>
        </div>
        <div
          className="md:w-7/12 mt-6 md:mt-0 rounded-lg overflow-hidden border-8 border-white shadow-lg">
          <IssuedCertificate__Root issuedCertificate verifyImageUrl />
        </div>
      </div>
      {ReactUtils.nullIf(
        <div
          id="name-change-notice"
          className="border border-blue-200 rounded-lg shadow-lg bg-blue-100 p-3 md:p-6 mt-6 flex items-center">
          <div>
            <i className="fas fa-exclamation-circle text-2xl text-blue-500" />
          </div>
          <div
            className="ms-4 text-sm"
            dangerouslySetInnerHTML={DOMPurify.sanitizedHTMLOpt(
              t(
                ~variables=[("name", IssuedCertificate.issuedTo(issuedCertificate))],
                "originally_issued_to",
              ),
              DOMPurify.makeOptions(~allowedTags=["strong"], ()),
            )}
          />
        </div>,
        IssuedCertificate.profileName(issuedCertificate) ==
          IssuedCertificate.issuedTo(issuedCertificate),
      )}
    </div>
  | Print =>
    <div className="flex flex-col items-start">
      <div className="print:hidden pb-4 md:pt-20">
        <button
          onClick={handleCancelPrint(setViewMode)}
          className="btn btn-subtle verify-certificate__cancel-button">
          <i className="fas fa-undo-alt" />
          <span className="ms-1"> {t("cancel")->str} </span>
        </button>
      </div>
      <IssuedCertificate__Root issuedCertificate verifyImageUrl />
    </div>
  }
}
