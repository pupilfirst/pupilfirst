module ResolveEmbedCodeMutator = %graphql(`
  mutation ResolveEmbedCodeMutation($contentBlockId: ID!) {
    resolveEmbedCode(contentBlockId: $contentBlockId) {
      embedCode
    }
  }
  `)

type state = {
  loading: bool,
  embedCode: option<string>,
  reloadsIn: int,
}

type action =
  | SetLoading
  | Reset
  | SetEmbedCode(string)

let t = I18n.t(~scope="components.CurriculumEditor__EmbedBlockResolver")
let ts = I18n.ts

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

  ResolveEmbedCodeMutator.make({contentBlockId: contentBlockId})
  |> Js.Promise.then_(response => {
    response["resolveEmbedCode"]["embedCode"]->Belt.Option.mapWithDefault(send(Reset), embedCode =>
      send(SetEmbedCode(embedCode))
    )

    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    Notification.error(ts("notifications.unexpected_error"), t("error_notification"))
    Js.Promise.resolve()
  })
  |> ignore
}

let embedCodeErrorText = (loading, requestSource) =>
  switch (loading, requestSource) {
  | (true, _) => t("trying_embed")
  | (false, #VimeoUpload) => t("video_processed")
  | (false, #User) => t("unable_embed")
  }

let onTimeout = (contentBlockId, send, ()) => resolveEmbedCode(contentBlockId, send)

let computeReloadsIn = lastResolvedAt => {
  let difference =
    lastResolvedAt->Belt.Option.mapWithDefault(0, l =>
      DateFns.differenceInSeconds(Js.Date.make(), l)
    )

  difference < 60 ? 60 - difference : 0
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
