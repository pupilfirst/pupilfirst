type subscription = {
  endpoint: string,
  p256dh: string,
  auth: string,
};

[@bs.module "./webpushSubscription"]
external createSubscription:
  unit => Js.Promise.t(Js.Nullable.t(subscription)) =
  "createSubscription";

[@bs.module "./webpushSubscription"]
external getWebpushData: unit => Js.Promise.t(Js.Nullable.t(subscription)) =
  "getWebpushData";

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

module CreateWebpushSubscriptionMutation = [%graphql
  {|
  mutation CreateWebpushSubscriptionMutation($endpoint: String!, $p256dh: String!, $auth: String!) {
    createWebpushSubscription(endpoint: $endpoint, p256dh: $p256dh, auth: $auth)  {
      success
    }
  }
|}
];

module DeleteWebpushSubscriptionMutation = [%graphql
  {|
  mutation DeleteWebPushSubscriptionMutation {
    deleteWebpushSubscription {
      success
    }
  }
|}
];

let deleteSubscription = (send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(SetSaving);
  DeleteWebpushSubscriptionMutation.make()
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##deleteWebpushSubscription##success
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
  CreateWebpushSubscriptionMutation.make(
    ~endpoint=subscription.endpoint,
    ~p256dh=subscription.p256dh,
    ~auth=subscription.auth,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##createWebpushSubscription##success
         ? send(SetStatusSubscribed) : send(ClearSaving);
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       send(ClearSaving);

       Js.Promise.resolve();
     })
  |> ignore;
};

let handleNotificationBlock = () => {
  Notification.error(
    "Permission Rejected",
    "If you change your mind, click the lock icon to give Chrome permission to send you desktop notifications.",
  );
};

let createSubscription = (send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  createSubscription()
  |> Js.Promise.then_(r => {
       switch (Js.Nullable.toOption(r)) {
       | Some(response) => saveSubscription(response, send)
       | None => handleNotificationBlock()
       };
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       send(ClearSaving);
       handleNotificationBlock();
       Js.Promise.resolve();
     })
  |> ignore;
};

let webpushEndpoint =
  Webapi.Dom.document
  |> Webapi.Dom.Document.documentElement
  |> Webapi.Dom.Element.getAttribute("data-subscription-endpoint");

let loadStatus = (status, send, ()) => {
  switch (status) {
  | UnSubscribed => ()
  | Subscribed
  | SubscribedOnAnotherDevice =>
    getWebpushData()
    |> Js.Promise.then_(r => {
         let response = Js.Nullable.toOption(r);
         switch (webpushEndpoint, response) {
         | (None, _) => send(SetStatusUnSubscribed)
         | (Some(""), _) => send(SetStatusUnSubscribed)
         | (Some(_endpoint), None) =>
           send(SetStatusSubscribedOnAnotherDevice)
         | (Some(endpoint1), Some(subscription)) =>
           send(
             endpoint1 == subscription.endpoint
               ? SetStatusSubscribed : SetStatusSubscribedOnAnotherDevice,
           )
         };

         Js.Promise.resolve();
       })
    |> Js.Promise.catch(_ => {Js.Promise.resolve()})
    |> ignore
  };
  None;
};

let computeInitialState = () => {
  status:
    webpushEndpoint->Belt.Option.mapWithDefault(UnSubscribed, _u =>
      Subscribed
    ),
  saving: false,
};

let button = (saving, onClick, icon, text) => {
  <button
    onClick
    disabled=saving
    className="inline-flex items-center font-semibold p-2 md:py-1 bg-white hover:bg-gray-300 border rounded text-xs flex-shrink-0">
    <FaIcon
      classes={"mr-2 fa-fw fas fa-" ++ (saving ? "spinner fa-spin" : icon)}
    />
    {str(text)}
  </button>;
};

[@react.component]
let make = () => {
  let (state, send) = React.useReducer(reducer, computeInitialState());

  React.useEffect1(loadStatus(state.status, send), [||]);

  switch (state.status) {
  | Subscribed =>
    button(
      state.saving,
      deleteSubscription(send),
      "bell-slash",
      "Unsubscribe",
    )
  | UnSubscribed =>
    button(state.saving, createSubscription(send), "bell", "Subscribe")

  | SubscribedOnAnotherDevice =>
    <div>
      {button(
         state.saving,
         createSubscription(send),
         "bell",
         "Subscribe on this Device",
       )}
    </div>
  };
};
