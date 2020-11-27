let str = React.string

let paddingPercentage = issuedCertificate =>
  (IssuedCertificate.margin(issuedCertificate) |> string_of_int) ++ "%"

let certificateContainerStyle = issuedCertificate =>
  ReactDOMRe.Style.make(~padding=paddingPercentage(issuedCertificate), ())

let issuedToStyle = issuedCertificate =>
  ReactDOMRe.Style.make(
    ~top=(IssuedCertificate.nameOffsetTop(issuedCertificate) |> string_of_int) ++ "%",
    (),
  )

let qrCodeStyle = issuedCertificate =>
  ReactDOMRe.Style.make(~padding=paddingPercentage(issuedCertificate), ())

let nameCanvasId = issuedCertificate =>
  "name-canvas-" ++ IssuedCertificate.serialNumber(issuedCertificate)

let nameCanvas = issuedCertificate =>
  <canvas
    height="100"
    width="2000"
    id={nameCanvasId(issuedCertificate)}
    className="absolute top-0 w-full"
    style={issuedToStyle(issuedCertificate)}
  />

let qrPositionClasses = issuedCertificate =>
  switch issuedCertificate |> IssuedCertificate.qrCorner {
  | #Hidden => "hidden"
  | #TopLeft => "top-0 left-0"
  | #TopRight => "top-0 right-0"
  | #BottomRight => "bottom-0 right-0"
  | #BottomLeft => "bottom-0 left-0"
  }

let qrContainerStyle = issuedCertificate => {
  let widthPercentage =
    (issuedCertificate |> IssuedCertificate.qrScale |> float_of_int) /. 100.0 *. 10.0
  ReactDOMRe.Style.make(~width=Js.Float.toString(widthPercentage) ++ "%", ())
}

let certificateUrl = issuedCertificate => {
  let prefix = {
    open Webapi.Dom
    location |> Webapi.Dom.Location.origin
  }
  let suffix = "/c/" ++ IssuedCertificate.serialNumber(issuedCertificate)
  prefix ++ suffix
}

let qrCode = (issuedCertificate, verifyImageUrl) =>
  switch issuedCertificate |> IssuedCertificate.qrCorner {
  | #Hidden => React.null
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
  }

@bs.send
external getContextWithAlpha: (Dom.element, string, {"alpha": bool}) => Webapi.Canvas.Canvas2d.t =
  "getContext"

let drawName = issuedCertificate => {
  let canvasId = nameCanvasId(issuedCertificate)

  let canvasElement = {
    open Webapi
    Dom.document |> Dom.Document.getElementById(canvasId)
  }

  let ctx = Belt.Option.map(canvasElement, el => getContextWithAlpha(el, "2d", {"alpha": true}))

  // Begin by clearing the canvas.
  Belt.Option.forEach(ctx, ctx =>
    Webapi.Canvas.Canvas2d.clearRect(~x=0.0, ~y=0.0, ~w=2000.0, ~h=100.0, ctx)
  )

  let fontSize = 50.0 *. ((IssuedCertificate.fontSize(issuedCertificate) |> float_of_int) /. 100.0)

  ctx
  |> OptionUtils.map(ctx =>
    Webapi.Canvas.Canvas2d.font(
      ctx,
      (fontSize
      |> Js.Math.floor_int
      |> string_of_int) ++ "px Menlo, Monaco, Consolas, Liberation Mono, Courier New, monospace",
    )
  )
  |> ignore

  ctx |> OptionUtils.map(ctx => Webapi.Canvas.Canvas2d.textAlign(ctx, "center")) |> ignore

  ctx |> OptionUtils.map(ctx => Webapi.Canvas.Canvas2d.textBaseline(ctx, "middle")) |> ignore

  ctx
  |> OptionUtils.map(ctx =>
    Webapi.Canvas.Canvas2d.fillText(
      IssuedCertificate.profileName(issuedCertificate),
      ~x=1000.0,
      ~y=50.0,
      ctx,
    )
  )
  |> ignore
}

@react.component
let make = (~issuedCertificate, ~verifyImageUrl) => {
  React.useEffect1(() => {
    drawName(issuedCertificate)
    None
  }, [IssuedCertificate.fontSize(issuedCertificate)])

  <div className="relative">
    <img className="w-full" src={IssuedCertificate.imageUrl(issuedCertificate)} />
    <div
      className="absolute top-0 left-0 w-full h-full"
      style={certificateContainerStyle(issuedCertificate)}>
      <div className="relative w-full h-full">
        {nameCanvas(issuedCertificate)} {qrCode(issuedCertificate, verifyImageUrl)}
      </div>
    </div>
  </div>
}
