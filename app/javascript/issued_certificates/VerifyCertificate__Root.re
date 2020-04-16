[%bs.raw {|require("./VerifyCertificate__Root.css")|}];

let str = React.string;

let printCertificate = _event => Webapi.Dom.(window |> Window.print);

[@react.component]
let make = (~issuedCertificate, ~verifyImageUrl) => {
  <div className="py-4">
    <div
      className="verify-certificate__header container mx-auto px-3 max-w-5xl">
      <h1>
        {"Certificate "
         ++ (issuedCertificate |> IssuedCertificate.serialNumber)
         |> str}
      </h1>
      <span>
        <span> {"This certificate was issued to " |> str} </span>
        <strong>
          {issuedCertificate |> IssuedCertificate.issuedTo |> str}
        </strong>
        <span> {" on " |> str} </span>
        <strong>
          {issuedCertificate
           |> IssuedCertificate.issuedAt
           |> DateTime.format(DateTime.OnlyDate)
           |> str}
        </strong>
        <span> {" for completing the course " |> str} </span>
        <strong>
          {issuedCertificate |> IssuedCertificate.courseName |> str}
        </strong>
        <span> {"." |> str} </span>
      </span>
      <div className="mt-2">
        <button onClick=printCertificate className="btn btn-primary">
          <i className="fas fa-print" />
          <span className="ml-2"> {"Print, or save as PDF" |> str} </span>
        </button>
      </div>
    </div>
    <div className="verify-certificate__certificate-container">
      <IssuedCertificate__Root issuedCertificate verifyImageUrl />
    </div>
  </div>;
};
