exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let acceptOrRejectResponse = response =>
  if (Fetch.Response.ok(response) || Fetch.Response.status(response) == 422) {
    response |> Fetch.Response.json;
  } else {
    Js.Promise.reject(UnexpectedResponse(response |> Fetch.Response.status));
  };

let handleResponseError = error =>
  switch (error |> handleApiError) {
  | Some(code) =>
    Notification.error(code |> string_of_int, "Please try again")
  | None => Notification.error("Something went wrong!", "Please try again")
  };

let handleResponseJSON = (json, responseCB, errorCB) =>
  switch (
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption
  ) {
  | Some(error) =>
    Notification.error("Something went wrong!!", error);
    errorCB();
  | None => responseCB(json)
  };

let create = (url, payload, responseCB, errorCB) =>
  Js.Promise.(
    Fetch.fetchWithInit(
      url,
      Fetch.RequestInit.make(
        ~method_=Post,
        ~body=
          Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
        ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
        ~credentials=Fetch.SameOrigin,
        (),
      ),
    )
    |> then_(response => acceptOrRejectResponse(response))
    |> then_(json =>
         handleResponseJSON(json, responseCB, errorCB) |> resolve
       )
    |> catch(error =>
         handleResponseError(error |> handleApiError) |> resolve
       )
    |> ignore
  );

let update = (url, payload, responseCB, errorCB) =>
  Js.Promise.(
    Fetch.fetchWithInit(
      url,
      Fetch.RequestInit.make(
        ~method_=Patch,
        ~body=
          Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
        ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
        ~credentials=Fetch.SameOrigin,
        (),
      ),
    )
    |> then_(response => acceptOrRejectResponse(response))
    |> then_(json =>
         handleResponseJSON(json, responseCB, errorCB) |> resolve
       )
    |> catch(error =>
         handleResponseError(error |> handleApiError) |> resolve
       )
    |> ignore
  );