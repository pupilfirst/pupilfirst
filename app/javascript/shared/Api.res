exception UnexpectedResponse(int)

let apiErrorTitle = x =>
  switch x {
  | UnexpectedResponse(code) => string_of_int(code)
  | _ => "An unexpected error occurred"
  }

let acceptOrRejectResponse = response =>
  if Fetch.Response.ok(response) || Fetch.Response.status(response) == 422 {
    response |> Fetch.Response.json
  } else {
    Js.Promise.reject(UnexpectedResponse(response |> Fetch.Response.status))
  }

let handleResponseError = error => {
  let title = PromiseUtils.errorToExn(error)->apiErrorTitle

  Notification.error(
    title,
    "Our team has been notified of this error. Please reload the page and try again.",
  )
}

let handleResponseJSON = (json, responseCB, errorCB, notify) => {
  let error = json |> {
    open Json.Decode
    optional(field("error", string))
  }

  switch error {
  | Some(error) =>
    notify ? Notification.error("Something went wrong!", error) : ()
    errorCB()
  | None => responseCB(json)
  }
}

let handleResponse = (~responseCB, ~errorCB, ~notify=true, promise) => {
  open Js.Promise
  promise
  |> then_(response => acceptOrRejectResponse(response))
  |> then_(json => handleResponseJSON(json, responseCB, errorCB, notify) |> resolve)
  |> catch(error => {
    errorCB()
    Js.log(error)
    resolve(notify ? handleResponseError(error) : ())
  })
  |> ignore
}

let sendPayload = (url, payload, responseCB, errorCB, method_) =>
  Fetch.fetchWithInit(
    url,
    Fetch.RequestInit.make(
      ~method_,
      ~body=Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
      ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
      ~credentials=Fetch.SameOrigin,
      (),
    ),
  ) |> handleResponse(~responseCB, ~errorCB)

let sendFormData = (url, formData, responseCB, errorCB) =>
  Fetch.fetchWithInit(
    url,
    Fetch.RequestInit.make(
      ~method_=Post,
      ~body=Fetch.BodyInit.makeWithFormData(formData),
      ~credentials=Fetch.SameOrigin,
      (),
    ),
  ) |> handleResponse(~responseCB, ~errorCB)

let get = (~url, ~responseCB, ~errorCB, ~notify) =>
  Fetch.fetch(url) |> handleResponse(~responseCB, ~errorCB, ~notify)

let create = (url, payload, responseCB, errorCB) =>
  sendPayload(url, payload, responseCB, errorCB, Post)

let update = (url, payload, responseCB, errorCB) =>
  sendPayload(url, payload, responseCB, errorCB, Patch)
