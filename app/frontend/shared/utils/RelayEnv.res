/**
 * A standard fetch that sends our operation and variables to the
 * GraphQL server, and then decodes and returns the response.
 */
let fetchQuery: RescriptRelay.Network.fetchFunctionPromise = async (
  operation,
  variables,
  _cacheConfig,
  _uploadables,
) => {
  open Fetch
  let resp = await fetch(
    "/graphql",
    {
      method: #POST,
      body: {"query": operation.text, "variables": variables}
      ->JSON.stringifyAny
      ->Option.getExn
      ->Body.string,
      headers: Headers.fromObject({
        "content-type": "application/json",
        "accept": "application/json",
      }),
    },
  )

  if Response.ok(resp) {
    await Response.json(resp)
  } else {
    panic("Request failed: " ++ Response.statusText(resp))
  }
}

let network = RescriptRelay.Network.makePromiseBased(~fetchFunction=fetchQuery)

let environment = RescriptRelay.Environment.make(
  ~network,
  ~store=RescriptRelay.Store.make(
    ~source=RescriptRelay.RecordSource.make(),
    ~gcReleaseBufferSize=10 /* This sets the query cache size to 10 */,
  ),
)
