type subscription = {
  endpoint: string,
  p256dh: string,
  auth: string,
};

[@bs.module "./webpushSubscription"]
external createSubscription: unit => Js.Promise.t(subscription) =
  "createSubscription";

[@bs.module "./webpushSubscription"]
external getWebPushData: unit => Js.Promise.t(option(subscription)) =
  "getWebPushData";

let str = React.string;

type status =
  | Subscribed
  | UnSubscribed
  | SubscribedOnAnotherDevice;

type state = {
  saving: bool,
  status,
};

type action =
  | SetStatusSubscribed
  | SetStatusUnSubscribed
  | SetStatusSubscribedOnAnotherDevice
  | SetSaving
  | ClearSaving;

let reducer = (state, action) => {
  switch (action) {
  | SetStatusSubscribed => {saving: false, status: Subscribed}
  | SetStatusUnSubscribed => {saving: false, status: UnSubscribed}
  | SetStatusSubscribedOnAnotherDevice => {
      saving: false,
      status: SubscribedOnAnotherDevice,
    }
  | SetSaving => {...state, saving: true}
  | ClearSaving => {...state, saving: false}
  };
};

module CreateWebPushSubscriptionMutation = [%graphql
  {|
  mutation CreateWebPushSubscriptionMutation($endpoint: String!, $p256dh: String!, $auth: String!) {
    createWebPushSubscription(endpoint: $endpoint, p256dh: $p256dh, auth: $auth)  {
      success
    }
  }
|}
];

module DeleteWebPushSubscriptionMutation = [%graphql
  {|
  mutation DeleteWebPushSubscriptionMutation {
    deleteWebPushSubscription {
      success
    }
  }
|}
];

let deleteSubscription = (send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(SetSaving);
  DeleteWebPushSubscriptionMutation.make()
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##deleteWebPushSubscription##success
         ? {
           send(SetStatusUnSubscribed);
         }
         : send(ClearSaving);
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       send(ClearSaving);
       Js.Promise.resolve();
     })
  |> ignore;
};

let saveSubscription = (subscription, send) => {
  send(SetSaving);
  CreateWebPushSubscriptionMutation.make(
    ~endpoint=subscription.endpoint,
    ~p256dh=subscription.p256dh,
    ~auth=subscription.auth,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##createWebPushSubscription##success
         ? {
           send(SetStatusSubscribed);
         }
         : send(ClearSaving);
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       send(ClearSaving);

       Js.Promise.resolve();
     })
  |> ignore;
};

let createSubscription = (send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  createSubscription()
  |> Js.Promise.then_(response => {
       saveSubscription(response, send);
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       send(ClearSaving);
       Js.Promise.resolve();
     })
  |> ignore;
};

let webPushEndpoint =
  Webapi.Dom.document
  |> Webapi.Dom.Document.documentElement
  |> Webapi.Dom.Element.getAttribute("data-subscription-endpoint");

let loadStatus = (status, send) => {
  switch (status) {
  | UnSubscribed => ()
  | Subscribed
  | SubscribedOnAnotherDevice =>
    getWebPushData()
    |> Js.Promise.then_(response => {
         //  Js.log(response->Belt.Option.mapWithDefault("a", b => b.endpoint));

         switch (response) {
         | Some(x) => Js.log(x)
         | None => Js.log("q")
         };

         //  switch (webPushEndpoint, response) {
         //  | (None, _) => send(SetStatusUnSubscribed)
         //  | (Some(_endpoint), None) =>
         //    send(SetStatusSubscribedOnAnotherDevice)
         //  | (Some(endpoint1), Some(subscription)) =>
         //    Js.log("here");
         //    Js.log(endpoint1);
         //    Js.log(subscription.endpoint);
         //    Js.log(endpoint1 === subscription.endpoint);
         //    send(
         //      endpoint1 == subscription.endpoint
         //        ? SetStatusSubscribed : SetStatusSubscribedOnAnotherDevice,
         //    );
         //  };

         Js.Promise.resolve();
       })
    |> Js.Promise.catch(_ => {
         Js.log("catch");
         Js.Promise.resolve();
       })
    |> ignore
  };
};

let computeInitialState = () => {
  status:
    webPushEndpoint->Belt.Option.mapWithDefault(UnSubscribed, _u =>
      Subscribed
    ),
  saving: false,
};

let button = (disabled, onClick, icon, text) => {
  <button
    onClick
    disabled
    className="inline-flex items-center font-semibold p-2 md:py-1 bg-white hover:bg-gray-300 border rounded text-xs flex-shrink-0">
    <FaIcon classes={"mr-2 fas fa-" ++ icon} />
    {str(text)}
  </button>;
};

[@react.component]
let make = () => {
  let (state, send) = React.useReducer(reducer, computeInitialState());

  React.useEffect(() => {
    loadStatus(state.status, send);
    None;
  });

  <div>
    {switch (state.status) {
     | Subscribed =>
       button(
         state.saving,
         deleteSubscription(send),
         "bell-slash",
         "unsubscribe",
       )
     | UnSubscribed =>
       button(state.saving, createSubscription(send), "bell", "Subscribe")

     | SubscribedOnAnotherDevice =>
       <div>
         {str("subscribed on another device")}
         {button(
            state.saving,
            createSubscription(send),
            "bell",
            "Subscribe on this Device",
          )}
       </div>
     }}
  </div>;
};
