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
         : Notification.error(
             "Error!",
             "Something went wrong! Please try again",
           );
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       ();
       Js.Promise.resolve();
     })
  |> ignore;
  ();
};

[@react.component]
let make = (~token) => {
  let (accountDeleted, setAccountDeleted) = React.useState(() => false);
  <div className="m-10">
    {accountDeleted
       ? <p>
           {"Account deletion initated successfully. This might take a few minutes. You will be notified over email once complete "
            |> str}
         </p>
       : <div className="flex flex-col items-center justify-center">
           <p>
             {"Please click the button below to permanently delete your account in this school"
              |> str}
           </p>
           <button
             onClick={deleteAccount(token, setAccountDeleted)}
             className="btn btn-danger mt-2">
             {"Delete Account" |> str}
           </button>
         </div>}
  </div>;
};
