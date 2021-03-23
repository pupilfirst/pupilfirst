type styles = {
  "height": string,
  "width": string,
  "minWidth": string,
}

type prefill = {
  email: string,
  firstName: option<string>,
  lastName: option<string>,
  name: option<string>,
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
