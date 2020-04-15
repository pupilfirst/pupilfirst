let str = React.string;

let paddingPercentage = issuedCertificate =>
  (issuedCertificate |> IssuedCertificate.margin |> string_of_int) ++ "%";

let certificateContainerStyle = issuedCertificate =>
  ReactDOMRe.Style.make(~padding=issuedCertificate |> paddingPercentage, ());

let issuedToStyle = (issuedCertificate, fontSize) => {
  ReactDOMRe.Style.make(
    ~top=
      (issuedCertificate |> IssuedCertificate.nameOffsetTop |> string_of_int)
      ++ "%",
    ~fontSize=(fontSize |> Js.Math.ceil_int |> string_of_int) ++ "%",
    (),
  );
};

let computeFontSize = (~maxWidth, ~minWidth, ~issuedCertificate) => {
  let configuredFontSize =
    issuedCertificate |> IssuedCertificate.fontSize |> float_of_int;

  let windowWidth = Webapi.Dom.(window |> Window.innerWidth);

  let maxLimitedWidth =
    maxWidth
    |> OptionUtils.mapWithDefault(
         maxWidth => windowWidth > maxWidth ? maxWidth : windowWidth,
         windowWidth,
       );

  let limitedWidth =
    minWidth
    |> OptionUtils.mapWithDefault(
         minWidth => windowWidth < minWidth ? minWidth : maxLimitedWidth,
         maxLimitedWidth,
       );

  configuredFontSize *. (float_of_int(limitedWidth) /. 672.0);
};

let qrCodeStyle = issuedCertificate => {
  let padding = issuedCertificate |> paddingPercentage;

  ReactDOMRe.Style.make(~padding, ());
};

let name = (issuedCertificate, fontSize) =>
  <div
    className="absolute top-0 w-full h-full text-center font-bold"
    style={issuedToStyle(issuedCertificate, fontSize)}>
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

[@react.component]
let make = (~issuedCertificate, ~verifyImageUrl, ~maxWidth=?, ~minWidth=?) => {
  let (fontSize, setFontSize) =
    React.useState(() =>
      computeFontSize(~maxWidth, ~minWidth, ~issuedCertificate)
    );

  React.useEffect(() => {
    let handleResize = _event =>
      setFontSize(_ =>
        computeFontSize(~maxWidth, ~minWidth, ~issuedCertificate)
      );

    Webapi.Dom.(window |> Window.addEventListener("resize", handleResize));

    Some(
      () =>
        Webapi.Dom.(
          window |> Window.removeEventListener("resize", handleResize)
        ),
    );
  });

  <div className="relative">
    <img src={issuedCertificate |> IssuedCertificate.imageUrl} />
    <div
      className="absolute top-0 left-0 w-full h-full"
      style={certificateContainerStyle(issuedCertificate)}>
      <div className="relative w-full h-full">
        {name(issuedCertificate, fontSize)}
        {qrCode(issuedCertificate, verifyImageUrl)}
      </div>
    </div>
  </div>;
};
