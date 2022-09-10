module type X = {
  module Raw: {
    type t
    type t_variables
  }
  type t
  type t_variables

  let query: string
  let parse: Raw.t => t
  let serialize: t => Raw.t
  let serializeVariables: t_variables => Raw.t_variables
  let variablesToJson: Raw.t_variables => Js.Json.t
  let toJson: Raw.t => Js.Json.t
  external unsafe_fromJson: Js.Json.t => Raw.t = "%identity"
}

module Extender = (M: X) => {
  exception Graphql_error(string)

  type notification = {
    kind: string,
    title: string,
    body: string,
  }

  let decodeNotification = json => {
    open Json.Decode
    {
      kind: json |> field("kind", string),
      title: json |> field("title", string),
      body: json |> field("body", string),
    }
  }

  let decodeObject = json => {
    let x = Js.Json.object_(json)

    x |> Js.Promise.resolve
  }

  let decodeNotifications = json => json |> Json.Decode.list(decodeNotification)

  let decodeErrors = json => {
    open Json.Decode
    json |> array(field("message", string))
  }

  let flashNotifications = obj =>
    switch Js.Dict.get(obj, "notifications") {
    | Some(notifications) =>
      notifications
      |> decodeNotifications
      |> List.iter(n => {
        let notify = switch n.kind {
        | "success" => Notification.success
        | "error" => Notification.error
        | _ => Notification.notice
        }

        notify(n.title, n.body)
      })
    | None => ()
    }

  let sendQuery = (~notify=true, ~notifyOnNotFound=true, query, variables) => {
    open Bs_fetch
    fetchWithInit(
      "/graphql",
      RequestInit.make(
        ~method_=Post,
        ~body=Js.Dict.fromList(list{("query", Js.Json.string(query)), ("variables", variables)})
        |> Js.Json.object_
        |> Js.Json.stringify
        |> BodyInit.make,
        ~credentials=Include,
        ~headers=HeadersInit.makeWithArray([
          ("X-CSRF-Token", AuthenticityToken.fromHead()),
          ("Content-Type", "application/json"),
        ]),
        (),
      ),
    )
    |> Js.Promise.then_(resp =>
      if Response.ok(resp) {
        Response.json(resp)
      } else {
        if notify {
          let statusCode = resp |> Fetch.Response.status |> string_of_int

          if notifyOnNotFound {
            Notification.error(
              "Error " ++ statusCode,
              "Our team has been notified of this error. Please reload the page and try again.",
            )
          }
        }

        Js.Promise.reject(Graphql_error("Request failed: " ++ Response.statusText(resp)))
      }
    )
    |> Js.Promise.then_(json =>
      switch Js.Json.decodeObject(json) {
      | Some(obj) =>
        if notify {
          obj |> flashNotifications
        }

        switch Js.Dict.get(obj, "errors") {
        | Some(errors) => {
            Js.Console.log(json)
            errors
            |> decodeErrors
            |> Js.Array.forEach(e => {
              Notification.error("Error", e)
            })

            Js.Promise.reject(Graphql_error("Something went wrong!"))
          }
        | None => Js.Dict.unsafeGet(obj, "data") |> Js.Promise.resolve
        }

      | None => Js.Promise.reject(Graphql_error("Response is not an object"))
      }
    )
  }

  external tToJsObject: M.t => Js.t<'a> = "%identity"

  let query = (notify, notifyOnNotFound, variables) => {
    sendQuery(
      ~notify,
      ~notifyOnNotFound,
      M.query,
      variables->M.serializeVariables->M.variablesToJson,
    )
  }

  let fetch = (~notify=true, ~notifyOnNotFound=true, variables) => {
    query(notify, notifyOnNotFound, variables) |> Js.Promise.then_(data =>
      M.unsafe_fromJson(data) |> M.parse |> Js.Promise.resolve
    )
  }

  @deprecated("Use fetch instead")
  let make = (~notify=true, ~notifyOnNotFound=true, variables) => {
    query(notify, notifyOnNotFound, variables) |> Js.Promise.then_(data => {
      tToJsObject(M.unsafe_fromJson(data) |> M.parse) |> Js.Promise.resolve
    })
  }
}
