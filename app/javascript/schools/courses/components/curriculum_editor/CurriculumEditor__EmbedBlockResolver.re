type provider =
  | SlideShare
  | Youtube
  | Vimeo
  | UnknownProvider;

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

// let getEmbedCode = (provider, url) => Api.get();

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

let updateEmbedCodeCB = (send, json) => {
  let html = json |> Json.Decode.field("html", Json.Decode.string);
  send(SetEmbedCode(html));
};

let errorCB = (send, _json) => {
  send(ToggleRelaod);
};

let resolveEmbedCode = (state, send, url, ()) => {
  state.timeoutId->Belt.Option.forEach(Js.Global.clearTimeout);
  send(SetLoading);
  switch (findProvider(url)) {
  | UnknownProvider => ()
  | provider =>
    let requestUrl = originUrl(provider) ++ url;

    Api.get(
      ~url=requestUrl,
      ~responseCB=updateEmbedCodeCB(send),
      ~errorCB=errorCB(send),
      ~notify=false,
    );
  };
};

let loadEmbedBlock = (state, send, url, ()) => {
  resolveEmbedCode(state, send, url, ());
  None;
};

let setTimeout = (state, send, url, ()) => {
  switch (state.embedCode) {
  | Some(_c) => ()
  | None =>
    let timeoutId =
      Js.Global.setTimeout(
        resolveEmbedCode(state, send, url),
        state.timeoutId->Belt.Option.mapWithDefault(0, _ => 60000),
      );
    send(SetTimeout(timeoutId));
  };
  Js.log("Foo");
  None;
};

[@react.component]
let make = (~url) => {
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

  React.useEffect1(setTimeout(state, send, url), [|state.reload|]);

  <div className="max-w-3xl py-6 px-3 mx-auto">
    {state.embedCode
     ->Belt.Option.mapWithDefault(
         <div>
           {SkeletonLoading.userCard()}
           <div>
             {state.loading
                ? React.string("Resolving Embed Block...!")
                : React.string(
                    "We are unable to resolve the embed block, retrying in 1 minute",
                  )}
           </div>
         </div>,
         code =>
         TargetContentView.embedContentBlock(code)
       )}
  </div>;
};
