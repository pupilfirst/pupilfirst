type subscription = {
  endpoint: string,
  p256dh: string,
  auth: string,
};

[@bs.module "./webpushSubscription"]
external createSubscription: unit => Js.Promise.t(subscription) =
  "createSubscription";

[@bs.module "./webpushSubscription"]
external showWebPushData: unit => unit = "showWebPushData";

let create = () => {
  createSubscription()
  |> Js.Promise.then_(response => {
       Js.log(response);

       Js.log(response.endpoint);
       Js.log("response End");
       Js.Promise.resolve();
     })
  |> ignore;
};
