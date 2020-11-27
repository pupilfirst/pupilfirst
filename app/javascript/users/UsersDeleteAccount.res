@bs.module
external permanentDeleteIcon: string = "./images/permanent-delete.svg"

let str = React.string

type state =
  | Waiting
  | Deleting
  | Deleted

module DeleteAccountQuery = %graphql(
  `
   mutation DeleteAccountMutation($token: String!) {
     deleteAccount(token: $token ) {
        success
       }
     }
   `
)

let deleteAccount = (token, setState, event) => {
  ReactEvent.Mouse.preventDefault(event)
  setState(_ => Deleting)

  DeleteAccountQuery.make(~token, ()) |> GraphqlQuery.sendQuery |> Js.Promise.then_(result => {
    result["deleteAccount"]["success"]
      ? {
          setState(_ => Deleted)
          Js.Global.setTimeout(() => DomUtils.redirect("/users/sign_out"), 5000) |> ignore
        }
      : ()
    Js.Promise.resolve()
  }) |> Js.Promise.catch(_ => Js.Promise.resolve()) |> ignore
  ()
}

@react.component
let make = (~token) => {
  let (state, setState) = React.useState(() => Waiting)

  <div className="m-6">
    <div className="w-64 h-64 mx-auto">
      <img className="object-contain mx-auto" src=permanentDeleteIcon />
    </div>
    {switch state {
    | Waiting =>
      <div className="flex flex-col items-center justify-center text-center max-w-sm mx-auto">
        <h3> {"We're sorry to see you go." |> str} </h3>
        <p className="mt-1">
          {"Please click the button below to permanently delete your account in this school" |> str}
        </p>
        <div className="flex mt-4 justify-center">
          <a href="/dashboard" className="btn btn-default mr-2"> {"Cancel" |> str} </a>
          <button onClick={deleteAccount(token, setState)} className="btn btn-danger">
            {"Delete Account" |> str}
          </button>
        </div>
      </div>
    | Deleting =>
      <div className="text-center max-w-sm mx-auto font-semibold text-red-600">
        <p> {str("Please wait...")} </p>
        <i className="my-3 text-3xl fa fa-spinner fa-pulse" />
        <p> {str("We're queuing your account for deletion.'")} </p>
      </div>
    | Deleted =>
      <div className="text-center max-w-sm mx-auto font-semibold text-red-600">
        <p> {str("Account deletion is in progress.")} </p>
        <i className="my-3 text-3xl fa fa-spinner fa-pulse" />
        <p>
          {str(
            "You will now be signed out, and you will be notified over email once deletion is complete.",
          )}
        </p>
      </div>
    }}
  </div>
}
