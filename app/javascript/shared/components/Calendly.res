type styles = {
  "height": string,
  "width": string,
  "minWidth": string,
}

type prefill = {
  name: string,
  email: string,
}

type pageSettings

type utm = {
  utmCampaign: option<string>,
  utmContent: option<string>,
  utmMedium: option<string>,
  utmSource: option<string>,
  utmTerm: option<string>,
}

module JsComponent = {
  @bs.module("./Calendly") @react.component
  external make: (
    ~id: string=?,
    ~url: string,
    ~styles: styles=?,
    ~prefill: prefill=?,
    ~pageSettings: pageSettings=?,
    ~utm: utm=?,
  ) => React.element = "default"
}

@react.component
let make = (~url, ~styles=?, ~prefill=?, ~=pageSettings=?, ~utm=?, ~id=?) =>
  <JsComponent ?id url ?styles ?prefill ?pageSettings ?utm />

module PopupLink = {
  module PopupLinkJsComponent = {
    @bs.module("./Calendly") @react.component
    external make: (
      ~id: string=?,
      ~url: string,
      ~text: string,
      ~styles: styles=?,
      ~prefill: prefill=?,
      ~pageSettings: pageSettings=?,
      ~utm: utm=?,
    ) => React.element = "popupText"
  }

  @react.component
  let make = (~url, ~text, ~styles=?, ~prefill=?, ~=pageSettings=?, ~utm=?, ~id=?) =>
    <PopupLinkJsComponent ?id url text ?styles ?prefill ?pageSettings ?utm />
}
