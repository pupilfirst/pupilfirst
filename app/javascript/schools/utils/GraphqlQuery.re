exception Graphql_error(string);

let sendQuery = q =>
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
            ("content-type", "application/json"),
          |]),
        (),
      ),
    )
    |> Js.Promise.then_(resp =>
         if (Response.ok(resp)) {
           Response.json(resp)
           |> Js.Promise.then_(data =>
                switch (Js.Json.decodeObject(data)) {
                | Some(obj) =>
                  Js.Dict.unsafeGet(obj, "data")
                  |>
                  q##parse
                  |> Js.Promise.resolve
                | None =>
                  Js.Promise.reject(
                    Graphql_error("Response is not an object"),
                  )
                }
              );
         } else {
           Js.Promise.reject(
             Graphql_error("Request failed: " ++ Response.statusText(resp)),
           );
         }
       )
  );