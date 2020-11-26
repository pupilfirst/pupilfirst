module ResolveEmbedCodeMutator = %graphql(
  `
  mutation ResolveEmbedCodeMutation($contentBlockId: ID!) {
    resolveEmbedCode(contentBlockId: $contentBlockId) {
      embedCode
    }
  }
  `
)

type state = {
  loading: bool,
  embedCode: option<string>,
  reloadsIn: int,
}

type action =
  | SetLoading
  | Reset
  | SetEmbedCode(string)

let reducer = (state, action) =>
  switch action {
  | SetLoading => {...state, loading: true}
  | Reset => {...state, loading: false, reloadsIn: 60}
  | SetEmbedCode(embedCode) => {
      embedCode: Some(embedCode),
      loading: false,
      reloadsIn: 0,
    }
  }

let resolveEmbedCode = (contentBlockId, send) => {
  send(SetLoading)

  ResolveEmbedCodeMutator.make(~contentBlockId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["resolveEmbedCode"]["embedCode"]->Belt.Option.mapWithDefault(send(Reset), embedCode =>
      send(SetEmbedCode(embedCode))
    )

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    Notification.error(
      "Unexpected Error",
      "An unexpected error occured, and our team has been notified about this. Please reload the page before trying again.",
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let embedCodeErrorText = (loading, requestSource) =>
  switch (loading, requestSource) {
  | (true, _) => "Trying to embed URL..."
  | (false, #VimeoUpload) => "Video is being processed, retrying in 1 minute..."
  | (false, #User) => "Unable to embed, retrying in 1 minute..."
  }

let onTimeout = (contentBlockId, send, ()) => resolveEmbedCode(contentBlockId, send)

let computeReloadsIn = lastResolvedAt => {
  let difference =
    lastResolvedAt->Belt.Option.mapWithDefault(0, l =>
      DateFns.differenceInSeconds(Js.Date.make(), l)
    )

  difference < 60 ? 60 - difference : 60
}

@react.component
let make = (~url, ~requestSource, ~contentBlockId, ~lastResolvedAt) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      loading: false,
      embedCode: None,
      reloadsIn: computeReloadsIn(lastResolvedAt),
    },
  )

  <div>
    {state.embedCode->Belt.Option.mapWithDefault(
      <div className="max-w-3xl py-6 px-3 mx-auto bg-primary-100 rounded-lg shadow">
        <div className="py-28">
          <div>
            {state.loading
              ? <DoughnutChart mode=DoughnutChart.Indeterminate className="mx-auto" />
              : <Countdown seconds=state.reloadsIn timeoutCB={onTimeout(contentBlockId, send)} />}
            <div className="text-center font-semibold text-primary-800 mt-2">
              {React.string(embedCodeErrorText(state.loading, requestSource))}
            </div>
            <div className="mx-auto text-center">
              <a className="text-xs" href=url target="_blank"> {React.string(url)} </a>
            </div>
          </div>
        </div>
      </div>,
      code => TargetContentView.embedContentBlock(code),
    )}
  </div>
}
