[%bs.raw {|require("./VerifyCertificate__Root.css")|}];

open VerifyCertificate__Types;

let str = React.string;

let paddingPercentage = issuedCertificate =>
  (issuedCertificate |> IssuedCertificate.margin |> string_of_int) ++ "%";

let certificateContainerStyle = issuedCertificate =>
  ReactDOMRe.Style.make(~padding=issuedCertificate |> paddingPercentage, ());

let issuedToStyle = issuedCertificate =>
  ReactDOMRe.Style.make(
    ~top=
      (issuedCertificate |> IssuedCertificate.nameOffsetTop |> string_of_int)
      ++ "%",
    ~fontSize=
      (issuedCertificate |> IssuedCertificate.fontSize |> string_of_int) ++ "%",
    (),
  );

let qrCodeStyle = issuedCertificate => {
  let padding = issuedCertificate |> paddingPercentage;

  ReactDOMRe.Style.make(~padding, ());
};

let name = issuedCertificate =>
  <div
    className="absolute top-0 w-full h-full text-center font-bold"
    style={issuedToStyle(issuedCertificate)}>
    {issuedCertificate |> IssuedCertificate.issuedTo |> str}
  </div>;

let qrPositionClasses = issuedCertificate =>
  switch (issuedCertificate |> IssuedCertificate.qrCorner) {
  | IssuedCertificate.Hidden => "hidden"
  | TopLeft => "top-0 left-0"
  | TopRight => "top-0 right-0"
  | BottomRight => "bottom-0 right-0"
  | BottomLeft => "bottom-0 left-0"
  };

let qrContainerStyle = issuedCertificate => {
  let widthPercentage =
    (issuedCertificate |> IssuedCertificate.qrScale |> float_of_int)
    /. 100.0
    *. 10.0;
  ReactDOMRe.Style.make(
    ~width=(widthPercentage |> Js.Float.toString) ++ "%",
    (),
  );
};

let certificateUrl = issuedCertificate => {
  let prefix = Webapi.Dom.(location |> Webapi.Dom.Location.origin);
  let suffix = "/c/" ++ (issuedCertificate |> IssuedCertificate.serialNumber);
  prefix ++ suffix;
};

let qrCode = (issuedCertificate, verifyImageUrl) =>
  switch (issuedCertificate |> IssuedCertificate.qrCorner) {
  | IssuedCertificate.Hidden => React.null
  | _ =>
    <div
      className={"absolute " ++ qrPositionClasses(issuedCertificate)}
      style={qrContainerStyle(issuedCertificate)}>
      <QrCode
        style={ReactDOMRe.Style.make(~width="100%", ~height="100%", ())}
        value={certificateUrl(issuedCertificate)}
        className="w-full h-full"
        size=256
        level="Q"
        bgColor="transparent"
        imageSettings={QrCode.imageSettings(
          ~src=verifyImageUrl,
          ~width=133,
          ~height=29,
          ~excavate=true,
          (),
        )}
      />
    </div>
  };

let printCertificate = _event => Webapi.Dom.(window |> Window.print);

[@react.component]
let make = (~issuedCertificate, ~verifyImageUrl) =>
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
    <div className="verify-certificate__certificate relative">
      <img src={issuedCertificate |> IssuedCertificate.imageUrl} />
      <div
        className="absolute top-0 left-0 w-full h-full"
        style={certificateContainerStyle(issuedCertificate)}>
        <div className="relative w-full h-full">
          {name(issuedCertificate)}
          {qrCode(issuedCertificate, verifyImageUrl)}
        </div>
      </div>
    </div>
  </div>;
