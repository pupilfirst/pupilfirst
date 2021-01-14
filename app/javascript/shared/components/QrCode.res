@bs.deriving(abstract)
type imageSettings = {
  src: string,
  @bs.optional
  x: int,
  @bs.optional
  y: int,
  @bs.optional
  height: int,
  @bs.optional
  width: int,
  @bs.optional
  excavate: bool,
}

@bs.module @react.component
external make: (
  ~value: string,
  ~style: ReactDOMRe.style=?,
  ~className: string=?,
  ~renderAs: string=?,
  ~size: int=?,
  ~bgColor: string=?,
  ~fgColor: string=?,
  ~level: string=?,
  ~includeMargin: bool=?,
  ~imageSettings: imageSettings=?,
) => React.element = "qrcode.react"
