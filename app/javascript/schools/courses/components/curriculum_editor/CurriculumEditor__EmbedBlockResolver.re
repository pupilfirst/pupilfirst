module ResolveEmbedCodeMutator = [%graphql
  {|
  mutation ResolveEmbedCodeMutation($contentBlockId: ID!) {
    resolveEmbedCode(contentBlockId: $contentBlockId) {
      embedCode
    }
  }
  |}
];

type state = {
  loading: bool,
  embedCode: option(string),
  timeoutId: option(Js.Global.timeoutId),
  errorMessage: option(string),
  reload: bool,
};

type action =
  | SetLoading
  | ClearLoading
  | SetUnknownProvider
  | SetTimeout(Js.Global.timeoutId)
  | ToggleRelaod
  | SetEmbedCode(string);

let reducer = (state, action) =>
  switch (action) {
  | SetLoading => {...state, loading: true}
  | ClearLoading => {...state, loading: false}
  | ToggleRelaod => {...state, reload: !state.reload, loading: false}
  | SetEmbedCode(embedCode) => {
      ...state,
      embedCode: Some(embedCode),
      loading: false,
      errorMessage: None,
    }
  | SetTimeout(timeoutId) => {...state, timeoutId: Some(timeoutId)}
  | SetUnknownProvider => {
      ...state,
      errorMessage:
        Some(
          "You can only use Youtube / Vimeo / Slide Share links in embed block",
        ),
    }
  };

let resolveEmbedCode = (state, contentBlockId, send, ()) => {
  state.timeoutId->Belt.Option.forEach(Js.Global.clearTimeout);
  send(SetLoading);

  ResolveEmbedCodeMutator.make(~contentBlockId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##resolveEmbedCode##embedCode
       ->Belt.Option.mapWithDefault(send(ToggleRelaod), embedCode =>
           send(SetEmbedCode(embedCode))
         );

       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       Notification.error(
         "Unexpected Error",
         "An unexpected error occured, and our team has been notified about this. Please reload the page before trying again.",
       );
       Js.Promise.resolve();
     })
  |> ignore;
};

let getEmbedCode = (state, contentBlockId, send, ()) => {
  switch (state.embedCode) {
  | Some(_c) => ()
  | None =>
    let timeoutId =
      Js.Global.setTimeout(
        resolveEmbedCode(state, contentBlockId, send),
        state.timeoutId->Belt.Option.mapWithDefault(0, _ => 60000),
      );
    send(SetTimeout(timeoutId));
  };
  None;
};

let embedCodeErrorText = (loading, requestSource) => {
  switch (loading, requestSource) {
  | (true, _)
  | (false, None) => "Unable to resolve, retrying in 1 minute"
  | (false, Some(requestSource)) =>
    requestSource == "vimeo_upload"
      ? "Processing Video, retrying in 1 minute"
      : "Unable to resolve, retrying in 1 minute"
  };
};

[@react.component]
let make = (~url, ~requestSource, ~contentBlockId) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        loading: true,
        embedCode: None,
        timeoutId: None,
        errorMessage: None,
        reload: false,
      },
    );

  React.useEffect1(
    getEmbedCode(state, contentBlockId, send),
    [|state.reload|],
  );

  <div>
    {state.embedCode
     ->Belt.Option.mapWithDefault(
         <div
           className="max-w-3xl py-6 px-3 mx-auto bg-primary-100 rounded-lg shadow">
           <div className="py-28">
             <div>
               {state.loading
                  ? <div className="h-20" /> : <Countdown seconds=60 />}
               <div
                 className="text-center font-semibold text-primary-800 mt-2">
                 {React.string(
                    embedCodeErrorText(state.loading, requestSource),
                  )}
               </div>
               <div className="text-xs text-center">
                 {React.string(url)}
               </div>
             </div>
           </div>
         </div>,
         code =>
         TargetContentView.embedContentBlock(code)
       )}
  </div>;
};
