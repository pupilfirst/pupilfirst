[@bs.module "./images/permanent-delete.svg"]
external permanentDeleteIcon: string = "default";

let str = React.string;

module DeleteAccountQuery = [%graphql
  {|
   mutation DeleteAccountMutation($token: String!) {
     deleteAccount(token: $token ) {
        success
       }
     }
   |}
];

let deleteAccount = (token, setAccountDeleted, event) => {
  ReactEvent.Mouse.preventDefault(event);

  DeleteAccountQuery.make(~token, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
       result##deleteAccount##success
         ? {
           setAccountDeleted(_ => true);
           Js.Global.setTimeout(
             () => DomUtils.redirect("/users/sign_out"),
             5000,
           )
           |> ignore;
         }
         : ();
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {Js.Promise.resolve()})
  |> ignore;
  ();
};

[@react.component]
let make = (~token) => {
  let (accountDeleted, setAccountDeleted) = React.useState(() => false);
  <div className="m-6">
    <div className="w-64 h-64 mx-auto">
      <img className="object-contain mx-auto" src=permanentDeleteIcon />
    </div>
    {accountDeleted
       ? <div
           className="text-center max-w-sm mx-auto font-semibold text-red-600">
           <p> {str("Account deletion is in progress.")} </p>
           <i className="my-3 text-3xl fa fa-spinner fa-pulse" />
           <p>
             {str(
                "You will now be signed out, and you will be notified over email once deletion is complete.",
              )}
           </p>
         </div>
       : <div
           className="flex flex-col items-center justify-center text-center max-w-sm mx-auto">
           <h3> {"We're sorry to see you go." |> str} </h3>
           <p className="mt-1">
             {"Please click the button below to permanently delete your account in this school"
              |> str}
           </p>
           <button
             onClick={deleteAccount(token, setAccountDeleted)}
             className="btn btn-danger mt-4">
             {"Delete Account" |> str}
           </button>
         </div>}
  </div>;
};
