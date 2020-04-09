open VerifyCertificate__Types;

let str = React.string;

module QrCode = {
  type options = {
    .
    "text": string,
    "width": int,
    "height": int,
  };

  type t;
  [@bs.new] external createQrCode: (string, options) => t = "QRCode";
  [@bs.send] external clear: t => unit = "clear";

  let make = (id, url) =>
    createQrCode(id, {"text": url, "width": 256, "height": 256});
};

module Test = {
  [@react.component]
  let make = (~url) => {
    let (id, _setId) = React.useState(DateTime.randomId);

    React.useEffect(() => {
      let qrCode = QrCode.make(id, url);
      Some(() => qrCode |> QrCode.clear);
    });

    <div id />;
  };
};

let paddingPercentage = issuedCertificate =>
  (issuedCertificate |> IssuedCertificate.margin |> string_of_int) ++ "%";

let issuedToStyle = issuedCertificate =>
  ReactDOMRe.Style.make(
    ~padding=issuedCertificate |> paddingPercentage,
    ~top=
      (issuedCertificate |> IssuedCertificate.nameOffsetTop |> string_of_int)
      ++ "%",
    ~fontSize=
      (issuedCertificate |> IssuedCertificate.fontSize |> string_of_int) ++ "%",
    (),
  );

let qrCodeStyle = issuedCertificate => {
  let padding = issuedCertificate |> paddingPercentage;

  ReactDOMRe.Style.make(
    ~paddingLeft=padding,
    ~paddingTop=padding,
    ~width="100px",
    (),
  );
};

let name = issuedCertificate =>
  <div
    className="absolute top-0 w-full h-full text-center font-bold"
    style={issuedToStyle(issuedCertificate)}>
    {issuedCertificate |> IssuedCertificate.issuedTo |> str}
  </div>;

let qrText = text =>
  <div
    className="font-mono font-semibold text-gray-600"
    style={ReactDOMRe.Style.make(~fontSize="13px", ())}>
    {text |> str}
  </div>;

let qrCode = issuedCertificate =>
  switch (issuedCertificate |> IssuedCertificate.qrCorner) {
  | IssuedCertificate.Hidden => React.null
  | _ =>
    <div
      className="absolute top-0 left-0"
      style={qrCodeStyle(issuedCertificate)}>
      // {qrText("VERIFY")}
       <Test url="https://example.com" /> </div>
  // {qrText("ONLINE")}
  };

[@react.component]
let make = (~issuedCertificate) =>
  <div className="container mx-auto px-3 max-w-5xl py-4">
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
    <div className="mt-4 max-w-2xl mx-auto relative">
      <img src={issuedCertificate |> IssuedCertificate.imageUrl} />
      {name(issuedCertificate)}
      {qrCode(issuedCertificate)}
    </div>
  </div>;
