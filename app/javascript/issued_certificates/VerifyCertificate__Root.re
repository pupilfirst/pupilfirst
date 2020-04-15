let str = React.string;

[@react.component]
let make = (~issuedCertificate, ~verifyImageUrl) => {
  <div className="py-4">
    <div className="container mx-auto px-3 max-w-5xl">
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
        <a
          href={
            "/c/"
            ++ (issuedCertificate |> IssuedCertificate.serialNumber)
            ++ "/print"
          }
          className="btn btn-primary">
          <i className="fas fa-print" />
          <span className="ml-2"> {"Print, or save as PDF" |> str} </span>
        </a>
      </div>
    </div>
    <div className="mt-4 max-w-2xl mx-auto">
      <IssuedCertificate__Root issuedCertificate verifyImageUrl maxWidth=672 />
    </div>
  </div>;
};
