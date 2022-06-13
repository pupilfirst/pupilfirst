@deriving(abstract)
type imageSettings = {
  src: string,
  @optional x: int,
  @optional y: int,
  @optional height: int,
  @optional width: int,
  @optional excavate: bool,
}

@module("qrcode.react") @react.component
external make: (
  ~value: string,
  ~size: int=?,
  ~bgColor: string=?,
  ~fgColor: string=?,
  ~level: string=?,
  ~includeMargin: bool=?,
  ~imageSettings: imageSettings=?,
  ~style: ReactDOM.style=?,
  ~className: string=?,
) => React.element = "QRCodeCanvas"
