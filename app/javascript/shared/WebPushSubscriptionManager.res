type subscription = {
  endpoint: string,
  p256dh: string,
  auth: string,
}

let t = I18n.t(~scope="components.WebPushSubscriptionManager")

@bs.module("./webPushSubscription")
external createSubscription: unit => Js.Promise.t<Js.Nullable.t<subscription>> =
  "createSubscription"

@bs.module("./webPushSubscription")
external getWebPushData: unit => Js.Promise.t<Js.Nullable.t<subscription>> = "getWebPushData"

let str = React.string

type status =
  | Subscribed
  | UnSubscribed
  | SubscribedOnAnotherDevice

type state = {
  saving: bool,
  status: status,
}

type action =
  | SetStatusSubscribed
  | SetStatusUnSubscribed
  | SetStatusSubscribedOnAnotherDevice
  | SetSaving
  | ClearSaving

let reducer = (state, action) =>
  switch action {
  | SetStatusSubscribed => {saving: false, status: Subscribed}
  | SetStatusUnSubscribed => {saving: false, status: UnSubscribed}
  | SetStatusSubscribedOnAnotherDevice => {
      saving: false,
      status: SubscribedOnAnotherDevice,
    }
  | SetSaving => {...state, saving: true}
  | ClearSaving => {...state, saving: false}
  }

module CreateWebPushSubscriptionMutation = %graphql(
  `
  mutation CreateWebPushSubscriptionMutation($endpoint: String!, $p256dh: String!, $auth: String!) {
    createWebPushSubscription(endpoint: $endpoint, p256dh: $p256dh, auth: $auth)  {
      success
    }
  }
`
)

module DeleteWebPushSubscriptionMutation = %graphql(
  `
  mutation DeleteWebPushSubscriptionMutation {
    deleteWebPushSubscription {
      success
    }
  }
`
)

let deleteSubscription = (send, event) => {
  event |> ReactEvent.Mouse.preventDefault
  send(SetSaving)
  DeleteWebPushSubscriptionMutation.make()
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["deleteWebPushSubscription"]["success"]
      ? send(SetStatusUnSubscribed)
      : send(ClearSaving)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    send(ClearSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let saveSubscription = (subscription, send) => {
  send(SetSaving)
  CreateWebPushSubscriptionMutation.make(
    ~endpoint=subscription.endpoint,
    ~p256dh=subscription.p256dh,
    ~auth=subscription.auth,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["createWebPushSubscription"]["success"] ? send(SetStatusSubscribed) : send(ClearSaving)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => {
    send(ClearSaving)

    Js.Promise.resolve()
  })
  |> ignore
}

let handleNotificationBlock = () =>
  Notification.error(t("notification_rejected"), t("notification_rejected_message"))

let createSubscription = (send, event) => {
  event |> ReactEvent.Mouse.preventDefault
  createSubscription() |> Js.Promise.then_(r => {
    switch Js.Nullable.toOption(r) {
    | Some(response) => saveSubscription(response, send)
    | None => handleNotificationBlock()
    }
    Js.Promise.resolve()
  }) |> Js.Promise.catch(_ => {
    send(ClearSaving)
    Js.log("here i catch you")
    handleNotificationBlock()
    Js.Promise.resolve()
  }) |> ignore
}

let webPushEndpoint =
  Webapi.Dom.document
  |> Webapi.Dom.Document.documentElement
  |> Webapi.Dom.Element.getAttribute("data-subscription-endpoint")

let loadStatus = (status, send, ()) => {
  switch status {
  | UnSubscribed => ()
  | Subscribed
  | SubscribedOnAnotherDevice =>
    getWebPushData() |> Js.Promise.then_(r => {
      let response = Js.Nullable.toOption(r)
      switch (webPushEndpoint, response) {
      | (None, _) => send(SetStatusUnSubscribed)
      | (Some(""), _) => send(SetStatusUnSubscribed)
      | (Some(_endpoint), None) => send(SetStatusSubscribedOnAnotherDevice)
      | (Some(endpoint1), Some(subscription)) =>
        send(
          endpoint1 == subscription.endpoint
            ? SetStatusSubscribed
            : SetStatusSubscribedOnAnotherDevice,
        )
      }

      Js.Promise.resolve()
    }) |> Js.Promise.catch(_ => Js.Promise.resolve()) |> ignore
  }
  None
}

let computeInitialState = () => {
  status: webPushEndpoint->Belt.Option.mapWithDefault(UnSubscribed, _u => Subscribed),
  saving: false,
}

let button = (saving, onClick, icon, text) =>
  <button
    onClick
    disabled=saving
    className="inline-flex items-center font-semibold px-2 py-1 md:py-1 ml-2 bg-white hover:bg-gray-300 border rounded text-xs flex-shrink-0">
    <FaIcon classes={"mr-2 fa-fw fas fa-" ++ (saving ? "spinner fa-spin" : icon)} /> {str(text)}
  </button>

@react.component
let make = () => {
  let (state, send) = React.useReducer(reducer, computeInitialState())

  React.useEffect1(loadStatus(state.status, send), [])

  switch state.status {
  | Subscribed => button(state.saving, deleteSubscription(send), "bell-slash", t("unsubscribe"))
  | UnSubscribed => button(state.saving, createSubscription(send), "bell", t("subscribe"))
  | SubscribedOnAnotherDevice =>
    <div>
      {button(state.saving, createSubscription(send), "bell", t("subscribed_on_another_device"))}
    </div>
  }
}
