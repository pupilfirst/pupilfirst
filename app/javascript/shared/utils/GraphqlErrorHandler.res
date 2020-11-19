module type Error = {
  type t
  let notification: t => (string, string)
}

module Make = (Error: Error) => {
  exception Errors(array<Error.t>)

  let handler = x =>
    switch x {
    | Errors(errors) => errors |> Array.iter(error => {
        let (title, message) = Error.notification(error)
        Notification.error(title, message)
      })
    | _ =>
      Notification.error(
        "Something went wrong!",
        "An unexpected error has occurred, and our team has been notified about this. Please reload the page and try again.",
      )
    }

  let catch = (callback, promise) => promise |> Js.Promise.catch(error => {
      PromiseUtils.errorToExn(error)->handler
      callback()
      Js.Promise.resolve()
    })
}
