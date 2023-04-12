@module("./images/permanent-delete.svg")
external permanentDeleteIcon: string = "default"

let str = React.string

let t = I18n.t(~scope="components.UsersDeleteAccount")
let ts = I18n.t(~scope="shared")

type state =
  | Waiting
  | Deleting
  | Deleted

module DeleteAccountQuery = %graphql(`
   mutation DeleteAccountMutation($token: String!) {
     deleteAccount(token: $token ) {
        success
       }
     }
   `)

let deleteAccount = (token, setState, event) => {
  ReactEvent.Mouse.preventDefault(event)
  setState(_ => Deleting)

  DeleteAccountQuery.fetch({token: token})
  |> Js.Promise.then_((result: DeleteAccountQuery.t) => {
    result.deleteAccount.success
      ? {
          setState(_ => Deleted)
          Js.Global.setTimeout(() => DomUtils.redirect("/users/sign_out"), 5000) |> ignore
        }
      : ()
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => Js.Promise.resolve())
  |> ignore
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
        <h3> {t("head") |> str} </h3>
        <p className="mt-1"> {t("click_button_below") |> str} </p>
        <div className="flex mt-4 justify-center">
          <a href="/dashboard" className="btn btn-default me-2"> {t("cancel") |> str} </a>
          <button onClick={deleteAccount(token, setState)} className="btn btn-danger">
            {t("delete_account") |> str}
          </button>
        </div>
      </div>
    | Deleting =>
      <div className="text-center max-w-sm mx-auto font-semibold text-red-600">
        <p> {str(t("please_wait"))} </p>
        <i className="my-3 text-3xl fa fa-spinner fa-pulse" />
        <p> {str(t("queuing_deletion"))} </p>
      </div>
    | Deleted =>
      <div className="text-center max-w-sm mx-auto font-semibold text-red-600">
        <p> {str(t("deletion_progresss"))} </p>
        <i className="my-3 text-3xl fa fa-spinner fa-pulse" />
        <p> {str(t("signed_out_notified"))} </p>
      </div>
    }}
  </div>
}
