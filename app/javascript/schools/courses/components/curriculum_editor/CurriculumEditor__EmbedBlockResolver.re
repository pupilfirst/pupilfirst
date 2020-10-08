type provider =
  | SlideShare
  | Youtube
  | Vimeo
  | UnknownProvider;

module ResolveEmbedCodeMutator = [%graphql
  {|
  mutation ResolveEmbedCodeMutation($contentBlockId: ID!) {
    resolveEmbedCode(contentBlockId: $contentBlockId) {
      success
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

let originUrl = provider => {
  switch (provider) {
  | SlideShare => "https://www.slideshare.net/api/oembed/2?format=json&url="
  | Youtube => "https://www.youtube.com/oembed?format=json&url="
  | Vimeo => "https://vimeo.com/api/oembed.json?url="
  | UnknownProvider => ""
  };
};

let test = (value, url) => {
  let tester = Js.Re.fromString(value);
  url |> Js.Re.test_(tester);
};

let findProvider = url => {
  switch (url) {
  | url when url |> test("slideshare") => SlideShare
  | url when url |> test("vimeo") => Vimeo
  | url when url |> test("youtu") => Youtube
  | _unknownUrl => UnknownProvider
  };
};

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

let updateEmbedCodeCB = (send, contentBlockId, json) => {
  let html = json |> Json.Decode.field("html", Json.Decode.string);
  send(SetEmbedCode(html));

  ResolveEmbedCodeMutator.make(~contentBlockId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       if (response##resolveEmbedCode##success) {
         ();
       } else {
         Notification.notice(
           "Unable to save embed block",
           "Please reload the page.",
         );
       };
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

let errorCB = (send, _json) => {
  send(ToggleRelaod);
};

let resolveEmbedCode = (state, contentBlockId, send, url, ()) => {
  state.timeoutId->Belt.Option.forEach(Js.Global.clearTimeout);
  send(SetLoading);
  switch (findProvider(url)) {
  | UnknownProvider => ()
  | provider =>
    let requestUrl = originUrl(provider) ++ url;

    Api.get(
      ~url=requestUrl,
      ~responseCB=updateEmbedCodeCB(send, contentBlockId),
      ~errorCB=errorCB(send),
      ~notify=false,
    );
  };
};

let getEmbedCode = (state, contentBlockId, send, url, ()) => {
  switch (state.embedCode) {
  | Some(_c) => ()
  | None =>
    let timeoutId =
      Js.Global.setTimeout(
        resolveEmbedCode(state, contentBlockId, send, url),
        state.timeoutId->Belt.Option.mapWithDefault(0, _ => 60000),
      );
    send(SetTimeout(timeoutId));
  };
  Js.log("Foo");
  None;
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
    getEmbedCode(state, contentBlockId, send, url),
    [|state.reload|],
  );

  <div>
    {state.embedCode
     ->Belt.Option.mapWithDefault(
         <div
           className="max-w-3xl py-6 px-3 mx-auto bg-primary-100 rounded-lg shadow">
           <div className="py-40">
             <div>
               <Countdown seconds=60 />
               {state.loading
                  ? React.string("Resolving Embed Block...!")
                  : React.string(
                      "We are unable to resolve the embed block, retrying in 1 minute",
                    )}
             </div>
           </div>
         </div>,
         code =>
         TargetContentView.embedContentBlock(code)
       )}
  </div>;
};
