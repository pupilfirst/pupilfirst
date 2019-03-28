exception Graphql_error(string);

let sendQuery = (authenticityToken, q) =>
  Bs_fetch.(
    fetchWithInit(
      "/graphql",
      RequestInit.make(
        ~method_=Post,
        ~body=
          Js.Dict.fromList([
            ("query", Js.Json.string(q##query)),
            ("variables", q##variables),
          ])
          |> Js.Json.object_
          |> Js.Json.stringify
          |> BodyInit.make,
        ~credentials=Include,
        ~headers=
          HeadersInit.makeWithArray([|
            ("X-CSRF-Token", authenticityToken),
            ("Content-Type", "application/json"),
          |]),
        (),
      ),
    )
    |> Js.Promise.then_(resp =>
         if (Response.ok(resp)) {
           Response.json(resp);
         } else {
           Js.Promise.reject(
             Graphql_error("Request failed: " ++ Response.statusText(resp)),
           );
         }
       )
    |> Js.Promise.then_(json =>
         switch (Js.Json.decodeObject(json)) {
         | Some(obj) =>
           Js.Dict.unsafeGet(obj, "data") |> q##parse |> Js.Promise.resolve
         | None =>
           Js.Promise.reject(Graphql_error("Response is not an object"))
         }
       )
  );