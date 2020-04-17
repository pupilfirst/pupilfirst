let str = React.string;

let paddingPercentage = issuedCertificate =>
  (issuedCertificate |> IssuedCertificate.margin |> string_of_int) ++ "%";

let certificateContainerStyle = issuedCertificate =>
  ReactDOMRe.Style.make(~padding=issuedCertificate |> paddingPercentage, ());

let issuedToStyle = issuedCertificate => {
  ReactDOMRe.Style.make(
    ~top=
      (issuedCertificate |> IssuedCertificate.nameOffsetTop |> string_of_int)
      ++ "%",
    (),
  );
};

let qrCodeStyle = issuedCertificate => {
  let padding = issuedCertificate |> paddingPercentage;

  ReactDOMRe.Style.make(~padding, ());
};

let nameCanvasId = issuedCertificate =>
  "name-canvas-" ++ IssuedCertificate.serialNumber(issuedCertificate);

let nameCanvas = issuedCertificate =>
  <canvas
    height="100"
    width="2000"
    id={nameCanvasId(issuedCertificate)}
    className="absolute top-0 w-full"
    style={issuedToStyle(issuedCertificate)}
  />;

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

[@bs.send]
external getContextWithAlpha:
  (Dom.element, string, {. "alpha": bool}) => Webapi.Canvas.Canvas2d.t =
  "getContext";

let drawName = issuedCertificate => {
  let canvasId = nameCanvasId(issuedCertificate);

  let ctx =
    Webapi.(
      Dom.document
      |> Dom.Document.getElementById(canvasId)
      |> OptionUtils.map(el =>
           getContextWithAlpha(el, "2d", {"alpha": true})
         )
    );

  let fontSize =
    50.0
    *. (
      (issuedCertificate |> IssuedCertificate.fontSize |> float_of_int)
      /. 100.0
    );

  ctx
  |> OptionUtils.map(ctx =>
       Webapi.Canvas.Canvas2d.font(
         ctx,
         (fontSize |> Js.Math.floor_int |> string_of_int)
         ++ "px Menlo, Monaco, Consolas, Liberation Mono, Courier New, monospace",
       )
     )
  |> ignore;

  ctx
  |> OptionUtils.map(ctx => Webapi.Canvas.Canvas2d.textAlign(ctx, "center"))
  |> ignore;

  ctx
  |> OptionUtils.map(ctx =>
       Webapi.Canvas.Canvas2d.textBaseline(ctx, "middle")
     )
  |> ignore;

  ctx
  |> OptionUtils.map(ctx =>
       Webapi.Canvas.Canvas2d.fillText(
         IssuedCertificate.issuedTo(issuedCertificate),
         ~x=1000.0,
         ~y=50.0,
         ctx,
       )
     )
  |> ignore;
};

[@react.component]
let make = (~issuedCertificate, ~verifyImageUrl) => {
  React.useEffect0(() => {
    drawName(issuedCertificate);
    None;
  });

  <div className="relative">
    <img src={issuedCertificate |> IssuedCertificate.imageUrl} />
    <div
      className="absolute top-0 left-0 w-full h-full"
      style={certificateContainerStyle(issuedCertificate)}>
      <div className="relative w-full h-full">
        {nameCanvas(issuedCertificate)}
        {qrCode(issuedCertificate, verifyImageUrl)}
      </div>
    </div>
  </div>;
};
