exception UnexpectedResponse(int)

let t = I18n.t(~scope="components.Api", ...)
let ts = I18n.t(~scope="shared", ...)

let apiErrorTitle = x =>
  switch x {
  | UnexpectedResponse(code) => string_of_int(code)
  | _ => t("error_notification_title")
  }

let acceptOrRejectResponse = response =>
  if Fetch.Response.ok(response) || Fetch.Response.status(response) == 422 {
    Fetch.Response.json(response)
  } else {
    Js.Promise.reject(UnexpectedResponse(Fetch.Response.status(response)))
  }

let handleResponseError = error => {
  let title = PromiseUtils.errorToExn(error)->apiErrorTitle

  Notification.error(title, t("error_notification_body"))
}

module Decode = {
  open Json.Decode

  let error = object(field => {
    field.optional("error", option(string))->Option.flatMap(x => x)
  })
}

let handleResponseJSON = (json, responseCB, errorCB, notify) => {
  let error = json->Json.decode(Decode.error)->Result.getExn

  switch error {
  | Some(error) =>
    notify ? Notification.error(ts("notifications.something_wrong"), error) : ()
    errorCB()
  | None => responseCB(json)
  }
}

let handleResponse = (~responseCB, ~errorCB, ~notify=true, promise) => {
  open Js.Promise

  ignore(catch(error => {
      errorCB()
      Js.log(error)
      resolve(notify ? handleResponseError(error) : ())
    }, then_(
      json => resolve(handleResponseJSON(json, responseCB, errorCB, notify)),
      then_(response => acceptOrRejectResponse(response), promise),
    )))
}

let sendPayload = (url, payload, responseCB, errorCB, method_) =>
  handleResponse(
    ~responseCB,
    ~errorCB,
    Fetch.fetchWithInit(
      url,
      Fetch.RequestInit.make(
        ~method_,
        ~body=Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
        ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
        ~credentials=Fetch.SameOrigin,
        (),
      ),
    ),
  )

let sendFormData = (url, formData, responseCB, errorCB) =>
  handleResponse(
    ~responseCB,
    ~errorCB,
    Fetch.fetchWithInit(
      url,
      Fetch.RequestInit.make(
        ~method_=Post,
        ~body=Fetch.BodyInit.makeWithFormData(formData),
        ~credentials=Fetch.SameOrigin,
        (),
      ),
    ),
  )

let get = (~url, ~responseCB, ~errorCB, ~notify) =>
  handleResponse(~responseCB, ~errorCB, ~notify, Fetch.fetch(url))

let create = (url, payload, responseCB, errorCB) =>
  sendPayload(url, payload, responseCB, errorCB, Post)

let update = (url, payload, responseCB, errorCB) =>
  sendPayload(url, payload, responseCB, errorCB, Patch)
