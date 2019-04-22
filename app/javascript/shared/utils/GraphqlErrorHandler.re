module type Error = {
  type t;
  exception Errors(array(t));
  let notification: t => (string, string);
};

module Make = (Error: Error) => {
  let handler = () =>
    [@bs.open]
    (
      fun
      | Error.Errors(errors) =>
        errors
        |> Array.iter(error => {
             let (title, message) = Error.notification(error);
             Notification.error(title, message);
           })
    );

  let catch = (callback, promise) =>
    promise
    |> Js.Promise.catch(error => {
         switch (error |> handler()) {
         | Some(_x) => callback()
         | None => ()
         };
         Js.Promise.resolve();
       });
};